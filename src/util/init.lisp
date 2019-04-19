(import lua/basic (_ENV _G dofile type# load))
(import lua/os luaos)
(import lua/io luaio)
(import cli (cli-args))
(import util/embed (embedded-json))
(import util/io (read-file-force! resolve-path))
(import io)

(define version "0.3.0-pre")

(define write! luaio/write)

(defun log! (message)
  (when (.> cli-args :log-path)
    (let* [(clock (luaos/clock)) ; TODO: Use time from originating computer.
           (time (.. (math/floor clock) "." (string/format "%02d" (* 100 (- clock (math/floor clock))))))]
      (io/append-all! (resolve-path (.> cli-args :log-path)) (format nil "[{#time}] {#message}\n")))))

(defun get-platform ()
  (cond
    [(or (.> _G :_CC_VERSION) (.> _G :_HOST)) 'cc]
    [else 'puc]))

(defun clamp (val min max)
  (cond
    [(< val min) min]
    [(> val max) max]
    [else val]))

(defun list->true-map (xs)
  (assoc->struct (map (lambda (x)
                        (list x true))
                      xs)))

(defun escape-pattern-string (str)
  (string/gsub str "([^%w])" "%%%1"))

(defmacro push-table! (xs x)
  `(.<! ,xs (+ (len# ,xs) 1) ,x))

(defun demand-type! (val typename)
  (with (error-message (.. "Invalid type: expected " typename " but got " (type# val)))
    (when (/= (type# val) typename)
      (log! error-message))
    (demand (= (type# val) typename) error-message)))

(define json
  ((load
    (if (.> cli-args :json-path)
      (io/read-all! (resolve-path (.> cli-args :json-path)))
      embedded-json)
    "json.lua"
    "t")))
