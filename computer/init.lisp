(import vfs (create-vfs))
(import term (create-term))
(import platforms (create-native-term))
(import computer/env (create-env))
(import computer/event event)
(import computer/coroutine (create-coroutine))

(defun create (spec)
  (let* [(cid 0)
         (label (format nil "computer-{#cid}"))
         (computer { :id cid
                     :label label
                     :running true
                     :spec spec
                     :event-env (event/create-event-env)
                     :term (create-term (create-native-term) (not (.> spec :non-advanced)))
                     :vfs (create-vfs (.> spec :vfs-mounts) (.> spec :enable-runtime-mount)) })]
      (.<! computer :env (create-env computer))
      (.<! computer :coroutine (create-coroutine computer))
      ; Boot the computer
      (event/queue! computer '())
      (event/tick! computer)

      computer))

