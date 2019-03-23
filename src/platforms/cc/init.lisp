(import lua/basic (_G))

(defun create-libs ()
  { :term ((.> _G :term :current))
    :http-request (lambda (computer) (.> _G :http :request)) })
