;;; init-term.el --- Configuration for
;;; Commentary:
;;;   much thanks to:
;;;     - http://echosa.github.io/blog/2012/06/06/improving-ansi-term/
;;;     - https://emacs.stackexchange.com/questions/328/how-to-override-keybindings-for-term
;;;     - http://oremacs.com/2015/01/01/three-ansi-term-tips/
;;;     - https://emacs.stackexchange.com/questions/18672/how-to-define-a-function-that-calls-a-console-process-using-ansi-term
;;;     - https://github.com/wpcarro/pc_settings/commit/aab701e10e52afec790b069a5e14c961c6f32307
;;; Code:

;;; git diff and glp are too tall
;;; fzf -> use helm for c-r, c-t, c-y

(defadvice term-sentinel (around my-advice-term-sentinel (proc msg))
  (if (memq (process-status proc) '(signal exit))
      (let ((buffer (process-buffer proc)))
        ad-do-it
        ;; (kill-window)
        )
    ad-do-it))
(ad-activate 'term-sentinel)

(defadvice ansi-term (before force-zsh)
  (interactive (ansi-term "/bin/zsh")))
(ad-activate 'ansi-term)

(defun rm/switch-to-terminal-other-window ()
  "Switch to the project's root term instance.
Creates it if it doesn't exist.
If the window is already open, moves focus to that window.
Otherwise, opens the terminal in 'other' window."
  (interactive)
  (rm/run-shell-command "" nil t)
)

(defun rm/switch-to-terminal-window ()
  "Switch to the project's root term instance.
Creates it if it doesn't exist.
If the window is already open, moves focus to that window.
Otherwise, opens the terminal in this window."
  (interactive)
  (rm/run-shell-command "" nil t t))

(defun rm/term-exec-hook ()
  (set-buffer-process-coding-system 'utf-8-unix 'utf-8-unix)
  ;; (term-send-raw-string (format "export LINES=%s\n" (truncate (* (/ 2.0 3) (window-height)))))
)
(add-hook 'term-exec-hook 'rm/term-exec-hook)

;; force term-mode to expose the passed global binding
(defun expose-global-binding-in-term (binding)
   (define-key term-raw-map binding
     (lookup-key (current-global-map) binding)))

(defun rm/evil-open-at-bottom ()
  (interactive)
  (end-of-buffer)
  (evil-insert-state 1)
  (term-send-raw-string "\b"))

(eval-after-load "term"
  '(progn
     ;; ensure that scrolling doesn't break on output
     (setq term-scroll-to-bottom-on-output t)))


(defun rm/term-mode-hook ()
  (goto-address-mode)
  (linum-mode -1)

  (setq window-max-chars-per-line 1000)
  ;; (setq term-scroll-show-maximum-output t)

  ;; expose for Ctrl-{h,j,k,l} window movement
  (expose-global-binding-in-term (kbd "C-l"))
  (expose-global-binding-in-term (kbd "C-h"))
  (expose-global-binding-in-term (kbd "C-j"))
  (expose-global-binding-in-term (kbd "C-k"))

  ;; keep M-x
  (expose-global-binding-in-term (kbd "M-x"))
  (expose-global-binding-in-term (kbd "M-:"))

  ;; ensure these are unset in term
  (evil-define-key 'insert term-raw-map
    (kbd "C-k") nil
    (kbd "C-p") nil
    (kbd "C-n") nil
    (kbd "C-r") nil
    (kbd "C-t") nil
    (kbd "C-e") nil
    (kbd "C-a") nil
    (kbd "C-c") 'term-interrupt-subjob
  ;;   (kbd "ESC") 'term-pager-discard
  )
  (evil-define-key 'normal term-raw-map
    (kbd "C-r") nil
    (kbd "C-c") 'term-interrupt-subjob
    (kbd "i") 'rm/evil-open-at-bottom
    (kbd ".") 'rm/repeat-last-shell-command
  )

  (define-key term-raw-map (kbd "C-r") 'wc/helm-shell-history)
  (define-key term-raw-map (kbd "M-j") 'wc/helm-autojump)
  (define-key term-raw-map (kbd "M-g") 'wc/helm-git-branches)
  (define-key term-raw-map (kbd "s-v") 'term-paste)
  (define-key term-raw-map (kbd "C-z") 'rm/helm-shell-commands)
)
(add-hook 'term-mode-hook 'rm/term-mode-hook)

(add-hook 'shell-mode-hook (lambda () (linum-mode -1)))



(defun wc/git-branches ()
  (setq branches (shell-command-to-string "git branch -a | tr -d '* ' | sed 's/^remotes\\/origin\\///' | sort | uniq"))
  (split-string branches "\n"))

(defun wc/shell-history ()
  (setq history (shell-command-to-string "tac ~/.zsh_history | sed 's/^.*;//'"))
  (split-string history "\n"))


(defun wc/helm-shell-history ()
  "Reverse-I search using Helm."
  (interactive)
  (helm :sources (helm-build-in-buffer-source "helm-shell-history"
                 :data (wc/shell-history)
                 :action 'rm/run-shell-command)
      :buffer "*helm shell history*"))


(defvar rm/common-mix-commands
  (helm-build-in-buffer-source "Common mix commands"
    :data '(
            "MIX_ENV=test iex -S mix"
            "iex -S mix"
            "mix test"
            "mix docs.dash"
            "mix deps.get"
            "mix compile --force"
            "mix credo --strict"
            "mix dialyzer"
            )
    :action 'rm/run-shell-command))


(defvar rm/common-cli-commands
  (helm-build-in-buffer-source "Common cli commands"
    :data '(
            "git commit --amend --no-edit"
            "gst"
            "git diff --staged"
            )
    :action 'rm/run-shell-command))

(defun rm/term-checkout-branch (branch)
  "Fires `gco` BRANCH in a local term."
  (rm/run-shell-command (format "gco %s" branch) nil t))

(defun rm/helm-gco-branches (str)
  "Checkout a git branch with helm.
STR is ignored.
This is a convenience function for helm actions."
  (interactive)
  (helm :sources (helm-build-in-buffer-source "git branches"
                 :data (wc/git-branches)
                 :action 'rm/term-checkout-branch)
      :buffer "*helm git branches*"))

(defvar rm/git-chain-commands
  (helm-build-in-buffer-source "Git branch commands"
    :data '(
            "gco [branch-to-checkout]"
            )
    :action 'rm/helm-gco-branches))

(defvar rm/custom-command
  (helm-build-in-buffer-source "Custom"
    :data '(
            "ENTER via prompt"
            )
    :action 'rm/run-shell-command-from-minibuffer-action))

(defun rm/helm-shell-commands ()
  "Helm interface to fire shell commands in a local terminal session."
  (interactive)
  (helm :sources '(
                   rm/custom-command
                   rm/git-chain-commands
                   rm/common-cli-commands
                   rm/common-mix-commands
                   ;; wc/discover-shell-commands
                  )
  :buffer "*helm mix commands*"))

(defun rm/repeat-last-shell-command ()
  "Rerun the last shell command in the local project terminal."
  (interactive)
  (rm/run-shell-command "!! "))

(defun rm/run-shell-command-from-minibuffer-action (command)
  "Open the mini-buffer for command input.
COMMAND is ignored.
This is a convenience function for helm."
  (interactive)
  (rm/run-shell-command-from-minibuffer))

(defun rm/run-shell-command-from-minibuffer ()
  "Run COMMAND in a `term' buffer."
  (interactive)
  (let* ((command (read-from-minibuffer "$ ")))
    (rm/run-shell-command command nil t)))


(defun rm/term-scroll-page-up ()
  "Scroll the term window up."
  (interactive)
  (setq other-window-scroll-buffer (rm/get-term-buffer))
  (scroll-other-window))

(defun rm/term-scroll-page-down ()
  "Scroll the term window down."
  (interactive)
  (setq other-window-scroll-buffer (rm/get-term-buffer))
  (scroll-other-window-down))


(defun rm/run-shell-command (command &optional start-new-session focus-on-term-window use-this-window) ;; string
  "Run a passed string as a CLI command in the project's local terminal.

If no term for the current project exists, it is created and the command is fired.
If new-session-p is non-nil, a new session will be created, even if one already exists.
If focus-on-term-window is non-nil, Emacs will select on the window the term session is in after sending the string.

(rm/run-shell-command 'gst') ;; runs `gst` in an existing terminal session.
(rm/run-shell-command 'glp' t) ;; runs `glp` in a new terminal session.
(rm/run-shell-command 'git diff' nil t) ;; run `git diff` and move cursor to the term window running it."
  (cond ((rm/is-term-window-p) ())
        (use-this-window (unless (rm/term-window-open-p) (rm/show-terminal-this-window)))
        (t (rm/show-terminal-other-window)))

  (cond ((or start-new-session (not (rm/term-session-exists-p)))
         (rm/send-command-to-new-terminal (format "%s\n" command))
        )
        (t (rm/send-command-to-existing-terminal (format "%s\n" command))))

  (if (or focus-on-term-window use-this-window)
      (rm/focus-on-terminal-window)))

(defun rm/start-new-terminal ()
  "Create a new terminal session."
  (projectile-with-default-dir (projectile-project-root)
    (set-buffer (make-term (replace-regexp-in-string "\*" "" (rm/new-term-buffer-name)) "/bin/zsh"))
    (term-mode)
    (term-char-mode)
  )
)

(defun rm/send-command-to-new-terminal (command)
  "COMMAND is the command to send.
Creates a new terminal session in the current projectile root, and fires the passed command."
  (rm/start-new-terminal)
  (term-send-raw-string command)
)

(defun rm/send-command-to-existing-terminal (command)
  "COMMAND is the command to send.
Sends the command to the passed buffer name via term-send-raw-string.
Crashes if the buffer name does not exist, or the buffer has no terminal process."
  (set-buffer (rm/local-term-buffer-name))
  (term-send-raw-string command))


(defun rm/local-term-buffer-name ()
  "Return a name for a terminal buffer based on the projectile project it is in."
  (concat "*term " (projectile-project-name) "*"))

(defun rm/new-term-buffer-name ()
  "Return a new buffer name for the current context.  If one exists, append`<n>`."
  (generate-new-buffer-name
    (rm/local-term-buffer-name)))

(defun rm/get-term-buffer ()
  "Return the current local term buffer."
  (get-buffer (rm/local-term-buffer-name)))

(defun rm/term-session-exists-p ()
  "Return non-nil if a session for the current context exists."
  (get-buffer (rm/local-term-buffer-name)))

(defun rm/is-term-window-p ()
  "Return non-nil if the current window is a *term window."
  (string-prefix-p "*term " (buffer-name (current-buffer))))

(defun rm/term-window-open-p ()
  "Return non-nil if the project's term window is already open."
  (if (get-buffer-window (rm/local-term-buffer-name)) t
    nil))


(defun rm/show-terminal-this-window ()
  "Crashes if a terminal session does not exist."
  (display-buffer-same-window (get-buffer (rm/local-term-buffer-name)) nil))

(defun rm/show-terminal-other-window ()
  "Crashes if a terminal session does not exist."
  (display-buffer (get-buffer (rm/local-term-buffer-name)) 'display-buffer-reuse-window))

(defun rm/get-term-window ()
  "Gets the window for terminal buffer."
  (get-buffer-window (rm/local-term-buffer-name) t))

(defun rm/focus-on-terminal-window ()
  "Crashes if a terminal session does not exist."
  (select-window (rm/get-term-window))
  (evil-insert 1))

(provide 'init-term)
;;; init-term.el ends here
