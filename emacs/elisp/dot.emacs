;; .emacs  
(message "loading dot.emacs")

(setq load-path (append '("~/elisp") load-path))
(setq default-directory "~/")

;; package.el
;;
;;    M-x package-list-packages           インストール出来るパッケージ一覧を取得;;    M-x package-list-packages-no-fetch  インストール出来るパッケージ一覧を取得(更新なし)
;;    M-x package-install                 パッケージ名を指定してインストール
(when (eq system-type 'darwin)
  (require 'package)
  (add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t)
  (add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/"))
  (setq package-user-dir "~/elisp/elpa/")
  (package-initialize)
  ;; (require 'melpa)
)


(load
 (cond ((featurep 'aquamacs) "dot.emacs-aquamacs")
       ((eq system-type 'gnu/linux) "dot.emacs-linux")
       (t "dot.emacs-mac")))


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ahs-default-range (quote ahs-range-whole-buffer))
 '(safe-local-variable-values (quote ((syntax . elisp))))
 '(vc-follow-symlinks t)
 '(which-func-format (quote ((:propertize which-func-current local-map (keymap (mode-line keymap (mouse-3 . end-of-defun) (mouse-2 . #[nil "e\300=\203	 \301 \207~\207" [1 narrow-to-defun] 2 nil nil]) (mouse-1 . beginning-of-defun))) face which-func mouse-face mode-line-highlight help-echo "mouse-1: go to beginning
mouse-2: toggle rest visibility
mouse-3: go to end" )))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(cursor ((t (:background "#F92672")))))
(put 'dired-find-alternate-file 'disabled nil)
