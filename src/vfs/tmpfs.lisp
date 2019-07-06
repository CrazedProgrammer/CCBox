(import lua/basic (type#))
(import io (write-all!))
(import util (error->nil))
(import util/json json)
(import util/io (read-file-force! resolve-path create-handle))
(import util/embed (embedded-ccfs))

(define embed-ccfs-path "@embed")

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

(defun open-file! (fs-tree path mode) :hidden
  (create-handle mode
                 (error->nil access-tree! fs-tree path)
                 (lambda (contents)
                   (access-tree! fs-tree path contents))))

(defun create (file)
  (let* [(fs-tree (if (/= file "")
                    (json/decode (if (= file embed-ccfs-path)
                                   embedded-ccfs
                                   (read-file-force! (resolve-path file))))
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
               (when (and (/= file "") (/= file embed-ccfs-path))
                 (write-all! (resolve-path file) (json/encode fs-tree)))) }))

