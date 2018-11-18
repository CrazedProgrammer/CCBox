(import util (is-computercraft?))
(import platforms/cc/event cc/event)
(import platforms/cc/term cc/term)

(defun create-event-env (next-fn!)
  (cond [(is-computercraft?) (cc/event/create next-fn!)]
        [else (error! "suitable event system not found")]))

(defun create-term ()
  (cond [(is-computercraft?) (cc/term/create)]
        [else (error! "suitable terminal not found")]))
