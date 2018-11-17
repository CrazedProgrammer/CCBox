(import computer)
(import config (args))


(defun run ()
  (with (comp (computer/create args))
    (while (.> comp :running)
      ((.> comp :event-env :next!) comp))))

(run)
