;; Early Initialisation -*- lexical-binding: t -*-

;; There are various snippets of code intermingled into here from Henrik
;; Lissner's doomemacs, which is under the MIT licence.

(setq package-enable-at-startup nil
      inhibit-splash-screen t
      inhibit-startup-screen t
      inhibit-startup-message t
      initial-major-mode 'fundamental-mode
      initial-scratch-message nil
      inhibit-startup-echo-area-message (getenv "USER")
      native-comp-async-report-warnings-errors 'silent
      byte-compile-warnings nil
      warning-minimum-level :error
      warning-inhibit-types '((files missing-lexbind-cookie))
      read-process-output-max (* 1024 1024))

(unless (fboundp 'igc-info)
  (setq gc-cons-percentage 1.0
        gc-cons-threshold  most-positive-fixnum))

(put 'if-let 'byte-obsolete-info nil)
(put 'when-let 'byte-obsolete-info nil)

(setenv "LSP_USE_PLISTS" "true")
;; (setenv "HOME" (getenv "USERPROFILE"))

(let (realhome)
  (when (and (memq system-type '(cygwin windows-nt ms-dos))
             (null (getenv-internal "HOME"))
             (setq realhome (getenv "USERPROFILE")))
    (setenv "HOME" realhome)
    (setq abbreviated-home-dir nil)))

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

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
(advice-add #'display-startup-echo-area-message :override #'ignore)
;; Fully suppress vanilla startup screen
(advice-add #'display-startup-screen :override #'ignore)

(defun set-font ()
  (progn
    (set-face-attribute 'default        nil :family "Iosevka Term SS07" :height 135)
    (set-face-attribute 'fixed-pitch    nil :family "Iosevka Term SS07")
    (set-face-attribute 'variable-pitch nil :family "IBM Plex Serif")
    (set-fontset-font
     t
     'symbol
     (cond
      ((eq system-type 'windows-nt) "Segoe UI Symbol")
      ((eq system-type 'darwin)     "Apple Symbols")
      ((eq system-type 'gnu/linux)  "Symbola")))
    (set-fontset-font
     t
     'emoji
     (cond
      ((eq system-type 'windows-nt) "Segoe UI Emoji")
      ((eq system-type 'darwin)     "Apple Color Emoji")
      ((eq system-type 'gnu/linux)  "Noto Color Emoji")))))

(if (daemonp)
    (add-hook 'server-after-make-frame-hook #'set-font)
  (set-font))

(add-to-list 'default-frame-alist '(alpha-background . 85))
