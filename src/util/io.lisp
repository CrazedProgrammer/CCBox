(import io (read-all! write-all!))
(import lua/basic (_ENV))
(import lua/io luaio)

(defun read-file-force! (path)
  (with (result (read-all! path))
    (if result
      result
      (error! (format nil "Could not read file \"{#path}\"")))))

(defun run-program! (prg)
  (let* [(handle (luaio/popen prg))
         (output (self handle :read "*a"))]
    (self handle :close)
    output))

(defun resolve-path (path)
  (if (and (.> _ENV :shell) (.> _ENV :shell :resolve))
    ((.> _ENV :shell :resolve) path)
    path))

(defun create-closable-handle (methods) :hidden
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

(defun create-handle (mode handle-data (write-data! (const nil)))
  (let* [(f-mode (string/sub mode 1 1))
         (binary (= (string/sub mode 2 2) "b"))
         ((success handle)
            (pcall (lambda ()
              (if (= f-mode "r")
                (create-read-handle handle-data binary)
                (create-write-handle handle-data write-data! (= f-mode "a") binary)))))]
    (if success
      handle
      nil)))

(defun create-read-handle (handle-data binary) :hidden
  (if binary
    (with (index 1)
      (create-closable-handle
        { :read (lambda ()
                  (with (result (string/byte (string/sub handle-data index index)))
                    (inc! index)
                    result)) }))
    (with (left-contents handle-data)
      (create-closable-handle
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
                       result)) }))))

(defun create-write-handle (handle-data write-data! append binary) :hidden
  (with (contents (or handle-data ""))
    (if binary
      (create-closable-handle
        { :write (lambda (b)
                   (set! contents (.. contents (string/char b)))
                   (write-data! contents)) })
      (create-closable-handle
        { :write (lambda (str)
                   (set! contents (.. contents str))
                   (write-data! contents))
          :writeLine (lambda (str)
                       (set! contents (.. contents str "\n"))
                       (write-data! contents)) }))))
