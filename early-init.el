;; Early Initialisation -*- lexical-binding: t -*-

(setq package-enable-at-startup nil
      inhibit-splash-screen t
      inhibit-startup-message t
      inhibit-startup-echo-area-message (getenv "USER")
      native-comp-async-report-warnings-errors 'silent
      byte-compile-warnings nil
      warning-minimum-level :error
      read-process-output-max (* 1024 1024))

;; (setenv "LSP_USE_PLISTS" "true")

(menu-bar-mode -1)
(tool-bar-mode -1)
;; (scroll-bar-mode -1)

;; (add-to-list 'default-frame-alist '(foreground-color . "#FFFFFF"))
;; (add-to-list 'default-frame-alist '(background-color . "#000000"))

(set-language-environment "UTF-8")
;; Undoes `set-language-environment`'s changes
(setq default-input-method nil)
;; Windows uses UTF-16 for its clipboard, so setting UTF-8 in that case would
;; break things
(unless (eq system-type 'windows-nt)
  (setq selection-coding-system 'utf-8))

;; Don't want to be reminded I'm using GNU software
(defun display-startup-echo-area-message () nil)
