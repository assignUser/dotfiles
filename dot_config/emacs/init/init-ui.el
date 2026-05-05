;;; init-ui.el --- Visual configuration -*- lexical-binding: t -*-

;;; Code:

(use-package catppuccin-theme
  :demand t
  :custom
  (catppuccin-flavor 'macchiato)
  (catppuccin-italic-comments t)
  (catppuccin-italic-variables t)
  :config
  (load-theme 'catppuccin :no-confirm)
  (when (fboundp 'jwj/apply-font-faces)
    (jwj/apply-font-faces)))

(defun jwj/pulse-advice (&optional beg end &rest _)
  "Pulse BEG..END or the current line when no region is provided."
  (if (and beg end (numberp beg) (numberp end))
      (pulse-momentary-highlight-region beg end)
    (pulse-momentary-highlight-one-line (point))))

(use-package pulse
  :demand t
  :after catppuccin-theme
  :custom
  (pulse-highlight-start-face ((t (:background (catppuccin-get-color 'sky)))))
  :config
  (advice-add 'evil-yank :after #'jwj/pulse-advice)
  (advice-add 'evil-yank-line :after #'jwj/pulse-advice)
  (advice-add 'evil-undo :after #'jwj/pulse-advice)
  (advice-add 'evil-redo :after #'jwj/pulse-advice))

(use-package ligature
  :straight (ligature :type git
                      :host github
                      :repo "mickeynp/ligature.el"
                      :build t)
  :hook
  (after-init . global-ligature-mode)
  :config
  (ligature-set-ligatures 't '("www"))
  (ligature-set-ligatures '(eww-mode org-mode)
                          '("ff" "fi" "ffi"))
  (ligature-set-ligatures
   'prog-mode
   '("|||>" "<|||" "<==>" "<!--" "####" "~~>" "***" "||=" "||>"
     ":::" "::=" "=:=" "===" "==>" "=!=" "=>>" "=<<" "=/=" "!==" "!!."
     ">=>" ">>=" ">>>" ">>-" ">->" "->>" "-->" "---" "-<<" "<~~" "<~>"
     "<*>" "<||" "<|>" "<$>" "<==" "<=>" "<=<" "<->" "<--" "<-<" "<<="
     "<<-" "<<<" "<+>" "</>" "###" "#_(" "..<" "..." "+++" "/==" "///"
     "_|_" "www" "&&" "^=" "~~" "~@" "~=" "~>" "~-" "**" "*>" "*/" "||"
     "|}" "|]" "|=" "|>" "|-" "{|" "[|" "]#" "::" ":=" ":>" ":<" "$>"
     "==" "=>" "!=" "!!" ">:" ">=" ">>" ">-" "-~" "-|" "->" "--" "-<"
     "<~" "<*" "<|" "<:" "<$" "<=" "<>" "<-" "<<" "<+" "</" "%%" ".="
     ".-" ".." ".?" "+>" "++" "?:" "?=" "?." "??" "/*" "/=" "/>" "//"
     "__" "~~" "(*" "*)" "\\\\" "://")))

(use-package git-gutter-fringe
  :hook ((prog-mode . git-gutter-mode)
         (org-mode . git-gutter-mode)
         (markdown-mode . git-gutter-mode)
         (latex-mode . git-gutter-mode)))

(use-package doom-modeline
  :custom
  (doom-modeline-buffer-file-name-style 'relative-to-project)
  (doom-modeline-buffer-encoding nil)
  :hook (after-init . doom-modeline-mode))

(use-package nyan-mode
  :hook (after-init . nyan-mode))

(use-package diminish)

(use-package auto-dim-other-buffers
  :after catppuccin-theme
  :hook (after-init . auto-dim-other-buffers-mode)
  :custom-face (auto-dim-other-buffers ((t (:background ,(catppuccin-get-color 'mantle)))))
  :custom
  (auto-dim-other-buffers-affected-faces '(
                                          (default auto-dim-other-buffers)
                                          (fringe auto-dim-other-buffers)
                                          (line-number auto-dim-other-buffers)
                                          (org-block auto-dim-other-buffers)
                                          (org-hide auto-dim-other-buffers-hide))
                                         ))


(use-package rainbow-delimiters
  :hook
  (emacs-lisp-mode . rainbow-delimiters-mode))

(use-package nerd-icons)

(use-package nerd-icons-completion
  :after marginalia
  :hook (marginalia-mode . nerd-icons-completion-marginalia-setup)
  :config
  (nerd-icons-completion-mode))

(use-package nerd-icons-dired
  :hook
  (dired-mode . (lambda () (nerd-icons-dired-mode t))))

(use-package nerd-icons-ibuffer
  :hook
  (ibuffer-mode . nerd-icons-ibuffer-mode))

(use-package olivetti
  :custom
  (olivetti-body-width 110))

(provide 'init-ui)
;;; init-ui.el ends here
