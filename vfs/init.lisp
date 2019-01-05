(import lua/basic (set-idx!))
(import vfs/ccfs ccfs)
(import vfs/tmpfs tmpfs)
(import util (log!))

(defun mount-path (mounts path)
  (let* [(abs-path (canonicalise path))
         (mount-name "")]
    (for-each mount-point (keys mounts)
      (when (and (> (n mount-point) (n mount-name))
                    (= (string/sub abs-path 1 (n mount-point)) mount-point))
        (set! mount-name mount-point)))
    (splice (list (.> (.> mounts mount-name) :fs)
                  (canonicalise (string/sub abs-path (+ 1 (n mount-name))))
                  (.> (.> mounts mount-name) :readOnly)))))

(defun canonicalise (path)
  (let* [(parts (string/split path "%/"))
         (i 1)]
    (while (<= i (n parts))
      (if (= (nth parts i) "..")
        (progn
          (remove-nth! parts i)
          (when (= (n parts) 0)
            (error! "invalid path."))
          (dec! i)
          (remove-nth! parts i))
        (inc! i)))
    (string/concat (filter (lambda (x)
                             (and (/= x "") (/= x ".")))
                           parts) "/")))

(defun mount-fs (vfs mounts new-vfs-mount)
  (let* [(mount-args (string/split new-vfs-mount "%:"))
         (attributes-str (car mount-args))
         (attributes (string/split attributes-str ""))
         (mount-point (canonicalise (cadr mount-args)))
         (dir (canonicalise (caddr mount-args)))
         (fs-type (cond
                    [(elem? "c" attributes) 'ccfs ]
                    [(elem? "t" attributes) 'tmpfs ]
                    [true (error! (.. "Supported file system type not found in " attributes-str))]))
         (read-only (not (elem? "w" attributes)))]
    (if (not (all (lambda (a) (elem? a (list "w" "c" "t")))
                  attributes))
      (error! (.. "Unsupported mount option in " attributes-str))
      (if (and (/= mount-point "") (not ((.> vfs :isDir) mount-point)))
        (error! (.. "Cannot mount /" mount-point ": directory does not exist in the parent filesystem"))
        (case fs-type
          [ccfs (.<! mounts mount-point
                     { :fs (ccfs/create dir)
                       :readOnly read-only })]
          [tmpfs (.<! mounts mount-point
                      { :fs (tmpfs/create dir)
                        :readOnly read-only })]
          [else (error! "unimplemented.")])))))


(defun create-vfs (vfs-mounts)
  (let* [(mounts {})
         (wrap-fun (lambda (function)
                     (lambda (path &rest)
                       (with ((mount local-path) (mount-path mounts path))
                         ((.> mount function) local-path (splice rest))))))
         (wrapped-funs-names (list :list :exists :isDir :isReadOnly :getSize :getFreeSpace :makeDir :delete :open))
         (wrapped-funs (assoc->struct (map (lambda (fun-name)
                                             (list fun-name (wrap-fun fun-name)))
                                           wrapped-funs-names)))
         (vfs {})]
    (.<! vfs :list (.> wrapped-funs :list))
    (.<! vfs :exists (.> wrapped-funs :exists))
    (.<! vfs :isDir (.> wrapped-funs :isDir))
             ; TODO: make the VFS prevent writing to read-only mounts.
    (.<! vfs :isReadOnly (lambda (path)
                           (if (caddr (list (mount-path mounts path)))
                             true
                             ((.> wrapped-funs :isReadOnly) path))))
    (.<! vfs :getName (lambda (path)
                        (with (name (last (string/split (canonicalise path) "%/")))
                          (if (= name "") "root" name))))
    (.<! vfs :getDrive (lambda (path) "hdd"))
    (.<! vfs :getSize (.> wrapped-funs :getSize))
    (.<! vfs :getFreeSpace (.> wrapped-funs :getFreeSpace))
    (.<! vfs :makeDir (lambda (path)
                        (if ((.> vfs :isReadOnly) path)
                          (error! "Permission denied")
                          ((.> wrapped-funs :makeDir) path))))
    (.<! vfs :delete (lambda (path)
                        (if ((.> vfs :delete) path)
                          (error! "Permission denied")
                          ((.> wrapped-funs :delete) path))))
    (.<! vfs :combine (lambda (path child-path)
                        (canonicalise (.. path "/" child-path))))
    (.<! vfs :open (lambda (path mode)
                     (if (and (elem? mode (list "w" "wb" "a" "ab")) ((.> vfs :isReadOnly) path))
                       (splice (list nil "Permission denied"))
                       ((.> wrapped-funs :open) path mode))))
             ; TODO: proper wildcard support.
    (.<! vfs :find (lambda (wildcard)
                     (if ((.> wrapped-funs :exists) wildcard)
                       (list wildcard)
                       '())))
    (.<! vfs :getDir (lambda (path)
                       (with (parts (string/split (canonicalise path) "%/"))
                         (cond [(= (car parts) "") ".."]
                               [(= (n parts) 1) ""]
                               [else (cadr (reverse parts))]))))
    (.<! vfs :complete (lambda (partial-name path include-files include-slashes)
                         (if (not ((.> wrapped-funs :isDir)))
                           {}
                           (with (names ((.> wrapped-funs :list) path))
                             (filter
                               (lambda (x) (= x "nil"))
                               (map (lambda (name)
                                      (if (= (string/sub name 1 (n partial-name)) partial-name)
                                        name "nil"))))))))
    ; Copy and move need to be done manually in order to support copying across mounts.
    (.<! vfs :copy
         (lambda (raw-from-path raw-to-path)
           (let* [(from-path (canonicalise raw-from-path))
                  (to-path (canonicalise raw-to-path))]
             (if (not ((.> vfs :exists) from-path))
               (error! "No such file")
               (if ((.> vfs :exists) to-path)
                 (error! "File exists")
                 (letrec [(copy-path (lambda (from to)
                                       (log! (.. "copying " from " to " to))
                                       (if ((.> vfs :isDir) from)
                                         (progn
                                           ((.> vfs :makeDir) to)
                                           (do [(path (struct->list ((.> vfs :list) from)))]
                                             (copy-path (.. from "/" path) (.. to "/" path))))
                                         (let* [(read-handle ((.> vfs :open) from "r"))
                                                (write-handle ((.> vfs :open) to "w"))]
                                           ((.> write-handle :write) ((.> read-handle :readAll)))
                                           ((.> read-handle :close))
                                           ((.> write-handle :close))))))]
                   (copy-path from-path to-path)))))))

    (.<! vfs :move (lambda (from-path to-path)
                     ((.> vfs :copy) from-path to-path)
                     ((.> vfs :delete) from-path)))

    (for-each vfs-mount vfs-mounts
      (mount-fs vfs mounts vfs-mount))

    vfs))

