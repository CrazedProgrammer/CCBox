(import lua/basic (_ENV _G dofile type#))
(import lua/os os)
(import lua/io luaio)
(import config (args))
(import io)

(define version "0.2.0-pre")

(define write! luaio/write)

(defun log! (message)
  (when (.> args :log-file)
    (let* [(clock (get-time!))
           (time (.. (math/floor clock) "." (string/format "%02d" (* 100 (- clock (math/floor clock))))))]
      (io/append-all! (resolve-path (.> args :log-file)) (format nil "[{#time}] {#message}\n")))))

(defun resolve-path (path)
  (if (and (.> _ENV :shell) (.> _ENV :shell :resolve))
    ((.> _ENV :shell :resolve) path)
    path))

(defun get-platform ()
  (cond
    [(or (.> _G :_CC_VERSION) (.> _G :_HOST)) 'cc]
    [else 'puc]))

(defun read-file-force! (path)
  (with (result (io/read-all! path))
    (if result
      result
      (error! (format nil "Could not read file \"{#path}\"")))))

(defun run-program! (prg)
  (let* [(handle (luaio/popen prg))
         (output (self handle :read "*a"))]
    (self handle :close)
    output))

(defun get-time-raw! () :hidden
  (case (get-platform)
    [cc (os/clock)]
    [puc (/ (tonumber (run-program! "date +%s%N")) 1000000000)]))

(define startup-time :hidden
  (get-time-raw!))

(defun get-time! ()
  (- (get-time-raw!) startup-time))

(defun clamp (val min max)
  (cond
    [(< val min) min]
    [(> val max) max]
    [else val]))

(defun list->true-map (xs)
  (assoc->struct (map (lambda (x)
                        (list x true))
                      xs)))

(defun demand-type! (val typename)
  (with (error-message (.. "Invalid type: expected " typename " but got " (type# val)))
    (when (/= (type# val) typename)
      (log! error-message))
    (demand (= (type# val) typename) error-message)))

(define json
  (when (.> args :json-file)
    (dofile (resolve-path (.> args :json-file)))))
