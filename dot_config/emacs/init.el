;;; init.el --- Main entry point -*- lexical-binding: t -*-
(eval-and-compile
  (add-to-list 'load-path (expand-file-name "init" user-emacs-directory)))

;; Bootstrap straight.el.
(defvar straight-base-dir)
(setq straight-base-dir (expand-file-name "../straight/" user-emacs-directory))

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

(straight-use-package 'use-package)

(require 'init-fonts)
(require 'init-settings)
(require 'init-core)
(require 'init-completion)
(require 'init-ui)
(require 'init-dashboard)
(require 'init-keys)
(require 'init-tools)
(require 'init-agents)
(require 'init-rust)
(require 'init-lsp)
(require 'init-python)
(require 'init-org)

;; Dial gc threshold back down after startup.
(setq gc-cons-threshold (* 100 1024 1024))
