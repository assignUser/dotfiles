;;; init-agents.el --- LLM Agent tools and integrations -*- lexical-binding: t -*-

(use-package agent-shell
  :general
  ;; Evil state-specific RET behavior: insert mode = newline, normal mode = send
  (agent-shell-mode-map :states 'insert  "RET" #'newline)
  (agent-shell-mode-map :states 'insert  "C-<return>" #'comint-send-input)
  (agent-shell-mode-map :states 'normal  "RET" #'comint-send-input)
  (agent-shell-mode-map :states 'normal  "<tab>" #'agent-shell-next-item)
  :custom
  (agent-shell-preferred-agent-config (agent-shell-openai-make-codex-config))
  :hook
  ;; Configure *agent-shell-diff* buffers to start in Emacs state for easier y/n/v input
  (diff-mode .
             (lambda ()
               (when (string-match-p "\\*agent-shell-diff\\*" (buffer-name))
                 (evil-emacs-state)))))

(use-package agent-review
  :after (agent-shell mise)
  :straight (:host github :repo "nineluj/agent-review")
  :config
  ;; `agent-review' creates a temp work buffer and starts ACP from there.
  ;; Propagate the current buffer's `mise' environment so `codex-acp' and
  ;; other per-buffer tools remain resolvable.
  (advice-add #'agent-review :around #'mise-propagate-env))

(provide 'init-agents)
;;; init-agents.el ends here
