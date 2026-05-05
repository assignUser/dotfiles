;;; init-completion.el --- Minibuffer and completion setup -*- lexical-binding: t -*-

(defvar +vertico-transform-functions nil
  "Transformers applied to displayed Vertico candidates.")

(cl-defmethod vertico--format-candidate :around
  (cand prefix suffix index start &context ((not +vertico-transform-functions) null))
  (dolist (fun (ensure-list +vertico-transform-functions))
    (setq cand (funcall fun cand)))
  (cl-call-next-method cand prefix suffix index start))

(defun +vertico-highlight-directory (file)
  "Highlight FILE when it represents a directory."
  (if (string-suffix-p "/" file)
      (propertize file 'face 'marginalia-file-priv-dir)
    file))

(defun +vertico-directories-first (files)
  "Sort FILES with directories before regular entries."
  (setq files (vertico-sort-history-length-alpha files))
  (nconc (seq-filter (lambda (x) (string-suffix-p "/" x)) files)
         (seq-remove (lambda (x) (string-suffix-p "/" x)) files)))

(defun +vertico-highlight-enabled-mode (cmd)
  "Highlight CMD when it names an enabled major or minor mode."
  (let ((sym (intern cmd)))
    (if (or (eq sym major-mode)
            (and (memq sym minor-mode-list)
                 (boundp sym)))
        (propertize cmd 'face 'font-lock-constant-face)
      cmd)))

(defun embark-which-key-indicator ()
  "Display Embark keymaps using which-key."
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

(defun embark-hide-which-key-indicator (fn &rest args)
  "Hide which-key while FN handles completing-read with ARGS."
  (which-key--hide-popup-ignore-command)
  (let ((embark-indicators
         (remq #'embark-which-key-indicator embark-indicators)))
    (apply fn args)))

(use-package vertico
  :demand t
  :custom
  (vertico-count 20)
  (vertico-scroll-margin 0)
  (read-buffer-completion-ignore-case t)
  (read-file-name-completion-ignore-case t)
  (vertico-multiform-categories
   '((symbol (vertico-sort-function . vertico-sort-alpha))
     (file (vertico-sort-function . +vertico-directories-first)
           (+vertico-transform-functions . +vertico-highlight-directory))))
  (vertico-multiform-commands
   '((execute-extended-command
      (+vertico-transform-functions . +vertico-highlight-enabled-mode))
     (consult-line (:not posframe))
     (consult-ripgrep (:not posframe))
     (t posframe)))
  :hook
  (after-init . vertico-mode)
  (after-init . vertico-multiform-mode))

(use-package vertico-posframe
  :after catppuccin-theme
  :hook (after-init . vertico-posframe-mode)
  :custom
  (vertico-posframe-border-width 10)
  :config
  (set-face-background 'vertico-posframe-border (catppuccin-get-color 'mantle))
  (set-face-background 'vertico-posframe-border-2 (catppuccin-get-color 'maroon))
  (set-face-background 'vertico-posframe-border-3 (catppuccin-get-color 'green))
  (set-face-background 'vertico-posframe-border-4 (catppuccin-get-color 'sky))
  (set-face-background 'vertico-posframe-border-fallback (catppuccin-get-color 'yellow))
  (setq vertico-posframe-parameters
        '((undecorated . nil)))
  )

(use-package savehist
  :init
  (savehist-mode))

(use-package consult
  :init
  ;; Use tab/frame-local buffer listing so tabspaces isolation carries into consult.
  (setq consult-buffer-list-function #'consult--frame-buffer-list)
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref))

(use-package marginalia
  :after vertico
  :hook (after-init . marginalia-mode))

(use-package corfu
  :hook
  (after-init . global-corfu-mode)
  (after-init . corfu-history-mode)
  :custom
  (corfu-auto t)
  (corfu-auto-prefix 3))

(use-package nerd-icons-corfu)

(use-package cape
  :hook
  ((completion-at-point-functions . cape-dabbrev)
  (completion-at-point-functions . cape-file)
  (completion-at-point-functions . cape-elisp-block)))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles partial-completion))))
  (completion-pcm-leading-wildcard t))

(use-package embark
  :bind
  ("C-," . embark-act)
  :config
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none))))
  (setq embark-indicators
        '(embark-which-key-indicator
          embark-highlight-indicator
          embark-isearch-highlight-indicator))
  (advice-add #'embark-completing-read-prompter
              :around #'embark-hide-which-key-indicator))

(use-package embark-consult
  :after embark
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

(use-package wgrep
  :custom
  (wgrep-auto-save-buffer t))

(use-package avy)

(use-package treesit
  :straight (:type built-in)
  :custom
  (treesit-font-lock-level 4)
  (treesit-enabled-modes t)
  (treesit-auto-install-grammar 'ask))

(use-package tabspaces
  :after consult
  :hook
  (after-init . tabspaces-mode)
  :custom
  (tabspaces-include-buffers '("*scratch*" "*Messages*"))
  (tabspaces-session t)
  (tabspaces-session-auto-restore t)
  (tabspaces-session-file
   (expand-file-name ".tmp/sessions/global.el" user-emacs-directory))
  (tabspaces-session-project-session-store
   (expand-file-name ".tmp/sessions/" user-emacs-directory))
  :config
  (consult-customize consult-source-buffer :hidden t :default nil)
  (defvar consult--source-workspace
    (list :name "Workspace Buffers"
          :narrow ?w
          :history 'buffer-name-history
          :category 'buffer
          :state #'consult--buffer-state
          :default t
          :items (lambda ()
                   (consult--buffer-query
                    :predicate #'tabspaces--local-buffer-p
                    :sort 'visibility
                    :as #'buffer-name)))
    "Workspace-local source for `consult-buffer'.")
  (add-to-list 'consult-buffer-sources 'consult--source-workspace))

(provide 'init-completion)
;;; init-completion.el ends here
