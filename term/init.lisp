(import util (is-computercraft?))
(import term/cc)

(defun create-term ()
  (cond [(is-computercraft?) (term/cc/create-term)]
        [else (error! "suitable terminal not found")]))
