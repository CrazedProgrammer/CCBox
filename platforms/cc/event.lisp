(import lua/basic (_G))
(define os (.> _G :os))

(define event-whitelist :hidden
        '( "timer" "alarm" "terminate" "http_success" "http_failure"
           "paste" "char" "key" "key_up"
           "mouse_click" "mouse_up" "mouse_scroll" "mouse_drag" ))

; we can just borrow the host's event system for now
(defun create (next-fn!)
  { :queueEvent  (.> os :queueEvent)
    :startTimer  (.> os :startTimer)
    :cancelTimer (.> os :cancelTimer)
    :setAlarm    (.> os :setAlarm)
    :cancelAlarm (.> os :cancelAlarm)

    :next! (lambda (computer)
             (with (event-args (list ((.> os :pullEventRaw))))
               (when (elem? (car event-args) event-whitelist)
                 (next-fn! computer event-args)))) })
