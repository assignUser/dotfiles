;;; init-settings.el --- Shared built-in settings -*- lexical-binding: t -*-
(defvar my-auto-save-dir
  (expand-file-name ".tmp/auto-saves/" user-emacs-directory)
  "Directory where auto-save files are stored.")

(defun efs/display-startup-time ()
  "Report startup timing in the echo area."
  (message
   "Emacs loaded in %s with %d garbage collections."
   (format
    "%.2f seconds"
    (float-time
     (time-subtract after-init-time before-init-time)))
   gcs-done))

(setq straight-use-package-by-default t
      load-prefer-newer t
      use-package-always-defer t
      inhibit-startup-screen t
      help-window-select t
      ring-bell-function 'ignore
      kill-buffer-delete-auto-save-files t
      auto-save-visited-predicate (lambda ()
                                    (eq major-mode 'org-mode))
      create-lockfiles nil
      display-line-numbers-type 'visual
      scroll-margin 15
      scroll-conservatively 1000
      dired-kill-when-opening-new-dired-buffer t
      tab-width 4
      backup-directory-alist
      `(("." . ,(expand-file-name ".tmp/backups/" user-emacs-directory)))
      auto-save-file-name-transforms
      `((".*/\\([^/]+\\)"
         ,(concat my-auto-save-dir "\\1")
         t))
      delete-by-moving-to-trash t
      context-menu-mode t
      enable-recursive-minibuffers t
      read-extended-command-predicate #'command-completion-default-include-p
      minibuffer-prompt-properties
      '(read-only t cursor-intangible t face minibuffer-prompt)
      completion-cycle-threshold 3
      tab-always-indent 'complete
      text-mode-ispell-word-completion nil)

(setq-default initial-scratch-message nil
              indent-tabs-mode nil
              custom-file (expand-file-name ".custom.el" user-emacs-directory))

(add-hook 'prog-mode-hook (lambda () (setq indent-tabs-mode nil)))
(add-hook 'prog-mode-hook (lambda () (hs-minor-mode t)))
(add-hook 'prog-mode-hook #'subword-mode)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'makefile-mode-hook (lambda () (setq indent-tabs-mode t)))
(add-hook 'yaml-ts-mode-hook #'display-line-numbers-mode)
(add-hook 'toml-ts-mode-hook #'display-line-numbers-mode)
(add-hook 'conf-toml-mode-hook #'display-line-numbers-mode)
(add-hook 'before-save-hook #'whitespace-cleanup)
(add-hook 'org-mode-hook #'auto-save-visited-mode)
(add-hook 'server-after-make-frame-hook #'jwj/apply-base-fonts)
(add-hook 'emacs-startup-hook #'efs/display-startup-time)

(global-auto-revert-mode 1)
(auto-save-mode 1)
(column-number-mode 1)
(recentf-mode t)
(winner-mode 1)
(blink-cursor-mode 0)
(set-fringe-mode 10)
(put 'dired-find-alternate-file 'disabled nil)
(make-directory my-auto-save-dir t)

(when (file-exists-p custom-file)
  (load custom-file))

(defalias 'yes-or-no-p 'y-or-n-p)

(provide 'init-settings)
;;; init-settings.el ends here
