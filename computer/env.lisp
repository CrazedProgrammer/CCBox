(define env-whitelist :hidden
        '( "type" "setfenv" "string" "load" "loadstring" "pairs" "_VERSION"
           "ipairs" "rawequal" "xpcall" "_CC_DEFAULT_SETTINGS" "unpack" "bitop"
           "setmetatable" "rawset" "rawget" "table" "bit32"
           "_HOST" "bit" "assert" "error" "pcall"
           "tostring" "next" "tonumber" "math" "_RUNTIME" "coroutine"
           "biginteger" "getfenv" "select" "data" ))

(defun const-fun-struct (xxs) :hidden
  (assoc->struct
    (flat-map (lambda (xs)
      (with (value (const (car xs)))
        (map (lambda (name)
               (list name value))
             (cdr xs))))
      xxs)))

(define nil-disk :hidden
  (const-fun-struct
    (list (list nil "getMountPath" "setLabel" "getLabel" "getID"
                    "getAudioTitle" "playAudio" "stopAudio" "eject")
          (list false "isPresent" "hasData" "hasAudio"))))
(define nil-peripheral :hidden
  (const-fun-struct
    (list (list nil "getType" "getMethods" "call" "wrap" "find")
          (list false "isPresent")
          (list {} "getNames"))))
(define nil-redstone :hidden
  (const-fun-struct
    (list (list nil "setOutput" "setAnalogOutput" "setBundledOutput")
          (list false "getInput" "testBundledInput")
          (list {} "getSides")
          (list 0 "getAnalogInput" "getAnalogOutput"
                  "getBundledInput" "getBundledOutput"))))

(defun create-env (computer) :hidden
  (let* [(spec (.> computer :spec))
         (global (assoc->struct
                   (map (lambda (name)
                     (with (contents (.> _G name))
                       (list name
                             (case (type contents)
                               ["table" (merge contents {})]
                               [_ contents]))))
                     env-whitelist)))]
    (.<! global :_G global)
    (.<! global :getmetatable
             (lambda (a)
               (if (= (type# a) "string")
                 {}
                 (getmetatable a))))
    (.<! global :term (.> computer :term))
    (.<! global :os
         { :getComputerID (lambda () (.> computer :id))
           :getComputerLabel (lambda () (.> computer :label))
           :setComputerLabel (lambda (label) (.<! computer :label label))
           ; todo: create event system
           :queueEvent (.> _G :os :queueEvent)
           :startTimer (.> _G :os :startTimer)
           :cancelTimer (.> _G :os :cancelTimer)
           :setAlarm (.> _G :os :setAlarm)
           :cancelAlarm (.> _G :os :cancelAlarm)
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
