;;; ...  -*- lexical-binding: t -*-

(use-package org
  :straight '(:type built-in)
  :defer t
  :init
  (setq org-directory "~/org/")
  :custom
  (org-startup-with-link-previews t)
  (org-hide-emphasis-markers t)
  (org-agenda-files '("~/org/"))
  ;; (org-log-into-drawer "NOTES")
  (org-return-follows-link t)
  :hook
  ((org-mode . (lambda () (set-fill-column 90)))
   (org-mode . turn-on-visual-line-mode))
  :config
  (custom-set-faces
   `(org-document-title ((t (:height 1.6 :foreground ,(catppuccin-get-color 'blue)))))
   `(org-level-1          ((t (:height 1.4 :foreground ,(catppuccin-get-color 'sapphire)))))
   `(org-level-2          ((t (:height 1.3 :foreground ,(catppuccin-get-color 'sky)))))
   `(org-level-3          ((t (:height 1.2 :foreground ,(catppuccin-get-color 'teal)))))
   '(org-level-4          ((t (:height 1.2))))
   '(org-level-5          ((t (:height 1.2))))
   '(org-level-6          ((t (:height 1.2))))
   '(org-level-7          ((t (:height 1.2))))
   '(org-level-8          ((t (:height 1.2))))
   '(org-level-9          ((t (:height 1.2)))))

  )

(use-package org-modern
  :after org
  :hook
  (org-mode . org-modern-mode)
  :custom
  (org-modern-checkbox
   '((?X . "")
     (?- . #("–" 0 2 (composition ((2)))))
     (?\s . "")))
  (org-modern-todo 'nil)
  (org-modern-tag 'nil)
  (org-modern-timestamp 'nil)
  (org-modern-priority 'nil)
  (org-modern-star 'replace)
  )

(use-package svg-tag-mode
  :after org
  :hook
  (org-mode . svg-tag-mode)
  :config
  (defconst date-re "[0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}")
  (defconst time-re "[0-9]\\{2\\}:[0-9]\\{2\\}")
  (defconst day-re "[A-Za-z]\\{2,3\\}") ;; Mon Fri vs. Mo Fr
  (defconst day-time-re (format "\\(%s\\)? ?\\(%s\\)?\\(-%s\\)?" day-re time-re time-re))

  ;; (defun my/svg-icon (name)
  ;; ;; :collection 'material nutzt die mitgelieferte Material-Icon-Sammlung von svg-lib
  ;;   (svg-lib-icon name nil
  ;;                 :collection "material"
  ;;                 :scale 1.0         ;; ggf. 0.9–1.1 feinjustieren
  ;;                 :padding 0.5
  ;;                 :margin 0
  ;;                 :stroke 0
  ;;                 :ascent 0.8))


  (defun svg-progress-percent (value)
    (svg-image (svg-lib-concat
                (svg-lib-progress-bar (/ (string-to-number value) 100.0)
                                      nil :margin 0 :stroke 2 :radius 3 :padding 2 :width 11)
                (svg-lib-tag (concat value "%")
                             nil :stroke 0 :margin 0)) :ascent 'center))

  (defun svg-progress-count (value)
    (let* ((seq (mapcar #'string-to-number (split-string value "/")))
           (count (float (car seq)))
           (total (float (cadr seq))))
      (svg-image (svg-lib-concat
                  (svg-lib-progress-bar (/ count total) nil
                                        :margin 0 :stroke 2 :radius 3 :padding 2 :width 11)
                  (svg-lib-tag value nil
                               :stroke 0 :margin 0)) :ascent 'center)))
  (setq svg-tag-tags
        `(
          ;; ("\\(:#[A-Za-z0-9]+\\)" . ((lambda (tag)
          ;;                              (svg-tag-make tag :beg 2 :face 'org-tag :inverse t))))
          ;; ("\\(:#[A-Za-z0-9]+:\\)$" . ((lambda (tag)
          ;;                                (svg-tag-make tag :beg 2 :end -1 :face 'org-tag :inverse t))))
          ("TODO" . ((lambda (tag) (svg-tag-make "TODO" :face 'org-todo :inverse t :margin 0))))
          ("IDEA" . ((lambda (tag) (svg-tag-make "IDEA" :face 'org-agenda-done :inverse t :margin 0))))
          ("DONE" . ((lambda (tag) (svg-tag-make "DONE" :face 'org-done :margin 0))))
          ("PROJ" . ((lambda (tag) (svg-tag-make "PROJ" :face 'org-agenda-proj :inverse t :margin 0))))
          ;; Progress
          ("\\(\\[[0-9]\\{1,3\\}%\\]\\)" . ((lambda (tag)
                                              (svg-progress-percent (substring tag 1 -2)))))
          ("\\(\\[[0-9]+/[0-9]+\\]\\)" . ((lambda (tag)
                                            (svg-progress-count (substring tag 1 -1)))))

          ;; Citation of the form [cite:@Knuth:1984]
          ("\\(\\[cite:@[A-Za-z]+:\\)" . ((lambda (tag)
                                            (svg-tag-make tag
                                                          :inverse t
                                                          :beg 7 :end -1
                                                          :crop-right t))))
          ("\\[cite:@[A-Za-z]+:\\([0-9]+\\]\\)" . ((lambda (tag)
                                                     (svg-tag-make tag
                                                                   :end -1
                                                                   :crop-left t))))


          ;; Active date (with or without day name, with or without time)
          (,(format "\\(<%s>\\)" date-re) .
           ((lambda (tag)
              (svg-tag-make tag :beg 1 :end -1 :margin 0))))
          (,(format "\\(<%s \\)%s>" date-re day-time-re) .
           ((lambda (tag)
              (svg-tag-make tag :beg 1 :inverse nil :crop-right t :margin 0))))
          (,(format "<%s \\(%s>\\)" date-re day-time-re) .
           ((lambda (tag)
              (svg-tag-make tag :end -1 :inverse t :crop-left t :margin 0))))

          ;; Inactive date  (with or without day name, with or without time)
          (,(format "\\(\\[%s\\]\\)" date-re) .
           ((lambda (tag)
              (svg-tag-make tag :beg 1 :end -1 :margin 0 :face 'org-date))))
          (,(format "\\(\\[%s \\)%s\\]" date-re day-time-re) .
           ((lambda (tag)
              (svg-tag-make tag :beg 1 :inverse nil :crop-right t :margin 0 :face 'org-date))))
          (,(format "\\[%s \\(%s\\]\\)" date-re day-time-re) .
           ((lambda (tag)
              (svg-tag-make tag :end -1 :inverse t :crop-left t :margin 0 :face 'org-date))))
          ))
  )

(use-package org-noter
  :defer t
  :custom
  (org-noter-default-notes-file-names '("notes.org" "glr.org"))
  (org-noter-notes-search-path  (cons org-directory '()))
  :general
  (jwj/evil
  :keymaps 'org-noter-doc-mode-map
  "i" '("Insert note" . org-noter-insert-note)
  "q" '("Kill session" . org-noter-kill-session)
  )
)

;;;###autoload
(defun my-consult-org-clock-in (cand)
  "Clock in on selected candidate"
  (unless (markerp cand)
    (user-error "Candidate is not a marker"))
  (save-excursion
    (with-current-buffer (marker-buffer cand)
      (goto-char cand)
      (org-clock-in))))

;;;###autoload
(defun my-clockin-state ()
  "Pre-view org-headings and clock in on return"
  (consult--state-with-return (consult--jump-preview) #'my-consult-org-clock-in))

;;;###autoload
(defun consult-quick-clock ()
  "Pre-view org-agenda headings and clock-in on RETURN"
  (interactive )
  (require 'consult-org)
  (unless org-agenda-files
    (user-error "No agenda files"))

  (let ((prefix t)
        (match t)
        (scope 'agenda))
    (consult--read
     (consult--slow-operation "Collecting headings..."
       (or (consult-org--headings prefix match scope)
           (user-error "No headings")))
     :prompt "Clock in on: "
     :category 'org-heading
     :sort nil
     :require-match t
     :history '(:input consult-org--history)
     :narrow (consult-org--narrow)
     :initial-narrow 116 ;; TODOs.
     :state (my-clockin-state)
     :annotate #'consult-org--annotate
     :group (and prefix #'consult-org--group)
     :lookup (apply-partially #'consult--lookup-prop 'org-marker))))

(use-package org-clock-reminder
  :defer t
  :straight (:host github :repo "inickey/org-clock-reminder")
  :custom
  (org-clock-reminder-inactive-notifications-p t)
  (org-clock-reminder-inactive-text "No task is being clocked. Reminder to clock-in")
  (org-clock-reminder-inactive-title "Clock Notification")
  (org-clock-reminder-active-title "Clock Notification")
  (org-clock-reminder-icons (cons  (expand-file-name "straight/repos/org-clock-reminder/icons/clocking.png" user-emacs-directory)
                                   (expand-file-name "straight/repos/org-clock-reminder/icons/inactivity.png" user-emacs-directory)))
  :hook (after-init . org-clock-reminder-mode)
)


(provide 'init-org)
;;; init-org.el ends here
