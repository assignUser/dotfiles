;;; init-core.el --- Core editor behavior -*- lexical-binding: t -*-

(use-package benchmark-init
  :demand t
  :hook (after-init . benchmark-init/deactivate))

(defun jwj/undo-tree-append-zst-to-filename (filename)
  "Append .zst to FILENAME so undo history is compressed."
  (concat filename ".zst"))

(use-package tab-bar
  :straight (:type built-in)
  :custom
  (tab-bar-show t)
  (tab-bar-tab-hints t)
  (tab-bar-select-tab-modifiers '(meta)))

(use-package which-key
  :straight (:type built-in)
  :hook
  (after-init . which-key-mode)
  :diminish which-key-mode
  :custom
  (which-key-sort-order #'which-key-key-order-alpha)
  (which-key-sort-uppercase-first nil)
  (which-key-add-column-padding 1)
  (which-key-min-display-lines 6)
  (which-key-idle-delay 0.8)
  (which-key-max-description-length 25))

(use-package general
  :demand t
  :config
  (general-auto-unbind-keys))

(use-package evil
  :demand t
  :after general
  :init
  (setq evil-want-integration t
        evil-want-keybinding nil
        evil-want-C-u-scroll t)
  :config
  (evil-set-undo-system 'undo-tree)
  (general-define-key
   :keymaps 'evil-motion-state-map
   "SPC" nil
   "K" nil)
  (evil-mode 1)
  (setq evil-want-fine-undo t)
  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

(use-package evil-collection
  :demand t
  :after evil
  :hook
  (after-init . evil-collection-init))

(use-package undo-tree
  :hook
  (after-init . global-undo-tree-mode)
  :custom
  (undo-tree-history-directory-alist
   `(("." . ,(expand-file-name (file-name-as-directory "undo-tree-hist")
                               user-emacs-directory))))
  :config
  (when (executable-find "zstd")
    (advice-add 'undo-tree-make-history-save-file-name
                :filter-return
                #'jwj/undo-tree-append-zst-to-filename))
  (setq undo-tree-visualizer-diff t
        undo-tree-auto-save-history t
        undo-tree-enable-undo-in-region t
        undo-limit (* 800 1024)
        undo-strong-limit (* 12 1024 1024)
        undo-outer-limit (* 128 1024 1024)))

(use-package evil-commentary
  :hook
  (after-init . evil-commentary-mode))

(use-package smartparens
  :hook (prog-mode text-mode markdown-mode)
  :config
  ;; load default config
  (require 'smartparens-config))

(provide 'init-core)
;;; init-core.el ends here
