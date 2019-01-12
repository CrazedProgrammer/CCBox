(import lua/basic (_ENV _G dofile type#))
(import lua/os os)
(import config (args))
(import io)

(define version "0.2.0-pre")

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


(defun get-time-raw! () :hidden
  (case (get-platform)
    [cc (os/clock)]
    [puc (os/time)]))

(define startup-time :hidden
  (get-time-raw!))

(defun get-time! ()
  (- (get-time-raw!) startup-time))

(define json
  (when (.> args :json-file)
    (dofile (resolve-path (.> args :json-file)))))

(defun demand-type! (val typename)
  (when (/= (type# val) typename)
    (log!(.. "Invalid type: expected " typename " but got " (type# val))))
  (demand (= (type# val) typename) (.. "Invalid type: expected " typename " but got " (type# val))))
