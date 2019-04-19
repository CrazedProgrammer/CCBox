(import util (log!))
(import util/io (run-program!))
(import io (write-all!))
(import lua/os luaos)
(import computer/event event)

(defun recapitalise-header-name (raw-name) :hidden
  ;; TODO: Implement all special cases that CC expects to be handled
  ;; See https://github.com/netty/netty/blob/00afb19d7a37de21b35ce4f6cb3fa7f74809f2ab/codec-http/src/main/java/io/netty/handler/codec/http/HttpHeaders.java
  (concat
    (map (lambda (word)
           (.. (string/upper (string/sub word 1 1))
               (string/sub word 2 -1)))
         (string/split raw-name "%-"))
    "-"))

(defun parse-http-response (all-headers) :hidden
  (let* [(status-code (tonumber (cadr (string/split all-headers " "))))
         (headers
           (assoc->struct
             (map (lambda (line)
                    (let* [(parts (string/split line "%: "))
                           (raw-name (car parts))
                           (value (cadr parts))]
                      (list (recapitalise-header-name raw-name) value)))
                  (cdr (string/split all-headers "\r\n")))))]
    (values-list status-code headers)))

(defun headers->curl-options (headers) :hidden
  (string/concat
    (map (lambda (header-name)
           (.. "-H " (string/quoted (.. header-name ": " (.> headers header-name)))))
         (keys headers))
    " "))

(defun request (computer)
  (lambda (url postData (headers {}) binary)
    (let* [(post-file-path (when postData
                             (with (tmp-path (luaos/tmpname))
                               (write-all! tmp-path postData)
                               tmp-path)))
           (curl-invocation (.. "curl -sLD - "
                                (headers->curl-options headers) " "
                                (if postData
                                  (.. "--data-binary " (string/quoted (.. "@" post-file-path)) " ")
                                  "")
                                (string/quoted url)))
           (all-response-parts (string/split (run-program! curl-invocation) "\r\n\r\n"))
           (n-redirect-headers (n (take-while (lambda (all-headers)
                                                (with ((response-code headers) (parse-http-response all-headers))
                                                  (or (= response-code 301) (= response-code 302))))
                                              all-response-parts
                                              1)))
           ((response-code response-headers) (parse-http-response (nth all-response-parts (+ n-redirect-headers 1))))
           (response (string/concat (drop all-response-parts (+ n-redirect-headers 1)) "\r\n\r\n"))
           (handle
             { :readAll (const response)
               :getResponseCode (const response-code)
               :getResponseHeaders (const response-headers)
               :close (const nil)})]
      (when postData
        (luaos/remove post-file-path))
      ;; TODO: Implement proper (binary) handles
      (event/queue! computer (list "http_success" url handle))
      true)))
