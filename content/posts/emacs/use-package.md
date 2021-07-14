---
title: "use-packagesを使ってみる"
slug: "emacs-use-package"
tags: ["emacs"]
date: "2018-11-20T20:48:42+09:00"
draft: false
---

これまで長い間放置しててきたemacsの設定たちを見直すついでに、use-pacakgeを使ってみようと思う。  
https://github.com/jwiegley/use-package  

use-packageとは、emacsのパッケージ管理を強化するパッケージです。  

use-packageのマクロを使用することで、  

- 統一した記述による可読性が向上
- パッケージの遅延ロードの設定を簡潔にかけることによる起動の高速化

などのメリットがあります。  

## シンプルな例
requireでのライブラリの読み込みは次のように書き換えることができます。  


```lisp
 (require 'foo)
```


```lisp
 (use-package foo)
```

use-packageではキーワードを使うことで、パッケージロード時の振る舞いを指定することができます。  

## :init
パッケージが読み込まれる前に実行される。

```lisp
 (use-package foo
   :init
   (setq foo-variable t))
```

## :config
パッケージがロードされた後に実行される。


```lisp
(use-package foo
  :init
  (setq foo-variable t)
  :config
  (foo-mode 1))
```
## :commands
`auto-load`するコマンドを指定する。

```lisp
(use-package color-moccur
  :commands (isearch-moccur isearch-all)
  :bind (("M-s O" . moccur)
         :map isearch-mode-map
         ("M-o" . isearch-moccur)
         ("M-O" . isearch-moccur-all))
  :init
  (setq isearch-lazy-highlight t)
  :config
  (use-package moccur-edit))
```

この場合、`isearch-moccur`と`isearch-all`が`color-moccur.el`から`auto-load`される。


## key-binding
`:bind`キーワードを使用し以下のように設定する。  

```lisp
(use-package ace-jump-mode
  :bind ("C-." . ace-jump-mode))
```

リストを使い以下のように複数のキーバインドを設定することも可能  

```lisp
(use-package hi-lock
  :bind (("M-o l" . highlight-lines-matching-regexp)
         ("M-o r" . highlight-regexp)
         ("M-o w" . highlight-phrase)))
```

キーバインドは`:init`と:`:commands`キーワードを使用し、以下のようにも設定できる。  

```lisp
 (use-package ace-jump-mode
   :commands ace-jump-mode
   :init
   (bind-key "C-." 'ace-jump-mode))
```

## :mode
拡張子とメジャーモードの対応づけは`auto-mode-alist`で行なっていたが、`:mode`キーワードを使うことで簡潔に設定できるようになります。  

```lisp
(use-package python-mode
  :mode (("\\.py\\'")
             ("\\.pyx\\'"))
  )
```


## :interpreter
シェバンとメジャーモードの対応づけは、`:interpreter`キーワードを使って設定できます。  

```lisp
 (use-package python-mode
     :interpreter (("python" . python-mode)
                        ("python" . python-mode))
```

## :hooks
`:hook`キーワードを使用して、以下のように設定できます。  

```lisp
 (use-package ace-jump-mode
    :hook prog-mode)
	
  (use-package ace-jump-mode
    :hook (prog-mode . ace-jump-mode))
```

また、従来のように`add-hook`を用いても設定が可能。  

```lisp
 (use-package ace-jump-mode
     :commands ace-jump-mode
     :init
     (add-hook 'prog-mode-hook #'ace-jump-mode))
```

## まとめ
use-packageの使い方を簡単にまとめてみました。このくらいあればある程度の設定はできるでしょう。余力があれば加筆します。


