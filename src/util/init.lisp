(import lua/basic (_ENV _G dofile type# len# load))
(import lua/os luaos)
(import lua/io luaio)
(import cli (cli-args))
(import util/io (read-file-force! resolve-path))
(import io)

(define version "0.3.0-pre")

(define write! luaio/write)

;; TODO: Make logging computer-specific so name and timestamp can be added.
(defun log! (message)
  (when (.> cli-args :log-path)
    (io/append-all! (resolve-path (.> cli-args :log-path)) (.. message "\n"))))

(defun get-platform ()
  (cond
    [(or (.> _G :_CC_VERSION) (.> _G :_HOST)) 'cc]
    [else 'puc]))

(defun time->daytime (time)
  (splice (list
            (mod (/ time 60) 24)
            (math/floor (/ time 60 24)))))

(defun error->nil (fn &args)
  (with ((ok ret) (pcall fn (splice args)))
    (if ok
      ret
      nil)))

(defun clamp (val min max)
  (cond
    [(< val min) min]
    [(> val max) max]
    [else val]))

(defun list->true-map (xs)
  (assoc->struct (map (lambda (x)
                        (list x true))
                      xs)))

(defun push-raw! (t x)
  (.<! t (+ (len# t) 1) x))

(defun escape-pattern-string (str)
  (string/gsub str "([^%w])" "%%%1"))

(defmacro push-table! (xs x)
  `(.<! ,xs (+ (len# ,xs) 1) ,x))

(defun demand-type! (val typename)
  (with (error-message (.. "Invalid type: expected " typename " but got " (type# val)))
    (when (/= (type# val) typename)
      (log! error-message))
    (demand (= (type# val) typename) error-message)))
