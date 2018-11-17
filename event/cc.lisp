(import lua/basic (_G))
(define os (.> _G :os))

; we can just borrow the host's event system for now
(defun create-event-env (next-fn!)
  { :queueEvent  (.> os :queueEvent)
    :startTimer  (.> os :startTimer)
    :cancelTimer (.> os :cancelTimer)
    :setAlarm    (.> os :setAlarm)
    :cancelAlarm (.> os :cancelAlarm)

    :next! (lambda (computer)
             (next-fn! computer (list ((.> os :pullEventRaw))))) })
