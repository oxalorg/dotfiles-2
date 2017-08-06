;;; init-themes.el --- Theme configuration
;;; Commentary:
;;; Code:

(use-package doom-themes
  :init
  ;;; Settings (defaults)
  (setq doom-enable-bold t
      doom-enable-italic t

      ;; doom-one specific settings
      doom-one-brighter-comments t)

  ;; brighter source buffers (that represent files)
  (add-hook 'find-file-hook 'doom-buffer-mode-maybe)
  ;; if you use auto-revert-mode
  (add-hook 'after-revert-hook 'doom-buffer-mode-maybe)
  ;; you can brighten other buffers (unconditionally) with:
  (add-hook 'ediff-prepare-buffer-hook 'doom-buffer-mode)

  :config
  (load-theme 'doom-tomorrow-night))


(use-package smart-mode-line
  :config
  (setq sml/no-confirm-load-theme t)
  (sml/setup))

(use-package color-identifiers-mode
  :config
  (global-color-identifiers-mode))

(use-package rainbow-delimiters
  :config
  (add-hook 'prog-mode-hook 'rainbow-delimiters-mode))

(use-package solaire-mode
  :config
  ;; ;; brighten buffers (that represent real files)
  (add-hook 'after-change-major-mode-hook #'turn-on-solaire-mode)
  ;; ...if you use auto-revert-mode:
  (add-hook 'after-revert-hook #'turn-on-solaire-mode))


(provide 'init-themes)
;;; init-themes.el ends here
