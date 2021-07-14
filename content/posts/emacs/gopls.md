---
title: "emacsのgo lang用のlanguage serverをgoplsに乗り換える"
slug: "gopls-introduction"
tags: ["emacs"]
date: "2019-10-08T00:00:00+09:00"
draft: false
---

emacsでgo langを書くときに使っているlspのlanguage serverがbingoからgoplsに変わったので、emacsの設定も更新しておこうと思います。  
bingoは、golangの公式に取り込まれる形になったようですね。  

## インストール

ドキュメント通りです。  
https://github.com/golang/tools/blob/master/gopls/doc/user.md   

```bash
$ go get golang.org/x/tools/gopls@latest
```

GO111MODULEをonにする必要がある人は、適宜onにしてあげてください。

## emacs
golang用の設定は、現状以下のようになってます。

```lisp
(use-package go-mode
  :ensure t
  :commands go-mode
  :init
  (bind-key "C-c i" 'gofmt-before-save)
  :config
  (add-hook 'go-mode-hook #'lsp)  ;; lsp-mode
  (add-hook 'go-mode-hook (lambda ()  ;; company-goを使う
                          (set (make-local-variable 'company-backends) '(company-go))
                          (company-mode)))
  (add-hook 'go-mode-hook 'go-eldoc-setup)
  )
```

gopls for emacs setting  
https://github.com/golang/tools/blob/master/gopls/doc/emacs.md

小さいプロジェクトなら、コードの補完、ドキュメント表示、定義ジャンプなど問題なく使えてます。

ただ、大きいプロジェクトとなると、補完やドキュメントを表示しようとするとタイムアウトしてしまうので、少し調整が必要みたいです。

