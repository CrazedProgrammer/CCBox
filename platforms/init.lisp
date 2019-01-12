(import config (args))
(import util (is-computercraft?))
(import platforms/cc/runtime cc/runtime)
(import platforms/cc/term cc/term)

(defun start-runtime! (computer)
  (cond [(is-computercraft?) (cc/runtime/start! computer)]
        [else (error! "suitable runtime not found")]))

(defun create-native-term ()
  (with (term (cond [(is-computercraft?) (cc/term/create)]
                    [else (error! "suitable terminal not found")]))
    ; TODO: write a layer around this so that black and white terminals cannot display colour
    (merge term
           { :isColour (const (not (.> args :non-advanced)))
             :isColor (const (not (.> args :non-advanced)))  })))
