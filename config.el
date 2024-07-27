;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(setq user-full-name "Daniel Xu"
      user-mail-address "danielxu0307@proton.me")

;; When I bring up Doom's scratch buffer with SPC x, it's often to play with
;; elisp or note something down (that isn't worth an entry in my notes). I can
;; do both in `lisp-interaction-mode'.
(setq doom-scratch-initial-major-mode 'lisp-interaction-mode)

;; macos stuff
;; Use Option as Super
(setq mac-option-modifier 'super)
;; Use Command as Meta
(setq mac-command-modifier 'meta)
;; create a new frame when closing emacs
(mac-pseudo-daemon-mode 1)

;; Implicit /g flag on evil ex substitution, because I use the default behavior
;; less often.
(setq evil-ex-substitute-global t)

;; supress warnings, not errors
(setq warning-suppress-types '((bytecomp)))

;; let emacs use the gpg ssh socket
(setenv "SSH_AUTH_SOCK" (concat (getenv "HOME") "/.gnupg/S.gpg-agent.ssh"))

(setq doom-font (font-spec :family "Berkeley Mono" :size 13)
      doom-variable-pitch-font (font-spec :family "Inter" :size 13)
      doom-symbol-font (font-spec :family "Symbols Nerd Font" :size 13)
      doom-theme 'doom-vibrant)

;; Prevents some cases of Emacs flickering.
(add-to-list 'default-frame-alist '(inhibit-double-buffering . t))

;;; :tools magit
(setq magit-repository-directories '(("~/code" . 2))
      magit-save-repository-buffers nil
      ;; Don't restore the wconf after quitting magit, it's jarring
      magit-inhibit-save-previous-winconf t
      evil-collection-magit-want-horizontal-movement t
      magit-openpgp-default-signing-key "7062369036F842822CA109C2660DBDE129F4E1D9"
      transient-values '((magit-rebase "--autosquash" "--autostash")
                         (magit-pull "--rebase" "--autostash")
                         (magit-revert "--autostash")))

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


(setq display-line-numbers-type 'relative)

(setq fancy-splash-image (file-name-concat doom-user-dir "splash.png"))
;; Hide the menu for as minimalistic a startup screen as possible.
(setq +doom-dashboard-functions '(doom-dashboard-widget-banner))

;;
;;;; Org mode tweaks
(setq org-directory "~/org/")
(setq org-agenda-files (directory-files-recursively "~/org" "\\.org$"))


(after! org
  (setq org-startup-folded 'show2levels
        org-ellipsis " [...] "
        org-capture-templates
        '(("t" "todo" entry (file+headline "todo.org" "Inbox")
           "* [ ] %?\n%i\n%a"
           :prepend t)
          ("d" "deadline" entry (file+headline "todo.org" "Inbox")
           "* [ ] %?\nDEADLINE: <%(org-read-date)>\n\n%i\n%a"
           :prepend t)
          ("s" "schedule" entry (file+headline "todo.org" "Inbox")
           "* [ ] %?\nSCHEDULED: <%(org-read-date)>\n\n%i\n%a"
           :prepend t)
          ("c" "check out later" entry (file+headline "todo.org" "Check out later")
           "* [ ] %?\n%i\n%a"
           :prepend t)
          ("l" "ledger" plain (file "ledger/personal.gpg")
           "%(+beancount/clone-transaction)"))))
