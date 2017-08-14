(import lua/basic (_G load setmetatable))
(import lua/coroutine coroutine)
(import base (set-idx!))
(import bindings/fs fs)
(import bindings/window window)
(import bindings/term term)
(import util (deep-copy))

(defun create (boot-file)
  (let* [(cid 0)
         (label $"computer-${cid}")
         (env (create-env))
         (boot-code-handle (fs/open boot-file "r"))
         (boot-code (self boot-code-handle :readAll))
         (boot-coroutine (coroutine/create (load boot-code "ccjam-bios.lua" "t" env)))
         (computer { :id cid
                     :label label
                     :env env
                     :coroutine boot-coroutine})]
    (self boot-code-handle :close)
    computer))

(defun next (computer args)
  (with (result (list (coroutine/resume (.> computer :coroutine) (unpack args))))
    (if (= (car result) false)
      (error! (.. "computer panicked! error: \n" (cadr result)))
      (progn
        (when (caddr result)
          (print! (.. "args: " (pretty args) " result: " (pretty result))))
        (unpack (cddr result))))))


(define api-blacklist :hidden
 { ; "gps" "parallel" "peripheral" "settings"
    :colors '() :colours '() :disk '() :help '() :settings '()
    :io '() :keys '() :paintutils '() :term '() :shell '()
    :rednet '() :textutils '() :vector '() :window '()
    :os '("shutdown") })

(defun create-env () :hidden
  (let* [(global (deep-copy _G))
         (env (setmetatable { :_G global } { :__index global }))
         (window (window/create (term/current) 1 1 (term/getSize)))]
    (for-each api-name (keys api-blacklist)
      (if (= (n (.> api-blacklist api-name)) 0)
        (set-idx! global api-name nil)
        (for-each api-item (.> api-blacklist api-name)
          (set-idx! (.> global api-name) api-item nil))))
    (.<! global :getmetatable
             (lambda (a)
               (if (= (type a) "string")
                 {}
                 ((.> global :getmetatable)))))
    (.<! global :term { :native (lambda () window) })
    (.<! global :os :shutdown (lambda () (coroutine/yield "emu/shutdown")))
    env))
