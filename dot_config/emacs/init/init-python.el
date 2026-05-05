;;; init-python.el --- Python tooling -*- lexical-binding: t -*-

(use-package uv-mode
  :commands (uv-mode-auto-activate-hook)
  :hook
  ((python-ts-mode . uv-mode-auto-activate-hook)
   (python-ts-mode . (lambda ()
                       (when (fboundp 'mise-turn-on-if-enable)
                         (mise-turn-on-if-enable))
                       (lsp)))))

(provide 'init-python)
;;; init-python.el ends here
;; bla 
