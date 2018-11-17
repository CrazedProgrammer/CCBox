(import computer)
(import vfs)
(import bindings/os os)
(import config (args))


(defun run ()
  (with (comp (computer/create args))
    (while (.> comp :running)
      (computer/next! comp (list (os/pullEventRaw))))))

(run)
