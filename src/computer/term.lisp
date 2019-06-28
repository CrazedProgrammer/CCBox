(import util (demand-type! clamp list->true-map))

(define colour-to-hex :hidden
  (assoc->struct (map (lambda (colour-n)
                        (list (expt 2 colour-n) (string/format "%01x" colour-n)))
                      (range :from 0 :to 15))))

(define supported-colours :hidden
  (map (cut expt 2 <>) (range :from 0 :to 15)))
(define supported-bw-colours :hidden '(0 128 256 32768))
(define supported-colours-map :hidden (list->true-map supported-colours))
(define supported-bw-colours-map :hidden (list->true-map supported-bw-colours))

(define default-palette :hidden
  { 1     '(0.941 0.941 0.941)
    2     '(0.949 0.698 0.200)
    4     '(0.898 0.498 0.847)
    8     '(0.600 0.698 0.949)
    16    '(0.871 0.871 0.424)
    32    '(0.498 0.800 0.098)
    64    '(0.949 0.698 0.800)
    128   '(0.298 0.298 0.298)
    256   '(0.600 0.600 0.600)
    512   '(0.298 0.600 0.698)
    1024  '(0.698 0.400 0.898)
    2048  '(0.200 0.400 0.800)
    4096  '(0.498 0.400 0.298)
    8192  '(0.341 0.651 0.306)
    16384 '(0.800 0.298 0.298)
    32768 '(0.067 0.067 0.067) })

(defun assert-colour! (colour is-colour) :hidden
  (demand-type! colour "number")
  (demand (.> (if is-colour supported-colours-map supported-bw-colours-map) colour)))

;;; Reduce required functions of the native terminal implementation to:
;;; - getSize
;;; - setCursorPos
;;; - setCursorBlink
;;; - blit
;;; - scroll
;;; - setPaletteColour (optional)
(defun create-term (native-term is-colour)
  (letrec
    [(cursor-x 1)
     (cursor-y 1)
     (cursor-blink false)
     (text-colour 1) ; White
     (background-colour 32768) ; Black
     (colour-palette { })
     (term
       { :getSize (.> native-term :getSize)
         :scroll (.> native-term :scroll)
         :getCursorPos (lambda ()
                         (splice (list cursor-x cursor-y)))
         :setCursorPos (lambda (x y)
                         (demand-type! x "number")
                         (demand-type! y "number")
                         (set! cursor-x (math/floor x))
                         (set! cursor-y (math/floor y))
                         ((.> native-term :setCursorPos) cursor-x cursor-y))
         :setCursorBlink (lambda (blink)
                           (demand-type! blink "boolean")
                           (set! cursor-blink blink)
                           ((.> native-term :setCursorBlink) cursor-blink))
         :isColour (const is-colour)

         :getTextColour (lambda ()
                          text-colour)
         :getBackgroundColour (lambda ()
                                background-colour)
         :setTextColour (lambda (colour)
                          (when (/= colour text-colour)
                            (assert-colour! colour is-colour)
                            (set! text-colour colour)))
         :setBackgroundColour (lambda (colour)
                                (when (/= colour background-colour)
                                  (assert-colour! colour is-colour)
                                  (set! background-colour colour)))
         :getPaletteColour (lambda (colour)
                             (assert-colour! colour is-colour)
                             (splice (.> colour-palette colour)))
         :setPaletteColour (lambda (colour r g b)
                             (assert-colour! colour is-colour)
                             (cond
                               [(and r g b)
                                (progn
                                  (demand-type! r "number")
                                  (demand-type! g "number")
                                  (demand-type! b "number")
                                  (.<! colour-palette colour (list (clamp r 0 1)
                                                                   (clamp g 0 1)
                                                                   (clamp b 0 1))))]
                               ;; TODO: Hex colours
                               [else (.<! colour-palette colour (.> default-palette colour))])
                             (when (.> native-term :setPaletteColour)
                               ((.> native-term :setPaletteColour) colour
                                                                   (splice (.> colour-palette colour)))))

         :clearLine (lambda ()
                      (let* [((prev-cursor-x prev-cursor-y) ((.> term :getCursorPos)))
                             ((term-width term-height) ((.> term :getSize)))]
                        ((.> term :setCursorPos) 1 prev-cursor-y)
                        ((.> term :write) (string/rep " " term-width))
                        ((.> term :setCursorPos) prev-cursor-x prev-cursor-y)))
         :clear (lambda ()
                  (let* [((prev-cursor-x prev-cursor-y) ((.> term :getCursorPos)))
                         ((term-width term-height) ((.> term :getSize)))]
                    (for i 1 term-height 1
                      ((.> term :setCursorPos) 1 i)
                      ((.> term :write) (string/rep " " term-width)))
                    ((.> term :setCursorPos) prev-cursor-x prev-cursor-y)))

         :write (lambda (val)
                  (let* [(str (tostring val))
                         (str-len (len# str))]
                    ((.> term :blit) str
                                     (string/rep (.> colour-to-hex text-colour) str-len)
                                     (string/rep (.> colour-to-hex background-colour) str-len))))
         :blit (lambda (blit-str blit-text blit-background)
                 (demand-type! blit-str "string")
                 (demand-type! blit-background "string")
                 (demand-type! blit-text "string")
                 (set! cursor-x (+ cursor-x (len# blit-str)))
                 ((.> native-term :blit) blit-str blit-text blit-background)) })]
    ;; Reset native cursor to its standard position
    ((.> native-term :setCursorPos) cursor-x cursor-y)
    ((.> native-term :setCursorBlink) cursor-blink)
    ;; Apply default palette to native terminal
    (do [(colour (if is-colour
                   supported-colours
                   supported-bw-colours))]
      ((.> term :setPaletteColour) colour))
    ;; Add aliases
    (merge term
           { :isColor (.> term :isColour)
             :getTextColor (.> term :getTextColour)
             :getBackgroundColor (.> term :getBackgroundColour)
             :setTextColor (.> term :setTextColour)
             :setBackgroundColor (.> term :setBackgroundColour)
             :getPaletteColor (.> term :getPaletteColour)
             :setPaletteColor (.> term :setPaletteColour) })))

(define nil-term
  { :getSize (const (splice (list 100 100)))
    :setCursorPos (const nil)
    :setCursorBlink (const nil)
    :scroll (const nil)
    :setPaletteColour (const nil) })
