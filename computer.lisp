(import lua/basic (_G load))
(import lua/coroutine coroutine)
(import bindings/fs fs)
(import util (deep-copy))
(import base (set-idx!))

(defun create ()
  (let* [(cid 0)
         (label $"computer-${cid}")
         (env (deep-copy _G))
         (blacklist
           '( ;"term" "gps" "parallel" "peripheral" "settings"
              "colors" "colours" "disk" "help"
              "io" "keys" "paintutils"
              "rednet" "textutils" "vector" "window" ))
         (computer { :id cid
                     :label label
                     :env env })]
    (.<! env :getmetatable (lambda (a)
                             (if (= (type a) "string")
                               {}
                               (.> env :getmetatable))))
    (for-each entry blacklist
      (set-idx! env entry nil))
    (.<! computer :coroutine
                  (coroutine/create (lambda () (run computer))))
    computer))

(defun run (computer) :hidden
  (let* [(handle (fs/open "bios.lua" "r"))
         (code ((.> handle :readAll)))]
    ((.> handle :close))
    ((load code "ccjam-bios.lua" "t" (.> computer :env)))))

(defun next (computer args)
  (coroutine/resume (.> computer :coroutine) (unpack args)))
