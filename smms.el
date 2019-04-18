;;; smms.el --- sm.ms helper functions

;; Copyright (C) 2004-2019 DarkSun <lujun9972@gmail.com>.

;; Author: DarkSun <lujun9972@gmail.com>
;; Keywords: image sm.ms

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Source code
;;
;; smms's code can be found here:
;;   http://github.com/lujun9972/smms.el

;;; Commentary:

;; smms defined some sm.ms helper functions
;;


;;; Code:

(require 'json)
(require 'request)
(require 'vc)
(defun smms-api-upload (smfile)
  "图片上传"
  (request-response-data (request "https://sm.ms/api/upload"
                                  :type "POST"
                                  :files `(("smfile" . ,smfile))
                                  :parser 'json-read
                                  :sync t)))
(defun smms-api-delete (hash)
  "删除图片"
  (request-response-data (request (format "https://sm.ms/delete/%s" hash)
                                  :parser 'buffer-string
                                  :sync t)))

(defun smms-api-list ()
  "获得过去一小时内上传的文件列表"
  (request-response-data (request "https://sm.ms/api/list"
                                  :parser 'json-read
                                  :sync t)))

(defun smms-api-clear ()
  "清除历史上传"
  (request-response-data (request "https://sm.ms/api/clear"
                                  :parser 'json-read
                                  :sync t)))


(defvar smms-db-filename ".smms.db")

(defun smms-get-db-file ()
  "返回数据文件的路径,数据文件中记录了本地图片路径，图片URL以及删除URL的对应关系"
  (let ((root (or (vc-root-dir)
                  default-directory)))
    (expand-file-name smms-db-filename root)))

;;;###autoload
(defun smms-upload-image (&optional file)
  "上传图片，将图片URL保存到kill-ring中"
  (interactive)
  (let* ((file (or file
                   (read-file-name "请选择要上传的图片")))
         (file (expand-file-name file))
         (result (smms-api-upload file))
         (code (assoc-default 'code result))
         (data (assoc-default 'data result))
         (url (assoc-default 'url data))
         (delete (assoc-default 'delete data))
         (line `(:file ,file :url ,url :delete ,delete)))
    (when (equal code "success")
      (with-temp-file (smms-get-db-file)
        (when (file-exists-p (smms-get-db-file))
          (insert-file-contents-literally (smms-get-db-file)))
        (print line (current-buffer)))
      (message "%s" url)
      (kill-new url))))

(provide 'smms)



;;; smms.el ends here
