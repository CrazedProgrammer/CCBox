(define special-key-map :hidden
  { "\x0d" "enter"
    "\x7f" "backspace"
    "\x09" "tab" })

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

(defun parse-key (chars)
  (with (ch (car chars))
    (if (.> special-key-map ch)
      (list (.> key-map (.> special-key-map ch))
            nil)
      (list nil
            ch))))

