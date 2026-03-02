;;; ...  -*- lexical-binding: t -*-
(defun jwj/fix-rust-hl ()
  (setq treesit-font-lock-settings
        (append treesit-font-lock-settings
                (treesit-font-lock-rules
                 :default-language 'rust

                 ;; Non-type identifiers in use lists
                 :override 'keep
                 :feature'function
                 '((use_list (identifier) @font-lock-function-name-face))

                 ;; Enforce punctionation coloring everywhere (it wasn't honored i.e. in attributes)
                 :override t
                 :feature'function
                 '([
                    "("
                    ")"
                    "["
                    "]"
                    "{"
                    "}"
                    ] @font-lock-bracket-face)

                 :override t
                 :feature'function
                 '([
                    ","
                    "."
                    ":"
                    "::"
                    ";"
                    "->"
                    "=>"
                    ] @font-lock-delimiter-face)

                 :override t
                 :feature'function
                 '(((identifier) @font-lock-constant-face
                    (:match "^[A-Z][A-Z%d_]*$" @font-lock-constant-face ))
                   )

                 :override t
                 :feature'function
                 '(((identifier) @font-lock-operator-face
                    (:match "^Some|None|Ok|Err$" @font-lock-operator-face)))

                 ;; Same for other literals
                 :override t
                 :feature'attribute
                 '([
                    (boolean_literal "true")
                    (boolean_literal "false")
                    ] @font-lock-constant-face)

                 :override t
                 :feature'attribute
                 '((string_literal) @font-lock-string-face)

                 ;; The default queries use a single color for attributes
                 :override t
                 :feature'attribute
                 '((attribute_item
                    "#" @font-lock-keyword-face))

                 :override t
                 :feature'attribute
                 '( (attribute_item (attribute (identifier)  @font-lock-constant-face)))

                 :override t
                 :feature'attribute
                 '((attribute arguments: (token_tree "=" @font-lock-operator-face)))

                 :override t
                 :feature'attribute
                 '((enum_variant_list (enum_variant name: (identifier) @font-lock-operator-face)))

                 )))
  )

(use-package rust-mode
  :init
  (setq rust-mode-treesitter-derive t) ; use treesit for hl
  :custom
  (rust-ts-flymake-command nil) ; disable ts based flymake, rustic sets that up
  :hook
  (rust-mode . jwj/fix-rust-hl)
  )

(use-package rustic
  :after rust-mode
  :custom
  (rustic-format-on-save t)
  (lsp-rust-analyzer-cargo-watch-command "clippy") ;; Use clippy instead of just check
  (lsp-rust-analyzer-checkonsave-features "all") ;; always check with --all-targets
  :config
;;;###autoload
  (defun my/rust-expand-macro ()
    "Wrapper around `lsp-rust-analyzer-expand-macro' that fixes the propertize function.
    See https://github.com/emacs-rustic/rustic/issues/83"
    (interactive)
    (require 'rust-prog-mode)
    (lsp-rust-analyzer-expand-macro))

;;;###autoload
  (defun my/rustic-run-test-at-point-ts ()
  "Find the enclosing function or module and run it via rustic."
  (interactive)
  (let* ((node (treesit-node-at (point)))
         ;; Find the closest ancestor that is either a function or a module
         (target-node (treesit-parent-until
                       node
                       (lambda (n)
                         (member (treesit-node-type n)
                                 '("function_item" "mod_item"))))))
    (if target-node
        (let ((name-node (treesit-node-child-by-field-name target-node "name")))
          (if name-node
              (save-excursion
                (goto-char (treesit-node-start name-node))
                (message "Running tests for: %s" (treesit-node-text name-node))
                (rustic-cargo-current-test))
            (message "Found %s, but could not find its name." (treesit-node-type target-node))))
      (message "No Rust function or module found at point.")))))



(provide 'init-rust)
;;; init-rust.el ends here
