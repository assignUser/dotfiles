;;; ...  -*- lexical-binding: t -*-
(add-to-list 'load-path (expand-file-name "init" user-emacs-directory))

;; bootstrap straight.el
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        (or (bound-and-true-p straight-base-dir)
            user-emacs-directory)))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; Install use-package using straight
(straight-use-package 'use-package)

(use-package benchmark-init
  :straight t
  :config
  ;; To disable collection of benchmark data after init is done.
  (add-hook 'after-init-hook 'benchmark-init/deactivate))

;;; General Behavior
(use-package emacs
  :straight '(:type built-in)
  :init
  (setq-default my-auto-save-dir (expand-file-name ".tmp/auto-saves/" user-emacs-directory))

  :custom
  ;; always use straight to install packages in use-package
  (straight-use-package-by-default t)
  (use-package-always-defer t) ;; default to :defer  t
  (inhibit-startup-screen t)
  (help-window-select t) ; always switch focus to new help window
  (ring-bell-function 'ignore)
  (global-auto-revert-mode 1) ;; Update clean buffers for files changed on disk. Dirty buffers will not be changed
  (auto-save-mode 1)
  (kill-buffer-delete-auto-save-files t)
  ;; Save into org files directly, this prevents losing clock data in auto-save files
  (auto-save-visited-predicate (lambda ()
                                 (eq major-mode 'org-mode)))
  (electric-pair-mode t)
  (create-lockfiles nil)
  ;; Use relative line numbers but only lines actually shown on the display will be counted,
  ;; better for vim movements
  (display-line-numbers-type 'visual)
  (scroll-margin 15) ; scroll-off
  (scroll-conservatively 1000) ; progressive-scrollign
  (recentf-mode t) ; keep track of recently visited files
  (dired-kill-when-opening-new-dired-buffer t)
  (winner-mode 1)
  (tab-width 4)
  :hook
  ((prog-mode . (lambda () (setq indent-tabs-mode nil)))
   (makefile-mode . (lambda () (setq indent-tabs-mode t)))
   (prog-mode . display-line-numbers-mode)
   (yaml-ts-mode . display-line-numbers-mode) ;; yaml-ts-mode derives from text-mode for some reason
   (toml-ts-mode . display-line-numbers-mode) ;; yaml-ts-mode derives from text-mode for some reason
   (conf-toml-mode . display-line-numbers-mode) ;; yaml-ts-mode derives from text-mode for some reason
   (prog-mode . (lambda () (hs-minor-mode t))) ;; Enable folding hide/show globally
   (prog-mode . subword-mode) ;; improved vim motions within camleCase
   (before-save . whitespace-cleanup)
   (org-mode . auto-save-visited-mode)
   )
  :config
  (blink-cursor-mode 0)              ; disable blinking cursor
  (set-fringe-mode 10)               ; give some breathing room
  (put 'dired-find-alternate-file 'disabled nil) ; 'a' opens file and kills dired buffer
  ;; create custom auto-save dir
  (if (not (file-exists-p my-auto-save-dir)) (make-directory  my-auto-save-dir t))
  ;; Use an extra file for custom variables to avoid polluting init.el
  (setq-default custom-file (expand-file-name ".custom.el" user-emacs-directory))
  (when (file-exists-p custom-file) ; Don’t forget to load it, we still need it
    (load custom-file))

  ;; Save backup files in a central dir, avoids clutter
  (setq backup-directory-alist `(("." . ,(expand-file-name ".tmp/backups/"
                                                           user-emacs-directory))))
  ;; Same for auto-save files
  (setq auto-save-file-name-transforms
        `((".*/\\([^/]+\\)"
           ,(concat my-auto-save-dir "\\1")
           t)))

  ;; Start with an empty scratch buffer
  (setq-default initial-scratch-message nil)
  (setq delete-by-moving-to-trash t)

  ;; Disable tabs
  (setq-default indent-tabs-mode nil)

  ;; allow y/n instead of yes/no
  (defalias 'yes-or-no-p 'y-or-n-p)

  ;; Set fallback for icon glyps, this is the font installed by nerd-icons
  (set-fontset-font t nil "Symbols Nerd Font Mono" nil 'append)

  (defvar jwj/default-font-size 120
    "Default font size in 1/10pt.")
  (defvar jwj/default-font-name "JetBrains Mono"
    "Default font.")

  (defun my/set-font ()
    (when (find-font (font-spec :name jwj/default-font-name))
      (set-face-attribute 'default nil
                          :font jwj/default-font-name
                          :height jwj/default-font-size)))
  (my/set-font)
  (add-hook 'server-after-make-frame-hook #'my/set-font)
  )

(use-package tab-bar
  :straight (:type built-in)
  :custom
  (tab-bar-show t)
  (tab-bar-tab-hints t)
  (tab-bar-select-tab-modifiers '(meta)))

;;; Base Plugins

(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :custom
  (which-key-sort-order #'which-key-key-order-alpha) ;; Same as default, except single characters are sorted alphabetically
  (which-key-sort-uppercase-first nil)
  (which-key-add-column-padding 1) ;; Number of spaces to add to the left of each column
  (which-key-min-display-lines 6)  ;; Increase the minimum lines to display because the default is only 1
  (which-key-idle-delay 0.8)       ;; Set the time delay (in seconds) for the which-key popup to appear
  (which-key-max-description-length 25))

(use-package general
  :init
  (general-auto-unbind-keys))

(require 'init-keys)

(use-package evil
  :demand t
  :after general
  :init
  (setq evil-want-integration t ; needed for evil-collection
        evil-want-keybinding nil; ^
        evil-want-C-u-scroll t)
  (require 'evil-vars)
  (evil-set-undo-system 'undo-tree)
  :config
  (general-define-key
   :keymaps 'evil-motion-state-map
   "SPC" nil
   "K" nil)
  (evil-mode 1)
  (setq evil-want-fine-undo t) ; more granular undo with evil
  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

;; More keybinds for evil-mode
(use-package evil-collection
  :demand t
  :after evil
  :hook
  (after-init . evil-collection-init))

(use-package undo-tree
  :custom
  (undo-tree-history-directory-alist
   `(("." . ,(expand-file-name (file-name-as-directory "undo-tree-hist")
                               user-emacs-directory))))
  :init
  (global-undo-tree-mode)
  :config
  (when (executable-find "zstd")
    (defun my/undo-tree-append-zst-to-filename (filename)
      "Append .zst to the FILENAME in order to compress it."
      (concat filename ".zst"))
    (advice-add 'undo-tree-make-history-save-file-name
                :filter-return
                #'my/undo-tree-append-zst-to-filename))
  (setq undo-tree-visualizer-diff       t
        undo-tree-auto-save-history     t
        undo-tree-enable-undo-in-region t
        undo-limit        (* 800 1024)
        undo-strong-limit (* 12 1024 1024)
        undo-outer-limit  (* 128 1024 1024)))

(use-package evil-commentary
  :hook
  (after-init . evil-commentary-mode))

(use-package pulse
  :demand t ;; can't auto-load on advice that is set in :config, could use :init but this is easier
  :after catppuccin-theme
  :custom
  (pulse-highlight-start-face ((t (:background (catppuccin-get-color 'sky)))))
  :config
  (defun my/pulse-advice (&optional beg end &rest _)
    "Pulse the provided region (BEG END) or the current line if no region is given."
    (if (and beg end (numberp beg) (numberp end))
        (pulse-momentary-highlight-region beg end)
      (pulse-momentary-highlight-one-line (point))))

  (advice-add 'evil-yank :after #'my/pulse-advice)
  (advice-add 'evil-yank-line :after #'my/pulse-advice)
  (advice-add 'evil-undo :after #'my/pulse-advice)
  (advice-add 'evil-redo :after #'my/pulse-advice))

(use-package vterm
  :init
;;;###autoload
  (defun my/get-vterm-buffer-name ()
    "Generate a vterm buffer name based on the current project.
If not in a directory fall back to 'default-directory'"
    (interactive)
    (let* ((project (project-current))
           (name (file-name-nondirectory (directory-file-name (if project
                                                                  (project-root project)
                                                                default-directory)))))
      (format "*vterm: %s*" name)))
;;;###autoload
  (defun my/open-vterm (arg)
    "Open a vterm buffer or switch to the existing one. Non-nil prefix arg force new buffer."
    (interactive "P")
    (require 'vterm)
    (let ((vterm-buffer-name (my/get-vterm-buffer-name)))
        (call-interactively #'vterm-other-window)))
;;;###autoload
  (defun my/open-vterm-here (arg)
    "Open a vterm buffer in the current window or switch to the existing one. Non-nil prefix arg force new buffer."
    (interactive "P")
    (require 'vterm)
    (let ((vterm-buffer-name (my/get-vterm-buffer-name)))
        (call-interactively #'vterm)))
  :custom
  ;; Avoid issues with non posix shell
  (shell-file-name (executable-find "bash"))
  ;; Still use fish in vterm
  (vterm-shell "/usr/bin/fish")
  (vterm-environment '("SSH_AUTH_SOCK=/home/jwj/.1password/agent.sock"))
  )

;; Aesthetics
(use-package catppuccin-theme
  :demand t
  :custom
  (catppuccin-flavor 'macchiato)
  (catppucin-italic-comments t)
  (catppucin-italic-variables t)
  :config
  (load-theme 'catppuccin :no-confirm))

(use-package ligature
  :straight (ligature :type git
                      :host github
                      :repo "mickeynp/ligature.el"
                      :build t)
  :hook
  (after-init . global-ligature-mode)
  :config
  (ligature-set-ligatures 't
                          '("www"))
  ;; Enable traditional ligature support, if the
  ;; `variable-pitch' face supports it
  (ligature-set-ligatures '(eww-mode org-mode)
                          '("ff" "fi" "ffi"))
  ;; Enable all Cascadia Code ligatures in programming modes
  (ligature-set-ligatures 'prog-mode
                          '("|||>" "<|||" "<==>" "<!--" "####" "~~>" "***" "||=" "||>"
                            ":::" "::=" "=:=" "===" "==>" "=!=" "=>>" "=<<" "=/=" "!=="
                            "!!." ">=>" ">>=" ">>>" ">>-" ">->" "->>" "-->" "---" "-<<"
                            "<~~" "<~>" "<*>" "<||" "<|>" "<$>" "<==" "<=>" "<=<" "<->"
                            "<--" "<-<" "<<=" "<<-" "<<<" "<+>" "</>" "###" "#_(" "..<"
                            "..." "+++" "/==" "///" "_|_" "www" "&&" "^=" "~~" "~@" "~="
                            "~>" "~-" "**" "*>" "*/" "||" "|}" "|]" "|=" "|>" "|-" "{|"
                            "[|" "]#" "::" ":=" ":>" ":<" "$>" "==" "=>" "!=" "!!" ">:"
                            ">=" ">>" ">-" "-~" "-|" "->" "--" "-<" "<~" "<*" "<|" "<:"
                            "<$" "<=" "<>" "<-" "<<" "<+" "</"  "%%" ".=" ".-" ".." ".?"
                            "+>" "++" "?:" "?=" "?." "??" "/*" "/=" "/>" "//" "__"
                            "~~" "(*" "*)" "\\\\" "://"))
  ;; I don't really like these: ";;" "#{" "#[" "#:" "#=" "#!" "##" "#(" "#?" "#_"
  )

(use-package git-gutter-fringe
  :hook ((prog-mode     . git-gutter-mode)
         (org-mode      . git-gutter-mode)
         (markdown-mode . git-gutter-mode)
         (latex-mode    . git-gutter-mode)))

(use-package doom-modeline
  :demand t
  :custom
  (doom-modeline-buffer-file-name-style 'relative-to-project)
  (doom-modeline-buffer-encoding nil)
  :init
  (doom-modeline-mode 1)
  (column-number-mode))

(use-package diminish)

;; Highlight 'real' buffers
(use-package solaire-mode
  :init (solaire-global-mode +1))

(use-package rainbow-delimiters
  :hook (emacs-lisp-mode . rainbow-delimiters-mode))

(use-package nerd-icons)
(use-package nerd-icons-completion
  :after marginalia
  :config
  (nerd-icons-completion-mode)
  (add-hook 'marginalia-mode-hook #'nerd-icons-completion-marginalia-setup))

(use-package nerd-icons-dired
  :hook (dired-mode . (lambda () (nerd-icons-dired-mode t))))

(use-package nerd-icons-ibuffer
  :hook (ibuffer-mode . nerd-icons-ibuffer-mode))

;; UI
(use-package tabspaces
  :after consult
  :hook
  (after-init . tabspaces-mode)
  :custom
  (tabspaces-include-buffers '("*scratch*" "*Messages*"))
  (tabspaces-session t)
  (tabspaces-session-auto-restore t)
  (tabspaces-sesssion-file (expand-file-name ".tmp/sessions/global.el" user-emacs-directory))
  (tabspaces-session-project-session-store (expand-file-name ".tmp/sessions/" user-emacs-directory))
  :config
  ;; hide full buffer list (still available with "b" prefix)
  (consult-customize consult-source-buffer :hidden t :default nil)
  ;; set consult-workspace buffer list
  (defvar consult--source-workspace
    (list :name     "Workspace Buffers"
          :narrow   ?w
          :history  'buffer-name-history
          :category 'buffer
          :state    #'consult--buffer-state
          :default  t
          :items    (lambda () (consult--buffer-query
                                :predicate #'tabspaces--local-buffer-p
                                :sort 'visibility
                                :as #'buffer-name)))

    "Set workspace buffer list for consult-buffer.")
  (add-to-list 'consult-buffer-sources 'consult--source-workspace))

(use-package olivetti
  :custom
  (olivetti-body-width 110))

(use-package magit
  :init
  (setq forge-add-default-bindings nil)
  :custom
  (magit-list-refs-sortby "-creatordate")
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1)
  :config
  (with-eval-after-load 'evil-collection
    (jwj/evil
      :packages '(evil-collection magit)
      :keymaps '(magit-mode-map magit-log-mode-map magit-status-mode-map)
      :states 'normal
      "t" #'magit-tag
      "s" #'magit-stage))
  :general
  (general-def
    :keymaps 'transient-map
    "<escape>" '("Quit" . transient-quit-one))
  )

(use-package vertico
  :custom
  (vertico-count 20) ;; Show more candidates
  (vertico-scroll-margin 0)
  (read-buffer-completion-ignore-case t)
  (read-file-name-completion-ignore-case t)
  (vertico-multiform-categories
   '((symbol (vertico-sort-function . vertico-sort-alpha))
     (file (vertico-sort-function . +vertico-directories-first)
           (+vertico-transform-functions . +vertico-highlight-directory))))
  (vertico-multiform-commands
   '((execute-extended-command
      (+vertico-transform-functions . +vertico-highlight-enabled-mode))))
  :init
  (vertico-mode)
  (vertico-multiform-mode)
  :config
  ;; This is taken from the vertico docs
  (defvar +vertico-transform-functions nil)

  (cl-defmethod vertico--format-candidate :around
    (cand prefix suffix index start &context ((not +vertico-transform-functions) null))
    (dolist (fun (ensure-list +vertico-transform-functions))
      (setq cand (funcall fun cand)))
    (cl-call-next-method cand prefix suffix index start))

  (defun +vertico-highlight-directory (file)
    "If FILE ends with a slash, highlight it as a directory."
    (if (string-suffix-p "/" file)
        (propertize file 'face 'marginalia-file-priv-dir) ; or face 'dired-directory
      file))

  (defun +vertico-directories-first (files)
    ;; Still sort by history position, length and alphabetically
    (setq files (vertico-sort-history-length-alpha files))
    ;; But then move directories first
    (nconc (seq-filter (lambda (x) (string-suffix-p "/" x)) files)
           (seq-remove (lambda (x) (string-suffix-p "/" x)) files)))

  ;; function to highlight enabled modes similar to counsel-M-x
  (defun +vertico-highlight-enabled-mode (cmd)
    "If MODE is enabled, highlight it as font-lock-constant-face."
    (let ((sym (intern cmd)))
      (if (or (eq sym major-mode)
              (and
               (memq sym minor-mode-list)
               (boundp sym)))
          (propertize cmd 'face 'font-lock-constant-face)
        cmd)))
  (add-to-list 'vertico-multiform-commands
               '(execute-extended-command
                 (+vertico-transform-functions . +vertico-highlight-enabled-mode)))
  )

;; Persist history over Emacs restarts. Vertico sorts by history position.
(use-package savehist
  :init
  (savehist-mode))

(use-package emacs
  :straight '(:type built-in)
  :custom
  ;; Enable context menu. `vertico-multiform-mode' adds a menu in the minibuffer
  ;; to switch display modes.
  (context-menu-mode t)
  ;; Support opening new minibuffers from inside existing minibuffers.
  (enable-recursive-minibuffers t)
  ;; Hide commands in M-x which do not work in the current mode.  Vertico
  ;; commands are hidden in normal buffers. This setting is useful beyond
  ;; Vertico.
  (read-extended-command-predicate #'command-completion-default-include-p)
  ;; Do not allow the cursor in the minibuffer prompt
  (minibuffer-prompt-properties
   '(read-only t cursor-intangible t face minibuffer-prompt)))

(use-package consult
  :init
  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)
  )

(use-package marginalia
  :after vertico
  :init
  (marginalia-mode))

(use-package corfu
  :custom
  (corfu-auto t)
  (corfu-auto-prefix 3)
  :init
  (global-corfu-mode)
  (corfu-history-mode))

;; corfu related options
(use-package emacs
  :straight '(:type built-in)
  :custom
  ;; TAB cycle if there are only few candidates
  (completion-cycle-threshold 3)

  ;; Enable indentation+completion using the TAB key.
  ;; `completion-at-point' is often bound to M-TAB.
  (tab-always-indent 'complete)

  ;; Emacs 30 and newer: Disable Ispell completion function.
  ;; Try `cape-dict' as an alternative.
  (text-mode-ispell-word-completion nil)

  ;; Hide commands in M-x which do not apply to the current mode.  Corfu
  ;; commands are hidden, since they are not used via M-x. This setting is
  ;; useful beyond Corfu.
  (read-extended-command-predicate #'command-completion-default-include-p))

(use-package nerd-icons-corfu)

;; this doesn't work for some reason, would be cool though
;; might investigate later
;; (use-package corfu-candidate-overlay
;;   :after corfu
;;   :config
;;   ;; enable corfu-candidate-overlay mode globally
;;   ;; this relies on having corfu-auto set to nil
;;   (corfu-candidate-overlay-mode +1)
;;   ;; bind Ctrl + TAB to trigger the completion popup of corfu
;;   ;; (global-set-key (kbd "C-<tab>") 'completion-at-point)
;;   ;; bind Ctrl + Shift + Tab to trigger completion of the first candidate
;;   ;; (keybing <iso-lefttab> may not work for your keyboard model)
;;   :general
;;   ("C-<iso-lefttab>" 'corfu-candidate-overlay-complete-at-point)
;;   ("C-<tab>" 'completion-at-point)
;;   )

(use-package cape
  ;; Bind prefix keymap providing all Cape commands under a mnemonic key.
  ;; :general
  ;; ("C-c p" . 'cape-prefix-map) ;; Alternative key: M-<tab>, M-p, M-+
  :init
  ;; The order of the functions matters, the first function returning a result wins.
  ;; Note that the list of buffer-local completion functions takes precedence over the global list.
  (add-hook 'completion-at-point-functions #'cape-dabbrev)
  (add-hook 'completion-at-point-functions #'cape-file)
  (add-hook 'completion-at-point-functions #'cape-elisp-block)
  ;; (add-hook 'completion-at-point-functions #'cape-history)
  )

;; Enable orderless multi regex look up:
;; e.g. 'buf cons' instead of 'consult-b'
(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles partial-completion))))
  (completion-pcm-leading-wildcard t)) ;; Emacs 31: partial-completion behaves like substring

(use-package embark
  :general
  (general-def
    "C-," 'embark-act)
  :config
  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none))))
  (defun embark-which-key-indicator ()
    "An embark indicator that displays keymaps using which-key.
The which-key help message will show the type and value of the
current target followed by an ellipsis if there are further
targets."
    (lambda (&optional keymap targets prefix)
      (if (null keymap)
          (which-key--hide-popup-ignore-command)
        (which-key--show-keymap
         (if (eq (plist-get (car targets) :type) 'embark-become)
             "Become"
           (format "Act on %s '%s'%s"
                   (plist-get (car targets) :type)
                   (embark--truncate-target (plist-get (car targets) :target))
                   (if (cdr targets) "…" "")))
         (if prefix
             (pcase (lookup-key keymap prefix 'accept-default)
               ((and (pred keymapp) km) km)
               (_ (key-binding prefix 'accept-default)))
           keymap)
         nil nil t (lambda (binding)
                     (not (string-suffix-p "-argument" (cdr binding))))))))

  (setq embark-indicators
        '(embark-which-key-indicator
          embark-highlight-indicator
          embark-isearch-highlight-indicator))

  (defun embark-hide-which-key-indicator (fn &rest args)
    "Hide the which-key indicator immediately when using the completing-read prompter."
    (which-key--hide-popup-ignore-command)
    (let ((embark-indicators
           (remq #'embark-which-key-indicator embark-indicators)))
      (apply fn args)))

  (advice-add #'embark-completing-read-prompter
              :around #'embark-hide-which-key-indicator)
  )

(use-package embark-consult
  :after embark
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

;; Edit embark-export buffers to edit the matching files
(use-package wgrep
  :custom
  (wgrep-auto-save-buffer t))

(use-package avy)

(use-package treesit-auto
  :custom
  (treesit-auto-install 'prompt)
  (treesit-font-lock-level  4)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

(use-package pdf-tools
  :custom
  (jwj/pdf-preface-offset 0)
  :config
  (defun jwj/set-preface-offset (offset)
    (interactive
     (list (if current-prefix-arg
               (prefix-numeric-value current-prefix-arg)
             (read-number "Offset: "))))

    (make-local-variable 'jwj/pdf-preface-offset)
    (setq jwj/pdf-preface-offset offset))

  (defun jwj/goto-page (page)
    (interactive "P")
    (evil-collection-pdf-view-goto-page (+ page jwj/pdf-preface-offset)))

  (jwj/evil
    :keymaps 'pdf-view-mode-map
    "O" '("Set offset" . jwj/set-preface-offset)
    "G" '("Go to page" . jwj/goto-page))

  (pdf-tools-install))

(use-package mise
  :hook (after-init . global-mise-mode))

(require 'init-rust)
(require 'init-lsp)

;;; Python
(use-package uv-mode
  :hook
  ((python-ts-mode . (lambda ()
                       (mise-turn-on-if-enable)
                       (uv-mode-auto-activate-hook)
                       (lsp)))) ;; Start python lsp after uv-mode is set to ensure it is in the right venv
  )

(require 'init-org)

;; Dial gc threshold back down
(setq gc-cons-threshold (* 100 1024 1024))

;; Startup time
(defun efs/display-startup-time ()
  (message
   "Emacs loaded in %s with %d garbage collections."
   (format
    "%.2f seconds"
    (float-time
     (time-subtract after-init-time before-init-time)))
   gcs-done))

(add-hook 'emacs-startup-hook #'efs/display-startup-time)
