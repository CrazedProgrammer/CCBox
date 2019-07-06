(import cli (cli-args))
(import util/embed (embedded-json))
(import lua/basic (load type#))
(import util/io (resolve-path))
(import io (read-all!))

(define json :hidden
  ((load
    (if (.> cli-args :json-path)
      (read-all! (resolve-path (.> cli-args :json-path)))
      embedded-json)
    "json.lua"
    "t")))

(defun decode (str)
  ((.> json :decode) str))

; TODO: Make a lookup table for this.
(defun char->quoted (code)
  (cond [(= code #x22) "\\\""]
        [(= code #x5C) "\\\\"]
        [(= code #x0A) "\\n"]
        [(= code #x0D) "\\r"]
        [(< code #x20) (string/format "\\u%04x" code)]
        [else (string/char code)]))

(defun quoted (str)
  (.. "\""
      (string/concat
        (map (lambda (c)
               (char->quoted (string/byte c)))
             (string/split str "")))
      "\""))

(defun assoc->str (assoc)
  (.. (quoted (car assoc))
      ":"
      (encode (cadr assoc))))

; TODO: Optimise.
(defun encode (data)
  (if (= (type# data) "string")
    (quoted data)
    (.. "{"
        (string/concat
          (map assoc->str
               (struct->assoc data))
          ",")
        "}")))
