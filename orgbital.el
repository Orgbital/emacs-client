;;; orgbital.el --- description -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2020 Orgbital
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

;; HACK Probably not idiomatic code and HaoWei will slaughter, but it works. We
;; should probably be using `get-process' more.
(defun restart-orgbital-socket ()
  "Restarts the orbital network process, if it is closed."
  (if (eq (process-status orgbital-socket) 'closed)
      (setq orgbital-socket(make-network-process
                            :name "orgbital"
                            :service "/tmp/unix.sock"
                            :family 'local))))

(defun send-message (begin-pos end-pos pre-change-length)
  "Foo. C sucks."
  ;; First we need to connect to the node daemon
  ;; Next we need to figure out the character in the insert action
  ;; Transfrom character into {p:[path,offset], si:s}
  ;; Send this json over unix socket
  (with-current-buffer
      (current-buffer)
    (process-send-string orgbital-socket
                         (format "hi %d %d %d %s\n"
                                 begin-pos
                                 end-pos
                                 pre-change-length
                                 (buffer-substring-no-properties begin-pos end-pos)))))

;; TODO: send document to server and get a OK response
(defun send-buffer-to-node ()
  "Sends the text content of the current buffer to the node process."
  (interactive)

  (with-current-buffer (current-buffer)
    (let ((content (concat "ahkuanisgod"
                           (buffer-substring-no-properties (point-min) (point-max))
                           "godisahkuan")))
      (progn
        (restart-orgbital-socket) ; HACK stop using this when we figure out proper way LOL
        (process-send-string orgbital-socket content)))))

;; TODO: insert/delete
(defun send-deltas-to-socket (begin-pos end-pos pre-change-length)
  "Sends the text change in the current buffer to the node process.
BEGIN-POS signfies the starting position of the change and END-POS the ending.
PRE-CHANGE-LENGTH is used to determine if it was an insert or delete operation."
  ;; HACK: deal with the WTF message
  ;; (message "begin-pos %s end-pos %s" begin-pos end-pos)
  (cond ((string= "(send-deltas-to-socket)"
                  (buffer-substring-no-properties begin-pos end-pos))
         nil)
        (t (with-current-buffer (current-buffer)
             (let* ((path (file-name-nondirectory buffer-file-name)) ; e.g. "orgbital.el"
                    (ops (format "{\"p\":%d, %s}"
                                 begin-pos
                                 (if (> pre-change-length 0) ; It's a deletion
                                     (concat "\"d\":\"" ; delete op
                                             pre-change-length
                                             "\"")
                                   (concat "\"i\":\"" ; insert op
                                           "a"
                                           ;; (buffer-substring-no-properties begin-pos end-pos)
                                           "\""))))
                    (msg (concat "fsp"
                                 (format "{\"p\":[\"%s\"], \"t\":\"text0\", \"o\":[%s]}"
                                         path
                                         ops)
                                 "fsp")))
               (progn
                 (restart-orgbital-socket) ; HACK stop using this when we figure out proper way LOL
                 ;; (message "%s" msg)
                 (process-send-string orgbital-socket msg)))))))

(add-hook 'after-change-functions 'send-deltas-to-socket)

(provide 'orgbital)
;;; orgbital.el ends here
