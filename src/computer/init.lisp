(import vfs (create-vfs))
(import platforms (create-libs))
(import computer/env (create-env))
(import computer/event event)
(import computer/coroutine (create-coroutine))
(import computer/term (create-term))

(defun create (spec)
  (let* [(cid 0)
         (label (format nil "computer-{#cid}"))
         (platform-libs (create-libs (.> spec :platform)))
         (computer { :id cid
                     :label label
                     :running true
                     :spec spec
                     :event-env (event/create-event-env (.> platform-libs :os-clock))
                     :platform-libs platform-libs
                     :term (create-term (.> platform-libs :term) (elem? "advanced" (.> spec :features)))
                     :vfs (create-vfs (.> spec :vfs-mounts) (elem? "mount" (.> spec :features))) })]
      (.<! computer :env (create-env computer))
      (.<! computer :coroutine (create-coroutine computer))
      ;; Boot the computer
      (event/queue! computer '())
      (event/tick! computer)

      computer))

