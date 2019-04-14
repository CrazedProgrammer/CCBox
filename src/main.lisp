(import computer (create))
(import cli (cli-args))
(import spec (create-spec))
(import platforms (start-runtime!))


(defun run ()
  (with (computer (create (create-spec cli-args)))
    (start-runtime! computer)))

(run)
