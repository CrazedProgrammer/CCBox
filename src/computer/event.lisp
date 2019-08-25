(import computer/coroutine (resume!))
(import util (time->daytime))

(defun create-event-env (get-time!)
  (let* [(event-env { :next-timer-id 0
                      :timer-list '()
                      :queued-events '()
                      :get-time! get-time! })]
    (.<! event-env :api
         { :queueEvent (lambda (&event)
                         (queue-event! event-env event))
           :startTimer (lambda (timeout)
                         (start-timer! event-env timeout))
           :cancelTimer (lambda (timer-id)
                          (cancel-timer! event-env timer-id))
           :setAlarm (lambda (game-time)
                       (set-alarm! event-env game-time))
           :cancelAlarm (lambda (timer-id)
                          (cancel-timer! event-env timer-id)) } )
    event-env))

(defun queue-event! (event-env event) :hidden
  (push! (.> event-env :queued-events) event))

(defun start-timer! (event-env timeout is-alarm) :hidden
  (let* [(trigger-time (+ ((.> event-env :get-time!)) (or timeout 0.05)))
         (timer-id (.> event-env :next-timer-id))]
    (push! (.> event-env :timer-list)
           (list timer-id (if is-alarm 'alarm 'timer) trigger-time))
    (inc! (.> event-env :next-timer-id))
    timer-id))

(defun set-alarm! (event-env time) :hidden
  (let* [((current-time current-day) (time->daytime ((.> event-env :get-time!))))
         (delay-time (mod (- time current-time) 24))]
    (start-timer! event-env (* delay-time 60) true)))

(defun cancel-timer! (event-env timer-id) :hidden
  (.<! event-env :timer-list
       (filter (.> event-env :timer-list)
               (lambda (timer)
                 (= (car timer) timer-id)))))

(defun queue! (computer event)
  (queue-event! (.> computer :event-env) event))

(defun tick! (computer)
  (let* [(event-env (.> computer :event-env)) ; TODO: Find a more pure way of doing this
         (queued-events (.> event-env :queued-events))
         (current-time ((.> event-env :get-time!)))
         (has-passed? (lambda (timer)
                        (<= (caddr timer) current-time)))]
    (.<! event-env :timer-list
         (filter (lambda (timer)
                   (if (has-passed? timer)
                     (progn (push! (.> event-env :queued-events)
                                   (list (symbol->string (cadr timer)) (car timer)))
                            false)
                     true))
                 (.> event-env :timer-list)))
    (for i 1 (n queued-events) 1
      (let* [(event (car queued-events))]
        (resume! computer event)
        (remove-nth! queued-events 1)))))
