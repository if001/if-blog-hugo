---
title: "lsp-modeを導入する"
slug: "lsp-mode"
tags: ["emacs"]
date: "2018-11-20T20:48:42+09:00"
published: true
---

大学時代から使っていたemacsの設定たちを綺麗にするという目的で、ついでにlsp-modeを導入してみようと思う。  

lsp-mode  
https://github.com/emacs-lsp/lsp-mode  

## language server protocolとは
[language server protocol(lsp)](https://microsoft.github.io/language-server-protocol/)とは、IDEやエディタとIDEが提供する機能(補間、定義jump、ドキュメントの表示など)の間で使用されるプロトコルを定義したものである。  
これまで、IDEなどの提供する機能(補間、定義へのjump、ドキュメントの表示など)は言語ごと、IDEごとに提供されていた。  
それを取りまとめるプロトコルが定義されることで、IDEごとの格差が緩和され、emacsでもIDEと同様の機能が実現でき流ようになるということです。  
詳しくは、以下が参考になると思う。  

https://microsoft.github.io/language-server-protocol/  
https://github.com/Microsoft/language-server-protocol  
https://qiita.com/atsushieno/items/ce31df9bd88e98eec5c4  

## lsp-mode
emacsでは、lsp-modeとeglotがlspをサポートしているみたい。今回はlsp-modeを導入する。  
lsp-mode: https://github.com/emacs-lsp/lsp-mode  
を見ながら設定していく。  

melpaからインストール  

```bash
M-x package-install [RET] lsp-mode [RET]
```

以下のように設定する。  

```lisp
(use-package lsp-mode
  :custom
  (lsp-print-io t)
  (lsp-prefer-flymake 'flymake)
  :commands lsp)
```

`lsp-print-io`で全てのログを`*lsp-log*`に表示する。今回はflymakeを使うので、`(lsp-prefer-flymake 'flymake)` を設定しておく。  

続いて、lsp-modeのバックエンドにcompanyを使うためにcompany-lspを、lsp-modeのUIをリッチにしてくれるlsp-uiを入れる。  
それぞれmelpaからインストールします。  
 
### company-lsp
https://github.com/tigersoldier/company-lsp  

companyのバックエンドに設定  

```lisp
(use-package 'company-lsp
  :after (lsp-mode company)
  :init (push 'company-lsp company-backends)
 )
```

### lsp-ui
https://github.com/emacs-lsp/lsp-ui  


```lisp
(use-package lsp-ui
  :custom
  ;; lsp-ui-doc
  (lsp-ui-doc-enable nil)
  (lsp-ui-doc-header t)
  (lsp-ui-doc-include-signature t)
  (lsp-ui-doc-position 'at-point) ;; top, bottom, or at-point
  (lsp-ui-doc-max-width 150)
  (lsp-ui-doc-max-height 30)
  (lsp-ui-doc-use-childframe t)
  (lsp-ui-doc-use-webkit t)
  
  ;; lsp-ui-flycheck
  (lsp-ui-flycheck-enable nil)

  ;; lsp-ui-peek
  (lsp-ui-peek-enable t)
  (lsp-ui-peek-peek-height 20)
  (lsp-ui-peek-list-width 50)
  (lsp-ui-peek-fontify 'on-demand) ;; never, on-demand, or always
  
  ;; lsp-ui-imenu
  (lsp-ui-imenu-enable nil)
  (lsp-ui-imenu-kind-position 'top)
  
  ;; lsp-ui-sideline
  (lsp-ui-sideline-enable nil)
  
  :commands lsp-ui-mode
  :config
  (add-hook 'lsp-mode-hook 'lsp-ui-mode)
  (eval-after-load "flymake"
    (setq flymake-fringe-indicator-position nil)
    )
  )
 ```

主な機能は以下

- lsp-ui-doc:  
  リファレンス表示  
  (lsp-ui-doc-use-childframe t)でchildframeを使ったドキュメント表示ができる。webkitでもできるみたいだけどうまくいかない  
- lsp-ui-peek:  
  定義ジャンプ  
- lsp-ui-sideline  
  現在行の情報を表示(肩情報はchildframeで表示され、表示情報が重複しているので非表示にした) 

動いている様子は、各GitHubのページで確認  

以上で、lsp-modeの設定は終了

## 各言語の設定
goのLanguage Serverはbingoを使うと良いそうです。

bingo  
https://github.com/saibing/bingo  

これもmelpaでインストールし、以下のように設定

```lisp
(use-package go-mode
  :config
  (add-hook 'go-mode-hook #'lsp)
 )
```

## まとめ
lsp-modeを使って、IDEで提供されている機能をemacsでも使えるように設定しました。これでgo langで補間、リファレンス参照、定義ジャンプなどできるようになりました。その他設定の見直しは今後記事に落としていくということで。
