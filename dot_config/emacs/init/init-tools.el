;;; init-tools.el --- External tools and integrations -*- lexical-binding: t -*-

(defcustom jwj/terminal-backend 'ghostel
  "Terminal backend used by `jwj/open-term' commands."
  :type '(choice (const :tag "vterm" vterm)
                 (const :tag "ghostel" ghostel))
  :group 'jwj)

(defun jwj/get-term-buffer-name ()
  "Generate a terminal buffer name based on the current project."
  (interactive)
  (let* ((project (project-current))
         (name (file-name-nondirectory
                (directory-file-name
                 (if project
                     (project-root project)
                   default-directory)))))
    (format "*term: %s*" name)))

(defun jwj/open-term-with-vterm (other-window)
  "Open the configured vterm buffer.
When OTHER-WINDOW is non-nil, display it in another window."
  (require 'vterm)
  (let ((vterm-buffer-name (jwj/get-term-buffer-name)))
    (if other-window
        (call-interactively #'vterm-other-window)
      (call-interactively #'vterm))))

(defun jwj/open-term-with-ghostel (other-window arg)
  "Open the configured ghostel buffer.
When OTHER-WINDOW is non-nil, display it in another window.
ARG is forwarded to `ghostel'."
  (require 'ghostel)
  (let ((ghostel-buffer-name (jwj/get-term-buffer-name))
        (ghostel-set-title-function nil))
    (if other-window
        (let ((display-buffer-overriding-action
               '((display-buffer-pop-up-window)
                 (inhibit-same-window . t))))
          (ghostel arg))
      (ghostel arg))))

(defun jwj/open-term (_arg)
  "Open a project-scoped terminal buffer in another window."
  (interactive "P")
  (pcase jwj/terminal-backend
    ('vterm (jwj/open-term-with-vterm t))
    ('ghostel (jwj/open-term-with-ghostel t _arg))))

(defun jwj/open-term-here (_arg)
  "Open a project-scoped terminal buffer in the current window."
  (interactive "P")
  (pcase jwj/terminal-backend
    ('vterm (jwj/open-term-with-vterm nil))
    ('ghostel (jwj/open-term-with-ghostel nil _arg))))

(defun jwj/terminal-set-buffer-face ()
  "Apply a dedicated buffer-local face for terminal buffers."
  (let ((font-name (and (fboundp 'jwj/get-font-name)
                        (jwj/get-font-name 'term))))
    (when font-name
      (buffer-face-set `(:family ,font-name :height ,jwj/default-font-size :weight light))
      (buffer-face-mode 1))))

(defvar jwj/pdf-preface-offset 0
  "Page offset used for PDF documents with prefatory pages.")

(defun jwj/set-preface-offset (offset)
  "Set the local PDF page OFFSET used by `jwj/goto-page'."
  (interactive
   (list (if current-prefix-arg
             (prefix-numeric-value current-prefix-arg)
           (read-number "Offset: "))))
  (make-local-variable 'jwj/pdf-preface-offset)
  (setq jwj/pdf-preface-offset offset))

(defun jwj/goto-page (page)
  "Jump to PAGE in `pdf-view-mode', applying any prefatory offset."
  (interactive "P")
  (evil-collection-pdf-view-goto-page (+ page jwj/pdf-preface-offset)))

(use-package vterm
  :hook
  (vterm-mode . jwj/terminal-set-buffer-face)
  :custom
  (shell-file-name (executable-find "bash"))
  (vterm-shell "/usr/bin/fish")
  (vterm-environment '("SSH_AUTH_SOCK=/home/jwj/.1password/agent.sock")))

(use-package ghostel
  :custom (ghostel-module-auto-install 'compile)
  :hook (ghostel-mode . jwj/terminal-set-buffer-face))

(use-package evil-ghostel
  :after ghostel
  :hook   (ghostel-mode . evil-ghostel-mode))

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
  (general-def
    :keymaps 'transient-map
    "<escape>" '("Quit" . transient-quit-one)))

(use-package pdf-tools
  :mode ("\\.pdf\\'" . pdf-view-mode)
  :config
  (jwj/evil
    :keymaps 'pdf-view-mode-map
    "O" '("Set offset" . jwj/set-preface-offset)
    "G" '("Go to page" . jwj/goto-page))
  (pdf-tools-install))

(use-package mise
  :hook
  (after-init . global-mise-mode))

(provide 'init-tools)
;;; init-tools.el ends here
