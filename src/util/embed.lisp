(import compiler (flag?))
(import io (read-all!))

;;; Allows for embedding things like bios.lua into the CCBox binary itself

(define embedded-bios
 ,(when (flag? :embed-bios)
    (read-all! "./buildenv/bios.lua")))
(define embedded-json
 ,(when (flag? :embed-json)
    (read-all! "./buildenv/json.lua")))
(define embedded-ccfs
 ,(when (flag? :embed-ccfs)
    (read-all! "./buildenv/ccfs.json")))
