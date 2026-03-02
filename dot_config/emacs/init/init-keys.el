;;; ...  -*- lexical-binding: t -*-
(use-package general
  :defer t
  :config
  (general-create-definer jwj/undefine
    :keymaps 'override
    :states '(normal emacs))
  (general-create-definer jwj/evil
    :states '(normal))
  (general-define-key
   :states '(emacs insert normal visual)
   :prefix-map 'my-leader-map
   :prefix "SPC"
   :global-prefix "C-SPC"
   :non-normal-prefix "M-SPC")
  (general-create-definer jwj/leader-key
    :keymaps 'my-leader-map)
  (general-create-definer jwj/local-leader-key
   :states '(emacs insert normal visual)
   :prefix "SPC m"
   :global-prefix "M-m"))

  (use-package hydra
    :defer t
    :after catppucin-theme
    :config
    (set-face-attribute 'hydra-face-red nil :foreground (catppuccin-get-color 'mauve))
    (set-face-attribute 'hydra-face-blue nil :foreground (catppuccin-get-color 'blue))
    (set-face-attribute 'hydra-face-pink nil :foreground (catppuccin-get-color 'pink))
    (set-face-attribute 'hydra-face-teal nil :foreground (catppuccin-get-color 'teal))
    (set-face-attribute 'hydra-face-amaranth nil :foreground (catppuccin-get-color 'maroon))
    )

