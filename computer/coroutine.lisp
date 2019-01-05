(import util (log! resolve-path read-file-force!))
(import lua/basic (load getmetatable))
(import lua/coroutine coroutine)

(defun create-coroutine (computer)
  (let* [(boot-code (read-file-force! (resolve-path (.> computer :spec :boot-file))))
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
        (error! (.. "computer panicked! error: \n" (cadr result)))
        (progn
          (log! (.. "event: " (pretty args)))
          (cadr result))))))