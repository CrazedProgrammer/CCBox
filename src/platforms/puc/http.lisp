(import util (run-program! log!))
(import computer/event event)

(defun request (computer)
  (lambda (url post headers binary)
    ; TODO: implement all other features
    (event/queue! computer (list "http_success" url { :readAll (lambda ()
                 (run-program! (.. "curl -s \"" url "\""))) }))
    true))
