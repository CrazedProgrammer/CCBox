(import lua/basic (_G))
(import lua/os luaos)

(defun create-libs ()
  { :term ((.> _G :term :current))
    :http-request (lambda (computer) (.> _G :http :request))
    :os-clock luaos/clock })
