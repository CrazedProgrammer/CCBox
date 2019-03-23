(import platforms/puc/term term)
(import platforms/puc/http http)

(defun create-libs ()
  { :term (term/create)
    :http-request http/request })
