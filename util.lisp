(import lua/basic (_ENV _G dofile))
(import lua/os os)
(import config (args))
(import io)

(defun log! (message)
  (when (.> args :log-file)
    (let* [(clock (get-time!))
           (time (.. (math/floor clock) "." (string/format "%02d" (* 100 (- clock (math/floor clock))))))]
      (io/append-all! (resolve-path (.> args :log-file)) (format nil "[{#time}] {#message}\n")))))

(defun resolve-path (path)
  (if (and (.> _ENV :shell) (.> _ENV :shell :resolve))
    ((.> _ENV :shell :resolve) path)
    path))

(defun is-computercraft? ()
  (or (.> _G :_CC_VERSION)
      (.> _G :_HOST)))

(defun read-file-force! (path)
  (with (result (io/read-all! path))
    (if result
      result
      (error! (format nil "Could not read file \"{#path}\"")))))


(defun get-time-raw! () :hidden
  (if (is-computercraft?)
    (os/clock)
    (os/time)))

(define startup-time :hidden
  (get-time-raw!))

(defun get-time! ()
  (- (get-time-raw!) startup-time))

(define json
  (when (.> args :json-file)
    (dofile (resolve-path (.> args :json-file)))))
