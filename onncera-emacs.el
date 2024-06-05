;; -*- lexical-binding: t; -*-

(require 'package)
(setq package-archives '(
			("melpa"  . "https://melpa.org/packages/"    )
			("elpa"   . "https://elpa.gnu.org/packages/" )
			("nongnu" . "https://elpa.nongnu.org/nongnu/")
			)
)

(unless
	(bound-and-true-p package--initialized)
		(setq package-enable-at-startup nil)
		(package-initialize)
)

(unless (package-installed-p 'use-package) (package-refresh-contents) (package-install 'use-package))
(eval-when-compile (require 'use-package))

(use-package eldoc-box  ;; displays eldoc documentations in a childframe
:ensure t
:hook (eldoc-mode . eldoc-box-hover-mode)
:init (global-eldoc-mode 1) (setq eldoc-idle-delay 0.1)  ;; eldoc is a minor mode... provides documentation for functions, variables, & arguments in the minibuffer as you type
)


(add-hook 'window-setup-hook 'toggle-frame-fullscreen t)  ;; emacs eyes only!
(setq inhibit-splash-screen t)  ;; disables emacs's welcome page


(setq tab-always-indent         'complete)  ;; support indentation + completion using TAB key. `completion-at-point' normally bound to M-TAB
(setq display-line-numbers-type 'relative)  ;; enabling relative line numbers
(global-display-line-numbers-mode 1)        ;; enabling line numbers
(electric-pair-mode               1)        ;; enabling automatic parens pairing

(menu-bar-mode -1)                          ;; disable menu bar
(tool-bar-mode -1)                          ;; disable tool bar

(setq-default truncate-lines   t)           ;; enabling truncated lines
(setq mac-command-key-is-meta  t)
(setq mac-command-modifier 'meta)

(global-hl-line-mode 1)

(setq backup-directory-alist `(("." . ,(expand-file-name "~/.emacs-backups" user-emacs-directory))))  ;; set the directory for backup files
(setq auto-save-default nil auto-save-list-file-prefix nil)  ;; disable auto-saving, ensuring that emacs does not create the auto-save directory
(setq backup-by-copying   t)  ;; create backups by copying files, which avoids issues with hard links

;; create the backup directory if it does not exist
(unless (file-exists-p  "~/.emacs-backups"  )
	(make-directory "~/.emacs-backups" t)
)

(setq kept-new-versions   5)   ;; number of newest versions to keep
(setq kept-old-versions   5)   ;; number of oldest versions to keep
(setq delete-old-versions t)   ;; delete excess backup versions


(setq enable-recursive-minibuffers t)  ;; support opening new minibuffers from inside existing minibuffers
(setq delete-by-moving-to-trash    t)  ;; extra layer of precaution against deleting wanted files
(setq org-src-preserve-indentation t)  ;; disable automatic indentation in source code blocks

(setq read-extended-command-predicate #'command-completion-default-include-p)  ;; Hide commands in M-x which do not work in the current mode
(setq undo-limit 10000000)  ;; emacs remembers up to 10000000 undo actions for each BUFFER

(setq version-control t)    ;; use version numbers for backups

(defun onncera-post-loading ()
	(blink-cursor-mode -1) (fringe-mode -1) (scroll-bar-mode -1) (global-hl-line-mode 1) (set-face-underline 'hl-line nil) (split-window-horizontally)
	(set-background-color "#161616") (set-foreground-color "burlywood3") (set-cursor-color "#40FF40") (set-face-background hl-line-face "midnight blue")
)
(add-hook 'window-setup-hook 'onncera-post-loading t)
(add-hook 'after-init-hook (lambda ()
				(load-theme 'modus-vivendi-tritanopia t)
			   )
)

;; completion style that divides the pattern into space-separated
;; components, &  matches candidates that match all of the components in any order (provides better filtering methods)
(use-package orderless
	:ensure t
	:init
	(setq completion-styles '(orderless basic)  ;; `basic' completion style is specified as fallback in addition to `orderless'
	      completion-category-defaults nil      ;; serves as a default value for `completion-category-overrides'
	      completion-category-overrides '((file (styles basic partial-completion)))  ;; `partial-completion' style lets you use wildcards for file completion & partial paths, e.g., /u/s/l for /usr/share/local
	)
)


(use-package embark-consult :ensure t :hook (embark-collect-mode . consult-preview-at-point-mode))  ;; `embark-consult' package is glue code to tie together `embark' and `consult'.
;; makes it easy to choose a command to run based on what is near point, both during a
;; minibuffer completion session and in normal buffers
(use-package embark
	:ensure t
	:bind
		(
		("C-." . embark-act )  ;; essentially acts as a keyboard-based version of a right-click contextual menu
		("C-;" . embark-dwim)  ;; alternative == `M-.'
		)
	:init (setq prefix-help-command #'embark-prefix-help-command)  ;; change the key help with a completing-read interface... now, when you start on a prefix sequence such as `C-x', pressing `C-h' will up the
	                                                               ;; embark version of the built-in `prefix-help-command', which will list the keys under that prefix & their bindings, and lets you select the
                                                               	       ;; one you wanted with completion or by key binding if you press `embark-keymap-prompter-key', which is @ by default
)


;; provides search and navigation commands based on the emacs completion function
(use-package consult
	:ensure t
	:bind (
	("C-x b"   . consult-buffer     )  ;; orig. switch-to-buffer
	("M-g g"   . consult-goto-line  )  ;; orig. goto-line
	("M-g M-g" . consult-goto-line  )  ;; orig. goto-line
	("M-g o"   . consult-outline    )  ;; alternative: consult-org-heading
	("M-g m"   . consult-mark       )
	("M-g k"   . consult-global-mark)
	("M-g i"   . consult-imenu      )
	("M-g I"   . consult-imenu-multi)
	("M-s d"   . consult-find       )  ;; alternative: consult-fd
	("M-s c"   . consult-locate     )
	("M-s g"   . consult-grep       )
	("M-s r"   . consult-ripgrep    )
	("M-s l"   . consult-line       )

	:map isearch-mode-map
	("M-s l"   . consult-line       )  ;; needed by consult-line to detect isearch
	("M-s L"   . consult-line-multi )  ;; needed by consult-line to detect isearch

	)

	;; automatic live preview at point in the *Completions* BUFFER... especially good when you use default completion UI
	:hook (completion-list-mode . consult-preview-at-point-mode)

	:init
	(setq register-preview-delay 0)
	(setq register-preview-function #'consult-register-format)

	:config
	(setq consult-narrow-key "<") ;; configure the narrowing key... both "<" and "C-+" work reasonably well
)


;; annotations or marks placed at the margin of the page of a book or in this case helpful colorful
;; annotations placed at the margin of the minibuffer for your completion candidates
(use-package marginalia
	:ensure t
	:bind   (:map minibuffer-local-map ("M-A" . marginalia-cycle))  ;; allows you to cycle through different annotation styles provided
	:custom (marginalia-align 'right)
	:init
	;; marginalia must be activated in the :init section of use-package such that the
	;; mode gets enabled right away. Note that this forces loading the package
	(marginalia-mode 1)
)


;; provides a performant and minimalistic vertical completion
(use-package vertico
	:ensure t
	:init
		(setq vertico-cycle t)
		(vertico-mode 1)
)


;; allows you to edit a grep buffer and apply those changes to the file buffer like sed interactively
;; allows you to edit the results of a grep search while inside a `grep-mode' buffer
;; all we nned is to toggle the editable mode, make the changes, and then type C-c C-c to confirm or C-c C-k to abort.
;;
;; Further reading: https://protesilaos.com/emacs/dotemacs#h:9a3581df-ab18-4266-815e-2edd7f7e4852
(use-package wgrep
	:ensure t
	:bind (
		:map grep-mode-map
		("e"       . wgrep-change-to-wgrep-mode)
		("C-x C-q" . wgrep-change-to-wgrep-mode)
		("C-c C-c" . wgrep-finish-edit)
	      )
)

(use-package company
	:ensure t
	:config
;;	(add-hook 'after-init-hook 'global-company-mode)

	(define-key company-active-map (kbd "<tab>") 'company-complete-selection)
	(define-key company-active-map (kbd "C-n"  ) 'company-select-next)
	(define-key company-active-map (kbd "C-p"  ) 'company-select-previous)

	(setq company-minimum-prefix-length 1)
	(setq company-idle-delay 0)

	(setq company-tooltip-minimum-width 100)
	(setq company-tooltip-maximum-width 120)

	;; minimum spacing between a candidate and annotation ~ aligns annotations to the right side of the tooltip
	(setq company-tooltip-annotation-padding 3) (setq company-tooltip-align-annotations t)

	:init
	(global-company-mode 1)
)

;; IDE capabilities to various programming languages
(use-package lsp-mode :ensure t :hook (c-mode c++-mode objc-mode java-mode python-ts-mode) :init (setq lsp-keymap-prefix "C-c l")
	:config
	(setq lsp-diagnostics-provider :flycheck)
	(setq lsp-idle-delay 0.100)
	(setq read-process-output-max (* 1024 1024))
)

;; enhances LSP experience by offering a user-friendly interface with features like real-time error checking, code actions, and code lenses
(use-package lsp-ui :ensure t :hook (lsp-mode . lsp-ui-mode))

(setq treesit-extra-load-path '("~/.emacs.d/onncera-language-grammars"))  ;; additional directories to look for tree-sitter language definitions
(setq treesit-language-source-alist
	'(
		(bash   "https://github.com/tree-sitter/tree-sitter-bash"    )
		(c      "https://github.com/tree-sitter/tree-sitter-c"       )
		(cpp    "https://github.com/tree-sitter/tree-sitter-cpp"     )
		(css    "https://github.com/tree-sitter/tree-sitter-css"     )
		(csharp "https://github.com/tree-sitter/tree-sitter-c-sharp" )
		(go     "https://github.com/tree-sitter/tree-sitter-go"      )
		(html   "https://github.com/tree-sitter/tree-sitter-html"    )
		(java   "https://github.com/tree-sitter/tree-sitter-java"    )
		(python "https://github.com/tree-sitter/tree-sitter-python"  )
		(rust   "https://github.com/tree-sitter/tree-sitter-rust"    )
	 )
)

(add-to-list 'major-mode-remap-alist '(python-mode . python-ts-mode))
(use-package lsp-pyright
	:ensure t
	:hook (python-ts-mode . (lambda ()
					(require 'lsp-pyright)
					(lsp)
				)
	      )
)

;; simple global minor mode which will replicate the changes done by virtualenv activation inside emacs
(use-package pyvenv :ensure t)

(setq c-basic-offset 4)
(use-package ccls
	:ensure t
	:hook ((c-mode c++-mode objc-mode cuda-mode) . (lambda ()
							 (require 'ccls)
							 (lsp)
						       )
	      )
)

;; a replacement for the older Flymake extension which is part of GNU emacs
;; a modern (on-the-fly) syntax checking extension
(use-package flycheck :ensure t :config (add-hook 'after-init-hook #'global-flycheck-mode))

;; a modern & fast just-in-time spell checker
(use-package jinx :ensure t :hook (emacs-startup . global-jinx-mode))

(use-package undo-tree
	:ensure t
	:config
	(global-undo-tree-mode 1)
	(setq undo-tree-history-directory-alist '(
							("." . "~/.cache/emacs-undo")
						 )
	)
)

;; an interface to the version control system git... aspires to be a complete git porcelain
(use-package magit :ensure t :defer t)

;; DOOM EMACS
(use-package doom-themes
	:ensure t
	:config
	(setq doom-themes-enable-bold   t)    ;; if nil, bold    is universally disabled
	(setq doom-themes-enable-italic t)    ;; if nil, italics is universally disabled
;;	(load-theme 'doom-homage-white  t)
	(doom-themes-org-config)              ;; Corrects (and improves) org-mode's native fontification.
)


(use-package gruber-darker-theme :ensure t)
(use-package leuven-theme        :ensure t)
(use-package modus-themes        :ensure t)
(use-package moe-theme           :ensure t)

(set-face-italic 'font-lock-comment-face nil)
(set-face-bold-p 'bold                   nil)

;; modeline
(use-package doom-modeline :ensure t :init (setq doom-modeline-height 30) (doom-modeline-mode 1))

;; rainbow delimiters:
;; 	color delimiters such as parentheses, brackets or braces according to their depth
;;		each successive level is highlighted in a different color for easy spot matching of delimiters
(use-package rainbow-delimiters :ensure t :hook (prog-mode . rainbow-delimiters-mode))

(use-package org-bullets :ensure t)
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))
