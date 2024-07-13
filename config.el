;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(setq user-full-name "Daniel Xu"
      user-mail-address "danielxu0307@gmail.com")

;; When I bring up Doom's scratch buffer with SPC x, it's often to play with
;; elisp or note something down (that isn't worth an entry in my notes). I can
;; do both in `lisp-interaction-mode'.
(setq doom-scratch-initial-major-mode 'lisp-interaction-mode)

;; supress warnings, not errors
(setq warning-suppress-types '((bytecomp)))

;; let emacs use the gpg ssh socket
(setenv "SSH_AUTH_SOCK" (concat (getenv "HOME") "/.gnupg/S.gpg-agent.ssh"))

(setq doom-font (font-spec :family "SF Mono" :size 13)
      doom-variable-pitch-font (font-spec :family "Atkinson Hyperlegible" :size 13)
      doom-symbol-font (font-spec :family "Symbols Nerd Font" :size 13)
      doom-theme 'doom-vibrant)

;; Prevents some cases of Emacs flickering.
(add-to-list 'default-frame-alist '(inhibit-double-buffering . t))

(after! corfu
  (setq corfu-auto nil))

(setq doom-modeline-modal nil)
(use-package minions
  :after doom-modeline
  :config
  (setq doom-modeline-minor-modes t)
  (minions-mode 1))

(setq evil-split-window-below t
      evil-vsplit-window-right t)

;; Disable invasive lsp-mode features
(after! lsp-mode
  (setq lsp-enable-symbol-highlighting nil
        ;; If an LSP server isn't present when I start a prog-mode buffer, you
        ;; don't need to tell me. I know. On some machines I don't care to have
        ;; a whole development environment for some ecosystems.
        lsp-enable-suggest-server-download nil))
(after! lsp-ui
  (setq lsp-ui-sideline-enable nil  ; no more useful than flycheck
        lsp-ui-doc-enable nil))     ; redundant with K

(use-package vterm
  :config
  (setq vterm-shell (or (getenv "SHELL") shell-file-name "/bin/bash")))


(setq display-line-numbers-type 'relative)

(setq fancy-splash-image (file-name-concat doom-user-dir "splash.png"))
;; Hide the menu for as minimalistic a startup screen as possible.
(setq +doom-dashboard-functions '(doom-dashboard-widget-banner))


(after! mu4e
  (setq sendmail-program (executable-find "msmtp")
        send-mail-function #'smtpmail-send-it
        message-sendmail-f-is-evil t
        message-sendmail-extra-arguments '("--read-envelope-from")
        message-send-mail-function #'message-send-mail-with-sendmail))

(setq +mu4e-gmail-accounts '(("danielxu0307@gmail.com" . "/gmail")))


(setq +mu4e-backend nil)
(after! mu4e
  (setq mu4e-get-mail-command (concat (executable-find "mbsync") " -a")
        mu4e-update-interval 300))

;;
;;;; Org mode tweaks
(setq org-directory "~/org/")
(setq org-agenda-files (directory-files-recursively "~/org" "\\.org$"))

;; turn off line numbers in org mode
(defun my/disable-line-numbers ()
  (display-line-numbers-mode -1))
(add-hook 'org-mode-hook #'my/disable-line-numbers)

;; make org look a little nicer by making it use my variable-pitch font and
;; changing some font sizes
(after! org
  (setq org-hide-emphasis-markers t)
  (custom-set-faces!
    '(org-document-title :height 1.2)
    '(outline-1 :weight extra-bold :height 1.25)
    '(outline-2 :weight bold :height 1.15)
    '(outline-3 :weight bold :height 1.12)
    '(outline-4 :weight semi-bold :height 1.09)
    '(outline-5 :weight semi-bold :height 1.06)
    '(outline-6 :weight semi-bold :height 1.03)
    '(outline-8 :weight semi-bold)
    '(outline-9 :weight semi-bold))
  (setq org-agenda-deadline-faces
        '((1.001 . error)
          (1.0 . org-warning)
          (0.5 . org-upcoming-deadline)
          (0.0 . org-upcoming-distant-deadline)))
  (setq org-ellipsis " ▾ "
        org-hide-leading-stars t
        org-priority-highest ?A
        org-priority-lowest ?E
        org-priority-faces
        '((?A . 'nerd-icons-red)
          (?B . 'nerd-icons-orange)
          (?C . 'nerd-icons-yellow)
          (?D . 'nerd-icons-green)
          (?E . 'nerd-icons-blue)))
  (setq org-src-fontify-natively t)
  (setq org-fontify-quote-and-verse-blocks t)
  (defun locally-defer-font-lock ()
    "Set jit-lock defer and stealth, when buffer is over a certain size."
    (when (> (buffer-size) 50000)
      (setq-local jit-lock-defer-time 0.05
                  jit-lock-stealth-time 1)))
  (add-hook 'org-mode-hook #'locally-defer-font-lock)
  (setq doom-themes-org-fontify-special-tags nil)
  (add-hook 'org-mode-hook 'visual-line-mode))

(use-package! mixed-pitch
  :hook (org-mode . mixed-pitch-mode)
  :config
  (setq mixed-pitch-set-height t)
  (set-face-attribute 'variable-pitch nil :height 1.2))

(defun greedily-do-daemon-setup ()
  (require 'org)
  (when (require 'mu4e nil t)
    (setq mu4e-confirm-quit t)
    (setq +mu4e-lock-greedy t)
    (setq +mu4e-lock-relaxed t)
    (when (+mu4e-lock-available t)
      (mu4e--start)))
  (when (require 'elfeed nil t)
    (run-at-time nil (* 8 60 60) #'elfeed-update)))

(when (daemonp)
  (add-hook 'emacs-startup-hook #'greedily-do-daemon-setup)
  (add-hook! 'server-after-make-frame-hook
    (unless (string-match-p "\\*draft\\|\\*stdin\\|emacs-everywhere" (buffer-name))
      (switch-to-buffer +doom-dashboard-name))))

(add-hook 'server-after-make-frame-hook (lambda () (select-frame-set-input-focus (selected-frame))))
