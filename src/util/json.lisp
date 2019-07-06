(import cli (cli-args))
(import util/embed (embedded-json))
(import lua/basic (load))
(import util/io (resolve-path))
(import io (read-all!))

(define json :hidden
  ((load
    (if (.> cli-args :json-path)
      (read-all! (resolve-path (.> cli-args :json-path)))
      embedded-json)
    "json.lua"
    "t")))

(defun encode (data)
  ((.> json :encode) data))

(defun decode (str)
  ((.> json :decode) str))
