---
title: "Hugoの記事でコードハイライトする"
slug: "hugo-code-highlight"
tags: ["hugo"]
date: "2018-10-16T00:00:00+09:00"
published: true
---

Hugoでコードのシンタックスハイライトする場合のメモ  
Hugo自体の機能を使う方法と、ハイライトする機能を持つjavascriptを読み込む2つの方法がある。  

## Hugo自体の機能使う
Hugo 0.28からGo機能でシンタックスハイライトが可能になった。  
[Syntax Highlighting](https://gohugo.io/content-management/syntax-highlighting/)  
config.tomlに以下のように記述  

```toml
pygmentsCodefences = true
pygmentsUseClasses = true
```

以下のコマンドでcssを生成する。  

```bash
$hugo gen chromastyles --style=monokai > syntax.css
```

生成したcssをindex.htmlなどから読み込むと反映される。  
`--style`オプションの指定は、[pygments](https://help.farbox.com/pygments.html)から探す。  


## highlightjsを使う
[highlightjs](https://highlightjs.org/)  
対応言語が多いのがメリット。  

以下のようにcdnからとってくるようにしておくと良い。
```html
<link rel="stylesheet"
      href="//cdnjs.cloudflare.com/ajax/libs/highlight.js/9.15.6/styles/default.min.css">
<script src="//cdnjs.cloudflare.com/ajax/libs/highlight.js/9.15.6/highlight.min.js"></script>
<script>hljs.initHighlightingOnLoad();</script>
```

一行目の記述を以下のように書き換えることでテーマを選択できる。

```html
<link rel="stylesheet" href="//cdnjs.cloudflare.com/ajax/libs/highlight.js/9.15.6/styles/zenburn.min.css">
```
