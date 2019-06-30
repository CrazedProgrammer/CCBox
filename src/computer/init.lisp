(import vfs (create-vfs))
(import platforms (create-libs))
(import computer/env (create-env))
(import computer/event event)
(import computer/coroutine (create-coroutine))
(import computer/term (create-term nil-term))

(defun create (spec)
  (let* [(cid 0)
         (label (format nil "computer-{#cid}"))
         (platform-libs (create-libs (.> spec :platform)))
         (startup-time ((.> platform-libs :os-clock)))
         (get-time! (lambda ()
                      (- ((.> platform-libs :os-clock))
                         startup-time)))
         (computer { :id cid
                     :label label
                     :running true
                     :spec spec
                     :event-env (event/create-event-env get-time!)
                     :platform-libs platform-libs
                     :term (if (elem? "nil-term" (.> spec :features))
                             (create-term nil-term (elem? "advanced" (.> spec :features)))
                             (create-term (.> platform-libs :term) (elem? "advanced" (.> spec :features))))
                     :vfs (create-vfs (.> spec :vfs-mounts) (elem? "mount" (.> spec :features))) })]
      (when (elem? "testlog" (.> spec :features))
        (.<! computer :testlog '()))
      (.<! computer :env (create-env computer))
      (.<! computer :coroutine (create-coroutine computer))
      ;; Boot the computer
      (event/queue! computer '())
      (event/tick! computer)

      computer))

