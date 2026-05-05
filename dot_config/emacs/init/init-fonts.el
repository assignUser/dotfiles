;;; init-fonts.el --- Font selection and face styling -*- lexical-binding: t -*-

(defvar jwj/default-font-size 120
  "Default font size in 1/10pt.")

(defvar jwj/default-font-name nil
  "Resolved default font name.")

(defvar jwj/term-font-name nil
  "Resolved font name for terminal buffers.")

(defvar jwj/comment-font-name nil
  "Resolved font name for comments.")

(defvar jwj/doc-comment-font-name nil
  "Resolved font name for docstrings.")

(defvar jwj/heading-font-name nil
  "Resolved font name for headings and type-like faces.")

(defvar jwj/function-font-name nil
  "Resolved font name for function-like faces.")

(defvar jwj/preferred-font-names
  '("Monaspace Argon NFF"
    "JetBrains Mono")
  "Preferred fixed-pitch fonts in priority order.")

(defvar jwj/preferred-term-font-names
  '("Monaspace Krypton NFF"
    "JetBrains Mono")
  "Preferred fixed-pitch fonts for terminal buffers.")

(defvar jwj/preferred-comment-font-names
  '("Monaspace Radon NFF"
    "Monaspace Radon"
    "Monaspace Argon NFF")
  "Preferred fonts for comments.")

(defvar jwj/preferred-doc-comment-font-names
  '("Monaspace Xenon NFF"
    "Monaspace Xenon"
    "Monaspace Argon NFF")
  "Preferred fonts for docstrings.")

(defvar jwj/preferred-heading-font-names
  '("Monaspace Xenon NFF"
    "Monaspace Xenon"
    "Monaspace Argon NFF")
  "Preferred fonts for headings and type-like faces.")

(defvar jwj/preferred-function-font-names jwj/preferred-font-names
   "Preferred fonts for function-like faces.")

(defun jwj/first-installed-font (font-names)
  "Return the first installed font from FONT-NAMES, or nil."
  (catch 'font
    (dolist (name font-names)
      (when (find-font (font-spec :name name))
        (throw 'font name)))
    nil))

(defun jwj/get-font-name (role)
  "Return the resolved font name for ROLE."
  (pcase role
    ('default
     (or jwj/default-font-name
         (setq jwj/default-font-name
               (jwj/first-installed-font jwj/preferred-font-names))))
    ('term
     (or jwj/term-font-name
         (setq jwj/term-font-name
               (or (jwj/first-installed-font jwj/preferred-term-font-names)
                   (jwj/get-font-name 'default)))))
    ('comment
     (or jwj/comment-font-name
         (setq jwj/comment-font-name
               (or (jwj/first-installed-font jwj/preferred-comment-font-names)
                   (jwj/get-font-name 'default)))))
    ('doc-comment
     (or jwj/doc-comment-font-name
         (setq jwj/doc-comment-font-name
               (or (jwj/first-installed-font jwj/preferred-doc-comment-font-names)
                   (jwj/get-font-name 'default)))))
    ('heading
     (or jwj/heading-font-name
         (setq jwj/heading-font-name
               (or (jwj/first-installed-font jwj/preferred-heading-font-names)
                   (jwj/get-font-name 'default)))))
    ('function
     (or jwj/function-font-name
         (setq jwj/function-font-name
               (or (jwj/first-installed-font jwj/preferred-function-font-names)
                   (jwj/get-font-name 'default)))))
    (_ (error "Unknown font role: %S" role))))

(defun jwj/apply-base-fonts ()
  "Apply the preferred base fonts to the current frame."
  (let ((font-name (jwj/get-font-name 'default)))
    (when font-name
      (set-face-attribute 'default nil
                          :font font-name
                          :height jwj/default-font-size)
      (set-face-attribute 'fixed-pitch nil
                          :font font-name
                          :height jwj/default-font-size))))

(defun jwj/apply-font-faces ()
  "Apply semantic font family choices across major UI and syntax faces."
  (let ((default-font (jwj/get-font-name 'default))
        (comment-font (jwj/get-font-name 'comment))
        (doc-font (jwj/get-font-name 'doc-comment))
        (heading-font (jwj/get-font-name 'heading))
        (function-font (jwj/get-font-name 'function)))
    (when default-font
      (set-face-attribute 'mode-line nil :family default-font :weight 'regular)
      (set-face-attribute 'mode-line-inactive nil :family default-font :weight 'light)
      (set-face-attribute 'tab-bar nil :family default-font :weight 'regular)
      (set-face-attribute 'tab-bar-tab nil :family default-font :weight 'medium)
      (set-face-attribute 'tab-bar-tab-inactive nil :family default-font :weight 'regular))
    (when comment-font
      (set-face-attribute 'font-lock-comment-face nil :family comment-font :slant 'normal)
      (set-face-attribute 'font-lock-comment-delimiter-face nil :family comment-font ))
    (when doc-font
      (set-face-attribute 'font-lock-doc-face nil :family doc-font))
    (when function-font
      (set-face-attribute 'font-lock-function-name-face nil :family function-font :weight 'medium))
    ;; (when heading-font
    ;;   (set-face-attribute 'font-lock-type-face nil :family heading-font :weight 'medium))
  )
)

(set-fontset-font t nil "Symbols Nerd Font Mono" nil 'append)
(jwj/apply-base-fonts)

(provide 'init-fonts)
;;; init-fonts.el ends here
