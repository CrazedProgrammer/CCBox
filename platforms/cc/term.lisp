(import lua/basic (_G))
(define term (.> _G :term))

(defun create ()
  (merge ((.> term :current)) {}))
