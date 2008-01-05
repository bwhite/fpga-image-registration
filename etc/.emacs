;;Slime/LISP
;(add-to-list 'load-path "/Users/brandynwhite/.emacs.d/slime")  ; your SLIME directory
;(require 'slime)
;(add-hook 'lisp-mode-hook (lambda () (slime-mode t)))
;(add-hook 'inferior-lisp-mode-hook (lambda () (inferior-slime-mode t)))
;(setq inferior-lisp-program "/opt/local/bin/sbcl") ; your Lisp system
;(slime-setup)

;;Key bindings
(setq mac-option-modifier 'meta)

;;Other
(setq visible-bell t)
(custom-set-variables
  ;; custom-set-variables was added by Custom -- don't edit or cut/paste it!
  ;; Your init file should contain only one such instance.
 '(vhdl-reset-active-high t)
 '(vhdl-reset-kind (quote sync))
 '(vhdl-standard (quote (93 nil)))
 '(vhdl-upper-case-keywords t))
(custom-set-faces
  ;; custom-set-faces was added by Custom -- don't edit or cut/paste it!
  ;; Your init file should contain only one such instance.
 )
