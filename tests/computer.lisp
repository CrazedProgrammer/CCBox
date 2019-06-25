(import test ())
(import computer)
(import spec (create-spec))

(define test-spec
  { :bios "term.write(\"hello\")"
    :vfs-mounts '("tw:/:tests/testfs.json") })

(describe "A computer"
  (it "can turn on"
    (affirm (eq? (with (computer (computer/create (create-spec test-spec)))
                   true)
                 true))))
