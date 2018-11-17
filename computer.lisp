(import lua/basic (_G load getmetatable type#))
(import lua/coroutine coroutine)
(import core/base (set-idx!))
(import util (resolve-path read-file-force! get-time))
(import log (log!))
(import vfs (create-vfs))
(import event (create-event-env))
(import term (create-term))

(defun create (spec)
  (let* [(cid 0)
         (label (format nil "computer-{#cid}"))
         (computer { :id cid
                     :label label
                     :running true
                     :spec spec
                     :event-env (create-event-env next!)
                     :term (create-term)
                     :vfs (create-vfs (.> spec :vfs-mounts)) })
         (env (create-env computer))]
      ;; todo: fix this paradox
      (.<! computer :env env)
      (create-coroutine! computer)
      computer))

(defun create-coroutine! (computer) :hidden
  (let* [(boot-code (read-file-force! (resolve-path (.> computer :spec :boot-file))))
         (coroutine (coroutine/create (load boot-code "ccbox-bios.lua" "t" (.> computer :env))))]
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
      (with (result (list (coroutine/resume (.> computer :coroutine) event (splice (cdr args)))))
        (if (= (car result) false)
          (error! (.. "computer panicked! error: \n" (cadr result)))
          (progn
            (log! (.. "event: " (pretty args)))
            (splice (cdr result))))))))

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
    (.<! global :term (.> computer :term))
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
           :queueEvent (.> computer :event-env :queueEvent)
           :startTimer (.> computer :event-env :startTimer)
           :cancelTimer (.> computer :event-env :cancelTimer)
           :setAlarm (.> computer :event-env :setAlarm)
           :cancelAlarm (.> computer :event-env :cancelAlarm)
           :clock get-time
           :time (lambda ()
                   (mod (/ (get-time) 60) 24))
           :day (lambda ()
                  (math/floor (/ (get-time) 60 24)))
           :shutdown (lambda () (.<! computer :running false))
           :reboot (lambda ()
                     ; todo: find a nice way to refresh the screen when rebooting
                     (create-coroutine! computer) ) })
    (.<! global :rs (.> global :redstone))
    (when (not (.> computer :spec :disable-networking))
      (.<! global :http (when (.> _G :http) (merge (.> _G :http) {})))
      (.<! global :socket (when (.> _G :socket) (merge (.> _G :socket) {}))))
    (.<! global :fs (.> computer :vfs))
    global))
