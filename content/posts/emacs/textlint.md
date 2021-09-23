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

textlintのルールには、以下を使う。

日本語用のpreset(ルールの詳細はページの最後)

https://github.com/textlint-ja/textlint-rule-preset-japanese

技術記事用preset。日本語用のpresetより少しルールが厳しい

https://github.com/textlint-ja/textlint-rule-preset-ja-technical-writing

い抜き言葉を検知

https://github.com/textlint-ja/textlint-rule-no-dropping-i

表記ゆれを検知

https://github.com/textlint-ja/textlint-rule-ja-no-orthographic-variants

それぞれインストール

```
npm install textlint-rule-preset-japanese
npm install textlint-rule-preset-ja-technical-writing
npm install @textlint-ja/textlint-rule-no-dropping-i
npm install textlint-rule-ja-no-orthographic-variants
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
flycheckを使う。ポイントは２つ。

- emacsからtextlintを実行できるように、`.emacs.d/site-lisp/node_modules/bin`にpathを通す。

- `.emacs.d/site-lisp`に.textlintrcを作成したので、textlintに--configでtextlintrcを渡す。

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


## presetのルール一覧(詳細は公式のgithubを参照)

### textlint-rule-preset-japanese

https://github.com/textlint-ja/textlint-rule-preset-japanese

> 一文で使える"、"の数  
> 逆接の接続助詞「が」が、同一文中に複数回出現していないかどうか  
> 同じ接続詞で開始されていることを検出  
> 二重否定の検出  
> 二重助詞の検出  
> 一文の最大の長さ  
> ら抜き言葉を使用しない  
> 文の敬体(ですます調)、常体(である調)の混合をチェック  
> ホ゜ケット エンシ゛ン のような、Mac OS XでPDFやFinderからのコピペで発生する濁点のチェック  
> 制御文字の検出  
> ゼロ幅スペースの検出  
> 康煕部首の検出  

### textlint-rule-preset-ja-technical-writing

>1文の長さは100文字以下とする  
>カンマは1文中に3つまで  
>読点は1文中に3つまで  
>連続できる最大の漢字長は6文字まで  
>漢数字と算用数字を使い分けます  
>「ですます調」、「である調」を統一します  
>文末の句点記号として「。」を使います  
>二重否定は使用しない  
>ら抜き言葉を使用しない  
>逆接の接続助詞「が」を連続して使用しない  
>同じ接続詞を連続して使用しない  
>同じ助詞を連続して使用しない  
>UTF8-MAC 濁点を使用しない  
>不必要な制御文字を使用しない  
>不必要なゼロ幅スペースを使用しない  
>感嘆符!！、感嘆符?？を使用しない  
>半角カナを使用しない  
>弱い日本語表現の利用を使用しない  
>同一の単語を間違えて連続しているのをチェックする  
>よくある日本語の誤用をチェックする  
>冗長な表現をチェックする  
>入力ミスで発生する不自然なアルファベットをチェックする  
>対になっていない括弧をチェックする  


