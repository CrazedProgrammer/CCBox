(import vfs (create-vfs))
(import platforms (create-term))
(import computer/env (create-env))
(import computer/event (create-event-env))
(import computer/coroutine (create-coroutine))

(defun create (spec)
  (let* [(cid 0)
         (label (format nil "computer-{#cid}"))
         (computer { :id cid
                     :label label
                     :running true
                     :spec spec
                     :event-env (create-event-env)
                     :term (create-term)
                     :vfs (create-vfs (.> spec :vfs-mounts)) })]
      (.<! computer :env (create-env computer))
      (.<! computer :coroutine (create-coroutine computer))
      computer))

