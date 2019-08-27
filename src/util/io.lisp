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
    (with (left-contents (if binary
                           handle-data
                           ;; Convert CRLF to LF
                           (string/gsub handle-data "\r\n" "\n")))
      (create-closable-handle
        { :read (lambda (n-chars)
                  (if (/= (len# left-contents) 0)
                    (if (and (not n-chars) binary)
                      (with (ret-byte (string/byte left-contents 1))
                        (set! left-contents (string/sub left-contents 2))
                        ret-byte)
                      (with (ret-str (string/sub left-contents 1 (or n-chars 1)))
                        (set! left-contents (string/sub left-contents (+ (n ret-str) 1)))
                        ret-str))
                    nil))
          :readLine (lambda ()
                      (if (/= (len# left-contents) 0)
                        (with (lines (string/split left-contents "\n"))
                          (if (and (> (n lines) 1) (or (/= (n lines) 2) (/= (cadr lines) "")))
                            (set! left-contents (string/concat (cdr lines) "\n"))
                            (set! left-contents ""))
                          (car lines))
                        nil))
          :readAll (lambda ()
                     (with (result left-contents)
                       (set! left-contents "")
                       result)) }))))

(defun create-write-handle (handle-data write-data! append binary) :hidden
  (with (contents (if append
                    (or handle-data "")
                    ""))
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
