(import bindings/os os)
(import bindings/shell shell)
(import io (append-all!))
(import config (args))

(defun log! (message)
  (when (.> args :log-file)
    (let* [(clock (os/clock))
           (time (.. (math/floor clock) "." (string/format "%02d" (* 100 (- clock (math/floor clock))))))]
      (append-all! (shell/resolve (.> args :log-file)) (format nil "[{#time}] {#message}\n")))))
