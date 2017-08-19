(import lua/basic (_G load getmetatable type#))
(import lua/coroutine coroutine)
(import base (set-idx!))
(import bindings/fs fs)
(import bindings/window window)
(import bindings/term term)
(import bindings/os os)
(import bindings/shell shell)
(import debug)
(import vfs (create-vfs))

(defun create (spec)
  (let* [(cid 0)
         (label $"computer-${cid}")
         (computer { :id cid
                     :label label
                     :running true
                     :spec spec
                     :vfs (create-vfs (.> spec :vfs-mounts)) })
         (env (create-env computer))]
      ;; todo: fix this paradox
      (.<! computer :env env)
      (create-coroutine! computer)
      computer))

(defun create-coroutine! (computer) :hidden
  (let* [(boot-code-handle (fs/open (shell/resolve (.> computer :spec :boot-file)) "r"))
         (boot-code (progn (if boot-code-handle
                             (self boot-code-handle :readAll)
                             (error! "could not read boot file."))))
         (coroutine (coroutine/create (load boot-code "ccjam-bios.lua" "t" (.> computer :env))))]
    (self boot-code-handle :close)
    (.<! computer :coroutine coroutine)
    (when (> (n (.> computer :spec :startup-command)) 0)
      (next! computer '("char" " "))
      (for-each chr (string/split (.> computer :spec :startup-command) "")
        (next! computer (list "char" chr)))
      (next! computer '("key" 28)))))

(define event-whitelist :hidden
        '( "timer" "alarm" "terminate" "http_success" "http_failure"
           "paste" "char" "key" "key_up"
           "mouse_click" "mouse_up" "mouse_scroll" "mouse_drag" ))

(defun next! (computer args)
  (let* [(event (car args))]
    (when (elem? event event-whitelist)
      (with (result (list (coroutine/resume (.> computer :coroutine) event (unpack (cdr args)))))
        (if (= (car result) false)
          (error! (.. "computer panicked! error: \n" (cadr result)))
          (progn
            (debug/log! (.. "event: " (pretty args)))
            (unpack (cdr result))))))))

(define env-whitelist :hidden
        '( "type" "setfenv" "string" "load" "loadstring" "pairs" "_VERSION"
           "ipairs" "rawequal" "xpcall" "_CC_DEFAULT_SETTINGS" "unpack" "bitop"
           "setmetatable" "rawset" "rawget" "table" "bit32"
           "_HOST" "bit" "assert" "error" "pcall"
           "tostring" "next" "tonumber" "math" "_RUNTIME" "coroutine"
           "biginteger" "getfenv" "select" "data" ))

(defun create-env (computer) :hidden
  (let* [(spec (.> computer :spec))
         (global (assoc->struct
                   (map (lambda (name)
                     (with (contents (.> _G name))
                       (list name
                             (case (type contents)
                               ["table" (merge contents {})]
                               [_ contents]))))
                     env-whitelist)))
         (term (merge (term/current) {}))
         (const-fun-struct (lambda (xxs)
                             (assoc->struct
                               (flat-map (lambda (xs)
                                 (with (value (const (car xs)))
                                   (map (lambda (name)
                                          (list name value))
                                        (cdr xs))))
                                 xxs))))]
    (.<! global :_G global)
    (.<! global :getmetatable
             (lambda (a)
               (if (= (type# a) "string")
                 {}
                 (getmetatable a))))
    (.<! global :term term )
    (.<! global :disk (if (.> spec :enable-disk)
                        (.> _G :disk)
                        (const-fun-struct
                          (list (list nil "getMountPath" "setLabel" "getLabel" "getID"
                                          "getAudioTitle" "playAudio" "stopAudio" "eject")
                                (list false "isPresent" "hasData" "hasAudio")))))
    (.<! global :peripheral (if (.> spec :enable-peripheral)
                              (.> _G :peripheral)
                              (const-fun-struct
                                (list (list nil "getType" "getMethods" "call" "wrap" "find")
                                      (list false "isPresent")
                                      (list {} "getNames")))))
    (.<! global :redstone (if (.> spec :enable-redstone)
                            (.> _G :redstone)
                            (const-fun-struct
                              (list (list nil "setOutput" "setAnalogOutput" "setBundledOutput")
                                    (list false "getInput" "testBundledInput")
                                    (list {} "getSides")
                                    (list 0 "getAnalogInput" "getAnalogOutput"
                                            "getBundledInput" "getBundledOutput")))))
    (.<! global :os
         { :getComputerID (lambda () (.> computer :id))
           :getComputerLabel (lambda () (.> computer :label))
           :setComputerLabel (lambda (label) (.<! computer :label label))
           :queueEvent os/queueEvent
           :clock os/clock
           :startTimer os/startTimer
           :cancelTimer os/cancelTimer
           :time os/time
           :day os/day
           :setAlarm os/setAlarm
           :cancelAlarm os/cancelAlarm
           :shutdown (lambda () (.<! computer :running false))
           :reboot (lambda ()
                     (create-coroutine! computer)
                     (os/sleep 0)) })
    (.<! global :rs (.> global :redstone))
    (when (! (.> computer :spec :disable-networking))
      (.<! global :http (when (.> _G :http) (merge (.> _G :http) {})))
      (.<! global :socket (when (.> _G :socket) (merge (.> _G :socket) {}))))
    (.<! global :fs (.> computer :vfs))
    global))
