;;; ~/dotfiles/emacs/.doom.d/+clojure.el -*- lexical-binding: t; -*-

(require 'cl-lib)
(require 'dash)


(defmacro comment (&rest _)
  "Comment out one or more s-expressions."
  nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; systemic
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Fix docstring highlighting for `defsys`
(put 'defsys 'clojure-doc-string-elt 2)

;; The below functions allow you to control systemic from Emacs.
;; Personally, I have found binding them to keys to be very convenient.
(defun systemic/restart ()
  "Restarts all systemic systems"
  (interactive)
  (cider-interactive-eval "(systemic.core/restart!)"))

(defun systemic/start ()
  "Starts all systemic systems"
  (interactive)
  (cider-interactive-eval "(systemic.core/start!)"))

(defun systemic/stop ()
  "Stops all systemic systems"
  (interactive)
  (cider-interactive-eval "(systemic.core/stop!)"))

(defun wing-sync-libs ()
  (interactive)
  (cider-interactive-eval "(wing.repl/sync-libs)"))

(defhydra hydra-systemic (:exit t)
  ("r" systemic/restart "systemic/restart")
  ("s" systemic/start "systemic/start")
  ("S" systemic/stop "systemic/stop")
  ("l" wing-sync-libs "wing-sync-libs"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; cider company bindings fix
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; https://github.com/company-mode/company-quickhelp/issues/17
;; https://github.com/hlissner/doom-emacs/issues/2610

(let* ((bindings
        '("C-s" company-filter-candidates
          "C-h" company-show-doc-buffer
          "C-j" company-select-next
          "C-k" company-select-previous
          "C-l" company-complete-selection
          "<down>" company-select-next
          "<up>" company-select-previous
          "<right>" company-complete-selection
          "RET" company-complete-selection
          "C-p" company-other-backend
          "C-n" company-other-backend
          "TAB" company-complete-common-or-cycle
          ))
       (unset-bindings (mapcar (lambda (value)
                                 (if (stringp value)
                                     value
                                   nil))
                               bindings)))

  (defun custom/unset-company-bindings (&rest _args)
    (apply 'general-define-key
           :keymaps 'override
           :states  'insert
           unset-bindings))

  (defun custom/set-company-bindings (&rest _args)
    (apply 'general-define-key
           :keymaps 'override
           :states  'insert
           bindings)))

(after! cider
  (add-hook 'company-completion-started-hook 'custom/set-company-bindings)
  (add-hook 'company-completion-finished-hook 'custom/unset-company-bindings)
  (add-hook 'company-completion-cancelled-hook 'custom/unset-company-bindings))

;; fix company box in cider
(after! company-box
  (add-function
   :after
   (symbol-function 'company-box-doc--show)
   (lambda (_ frame)
     (let* ((doc-frame (frame-parameter frame 'company-box-doc-frame)))
       (when (frame-visible-p doc-frame)
         (make-frame-visible (company-box--get-frame)))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; cider helpers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun russ/switch-cider-connection ()
  "Buries the current cider repl buffer, promoting other cider conns."
  (interactive)
  (bury-buffer (cider-current-repl))
  (cider-switch-to-repl-buffer)
  (cider-switch-to-last-clojure-buffer)
  (cider-refresh-dynamic-font-lock))

(defun rs/cider-cycle-buffer-type ()
  "Cycles between clojure, clojurescript, and clojurec repl types"
  (interactive)
  (if (string= "cljc" (file-name-extension (buffer-file-name)))
      (let ((repl-open? (get-buffer-window (cider-current-repl-buffer)))
            (window (selected-window)))
        (setq clojure-verify-major-mode nil)
        (cond
         ((eq 'clojurec-mode major-mode) (clojure-mode))
         ((eq 'clojure-mode major-mode) (clojurescript-mode))
         ((eq 'clojurescript-mode major-mode) (clojurec-mode)))
        (when (and repl-open? (not (eq 'clojurec-mode major-mode)))
          (cider-switch-to-repl-buffer)
          (select-window window)))
    (message (concat "Cycle repl type called from non .cljc file" (buffer-file-name)))))

(defun rs/cider-clear-all-buffers ()
  "Clear all cider buffers"
  (interactive)
  (let ((inhibit-read-only 't))
    (dolist (repl (cider-repls))
      (with-current-buffer repl
        (cider-repl--clear-region (point-min) cider-repl-prompt-start-mark)
        (cider-repl--clear-region cider-repl-output-start cider-repl-output-end)
        (when (< (point) cider-repl-input-start-mark)
          (goto-char cider-repl-input-start-mark))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; cider bindings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defhydra hydra-clojure-docs (:exit t)
  ("n" cider-browse-ns "Browse Namespace" :column "Clojure doc lookup")
  ("s" cider-browse-spec "Browse Spec")
  ("h" cider-doc "cider-doc")
  ("f" clojure-essential-ref "Essential Ref"))

(defhydra hydra-cider-mode (:exit t)
  ("'" cider-jack-in "jack-in" :column "Jack in/Connect")
  ("\"" cider-jack-in-cljs "jack-in-cljs")
  ("c" cider-connect "cider-connect")
  ("C" cider-connect-cljs "cider-connect-cljs")

  ("DEL" ivy-cider-browse-ns "ivy-cider-browse-ns" :column "Browse")
  ("\\" ivy-cider-apropos "cider-apropos")
  ("j" cider-find-var "cider-find-var")
  ("h" cider-doc "cider-doc")
  ("d" hydra-clojure-docs/body "hydra-clojure-docs/body")

  ("l" cider-load-this-file "cider-load-this-file" :column "Eval/Repl")
  ("b" cider-eval-buffer "cider-eval-buffer")
  ("p" cider-eval-sexp-at-point "cider-eval-sexp-at-point")
  ("f" cider-eval-defun-at-point "cider-eval-defun-at-point")
  ("B" cider-switch-to-repl-buffer "cider-switch-to-repl-buffer")
  ("n" cider-repl-set-ns "cider-repl-set-ns")
  ("k" rs/cider-clear-all-buffers "rs/cider-clear-all-buffers")
  ("i" cider-inspect-last-result "cider-inspect-last-result")
  ("r" rs/cider-cycle-buffer-type "rs/cider-cycle-buffer-type")
  ("s" russ/switch-cider-connection "russ/switch-cider-connection")
  ("S" hydra-systemic/body "hydra-systemic")

  ("t" cider-test-run-ns-tests "cider-test-run-ns-tests" :column "Test")
  ("T" cider-test-run-test "cider-test-run-test")

  ("m" clojure-move-to-let "clojure-move-to-let" :column "Refactor")
  )

(map!
 (:after cider-mode
  (:map cider-mode-map
   (:leader
    :n "c" #'hydra-cider-mode/body))
  (:after cider-browse-ns-mode
   (:map cider-browse-ns-mode-map
    :n "RET"       #'cider-browse-ns-operate-at-point))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; cider reload this file, on-save
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun cider-load-this-file ()
  (interactive)
  (cider-load-file (buffer-file-name)))

(defun clj-file-p ()
  (string-match-p (rx (or
                       (and ".clj" eol)
                       (and ".cljc" eol)))
                  (buffer-file-name)))

(defun cider-eval-if-cider-buffer ()
  (interactive)
  (if (and
       (boundp 'cider-mode)
       cider-mode
       cider-eval-on-save
       (clj-file-p))
      (cider-load-this-file)))

(setq cider-eval-on-save t)

(defun cider-toggle-eval-on-save ()
  (interactive)
  (let ((new-val (not cider-eval-on-save)))
    (print! "setting eval-on-save: %s" new-val)
    (setq cider-eval-on-save new-val)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; flycheck
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package! flycheck-clj-kondo)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; company-css-classes-backend
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; TODO fix to work when no dir-locals are set
;; (use-package! company-css-classes)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; clojure and cider mode configs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package! clojure-mode
  :mode "\\.clj$"
  :mode "\\.edn$"
  :mode "\\(?:build\\|profile\\)\\.boot$"
  :mode ("\\.cljs$" . clojurescript-mode)
  :mode ("\\.cljc$" . clojurec-mode)

  :config
  (require 'flycheck-clj-kondo)

  (add-hook
   'cider-mode-hook
   #'(lambda ()
       (add-hook
        'after-save-hook
        #'cider-eval-if-cider-buffer)))

  ;; (set-company-backend!
  ;;   'clojurescript-mode
  ;;   '(company-capf company-yasnippet company-flow company-css-classes-backend))

  ;; (set-company-backend!
  ;;   'clojurec-mode
  ;;   '(company-capf company-yasnippet company-flow company-css-classes-backend))

  (setq cider-known-endpoints
        '(("system-babashka" "localhost" "1667")
          ("doctor-be" "localhost" "3336")
          ("doctor-fe" "localhost" "3335")
          ("expo-be" "localhost" "5553")
          ("expo-fe" "localhost" "5554")
          ))

  (setq cljr-magic-require-namespaces
        '(("io" . "clojure.java.io")
          ("sh" . "clojure.java.shell")
          ("set" . "clojure.set")
          ("str" . "cuerdas.core")
          ("path" . "pathetic.core")
          ("walk" . "clojure.walk")
          ("zip" . "clojure.zip")
          ("async" . "clojure.core.async")
          ("component" . "com.stuartsierra.component")
          ("sql" . "honeysql.core")
          ("csv" . "clojure.data.csv")
          ("json" . "cheshire.core")
          ("s" . "clojure.spec.alpha")
          ("rf" . "re-frame.core")
          ("r" . "reagent.core")
          ("t" . "tick.alpha.api"))

        clojure-align-forms-automatically t

        cider-save-file-on-load t

        cider-show-error-buffer 'only-in-repl
        cider-default-cljs-repl 'shadow
        cider-offer-to-open-cljs-app-in-browser nil
        cider-auto-jump-to-error nil
        cider-auto-select-error-buffer nil
        cider-auto-select-test-report-buffer nil
        cider-test-show-report-on-success t
        ;; cider-session-name-template "%j:%S"
        )

  (set-file-template! "/deps\\.edn$" :trigger "__deps.edn" :mode 'clojure-mode)
  (set-file-template! "/user\\.clj$" :trigger "__user.clj" :mode 'clojure-mode))

(use-package! ivy-cider
  :after cider-mode)

(use-package! clojure-essential-ref)
(use-package! clojure-essential-ref-nov
  :init
  (setq clojure-essential-ref-nov-epub-path
        "~/Dropbox/books/Clojure_The_Essential_Reference_v30.epub")
  (setq clojure-essential-ref-default-browse-fn
        #'clojure-essential-ref-nov-browse))

;; from @glittershark
;; https://cs.tvl.fyi/depot/-/blob/users/glittershark/emacs.d/+bindings.el#L1256-1267
(defun grfn/cider-copy-last-result ()
  (interactive)
  (cider-interactive-eval
   "*1"
   (nrepl-make-response-handler
    (current-buffer)
    (lambda (_ value)
      (kill-new value)
      (message "Copied last result (%s) to clipboard"
               (if (= (length value) 1) "1 char"
                 (format "%d chars" (length value)))))
    nil nil nil)))