(general-define-key
 "C-j" '("Jump to char" . avy-goto-char-timer)
 "C-5" 'other-window ; analog to C-6
 [escape]  'keyboard-escape-quit ;; Makes Escape quit prompts (Minibuffer Escape)
 ;; Zooming In/Out
 "C-+"  'text-scale-increase
 "C--"  'text-scale-decrease
 "<C-wheel-up>"  'text-scale-increase
 "<C-wheel-down>"  'text-scale-decrease)

(jwj/evil
  :packages 'org-mode
  :keymaps 'org-mode-map
  "C-j" '("Jump to char" . avy-goto-char-timer)
  "M-RET" '("Insert item" . org-insert-item))

(jwj/local-leader-key
  :packages 'org-mode
  :keymaps 'org-mode-map
  "t" '("Toggle" . (keymap))
  "t l" '("link display" . org-toggle-link-display)
  "t i" '("image preview " . org-toggle-inline-images)
  "t b" '("beautify" . (lambda ()
                         (interactive)
                         (org-modern-mode 'toggle)
                         (svg-tag-mode 'toggle))))

(jwj/local-leader-key
  :packages 'rustic
  :keymaps 'rustic-mode-map
  "t" '("Run current test" . my/rustic-run-test-at-point-ts)
  "f" '("Run clippy fix" . rustic-cargo-clippy-fix )
  "b" '("build this package" . rustic-cargo-build))

(jwj/evil
  "g r" '("Show references" . xref-find-references))

(jwj/leader-key
  "SPC" '("Switch buffer" . consult-buffer)
  "."   '("Find file" . find-file)
  "\""  '("Yank history" . consult-yank-from-kill-ring)
  "u"   '("C-u" . universal-argument))        ;; SPC u for prefix arg

(jwj/leader-key
  :infix "b"
  "" '("Buffer" . (keymap))
  "n" '("Next" . next-buffer)
  "p" '("Previous" . previous-buffer)
  "s"  '("Switch to scratch buffer." .
         (lambda ()
           (interactive)
           (switch-to-buffer "*scratch*"))
         )
  "d" '("Kill buffer" . kill-current-buffer)
  "D" '("Kill buffer & window" . kill-buffer-and-window))

(jwj/leader-key
  :infix "d"
  "" '("Describe" . (keymap))
  "b" '("Bindings" . describe-bindings)
  "o" '("Symbol" . describe-symbol)
  "f" '("Function" . describe-function)
  )

(jwj/leader-key
  :infix "f"
  :packages 'consult
  ""  '("Files" . (keymap))
  "f" '("Find file" . find-file)
  "r" '("Recover" . recover-this-file)
  "s" '("Save file" . save-buffer)
  "S" '("Save as..." . write-file)
  "D" '("Delete file" . delete-file)
  "c" '("Copy file" . copy-file)
  "i"  '("init.el" .
         (lambda ()
           (interactive)
           (find-file (concat user-emacs-directory "init.el"))))
  "l" #'load-file
  )

(jwj/leader-key
  :infix "p"
  ""  '("Projects" . (keymap))
  "d" '("Open dired in project" . project-dired)
  "f" '("Find in project" . project-find-file)
  "s" '("Switch project" . project-switch-project)
  "b" '("Buffer in project" . consult-project-buffer)
  "k" '("Kill project buffers" . project-kill-buffers)
  "c" '("Compile project" . project-compile)
  )

(jwj/leader-key
  :infix "o"
  ""  '("Open/Org" . (keymap))
  "c" '("Capture" . org-capture)
  "a" '("Agenda" . org-agenda)
  "h" '("Headings" . consult-org-agenda)
  "t" '("Terminal" . my/open-vterm)
  "T" '("Terminal here" . my/open-vterm-here)
  "-" '("Dired" . dired-jump)
  )

(jwj/leader-key
  :infix "q"
  ""  '("Quit" . (keymap))
  "q" '("Quit Emacs" . save-buffers-kill-terminal)
  "r" '("Restart Emacs" . restart-emacs)
  )

(jwj/leader-key
  :infix "s"
  ""  '("Search" . (keymap))
  "g" '("rip[g]rep" . consult-ripgrep)
  "f" '("Fd file" . consult-fd)
  "l" '("Search line in file" . consult-line)
  "h" '("Org heading" . consult-org-heading)
  )

(jwj/leader-key
  :infix "t"
  ""  '("Toggle" . (keymap))
  "c" '("Clock" . (lambda ()
                    (interactive)
                    (require 'org-clock)
                    (if (org-clocking-p)
                        (org-clock-out)
                      (if (null org-clock-history)
                          (consult-quick-clock)
                        (org-clock-in-last)))))
  "C" '("Clock in task" . consult-quick-clock)
  "o" '("Olivetti Mode" . olivetti-mode)
  "t" '("Toggle truncated lines (wrap)" . visual-line-mode)
  "l" '("Toggle line numbers" . display-line-numbers-mode)
  "f" '("Toggle flycheck-mode" . flycheck-mode)
  )

(jwj/leader-key
  :infix "l"
  "" '("LSP" . (keymap))
  "f" '("Format" . lsp-format-buffer)
  "c" '("Code Action" . lsp-code-action?)
  "s" '("Symbols (Document)" . consult-lsp-file-symbols)
  "S" '("Symbols (Project)" . consult-lsp-symbols)
  "d" '("Diagnostics (Document)" . consult-lsp-file-diagnostics)
  "D" '("Diagnostics (Project)" . consult-lsp-diagnostics)
  )

(defhydra hydra-window-size ()
  "
^Zoom^                                ^Other
^^^^^^^-----------------------------------------
[_j_/_k_] shrink/enlarge height   [_q_] quit
[_h_/_l_] shrink/enlarge width
"
  ("q" nil :exit t)
  ("j" evil-window-decrease-height)
  ("k" evil-window-increase-height)
  ("h" evil-window-decrease-width)
  ("l" evil-window-increase-width))

(jwj/leader-key
  :infix "w"
  ""  '("Window" . (keymap))

  ;; --- Navigation (Focus) ---

  "h" '("Focus Left" . evil-window-left)
  "j" '("Focus Down" . evil-window-down)
  "k" '("Focus Up" . evil-window-up)
  "l" '("Focus Right" . evil-window-right)

  ;; --- Manipulation (Move the buffer) ---
  "H" '("Move window Left" . evil-window-move-far-left)
  "J" '("Move window Down" . evil-window-move-very-bottom)
  "K" '("Move window Up" . evil-window-move-very-top)
  "L" '("Move window Right" . evil-window-move-far-right)

  ;; --- Splitting (Visual Mnemonics) ---
  ;; "/" looks like a vertical line, so it splits right
  "/" '("Split Right" . evil-window-vsplit)
  "v" '("Split Right" . evil-window-vsplit) ;; Alias for vim habit

  ;; "-" looks like a horizontal line, so it splits below
  "-" '("Split Below" . evil-window-split)
  "s" '("Split Below" . evil-window-split)  ;; Alias for vim habit

  ;; --- Management ---
  "c" '("Close Window" . evil-window-delete)
  "d" '("Delete Window" . evil-window-delete) ;; Alias
  "r" '("Resize" . hydra-window-size/body)
  "=" '("Balance splits" . balance-windows)
  "u" 'winner-undo
  "m" '("Maximize (Toggle)" .
        (lambda ()
          (interactive)
          (if (= 1 (count-windows))
              (winner-undo)
            (delete-other-windows)))))

(jwj/leader-key
  :infix   "g"
  :packages 'magit
  ""   '("Git" . (keymap))
  "b"  #'magit-blame
  "c"  #'magit-clone
  "d"  #'magit-dispatch
  "i"  #'magit-init
  "s"  #'magit-status
  "S"  #'magit-stage-file
  "U"  #'magit-unstage-file
  "fd" #'magit-diff
  "fc" #'magit-file-checkout
  "fl" #'magit-file-dispatch
  "fF" #'magit-find-file)

(provide 'init-keys)
;;; init-keys.el ends here
