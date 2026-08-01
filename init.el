; Initialisation -*- lexical-binding: t -*-

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

;; (if (eq system-type 'windows-nt)
;;     (when (member "Noto Emoji" (font-family-list))
;;       (set-fontset-font t
;;                         'emoji
;;                         (font-spec :family "Noto Emoji" :size 18)))
;;   (when (member "Noto Color Emoji" (font-family-list))
;;     (set-fontset-font t
;;                       'emoji
;;                       (font-spec :family "Noto Color Emoji" :size 18))))

;; === BEGIN ELPACA LOADER ===

(defvar elpaca-installer-version 0.12)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-sources-directory (expand-file-name "sources/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1 :inherit ignore
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca-activate)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-sources-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (<= emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let* ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                  ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                  ,@(when-let* ((depth (plist-get order :depth)))
                                                      (list (format "--depth=%d" depth) "--no-single-branch"))
                                                  ,(plist-get order :repo) ,repo))))
                  ((zerop (call-process "git" nil buffer t "checkout"
                                        (or (plist-get order :ref) "--"))))
                  (emacs (concat invocation-directory invocation-name))
                  ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                        "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                  ((require 'elpaca))
                  ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (let ((load-source-file-function nil)) (load "./elpaca-autoloads"))))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

;; Install use-package support
(elpaca elpaca-use-package
  (setq use-package-always-ensure t)
  ;; Enable use-package :ensure support for Elpaca.
  (elpaca-use-package-mode))

;; === END ELPACA LOADER ===

;; === CORE ===

