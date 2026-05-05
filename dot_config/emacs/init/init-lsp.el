;;; ...  -*- lexical-binding: t -*-

(use-package lsp-mode
  :defer t
  :custom
  (lsp-keymap-prefix nil)
  (lsp-enable-file-watchers t)
  (lsp-file-watch-threshold 1500)
  (lsp-inlay-hint-enable t)
  (lsp-semantic-tokens-enable t)
  (lsp-completion-provider ':none) ; uses company by default
  (lsp-disabled-clients '(pylsp))
  :config
  ;; workflows etc. should be watched by yamls
  (delete
   "[/\\\\]\\.github\\'"
   lsp-file-watch-ignored-directories )
  ;; add additional dirs for the file watcher to ignore
  (mapc (lambda (e) (add-to-list 'lsp-file-watch-ignored-directories e))
        '("[/\\\\]\\.ruff_cache\\'"
          "[/\\\\]\\.benchmarks\\'"
          "[/\\\\]\\.asv\\'"
          "[/\\\\]venv\\'"
          "[/\\\\].*\\.egg-info\\'"))
  (setq-default lsp-semantic-token-faces
                '(("comment" . lsp-face-semhl-comment)
                  ("keyword" . lsp-face-semhl-keyword)
                  ("string" . lsp-face-semhl-string)
                  ("number" . lsp-face-semhl-number)
                  ("regexp" . lsp-face-semhl-regexp)
                  ("operator" . lsp-face-semhl-operator)
                  ("namespace" . lsp-face-semhl-namespace)
                  ("type" . lsp-face-semhl-type)
                  ("struct" . lsp-face-semhl-struct)
                  ("class" . lsp-face-semhl-class)
                  ("interface" . lsp-face-semhl-interface)
                  ("enum" . lsp-face-semhl-enum)
                  ("typeParameter" . lsp-face-semhl-type-parameter)
                  ("function" . lsp-face-semhl-function)
                  ("method" . lsp-face-semhl-method)
                  ("member" . lsp-face-semhl-member)
                  ("property" . lsp-face-semhl-property)
                  ("event" . lsp-face-semhl-event)
                  ("macro" . lsp-face-semhl-macro)
                  ("variable" . lsp-face-semhl-variable)
                  ("parameter" . lsp-face-semhl-parameter)
                  ("label" . lsp-face-semhl-label)
                  ("enumConstant" . lsp-face-semhl-constant)
                  ("enumMember" . lsp-face-semhl-operator)
                  ("dependent" . lsp-face-semhl-type)
                  ("concept" . lsp-face-semhl-interface)))
  (setq-default lsp-semantic-token-modifier-faces
                '(("declaration" . lsp-face-semhl-interface)
                  ("definition" . lsp-face-semhl-definition)
                  ("implementation" . lsp-face-semhl-implementation)
                  ("readonly" . lsp-face-semhl-constant)
                  ("static" . lsp-face-semhl-static)
                  ("deprecated" . lsp-face-semhl-deprecated)
                  ("abstract" . lsp-face-semhl-keyword)
                  ("async" . lsp-face-semhl-macro)
                  ("modification" . lsp-face-semhl-operator)
                  ("documentation" . font-lock-doc-face)
                  ("defaultLibrary" . lsp-face-semhl-default-library)))

  (set-face-attribute 'lsp-inlay-hint-face nil
                      :family (jwj/get-font-name 'term) :weight 'light :slant 'normal :inherit 'font-lock-comment-face)
  (with-eval-after-load 'lsp-semantic-tokens
    (set-face-attribute 'lsp-face-semhl-property nil
                        :foreground (catppuccin-get-color 'lavender))
    (set-face-attribute 'lsp-face-semhl-operator nil
                        :inherit 'font-lock-operator-face)
    (set-face-attribute 'lsp-face-semhl-macro nil
                        :inherit 'font-lock-keyword-face)
    (set-face-attribute 'lsp-face-semhl-namespace nil
                        :weight 'bold))
  (with-eval-after-load 'lsp-rust
    (set-face-attribute 'lsp-rust-analyzer-documentation-modifier-face nil
                        :inherit 'font-lock-doc-face))
  :hook (
         (rust-ts-mode . lsp-inlay-hints-mode)
         (rust-ts-mode . (lambda ()
                           (when (fboundp 'mise-turn-on-if-enable)
                             (mise-turn-on-if-enable)) ;; This sets RUST_TOOLCHAIN
                           (lsp)))
         (yaml-ts-mode . lsp)
         ;;(python-ts-mode . lsp) ;; activated via uv-mode-hook
         (lsp-mode . lsp-enable-which-key-integration)
         (lsp-semantic-tokens-mode . (lambda ()
                                       (font-lock-ensure))))

  :commands lsp)

(use-package lsp-ui
  :after lsp-mode
  :commands lsp-ui-mode
  :config
  (setq lsp-ui-doc-position 'at-point)
  (jwj/evil
    :keymaps 'lsp-ui-mode-map
    "K" '("Show docs" . (lambda () (interactive)
                          (if (lsp-ui-doc--frame-visible-p)
                              (lsp-describe-thing-at-point)
                            (lsp-ui-doc-glance))))))

(use-package consult-lsp
  :after lsp-mode
  :config
  (general-define-key
   :keymaps 'lsp-mode-map
   [remap xref-find-apropos] #'consult-lsp-symbols))

(use-package flycheck
  :hook
  (after-init . global-flycheck-mode))

(use-package consult-flycheck)

(provide 'init-lsp)
;;; init-lsp.el ends here
