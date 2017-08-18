(import bindings/os os)
(import extra/io (append-all!))
(define log-path "log.txt")
(define logging-enabled true)

(defun log! (message)
  (when logging-enabled
    (let* [(clock (os/clock))
           (time (.. (math/floor clock) "." (string/format "%02d" (* 100 (- clock (math/floor clock))))))]
      (append-all! log-path $"[~{time}] ~{message}\n"))))