(use-package gcmh
  :demand t
  :ensure ( :wait t)
  ;; Don't use this hack if the new IGC garbage collector is being used
  :unless (fboundp 'igc-info)
  :custom
  (gcmh-idle-delay 'auto)
  (gcmh-auto-idle-delay-factor 10)
  (gcmh-high-cons-threshold (* 64 1024 1024)) ; 64 MiB
  :config (gcmh-mode 1))

;; (use-package compat :demand t) ; To resolve versioning issues

(use-package doom-themes
  :demand t
  :custom
  (doom-themes-enable-bold   t)
  (doom-themes-enable-italic t)
  :config (load-theme 'doom-molokai t))

(use-package mood-line
  :demand t
  :custom (mood-line-glyph-alist mood-line-glyphs-unicode)
  :config (mood-line-mode))

(use-package emacs
  :ensure nil
  :hook (prog-mode . (lambda ()
                       (display-line-numbers-mode)
                       (hl-line-mode)
                       (electric-pair-mode)))
  :custom
  ;; backup files config
  (backup-by-copying              t) ; don't clobber symlinks
  (backup-directory-alist         `(("." . ,(file-name-concat
                                             (getenv "HOME")
                                             ".emacs-saves/")))) ; don't litter my fs tree
  (delete-old-versions            t)
  (kept-new-versions              6)
  (kept-old-versions              2)
  (version-control                t) ; use versioned backups
  (create-lockfiles               nil)
  ;; Autosave files config
  (auto-save-file-name-transforms `((".*" ,temporary-file-directory t)))
  :bind (("C-+"             . text-scale-increase)
         ("C--"             . text-scale-decrease)
         ("C-<wheel-up>"    . text-scale-increase)
         ("C-<wheel-down>"  . text-scale-decrease)
         ("C-<tab>"         . tab-line-switch-to-next-tab)
         ("C-<iso-lefttab>" . tab-line-switch-to-prev-tab)
         ("C-S-<tab>"       . tab-line-switch-to-prev-tab))
  :config
  (add-to-list 'auto-mode-alist '("\\.cabal\\'" . prog-mode))
  (global-auto-revert-mode)
  (global-tab-line-mode)
  (window-divider-mode))

(elpaca-wait)

;; === MINIBUFFER PACKAGES ===

(use-package vertico
  :demand t
  :config (vertico-mode 1)
  :bind ( :map vertico-map
          ("M-j" . vertico-next)
          ("M-k" . vertico-previous)))

(use-package marginalia :demand t :config (marginalia-mode 1))

(use-package orderless :demand t :config (setq completion-styles '(orderless basic)))

(use-package consult :demand t :config (setq completion-in-region-function 'consult-completion-in-region))

;; === EDITOR FUNCTIONALITY ===

(use-package treesit-auto
  :demand t
  :custom (treesit-auto-install 'p)
  :init (setq treesit-font-lock-level 4)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

(use-package multiple-cursors)

(use-package avy)

(defun qak/join-line-forward () (interactive) (join-line 1))

(defvar-keymap qak/window-map
  :doc "Window Manipulation"
  "h" #'windmove-left
  "j" #'windmove-down
  "k" #'windmove-up
  "l" #'windmove-right
  "v" #'split-window-right
  "s" #'split-window-below
  "=" #'balance-windows
  "x" #'delete-window
  "q" #'kill-buffer-and-window)

(defvar-keymap qak/misc-map
  :doc "Miscellaneous"
  "s" #'save-buffer
  "f" #'find-file
  "q" #'save-buffers-kill-emacs)

;; Because `comment-dwim' does not in fact do what I mean :p
(defun qak/comment-line-or-region ()
  (interactive)
  (if (use-region-p)
      (comment-or-uncomment-region (region-beginning) (region-end))
    (comment-line 1)))

(use-package helix
  :demand t
  :config
  (helix-mode)
  (helix-define-key 'normal "J" #'qak/join-line-forward)
  (helix-define-key 'space  "c" #'qak/comment-line-or-region)
  (helix-define-key 'space  "w"   qak/window-map)
  (helix-define-key 'space  "m"   qak/misc-map))


(use-package which-key
  :custom
  (which-key-idle-delay             0.05)
  (which-key-add-column-padding     0)
  (which-key-show-docstrings        t)
  (which-key-max-description-length 60)
  :config (which-key-mode 1))

(use-package combobulate
  :ensure (combobulate :host github :repo "mickeynp/combobulate")
  :after helix
  :hook (prog-mode . combobulate-mode)
  :config
  (helix-define-key 'normal (kbd "C-M-u") #'combobulate-navigate-up)
  (helix-define-key 'normal (kbd "C-M-d") #'combobulate-navigate-down))

(use-package ligature
  :config
  (ligature-set-ligatures
   'prog-mode
   '("|||>" "<|||" "<==>" "<!--" "####" "~~>" "***" "||=" "||>"
     ":::" "::=" "=:=" "===" "==>" "=!=" "=>>" "=<<" "=/=" "!=="
     "!!." ">=>" ">>=" ">>>" ">>-" ">->" "->>" "-->" "---" "-<<"
     "<~~" "<~>" "<*>" "<||" "<|>" "<$>" "<==" "<=>" "<=<" "<->"
     "<--" "<-<" "<<=" "<<-" "<<<" "<+>" "</>" "###" "#_(" "..<"
     "..." "+++" "/==" "///" "_|_" "www" "&&" "^=" "~~" "~@" "~="
     "~>" "~-" "**" "*>" "*/" "||" "|}" "|]" "|=" "|>" "|-" "{|"
     "[|" "]#" "::" ":=" ":>" ":<" "$>" "==" "=>" "!=" "!!" ">:"
     ">=" ">>" ">-" "-~" "-|" "->" "--" "-<" "<~" "<*" "<|" "<:"
     "<$" "<=" "<>" "<-" "<<" "<+" "</" "#{" "#[" "#:" "#=" "#!"
     "##" "#(" "#?" "#_" "%%" ".=" ".-" ".." ".?" "+>" "++" "?:"
     "?=" "?." "??" ";;" "/*" "/=" "/>" "//" "__" "~~" "(*" "*)"
     "\\\\" "://"))
  (global-ligature-mode t))

;; === PROJECT MANAGEMENT ===

;; `:ensure nil' => built-in package
(use-package project
  :ensure nil
  :after helix
  :demand t
  :config (helix-define-key 'space (kbd "p") project-prefix-map))

;; === LANGUAGE SUPPORT ===

(defun qak/nix-avail-p ()
  "Return whether the nix package manager is available"
  (and
   (or (eq system-type 'gnu/linux)
       (eq system-type 'darwin))
   (executable-find "nix")))

(use-package inheritenv
  :if (qak/nix-avail-p)
  :demand t)

(use-package envrc
  :if (qak/nix-avail-p)
  :demand t
  :after helix
  :hook (elpaca-after-init . envrc-global-mode)
  :config (helix-define-key 'space "e" envrc-command-map))

;; Vastly simplified from doomemacs' `+lsp-optimization-mode' code
(defvar qak/lsp-gc-optimised-p nil)

(use-package lsp-mode
  :after helix
  :custom
  (lsp-completion-provider     :none)
  (lsp-keymap-prefix           "C-c l")
  (lsp-signature-auto-activate nil)
  (lsp-ui-doc-delay            0.075)
  (lsp-ui-doc-show-with-cursor t)
  (lsp-ui-doc-show-with-mouse  t)
  :hook
  (lsp-mode . lsp-enable-which-key-integration)
  (lsp-mode . lsp-inlay-hints-mode)
  :config
  ;; Bump up garbage collection threshold through `gcmh' to prevent LSP-induced
  ;; allocations from slowing down/freezing the UI.
  (unless (or qak/lsp-gc-optimised-p (fboundp 'igc-info))
    (setq-default gcmh-high-cons-threshold
                  (* 2 (default-value 'gcmh-high-cons-threshold)))
    (gcmh-set-high-threshold)
    (setq qak/lsp-gc-optimised-p t))
  
  (helix-define-key 'space  "a"   #'lsp-execute-code-action)
  (helix-define-key 'space  "r"   #'lsp-rename)
  (helix-define-key 'normal "g d" #'lsp-find-definition)
  (helix-define-key 'normal "g i" #'lsp-find-implementation)
  (helix-define-key 'normal "g r" #'lsp-find-references)
  (helix-define-key 'normal "g y" #'lsp-find-type-definition))

(use-package lsp-ui)

(use-package lsp-rust
  :ensure nil
  :after lsp-mode
  :custom
  (lsp-rust-analyzer-display-chaining-hints                t)
  (lsp-rust-analyzer-display-reborrow-hints                t)
  (lsp-rust-analyzer-display-parameter-hints               t)
  (lsp-rust-analyzer-display-closure-return-type-hints     t)
  (lsp-rust-analyzer-display-lifetime-elision-hints-enable t))

(use-package consult-lsp
  :after helix
  :config
  (helix-define-key 'space "d" #'consult-lsp-file-diagnostics)
  (helix-define-key 'space "D" #'consult-lsp-diagnostics)
  (helix-define-key 'space "s" #'consult-lsp-file-symbols)
  (helix-define-key 'space "D" #'consult-lsp-symbols))

(use-package flymake
  :ensure nil
  :config )

(use-package yasnippet :config (yas-global-mode 1))

(use-package corfu
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.075)
  (corfu-auto-prefix 2)
  (corfu-cycle t)
  :bind ( :map corfu-map
          ("M-j"   . corfu-next)
          ("M-k"   . corfu-previous)
          ("<tab>" . corfu-complete))
  :init (global-corfu-mode))

(use-package kind-icon
  :after corfu
  :config (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

(use-package markdown-mode
  :custom-face (markdown-code-face ((t :inherit fixed-pitch))))

(use-package rust-ts-mode
  :ensure nil
  :hook
  (rust-ts-mode . lsp-deferred)
  (rust-ts-mode . (lambda ()
                    (remove-hook 'flymake-diagnostic-functions #'rust-ts-flymake t))))

;; TODO: When emacs 31 comes around this will be built-in
(use-package markdown-ts-mode :mode ("\\.md\\'" . markdown-ts-mode))

(use-package mixed-pitch
  :hook
  (text-mode . mixed-pitch-mode)
  (markdown-ts-mode . mixed-pitch-mode))

;; Credit to: https://www.reddit.com/r/emacs/comments/1bgdw0y/comment/kv6q2vl
(defun qak/c-ts-indent-style()
  `(;; do not indent preprocessor statements
    ((node-is "preproc") column-0 0)
    ;; do not indent namespace children
    ((n-p-gp nil nil "namespace_definition") grand-parent 0)
    ;; append to linux style
    ,@(alist-get 'linux (c-ts-mode--indent-styles 'cpp))))

(use-package c-ts-mode
  :ensure nil
  :hook
  (c-ts-mode   . lsp-deferred)
  (c++-ts-mode . lsp-deferred)
  :custom
  (c-ts-mode-indent-offset  4)
  (c-ts-mode-indent-style #'qak/c-ts-indent-style))

(add-hook 'js-ts-mode-hook         #'lsp-deferred)
(add-hook 'typescript-ts-mode-hook #'lsp-deferred)

(use-package nix-ts-mode
  :if (qak/nix-avail-p)
  :mode "\\.nix\\'"
  :hook (nix-ts-mode . lsp-deferred))

(add-hook 'toml-ts-mode-hook #'lsp-deferred)

(use-package meson-mode :hook (meson-mode . lsp-deferred))
(use-package llvm-ts-mode :mode "\\.ll\\'")

(use-package astro-ts-mode
  :custom (astro-ts-mode-indent-offset 4)
  :hook
  (astro-ts-mode . lsp-deferred)
  (astro-ts-mode . (lambda () (mixed-pitch-mode -1))))

(use-package neocaml
  :hook
  (neocaml-mode . lsp-deferred)
  (neocaml-mode . prettify-symbols-mode))

(use-package haskell-ts-mode
  :mode "\\.hs\\'"
  :after helix
  :hook
  (haskell-ts-mode . lsp-deferred)
  (haskell-ts-mode . prettify-symbols-mode))

(use-package zig-ts-mode
  :mode "\\.\\(zig\\|zon\\)\\'"
  :hook (zig-ts-mode . lsp-deferred))

(use-package hl-todo)

(use-package consult-todo
  :after helix
  :config
  (helix-define-key 'space "t" #'consult-todo)
  (helix-define-key 'space "T" #'consult-todo-project))

;; === EXTRA ===

(use-package transient) ; To resolve versioning issues

(use-package magit :after helix :config (helix-define-key 'space "g" #'magit))
