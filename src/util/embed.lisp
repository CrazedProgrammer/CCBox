(import compiler (flag?))
(import io (read-all!))

;;; Allows for embedding things like bios.lua into the CCBox executable itself

(define embedded-bios
 ,(when (flag? :embed-bios)
    (read-all! "./buildenv/bios.lua")))
(define embedded-ccfs
 ,(when (flag? :embed-ccfs)
    (read-all! "./buildenv/ccfs.json")))
