(defun deep-copy (a)
  (case (type a)
    ["table" (with (t {})
               (for-each key (keys a)
                 (.<! t key
                        (with (item (.> a key))
                          (if (= item a)
                            item
                            (deep-copy item)))))
               t)]
    [_ a]))
