(import bindings/fs fs)
(import bindings/os os)
(import bindings/shell shell)
(import lua/basic (_ENV set-idx!))

(defun create-vfs (vfs-mounts)
  (let* [(mounts {})
         (wrap-fun (lambda (function)
                     (lambda (path &rest)
                       (with ((mount local-path) (mount-path mounts path))
                         ((.> mount function) local-path (splice rest))))))
         (dir-list (lambda (x)
                     (let* [(path (canonicalise x true))
                            (entries ((wrap-fun :list) path))]
                       (for-each mount-path (keys mounts)
                         (with (mount-path-parts (string/split mount-path "%/"))
                           (when (and (= path (string/concat (init mount-path-parts) "/")) (/= mount-path "")
                                      (not (elem? (last mount-path-parts) (values entries))))
                             (set-idx! entries (+ (len# entries) 1) (last mount-path-parts)))))
                       entries)))]
    (for-each vfs-mount vfs-mounts
      (let* [(mount-args (string/split vfs-mount "%:"))
             (attributes (string/split (car mount-args) ""))
             (mount-point (canonicalise (cadr mount-args) true))
             (dir (canonicalise (caddr mount-args) false))
             (fs-type (cond
                        [(elem? "r" attributes) 'realfs ]
                        [(elem? "t" attributes) 'tmpfs ]
                        [true (error! "file system type not found.")]))
             (read-only (not (elem? "w" attributes)))]
        (if (eq? fs-type 'realfs)
          (.<! mounts mount-point (create-realfs dir read-only))
          (error! "unimplemented."))))

    { :list dir-list
      :exists (wrap-fun :exists)
      :isDir (wrap-fun :isDir)
      :isReadOnly (wrap-fun :isReadOnly)
      :getName fs/getName
      :getDrive (lambda (path) "hdd")
      :getSize (wrap-fun :getSize)
      :getFreeSpace (wrap-fun :getFreeSpace)
      :makeDir (wrap-fun :makeDir)
      :move (lambda (from-path to-path)
              (if (or ((wrap-fun :isReadOnly) from-path)
                      ((wrap-fun :isReadOnly) to-path))
                (error! "permission denied.")
                (let* [((mount-from local-path-from) (mount-path mounts from-path))
                       ((mount-to local-path-to) (mount-path mounts to-path))]
                  (if (/= mount-from mount-to)
                    (error! "copying across mounts is currently not implemented.")
                    ((.> mount-from :move) local-path-from local-path-to)))))
      :copy (lambda (from-path to-path)
              (if ((wrap-fun :isReadOnly) to-path)
                (error! "permission denied.")
                (let* [((mount-from local-path-from) (mount-path mounts from-path))
                       ((mount-to local-path-to) (mount-path mounts to-path))]
                  (if (/= mount-from mount-to)
                    (error! "copying across mounts is currently not implemented.")
                    ((.> mount-from :copy) local-path-from local-path-to)))))
      :delete (wrap-fun :delete)
      :combine fs/combine
      :open (wrap-fun :open)
      :find (lambda (wildcard)
              (if ((wrap-fun :exists) wildcard)
                (list wildcard)
                '()))
      :getDir fs/getDir
      :complete (lambda (partial-name path include-files include-slashes)
                  (if (not ((wrap-fun :isDir)))
                    {}
                    (with (names (dir-list path))
                      (filter
                        (lambda (x) (= x "nil"))
                        (map (lambda (name)
                               (if (= (string/sub name 1 (n partial-name)) partial-name)
                                 name "nil"))))))) }))

(defun mount-path (mounts path)
  (let* [(abs-path (canonicalise path true))
         (mount-name "")]
    (for-each mount-point (keys mounts)
      (when (and (> (n mount-point) (n mount-name))
                    (= (string/sub abs-path 1 (n mount-point)) mount-point))
        (set! mount-name mount-point)))
    (splice (list (.> mounts mount-name)
                  (canonicalise (string/sub abs-path (+ 1 (n mount-name))) true)))))

(defun canonicalise (path abs)
  (let* [(abs-path (string/trim (if abs path
                                        (shell/resolve path))))
         (parts (string/split abs-path "%/"))
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

(defun create-realfs (dir read-only)
  { :list (lambda (path)
            (fs/list (format nil "{#dir}/{#path}")))
    :exists (lambda (path)
              (fs/exists (format nil "{#dir}/{#path}")))
    :isDir (lambda (path)
             (fs/isDir (format nil "{#dir}/{#path}")))
    :isReadOnly (lambda (path)
                  (or read-only
                    (fs/isReadOnly (format nil "{#dir}/{#path}"))))
    :getSize (lambda (path)
               (fs/getSize (format nil "{#dir}/{#path}")))
    :getFreeSpace (lambda (path)
                    (fs/getFreeSpace (format nil "{#dir}/{#path}")))
    :makeDir (lambda (path)
               (if read-only
                 (error! "permission denied.")
                 (fs/makeDir (format nil "{#dir}/{#path}"))))
    :delete (lambda (path)
              (if read-only
                (error! "permission denied.")
                (fs/delete (format nil "{#dir}/{#path}"))))
    :move (lambda (from to)
              (fs/move (format nil "{#dir}/{#from}") (format nil "{#dir}/{#to}")))
    :copy (lambda (from to)
              (fs/copy (format nil "{#dir}/{#from}") (format nil "{#dir}/{#to}")))
    :open (lambda (path mode)
              (fs/open (format nil "{#dir}/{#path}") mode)) })
