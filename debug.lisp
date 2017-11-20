(import bindings/os os)
(import io (append-all!))
(define log-path "log.txt")
(define logging-enabled false)

(defun log! (message)
  (when logging-enabled
    (let* [(clock (os/clock))
           (time (.. (math/floor clock) "." (string/format "%02d" (* 100 (- clock (math/floor clock))))))]
      (append-all! log-path $"[~{time}] ~{message}\n"))))
