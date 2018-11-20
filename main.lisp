(import computer (create next!))
(import config (args))
(import platforms (start-runtime!))


(defun run ()
  (with (computer (create args))
    (start-runtime! computer next!)))

(run)
