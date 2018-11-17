(import event/cc)
(import util (is-computercraft?))

(defun create-event-env (next-fn!)
  (cond [(is-computercraft?) (event/cc/create-event-env next-fn!)]
        [else (error! "suitable event system not found")]))
