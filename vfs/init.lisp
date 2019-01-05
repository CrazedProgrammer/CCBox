(import lua/basic (set-idx!))
(import vfs/ccfs ccfs)
(import vfs/tmpfs tmpfs)
(import util (log!))

(defun create-vfs (vfs-mounts)
  (let* [(mounts {})
         (wrap-fun (lambda (function)
                     (lambda (path &rest)
                       (with ((mount local-path) (mount-path mounts path))
                         ((.> mount function) local-path (splice rest))))))]
    ; TODO: if the mount point is not /, check if the mount point is a directory in the existing vfs.
    (for-each vfs-mount vfs-mounts
      (let* [(mount-args (string/split vfs-mount "%:"))
             (attributes (string/split (car mount-args) ""))
             (mount-point (canonicalise (cadr mount-args)))
             (dir (canonicalise (caddr mount-args)))
             (fs-type (cond
                        [(elem? "r" attributes) 'realfs ]
                        [(elem? "t" attributes) 'tmpfs ]
                        [true (error! "file system type not found.")]))
             (read-only (not (elem? "w" attributes)))]
        (case fs-type
          [realfs (.<! mounts mount-point (ccfs/create dir read-only))]
          [tmpfs (.<! mounts mount-point (tmpfs/create dir))]
          [else (error! "unimplemented.")])))

    (with (vfs
            { :list (wrap-fun :list)
              :exists (wrap-fun :exists)
              :isDir (wrap-fun :isDir)
              ; TODO: make the VFS prevent writing to read-only mounts.
              :isReadOnly (wrap-fun :isReadOnly)
              :getName (lambda (path)
                         (with (name (last (string/split (canonicalise path) "%/")))
                           (if (= name "") "root" name)))
              :getDrive (lambda (path) "hdd")
              :getSize (wrap-fun :getSize)
              :getFreeSpace (wrap-fun :getFreeSpace)
              :makeDir (wrap-fun :makeDir)
              :delete (wrap-fun :delete)
              :combine (lambda (path child-path)
                         (canonicalise (.. path "/" child-path)))
              :open (wrap-fun :open)
              ; TODO: proper wildcard support.
              :find (lambda (wildcard)
                      (if ((wrap-fun :exists) wildcard)
                        (list wildcard)
                        '()))
              :getDir (lambda (path)
                        (with (parts (string/split (canonicalise path) "%/"))
                          (cond [(= (car parts) "") ".."]
                                [(= (n parts) 1) ""]
                                [else (cadr (reverse parts))])))
              :complete (lambda (partial-name path include-files include-slashes)
                          (if (not ((wrap-fun :isDir)))
                            {}
                            (with (names ((wrap-fun :list) path))
                              (filter
                                (lambda (x) (= x "nil"))
                                (map (lambda (name)
                                       (if (= (string/sub name 1 (n partial-name)) partial-name)
                                         name "nil"))))))) })
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
      vfs)))

(defun mount-path (mounts path)
  (let* [(abs-path (canonicalise path))
         (mount-name "")]
    (for-each mount-point (keys mounts)
      (when (and (> (n mount-point) (n mount-name))
                    (= (string/sub abs-path 1 (n mount-point)) mount-point))
        (set! mount-name mount-point)))
    (splice (list (.> mounts mount-name)
                  (canonicalise (string/sub abs-path (+ 1 (n mount-name))))))))

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

