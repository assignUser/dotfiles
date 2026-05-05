;;; init-dashboard.el --- Startup dashboard -*- lexical-binding: t -*-

(defun jwj/dashboard-open-init ()
  "Open the main init file."
  (interactive)
  (find-file (expand-file-name "init.el" user-emacs-directory)))

(defun jwj/dashboard-open-org ()
  "Open the Org directory."
  (interactive)
  (dired org-directory))

(defun jwj/dashboard-open-terminal ()
  "Open a project-scoped terminal."
  (interactive)
  (jwj/open-term nil))

(defconst jwj/dashboard-initial-items
  '((recents . 8)
    (projects . 6)
    (bookmarks . 4))
  "Dashboard items rendered during startup.")

(defconst jwj/dashboard-full-items
  '((recents . 8)
    (projects . 6)
    (agenda . 6)
    (bookmarks . 4))
  "Dashboard items rendered after startup settles.")

(defun jwj/dashboard-load-agenda-deferred ()
  "Refresh the dashboard with agenda items after Emacs becomes idle."
  (run-with-idle-timer
   0.75 nil
   (lambda ()
     (when (get-buffer dashboard-buffer-name)
       (setq dashboard-items jwj/dashboard-full-items)
       (dashboard-refresh-buffer)))))

(use-package dashboard
  :straight (:host github :repo "emacs-dashboard/emacs-dashboard")
  :demand t
  :custom
  (dashboard-startup-banner 'official)
  (dashboard-center-content t)
  (dashboard-set-heading-icons t)
  (dashboard-set-file-icons t)
  (dashboard-show-shortcuts nil)
  (dashboard-projects-backend 'project-el)
  (dashboard-week-agenda t)
  (dashboard-items jwj/dashboard-initial-items)
  :config
  (set-face-attribute 'dashboard-items-face nil :weight 'regular)
  (set-face-attribute 'dashboard-no-items-face nil :weight 'regular)
  (let ((map dashboard-mode-map))
    (define-key map (kbd "r") #'recentf-open-files)
    (define-key map (kbd "p") #'project-switch-project)
    (define-key map (kbd "a") #'org-agenda)
    (define-key map (kbd "t") #'jwj/dashboard-open-terminal)
    (define-key map (kbd "g") #'magit-status)
    (define-key map (kbd "i") #'jwj/dashboard-open-init)
    (define-key map (kbd "q") #'quit-window))
  (with-eval-after-load 'evil
    (evil-define-key 'normal dashboard-mode-map
      (kbd "r") #'recentf-open-files
      (kbd "p") #'project-switch-project
      (kbd "a") #'org-agenda
      (kbd "t") #'jwj/dashboard-open-terminal
      (kbd "g") #'magit-status
      (kbd "i") #'jwj/dashboard-open-init
      (kbd "q") #'quit-window))
  (setq dashboard-footer-messages
        (list "Rust, Org, and Git. Keep the loop tight."))
  (setq dashboard-navigator-buttons
        `(((nil "Open Project" "Switch to a project" project-switch-project)
           (nil "Recent Files" "Open recent file list" recentf-open-files)
           (nil "Agenda" "Open Org agenda" org-agenda)
           (nil "Terminal" "Open terminal" jwj/dashboard-open-terminal))
          ((nil "Config" "Open init.el" jwj/dashboard-open-init)
           (nil "Org Dir" "Open org directory" jwj/dashboard-open-org)
           (nil "Magit" "Open magit status" magit-status)
           (nil "Scratch" "Switch to scratch buffer" (lambda (&rest _) (switch-to-buffer "*scratch*"))))))
  (add-hook 'emacs-startup-hook #'jwj/dashboard-load-agenda-deferred)
  (dashboard-setup-startup-hook))

(provide 'init-dashboard)
;;; init-dashboard.el ends here
