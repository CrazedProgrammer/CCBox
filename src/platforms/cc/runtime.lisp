(import computer/event event)
(import lua/basic (_G))

(define pull-event-raw! :hidden (.> _G :os :pullEventRaw))
(define start-timer! :hidden (.> _G :os :startTimer))
(define event-whitelist :hidden
        '( "terminate" "http_success" "http_failure"
           "paste" "char" "key" "key_up"
           "mouse_click" "mouse_up" "mouse_scroll" "mouse_drag" ))

(defun start! (computer)
  (with (tick-timer (start-timer! 0.05))
    (while (.> computer :running)
      (with (event-args (list (pull-event-raw!)))
        (if (elem? (car event-args) event-whitelist)
          (progn
            (event/queue! computer event-args)
            (event/tick! computer))
          (when (and (= (car event-args) "timer") (= (cadr event-args) tick-timer))
            (event/tick! computer)
            (set! tick-timer (start-timer! 0.05))))))))
