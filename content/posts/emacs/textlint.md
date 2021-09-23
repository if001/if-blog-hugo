---
title: "emacsにtext-lintを導入する"
slug: "text-lint"
tags: ["emacs"]
date: "2021-09-23T20:00:00+09:00"
draft: false
---

日本語文章用に、textlintを導入する。

## install
今回は.emacs.d以下にsite-lispというディレクトリを作り、そこにtextlintをinstallする。

```
cd .emacs.d/site-lisp
npm install -D textlint
```

textlintのルールには、以下の２つを使う。

https://github.com/textlint-ja/textlint-rule-preset-japanese

https://github.com/textlint-ja/textlint-rule-preset-ja-technical-writing

```
npm install -D textlint-rule-preset-japanese
npm install -D textlint-rule-preset-ja-technical-writing
```


.textlintrcを作成。rulesはとりあえずシンプルに以下のみ。

```json
{
  "rules": {
      "preset-japanese": true,
      "preset-ja-technical-writing": true
  }
}
```

## elisp
flycheckを使う。

emacsからtextlintを実行できるように、`.emacs.d/site-lisp/node_modules/bin`にpathを通す。

`.emacs.d/site-lisp`に.textlintrcを作成したので、textlintに--configでtextlintrcを渡す。

`"--config" (eval (expand-file-name (concat user-emacs-directory "site-lisp/.textlintrc")))`


全体

```lisp
(use-package flycheck
  :ensure t
  :init
  (global-flycheck-mode t)
  :config
  (flycheck-define-checker textlint
    "A linter for prose."
    :command ("textlint" "--format" "unix" "--config" (eval (expand-file-name (concat user-emacs-directory "site-lisp/.textlintrc")))
              source-inplace)
    :error-patterns
    ((warning line-start (file-name) ":" line ":" column ": "
	      (id (one-or-more (not (any " "))))
	      (message (one-or-more not-newline)
		       (zero-or-more "\n" (any " ") (one-or-more not-newline)))
	      line-end))
    :modes (text-mode markdown-mode gfm-mode))
  (add-to-list 'flycheck-checkers 'textlint)
    
  ;; node_module-sのpathを通す
  (with-eval-after-load 'markdown-mode
    (add-hook 'markdown-mode-hook
              (lambda ()
		(flycheck-mode)
		(setq exec-path (add-to-list 'exec-path (concat user-emacs-directory "site-lisp/node_modules/.bin")))
		)))
  )
```
