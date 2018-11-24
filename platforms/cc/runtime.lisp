(import computer/coroutine (resume!))
(import lua/coroutine coroutine)
(define event-whitelist :hidden
        '( "timer" "alarm" "terminate" "http_success" "http_failure"
           "paste" "char" "key" "key_up"
           "mouse_click" "mouse_up" "mouse_scroll" "mouse_drag" ))

(defun start! (computer)
  (while (.> computer :running)
    (with (event-args (list (coroutine/yield)))
      (when (elem? (car event-args) event-whitelist)
        (resume! computer event-args)))))
