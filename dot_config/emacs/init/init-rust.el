;;; ...  -*- lexical-binding: t -*-
(defcustom jwj/rust-large-file-threshold-bytes (* 500 1024)
  "File size threshold in bytes above which Rust large-file optimizations apply."
  :type 'integer
  :group 'rust)

(defvar-local jwj/rust-large-file-optimizations-enabled nil
  "Non-nil when large-file optimizations are enabled for the current Rust buffer.")

(defvar-local jwj/rust-hl-patched nil
  "Non-nil when custom Rust tree-sitter font-lock rules were applied in this buffer.")

(defun jwj/rust-large-file-p ()
  "Return non-nil when the current Rust buffer exceeds the configured size threshold."
  (let ((buffer-bytes (buffer-size))
        (file-bytes (when-let* ((name (buffer-file-name)))
                      (nth 7 (file-attributes name)))))
    (> (max buffer-bytes (or file-bytes 0)) jwj/rust-large-file-threshold-bytes)))

(defun jwj/rust-enable-large-file-optimizations ()
  "Enable per-buffer Rust optimizations for very large files."
  (interactive)
  (setq-local jwj/rust-large-file-optimizations-enabled t)
  ;; Disable expensive display and analysis features in huge Rust buffers.
  (setq-local lsp-inlay-hint-enable nil)
  (setq-local lsp-semantic-tokens-enable nil)
  (setq-local lsp-enable-symbol-highlighting nil)
  (when (bound-and-true-p display-line-numbers-mode)
    (display-line-numbers-mode -1))
  (when (and (fboundp 'flycheck-mode)
             (bound-and-true-p flycheck-mode))
    (flycheck-mode -1))
  (when (and (fboundp 'lsp-inlay-hints-mode)
             (bound-and-true-p lsp-inlay-hints-mode))
    (lsp-inlay-hints-mode -1))
  (when (and (fboundp 'lsp-semantic-tokens-mode)
             (bound-and-true-p lsp-semantic-tokens-mode))
    (lsp-semantic-tokens-mode -1))
  (message "Rust large-file optimizations enabled"))

(defun jwj/rust-disable-large-file-optimizations ()
  "Disable per-buffer Rust large-file optimizations."
  (interactive)
  (setq-local jwj/rust-large-file-optimizations-enabled nil)
  (kill-local-variable 'lsp-inlay-hint-enable)
  (kill-local-variable 'lsp-semantic-tokens-enable)
  (kill-local-variable 'lsp-enable-symbol-highlighting)
  (display-line-numbers-mode 1)
  (message "Rust large-file optimizations disabled"))

(defun jwj/rust-toggle-large-file-optimizations ()
  "Toggle large-file optimizations for the current Rust buffer."
  (interactive)
  (if jwj/rust-large-file-optimizations-enabled
      (jwj/rust-disable-large-file-optimizations)
    (jwj/rust-enable-large-file-optimizations)))

(defun jwj/rust-maybe-enable-large-file-optimizations ()
  "Enable Rust large-file optimizations when the current file is large."
  (when (jwj/rust-large-file-p)
    (jwj/rust-enable-large-file-optimizations)))

(defun jwj/fix-rust-hl ()
  (unless (or jwj/rust-hl-patched
              jwj/rust-large-file-optimizations-enabled)
    (setq-local treesit-font-lock-settings
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

                         ))))
    (setq-local jwj/rust-hl-patched t))

(use-package rust-mode
  :init
  (setq rust-mode-treesitter-derive t) ; use treesit for hl
  :custom
  (rust-ts-flymake-command nil) ; disable ts based flymake, rustic sets that up
  :hook
  ((rust-mode . jwj/rust-maybe-enable-large-file-optimizations)
   (rust-ts-mode . jwj/rust-maybe-enable-large-file-optimizations)
   (rust-mode . jwj/fix-rust-hl))
  )

;;;###autoload
(defun jwj/rust-expand-macro ()
  "Expand the Rust macro invocation at point."
  (interactive)
  (require 'rust-prog-mode)
  (lsp-rust-analyzer-expand-macro))

;;;###autoload
(defun jwj/rustic-run-test-at-point-ts ()
  "Find the enclosing function or module and run it via rustic."
  (interactive)
  (let* ((node (treesit-node-at (point)))
         ;; Find the closest ancestor that is either a function or a module.
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
      (message "No Rust function or module found at point."))))

(use-package rustic
  :after rust-mode
  :custom
  (rustic-format-on-save t)
  (lsp-rust-analyzer-cargo-watch-command "clippy") ;; Use clippy instead of just check
  (lsp-rust-analyzer-checkonsave-features "all")) ;; always check with --all-targets

(provide 'init-rust)
;;; init-rust.el ends here
