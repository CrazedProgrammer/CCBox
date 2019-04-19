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

