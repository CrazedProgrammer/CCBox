(import lua/basic (load type#))
(import lua/table luatable)
(import util (push-raw!))

;; Only decodes tables and strings
;; On malformed input, may throw an error or give malformed output
(defun json->lua (str) :hidden
  (let* ([buffer {}]
         [push-buffer! (cut push-raw! buffer <>)]
         [idx 1]
         [inside-string false])
    (while (<= idx (n str))
      (with (str-char (string/sub str idx idx))
        (if inside-string
          (case str-char
            ["\\" (progn
                    (push-buffer! "\\")
                    (inc! idx)
                    (with (escape-char (string/sub str idx idx))
                      (case escape-char
                        ["u" (progn
                               ;; Since Lua doesn't handle UTF-8 natively, limit the character to the ASCII/Latin-1 charset
                               (push-buffer! (string/format "%03d" (tonumber (string/sub str (+ idx 3) (+ idx 4)) 16)))
                               (set! idx (+ idx 4)))]
                        [else (push-buffer! escape-char)])))]
            ["\"" (progn (push-buffer! "\"")
                         (set! inside-string false))]
            [else (push-buffer! str-char)])
          (case str-char
            ;; Ignore whitespace
            [" " nil]
            ["\n" nil]
            ["\r" nil]
            ["\t" nil]

            ["{" (if (= (string/sub str (+ idx 1) (+ idx 1)) "}")
                   (push-buffer! "{")
                   (push-buffer! "{["))]
            ["}" (progn
                   (push-buffer! "}"))]
            [":" (push-buffer! "]=")]
            ["," (push-buffer! ",[")]
            ["\"" (progn (push-buffer! "\"")
                         (set! inside-string true))]
            [else (push-buffer! str-char)])))
      (inc! idx))
    (luatable/concat buffer)))

(defun decode (str)
  ((load (.. "return " (json->lua str)))))


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
