;;; orgbital.el --- description -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2020 Tan Yee Jian
;;
;; Author: Jing Yen Loh, Tan Yee Jian <http://github.com/orgbital>
;; Maintainer: Jing Yen Loh <lohjingyen@gmail.com>, Tan Yee Jian <tanyeejian@gmail.com>
;; Created: June 17, 2020
;; Modified: June 17, 2020
;; Version: 0.0.1
;; Keywords:
;; Homepage: https://github.com/orgbital
;; Package-Requires: ((emacs 27.0.91) (cl-lib "0.5"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;  description
;;
;;; Code:

(require 'json)

(defvar orgbital-socket (make-network-process
               :name "orgbital"
               :service "/tmp/unix.sock"
               :family 'local))

(defun send-message (begin-pos end-pos pre-change-length)
  "Foo. C sucks."
  ;; First we need to connect to the node daemon
  ;; Next we need to figure out the character in the insert action
  ;; Transfrom character into {p:[path,offset], si:s}
  ;; Send this json over unix socket
  (with-current-buffer
      (current-buffer)
    (process-send-string orgbital-socket
                         (format "hi %d %d %d %s\n" begin-pos end-pos pre-change-length (buffer-substring-no-properties begin-pos end-pos)))
    )
  )

(add-hook 'after-change-functions 'send-message)

(provide 'orgbital)
;;; orgbital.el ends here
