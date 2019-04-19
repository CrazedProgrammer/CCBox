(import util (log!))
(import lua/basic (load getmetatable))
(import lua/coroutine coroutine)
(import util/embed (embedded-bios))

(defun create-coroutine (computer)
  (let* [(boot-code (.> computer :spec :bios))
         (coroutine (coroutine/create (load boot-code "ccbox-bios.lua" "t" (.> computer :env))))]
    (when (> (n (.> computer :spec :startup-command)) 0)
      (resume! computer '("char" " "))
      (for-each chr (string/split (.> computer :spec :startup-command) "")
        (resume! computer (list "char" chr)))
      (resume! computer '("key" 28)))
    coroutine))


(defun resume! (computer args)
  (let* [(event (car args))]
    (with (result (list (coroutine/resume (.> computer :coroutine) event (splice (cdr args)))))
      (if (= (car result) false)
        (progn
          (log! (.. "computer panicked! error: \n" (tostring (cadr result))))
          (error! (.. "computer panicked! error: \n" (tostring (cadr result)))))
        (progn
          (log! (.. "event: " (pretty args)))
          ;; TODO: Verify if this is the correct place to put this in
          (when (not (.> computer :running))
            (close! computer))
          (cadr result))))))

(defun close! (computer)
  ;; TODO: Don't expose this globally
  ((.> computer :vfs :closeAll)))
