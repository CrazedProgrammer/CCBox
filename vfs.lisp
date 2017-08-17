(import bindings/fs fs)
(import bindings/os os)
(import bindings/shell shell)
(import lua/basic (_ENV))

(defun create-vfs (vfs-mounts)
  (let* [(mounts {})
         (wrap-fun (lambda (function)
                     (lambda (path &rest)
                       (with ((mount local-path) (mount-path mounts path))
                         ((.> mount function) local-path (unpack rest))))))]
    (for-each vfs-mount vfs-mounts
      (let* [(mount-args (string/split vfs-mount "%:"))
             (attributes (string/split (car mount-args) ""))
             (mount-point (canonicalise (cadr mount-args) true))
             (dir (canonicalise (caddr mount-args) false))
             (fs-type (cond
                        [(elem? "r" attributes) 'realfs ]
                        [(elem? "t" attributes) 'tmpfs ]
                        [true (error! "file system type not found.")]))
             (read-only (! (elem? "w" attributes)))]
        (if (eq? fs-type 'realfs)
          (.<! mounts mount-point (create-realfs dir read-only))
          (error! "unimplemented."))))

    { :list (wrap-fun :list)
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
                '()))
      :copy (lambda (from-path to-path)
              (if ((wrap-fun :isReadOnly) to-path)
                (error! "permission denied.")
                '()))
      :delete (wrap-fun :delete)
      :combine fs/combine
      :open (wrap-fun :open)
      :find (lambda (wildcard) '())
      :getDir fs/getDir
      :complete (lambda (partial-name path include-files include-slashes)
                  '()) }))

(defun mount-path (mounts path)
  (let* [(abs-path (canonicalise path true))
         (mount-name "")]
    (for-each mount-point (keys mounts)
      (when (and (> (n mount-point) (n mount-name))
                    (= (string/sub abs-path 1 (n mount-point)) mount-point))
        (set! mount-name mount-point)))
    (unpack (list (.> mounts mount-name)
                  (canonicalise (string/sub abs-path (+ 1 (n mount-name))) true)))))

(defun canonicalise (path abs)
  (let* [(abs-path (string/trim (if abs path
                                        (shell/resolve path))))
         (filtered-path (string/concat (filter (lambda (x)
                                                 (and (/= x "") (/= x ".")))
                                               (string/split abs-path "%/")) "/"))]
    filtered-path))

(defun create-realfs (dir read-only)
  { :list (lambda (path)
            (fs/list $"~{dir}/~{path}"))
    :exists (lambda (path)
              (fs/exists $"~{dir}/~{path}"))
    :isDir (lambda (path)
             (fs/exists $"~{dir}/~{path}"))
    :isReadOnly (lambda (path)
                  (or read-only
                    (fs/isReadOnly $"~{dir}/~{path}")))
    :getSize (lambda (path)
               (fs/getSize $"~{dir}/~{path}"))
    :getFreeSpace (lambda (path)
                    (fs/getFreeSpace $"~{dir}/~{path}"))
    :makeDir (lambda (path)
               (if read-only
                 (error! "permission denied.")
                 (fs/makeDir $"~{dir}/~{path}")))
    :delete (lambda (path)
              (if read-only
                (error! "permission denied.")
                (fs/delete $"~{dir}/~{path}")))
    :open (lambda (path mode)
              (fs/open $"~{dir}/~{path}")) })
