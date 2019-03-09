(import util (log!))

(define special-key-map :hidden
  { "\x0d" "enter"
    "\x7f" "backspace"
    "\x09" "tab"
    "\27[A" "up"
    "\27[B" "down"
    "\27[C" "right"
    "\27[D" "left"
    "\27" "leftCtrl"
    "\27[2~" "insert"
    "\27[3~" "delete"
    "\27[H" "home"
    "\27[F" "end"
    "\27[5~" "pageUp"
    "\27[6~" "pageDown" })

(define key-map :hidden
  { "a" 30
    "apostrophe" 40
    "at" 145
    "ax" 150
    "b" 48
    "backslash" 43
    "backspace" 14
    "c" 46
    "capsLock" 58
    "cimcumflex" 144
    "circumflex" 144
    "colon" 146
    "comma" 51
    "convert" 121
    "d" 32
    "delete" 211
    "down" 208
    "e" 18
    "eight" 9
    "end" 207
    "enter" 28
    "equals" 13
    "f10" 68
    "f11" 87
    "f12" 88
    "f13" 100
    "f14" 101
    "f15" 102
    "f1" 59
    "f2" 60
    "f" 33
    "f3" 61
    "f4" 62
    "f5" 63
    "f6" 64
    "f7" 65
    "f8" 66
    "f9" 67
    "five" 6
    "four" 5
    "g" 34
    "grave" 41
    "h" 35
    "home" 199
    "i" 23
    "insert" 210
    "j" 36
    "k" 37
    "kana" 112
    "kanji" 148
    "l" 38
    "left" 203
    "leftAlt" 56
    "leftBracket" 26
    "leftCtrl" 29
    "leftShift" 42
    "m" 50
    "minus" 12
    "multiply" 55
    "n" 49
    "nine" 10
    "noconvert" 123
    "numLock" 69
    "numPad0" 82
    "numPad1" 79
    "numPad2" 80
    "numPad3" 81
    "numPad4" 75
    "numPad5" 76
    "numPad6" 77
    "numPad7" 71
    "numPad8" 72
    "numPad9" 73
    "numPadAdd" 78
    "numPadComma" 179
    "numPadDecimal" 83
    "numPadDivide" 181
    "numPadEnter" 156
    "numPadEquals" 141
    "numPadSubtract" 74
    "o" 24
    "one" 2
    "p" 25
    "pageDown" 209
    "pageUp" 201
    "pause" 197
    "period" 52
    "q" 16
    "r" 19
    "return" 28
    "right" 205
    "rightAlt" 184
    "rightBracket" 27
    "rightCtrl" 157
    "rightShift" 54
    "s" 31
    "scollLock" 70
    "scrollLock" 70
    "semiColon" 39
    "seven" 8
    "six" 7
    "slash" 53
    "space" 57
    "stop" 149
    "t" 20
    "tab" 15
    "three" 4
    "two" 3
    "u" 22
    "underscore" 147
    "up" 200
    "v" 47
    "w" 17
    "x" 45
    "y" 21
    "yen" 125
    "z" 44
    "zero" 11 })

(define mouse-input-pattern "\27%[%<[;%d]*[mM]")
(define ansi-input-pattern "[\27\155][][()#;?%d]*[A-PRZcf-ntqry=><~]")

(define input-patterns :hidden
  (list mouse-input-pattern ; Mouse button tracking
        ansi-input-pattern ; ANSI escape sequence
        "."))

(defun parse-key (key) :hidden
  (if (.> special-key-map key)
    (list (.> key-map (.> special-key-map key))
          nil)
    (list nil
          key)))

(defun split-input (all-input) :hidden
  (let* [(idx 1)
         (input-parts '())
         (found-pattern false)]
    (while (<= idx (n all-input))
      (with (found-length-1 ; Length minus one
             (car (filter
                    (lambda (x) (not (nil? x)))
                    (map (lambda (pattern)
                           (with ((start end) (string/find all-input pattern idx))
                             (when (and start (= start idx))
                               (- end start))))
                           input-patterns))))
        (push! input-parts (string/sub all-input idx (+ idx found-length-1)))
        (set! idx (+ idx found-length-1 1))))
    input-parts))

(defun mouse-input->event (input) :hidden
  (let* [(mouse-pressed? (= (string/sub input (n input) (n input)) "M"))
         (codes (map tonumber (string/split (string/sub input 4 -2) ";")))
         (mouse-code (car codes))
         (mouse-x (cadr codes))
         (mouse-y (caddr codes))]
    (log! (.. "mouse: pressed:" (tostring mouse-pressed?) " code:" mouse-code " x:" mouse-x " y:" mouse-y))
    ;; TODO: Mouse wheel tracking.
    (case (list mouse-pressed? mouse-code)
      [(true 0) (list "mouse_click" 1 mouse-x mouse-y)]
      [(true 2) (list "mouse_click" 2 mouse-x mouse-y)]
      [(true 32) (list "mouse_drag" 1 mouse-x mouse-y)]
      [(true 34) (list "mouse_drag" 2 mouse-x mouse-y)]
      [(false 0) (list "mouse_up" 1 mouse-x mouse-y)]
      [(false 2) (list "mouse_up" 2 mouse-x mouse-y)]
      [else nil])))

(defun input->events (all-input)
  (let* [(events '())]
    (do [(input (split-input (string/sub all-input 1 -2)))]
      (case input
        ["\x03" (push! events "quit")]
        ["\x14" (push! events (list "terminate"))]
        [else
         (if (= (string/find input mouse-input-pattern) 1)
           (with (mouse-event (mouse-input->event input))
             (when mouse-event
               (push! events mouse-event)))
           (with (keychar (parse-key input))
             (when keychar ; TODO: Properly handle modifier keys.
               (progn
                 (when (car keychar)
                   (push! events (list "key" (car keychar)))
                   (push! events (list "key_up" (car keychar))))
                 (when (cadr keychar)
                   (push! events (list "char" (cadr keychar))))))))]))
    events))
