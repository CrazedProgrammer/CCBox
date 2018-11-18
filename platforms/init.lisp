(import config (args))
(import util (is-computercraft?))
(import platforms/cc/event cc/event)
(import platforms/cc/term cc/term)

(defun create-event-env (next-fn!)
  (cond [(is-computercraft?) (cc/event/create next-fn!)]
        [else (error! "suitable event system not found")]))

(defun create-term ()
  (with (term (cond [(is-computercraft?) (cc/term/create)]
                    [else (error! "suitable terminal not found")]))
    ; TODO: write a layer around this so that black and white terminals cannot display colour
    (merge term
           { :isColour (const (not (.> args :non-advanced)))
             :isColor (const (not (.> args :non-advanced)))  })))
