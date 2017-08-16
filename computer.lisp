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

(define event-whitelist :hidden
        '( "timer" "alarm" "terminate" "http_success" "http_failure"
           "paste" "char" "key" "key_up"
           "mouse_click" "mouse_up" "mouse_scroll" "mouse_drag" ))

(defun next (computer args)
  (with (event (car args))
    (when (elem? event event-whitelist)
      (with (result (list (coroutine/resume (.> computer :coroutine) (unpack args))))
        (if (= (car result) false)
          (error! (.. "computer panicked! error: \n" (cadr result)))
          (if (= (.> computer :running) false)
            (error! "computer shutdown!")
            (progn
              (debug/log! (.. "event: " (pretty args)))
              (unpack (cdr result)))))))))

(define env-whitelist :hidden
        '( "type" "setfenv" "string" "loadstring" "pairs" "_VERSION" "peripheral"
           "ipairs" "rawequal" "xpcall" "fs" "_CC_DEFAULT_SETTINGS" "unpack" "bitop" "os"
           "setmetatable" "rawset" "http" "rawget" "table" "bit32"
           "_HOST" "getmetatable" "bit" "assert" "error" "pcall"
           "socket" "tostring" "next" "tonumber" "math" "_RUNTIME" "coroutine"
           "biginteger" "loadfile" "getfenv" "dofile" "select" "load" "data" ))

(defun create-env (computer) :hidden
  (let* [(global (deep-copy _G))
         (env (setmetatable { :_G global } { :__index global }))
         (term (term/current))]
    (map (lambda (name)
           (with (contents (.> _G name))
             (.<! global name
               (case (type contents)
                 ["table" (merge contents {})]
                 [_ contents]))))
         env-whitelist)
    (.<! global :_G global)
    (.<! global :getmetatable
             (lambda (a)
               (if (= (type a) "string")
                 {}
                 ((.> global :getmetatable)))))
    (.<! global :term { :native (lambda () term) })
    (.<! global :os :shutdown (lambda () (.<! computer :running false)))
    (.<! global :os :reboot (lambda () (.<! computer :coroutine (create-coroutine (.> computer :boot-file) (.> computer :env)))))
    env))
