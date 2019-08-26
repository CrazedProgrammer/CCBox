(import cli (cli-args))
(import util/embed (embedded-json))
(import lua/basic (load type#))
(import util/io (resolve-path))
(import io (read-all!))

(define json :hidden
  ((load
    (if (.> cli-args :json-path)
      (read-all! (resolve-path (.> cli-args :json-path)))
      (or embedded-json
          (exit! "--json argument is required" 1)))
    "json.lua"
    "t")))

(defun decode (str)
  ((.> json :decode) str))

(define char->quoted :hidden
  (assoc->struct
    (map
      (lambda (code)
        (list
          (string/char code)
          (cond [(= code #x22) "\\\""]
                [(= code #x5C) "\\\\"]
                [(= code #x0A) "\\n"]
                [(= code #x0D) "\\r"]
                [(< code #x20) (string/format "\\u%04x" code)]
                [else (string/char code)])))
      (range :from 0 :to 255))))

(defun quoted (str) :hidden
  (.. "\""
      (string/concat
        (map (lambda (c)
               (.> char->quoted c))
             (string/split str "")))
      "\""))

(defun assoc->str (assoc) :hidden
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
