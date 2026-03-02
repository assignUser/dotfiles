;;; ...  -*- lexical-binding: t -*-

;; Set some options to speed up emacs
(setq       package-enable-at-startup nil ; prevent package.el loading packages prior to their init-file loading
            package-native-compile    t)

(scroll-bar-mode -1)               ; disable scrollbar
(tool-bar-mode -1)                 ; disable toolbar
(tooltip-mode -1)                  ; disable tooltips
(menu-bar-mode -1)                 ; disable menubar

;; Increase the GC threshold to 100MB (default is 800kb)
;; This prevents the garbage collector from running too often during startup/editing.
(setq gc-cons-threshold (* 1000 1024 1024))
(setenv "LSP_USE_PLISTS" "true")

;; Increase the amount of data Emacs reads from processes (like LSP servers)
(setq read-process-output-max (* 4 1024 1024)) ;; 2mb
