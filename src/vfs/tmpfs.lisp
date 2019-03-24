(import lua/basic (type#))
(import util (log! read-file-force! resolve-path json))
(import io (write-all!))

(defun access-tree! (inode path contents) :hidden
  (if (= path "")
    inode
    (let* [(path-parts (string/split path "%/"))
           (child-inode (.> inode (car path-parts)))]
      (if (> (n path-parts) 1)
        (if (= (type# child-inode) "table")
          (access-tree! child-inode (string/concat (cdr path-parts) "/") contents)
          (error! "No such file or directory"))
        (if (/= (type# contents) "nil")
          (.<! inode (car path-parts) (or contents nil))
          (if (/= (type# child-inode) "nil")
            child-inode
            (error! "No such file or directory")))))))

(defun create-handle (methods) :hidden
  (let* [(handle {})
         (closed false)
         (handle-methods
           (merge methods
                  { :close (lambda () (set! closed true)) })) ]
    (do [(method-name (keys handle-methods))]
      (.<! handle method-name
           (lambda (&args)
             (if (not closed)
               ((.> handle-methods method-name) (splice args))
               (error! "Attempt to use a closed file")))))
    handle))

(defun open-read-file! (fs-tree path binary) :hidden
  (with (inode (access-tree! fs-tree path))
    (if (/= (type# inode) "string")
      (error! "Could not open file for reading")
      (if binary
        (with (index 1)
          (create-handle
            { :read (lambda ()
                      (with (result (string/byte (string/sub inode index index)))
                        (inc! index)
                        result)) }))
        (with (left-contents inode)
          (create-handle
            { :readLine (lambda ()
                          (if left-contents
                            (with (lines (string/split left-contents "\n"))
                              (if (and (> (n lines) 1) (or (/= (n lines) 2) (/= (cadr lines) "")))
                                (set! left-contents (string/concat (cdr lines) "\n"))
                                (set! left-contents nil))
                              (car lines))
                            nil))
              :readAll (lambda ()
                         (with (result (or left-contents ""))
                           (set! left-contents nil)
                           result)) }))))))

(defun open-write-file! (fs-tree path append binary) :hidden
  (let* [(contents (if append
                     (access-tree! fs-tree path)
                     ""))
         (write-contents! (lambda ()
                            (access-tree! fs-tree path contents)))]
    (if (/= (type# contents) "string")
      (error! "Could not open file for writing")
      (progn
        (access-tree! fs-tree path contents)
        ;; TODO: Optimise this so it doesn't traverse the tree on every write
        (if binary
          (create-handle
            { :write (lambda (b)
                       (set! contents (.. contents (string/char b)))
                       (write-contents!)) })
          (create-handle
            { :write (lambda (str)
                       (set! contents (.. contents str))
                       (write-contents!))
              :writeLine (lambda (str)
                           (set! contents (.. contents str "\n"))
                           (write-contents!)) }))))))

(defun open-file! (fs-tree path mode) :hidden
  (log! (.. "open file " path " mode " mode))
  (let* [(f-mode (string/sub mode 1 1))
         (binary (= (string/sub mode 2 2) "b"))
         ((success handle)
            (pcall (lambda ()
              (if (= f-mode "r")
                (open-read-file! fs-tree path binary)
                (open-write-file! fs-tree path (= f-mode "a") binary)))))]
    (if success
      handle
      (splice (list nil handle)))))


(defun create (file)
  (let* [(fs-tree (if (/= file "")
                    ((.> json :decode) (read-file-force! (resolve-path file)))
                    {}))]
    { :list (lambda (path)
              (with (inode (access-tree! fs-tree path))
                (if (= (type# inode) "table")
                  (list->struct (keys inode))
                  (error! "Not a directory"))))
      :exists (lambda (path)
                (with ((ok inode) (pcall (lambda () (access-tree! fs-tree path))))
                  ok))
      :isDir (lambda (path)
               (with ((ok inode) (pcall (lambda () (access-tree! fs-tree path))))
                 (and ok
                      (= (type# inode) "table"))))
      :isReadOnly (const false)
      :getSize (const 0)
      :getFreeSpace (const 1000000000)
      :makeDir (lambda (path)
                 (access-tree! fs-tree path {}))
      :delete (lambda (path) (access-tree! fs-tree path false))
      :open (cut open-file! fs-tree <> <>)
      :close (lambda ()
               (when (/= file "")
                 (write-all! (resolve-path file) ((.> json :encode) fs-tree)))) }))

