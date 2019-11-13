;; Set basic details
(setq user-full-name "Udit Mukherjee")
(setq user-mail-address "uditmukherjee457@gmail.com")

;; There are plenty of things installed outside of the default PATH. This allows me to establish additional PATH information
(setenv "PATH" (concat "/usr/local/bin:/opt/local/bin:/usr/bin:/bin" (getenv "PATH")))
(setq exec-path (append exec-path '("/usr/local/bin")))
(require 'cl)

;; Added By Default
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (ace-jump-mode neotree doom-themes use-package yaml-mode writegood-mode web-mode solarized-theme smex rvm powerline paredit markdown-mode magit htmlize graphviz-dot-mode flycheck feature-mode f elpy cider autopair ac-slime))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; Default Package management
(load "package")
(package-initialize)
(add-to-list 'package-archives
             '("melpa-stable" . "https://stable.melpa.org/packages/") t)

;; Default package list
(defvar udit/packages '(ac-slime
                        auto-complete
                        autopair
                        cider
                        clojure-mode
                        elpy
                        f
                        feature-mode
                        flycheck
                        graphviz-dot-mode
                        htmlize
                        magit
                        markdown-mode
                        org
                        paredit
                        powerline
                        rvm
                        smex
                        solarized-theme
                        web-mode
                        writegood-mode
                        yaml-mode
                        py-autopep8
                        ace-jump-mode)
  "Default packages")

(defun udit/packages-installed-p ()
  (loop for pkg in udit/packages
        when (not (package-installed-p pkg)) do (return nil)
        finally (return t)))

(unless (udit/packages-installed-p)
  (message "%s" "Refreshing package database...")
  (package-refresh-contents)
  (dolist (pkg udit/packages)
    (when (not (package-installed-p pkg))
      (package-install pkg))))

;; Startup Options
(setq inhibit-splash-screen t
      initial-scratch-message nil
      initial-major-mode 'org-mode
      org-log-done 'time
      )
(scroll-bar-mode -1)
(tool-bar-mode -1)
(menu-bar-mode -1)
(display-time-mode 1)
(global-linum-mode t) ;; enable line numbers globally

(delete-selection-mode t) ;; Text marking and selection
(transient-mark-mode t)

(setq x-select-enable-clipboard t)
(setq-default indicate-empty-lines t) ;; Mark end of file
(when (not indicate-empty-lines)
  (toggle-indicate-empty-lines))

(setq make-backup-files nil) ;; Disable backup file
(setq backup-directory-alist `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms `((".*" ,temporary-file-directory t)))

(defalias 'yes-or-no-p 'y-or-n-p) ;; y or n answer

(setq tab-width 4
      indent-tabs-mode nil) ;; Disable tabs

(ido-mode t) ;; Enable ido mode
(setq ido-enable-flex-matching t
      ido-use-virtual-buffers t)
(setq column-number-mode t)

(require 'autopair)

(require 'auto-complete-config)
(ac-config-default)

(add-to-list 'initial-frame-alist '(fullscreen . maximized))
(add-to-list 'default-frame-alist '(fullscreen . fullheight))

(define-key global-map (kbd "M-`") 'other-frame) ;; switch between multiple monitors when multiple frames are opened
(define-key global-map (kbd "C-j") 'newline-and-indent)
(define-key global-map (kbd "RET") 'newline-and-indent)

(electric-pair-mode t)

(define-key global-map (kbd "C-a") 'back-to-indentation)

(global-set-key (kbd "M-n") (lambda () (interactive) (next-line) (call-interactively 'move-end-of-line)))
(global-set-key (kbd "M-p") (lambda () (interactive) (previous-line) (call-interactively 'move-end-of-line)))

(global-auto-revert-mode t)

;; Theme
(require 'doom-themes)

;; Global settings (defaults)
(setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
      doom-themes-enable-italic t) ; if nil, italics is universally disabled

(load-theme 'doom-city-lights t)

;; Enable flashing mode-line on errors
(doom-themes-visual-bell-config)

;; Enable custom neotree theme (all-the-icons must be installed!)
(doom-themes-neotree-config)

;; Corrects (and improves) org-mode's native fontification.
(doom-themes-org-config)

(require 'neotree)
(global-set-key [f8] 'neotree-toggle)


;; Indentation and Buffer cleanup
(defun untabify-buffer ()
  (interactive)
  (untabify (point-min) (point-max)))

(defun indent-buffer ()
  (interactive)
  (indent-region (point-min) (point-max)))

(defun cleanup-buffer ()
  "Perform a bunch of operations on the whitespace content of a buffer."
  (interactive)
  (indent-buffer)
  (untabify-buffer)
  (delete-trailing-whitespace))

(defun cleanup-region (beg end)
  "Remove tmux artifacts from region."
  (interactive "r")
  (dolist (re '("\\\\│\·*\n" "\W*│\·*"))
    (replace-regexp re "" nil beg end)))

(global-set-key (kbd "C-x M-t") 'cleanup-region)
(global-set-key (kbd "C-c n") 'cleanup-buffer)

(setq-default show-trailing-whitespace t)

;; Python Stuff
(package-initialize)
(elpy-enable)

(setq python-shell-interpreter "ipython"
      python-shell-interpreter-args "-i --simple-prompt")

(when (require 'flycheck nil t)
  (setq elpy-modules (delq 'elpy-module-flymake elpy-modules))
  (add-hook 'elpy-mode-hook 'flycheck-mode))


;; Other Plugins
(autoload
  'ace-jump-mode-pop-mark
  "ace-jump-mode"
  "Ace jump back:-)"
  t)
(eval-after-load "ace-jump-mode"
  '(ace-jump-mode-enable-mark-sync))
(define-key global-map (kbd "C-x SPC") 'ace-jump-mode-pop-mark)
(define-key global-map (kbd "C-c SPC") 'ace-jump-mode)

;; Select word the cursor is currently in
(defun mark-whole-word (&optional arg allow-extend)
  (interactive "P\np")
  (let ((num  (prefix-numeric-value arg)))
    (unless (eq last-command this-command)
      (if (natnump num)
          (skip-syntax-forward "\\s-")
        (skip-syntax-backward "\\s-")))
    (unless (or (eq last-command this-command)
                (if (natnump num)
                    (looking-at "\\b")
                  (looking-back "\\b")))
      (if (natnump num)
          (left-word)
        (right-word)))
    (mark-word arg allow-extend)))
(global-set-key [remap mark-word] 'mark-whole-word)
