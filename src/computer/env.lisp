(import lua/basic (type# len# load _G))
(import math/bit32 bit32)
(import computer/coroutine (create-coroutine))
(import util (version time->daytime))
(import computer/event event)

(define env-whitelist :hidden
        '( "type" "setfenv" "string" "load" "loadstring" "pairs" "_VERSION"
           "ipairs" "rawequal" "xpcall" "_CC_DEFAULT_SETTINGS" "unpack" "bitop" "setmetatable" "rawset" "rawget" "table" "bit32"
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

(defun undo-deprecations! (global) :hidden
  ;; Undo deprecations made by Lua 5.2/5.3
  (when (not (.> global :unpack))
    (.<! global :unpack (.> global :table :unpack)))
  (when (not (.> global :math :pow))
    (.<! global :math :pow ((load "return function(a, b) return a ^ b end"))))
  ;; math.atan also takes two arguments in Lua 5.3
  (when (not (.> global :math :atan2))
    (.<! global :math :atan2 (.> global :math :atan)))
  (when (not (.> global :table :getn))
    (.<! global :table :getn (lambda (t)
                               (or (.> t :n)
                                   (len# t)))))
  (when (not (.> global :table :setn))
    (.<! global :table :setn (lambda (t n)
                               (.<! t :n n)))))

(defun create-env (computer)
  (let* [(global (assoc->struct
                   (map (lambda (name)
                     (with (contents (.> _G name))
                       (list name
                             (case (type contents)
                               ["table" (merge contents {})]
                               [_ contents]))))
                     env-whitelist)))
         (get-time! (.> computer :event-env :get-time!))]
    (.<! global :_HOST (.. "ComputerCraft 1.80pr1.12 (CCBox " version ")"))
    (.<! global :_G global)
    (.<! global :getmetatable
             (lambda (a)
               (if (= (type# a) "string")
                 {}
                 (getmetatable a))))
    (.<! global :term (.> computer :term))

    (.<! global :disk (if (elem? "disk" (.> computer :spec :features))
                        (.> _G :disk)
                        nil-disk))
    (.<! global :redstone (if (elem? "redstone" (.> computer :spec :features))
                        (.> _G :redstone)
                        nil-redstone))
    (.<! global :peripheral (if (elem? "peripheral" (.> computer :spec :features))
                        (.> _G :peripheral)
                        nil-disk))

    (.<! global :bit
         { :blshift       bit32/shl
           :brshift       bit32/ashr
           :blogic_rshift bit32/shr
           :bxor          bit32/bit-xor
           :bor           bit32/bit-or
           :band          bit32/bit-and
           :bnot          bit32/bit-not })
    (.<! global :bit32
         { :blshift       bit32/shl
           :barshift      bit32/ashr
           :brshift       bit32/shr
           :bxor          bit32/bit-xor
           :bor           bit32/bit-or
           :band          bit32/bit-and
           :bnot          bit32/bit-not
           :btest         bit32/bit-test
           :extract       bit32/bit-extract
           :replace       bit32/bit-replace
           :lrotate       bit32/bit-rotl
           :rrotate       bit32/bit-rotr })
    (undo-deprecations! global)

    (.<! global :os
         { :getComputerID (lambda () (.> computer :id))
           :getComputerLabel (lambda () (.> computer :label))
           :setComputerLabel (lambda (label) (.<! computer :label label))
           :queueEvent (.> computer :event-env :api :queueEvent)
           :startTimer (.> computer :event-env :api :startTimer)
           :cancelTimer (.> computer :event-env :api :cancelTimer)
           :setAlarm (.> computer :event-env :api :setAlarm)
           :cancelAlarm (.> computer :event-env :api :cancelAlarm)
           :clock get-time!
           :time (lambda ()
                   (with ((time day) (time->daytime (get-time!)))
                     time))
           :day (lambda ()
                  (with ((time day) (time->daytime (get-time!)))
                    day))
           :shutdown (lambda () (.<! computer :running false))
           :reboot (lambda ()
                     ;; TODO: Find a nice way to refresh the screen when rebooting
                     ;; TODO: Fix temporary filesystem not flushing when shutting down after a reboot
                     (.<! computer :coroutine (create-coroutine computer))) })
    (.<! global :rs (.> global :redstone))
    (.<! global :fs (.> computer :vfs))
    (when (elem? "network" (.> computer :spec :features))
      (.<! global :http { :request ((.> computer :platform-libs :http-request) computer)
                          :checkURL (lambda (url)
                                      (event/queue!
                                        computer
                                        (append
                                          (list "http_check" url)
                                          (if (string/find url "https?%:%/%/")
                                            (list true)
                                            (list false "URL malformed")))))} ))
    (when (elem? "testlog" (.> computer :spec :features))
      (.<! global :testlog { :write (lambda (data)
                                      (push! (.> computer :testlog) data)) } ))
    global))
