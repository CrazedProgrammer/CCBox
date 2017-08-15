(import lua/basic (_G load setmetatable))
(import lua/coroutine coroutine)
(import base (set-idx!))
(import bindings/fs fs)
(import bindings/window window)
(import bindings/term term)
(import debug)
(import util (deep-copy))

(defun create (boot-file)
  (let* [(cid 0)
         (label $"computer-${cid}")
         (computer { :id cid
                     :label label
                     :boot-file boot-file })
         (env (create-env computer))]
      ;; todo: fix this paradox
      (.<! computer :env env)
      (.<! computer :coroutine (create-coroutine boot-file env))
      computer))

(defun create-coroutine (boot-file env) :hidden
   (let* [(boot-code-handle (fs/open boot-file "r"))
          (boot-code (self boot-code-handle :readAll))]
     (self boot-code-handle :close)
     (coroutine/create (load boot-code "ccjam-bios.lua" "t" env))))


(defun next (computer args)
  (with (result (list (coroutine/resume (.> computer :coroutine) (unpack args))))
    (if (= (car result) false)
      (error! (.. "computer panicked! error: \n" (cadr result)))
      (if (= (.> computer :running) false)
        (error! "computer shutdown!")
        (progn
          (debug/log! (.. "event: " (pretty args)))
          (unpack (cdr result)))))))


(define api-blacklist :hidden
 { ; "gps" "parallel" "peripheral" "settings"
    :colors '() :colours '() :disk '() :help '() :settings '()
    :io '() :keys '() :paintutils '() :term '() :shell '()
    :rednet '() :textutils '() :vector '() :window '()
    :os '("shutdown" "reboot") })

(defun create-env (computer) :hidden
  (let* [(global (deep-copy _G))
         (env (setmetatable { :_G global } { :__index global }))
         (term (term/current))]
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
    (.<! global :term { :native (lambda () term) })
    (.<! global :os :shutdown (lambda () (.<! computer :running false)))
    (.<! global :os :reboot (lambda () (.<! computer :coroutine (create-coroutine (.> computer :boot-file) (.> computer :env)))))
    env))
