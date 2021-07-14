---
title: "KaTeXを使ってみる"
slug: "katex-introduction"
tags: ["hugo"]
date: "2018-10-16T00:00:00+09:00"
published: false
---

これまでMathJaxを使っていたが、描画が遅いということもあり、KaTeXを使ってみることにしました。
KaTeX:https://katex.org/

以下を加えるだけでおk

```html
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/KaTeX/0.8.3/katex.min.css" />
<script src="https://cdnjs.cloudflare.com/ajax/libs/KaTeX/0.10.0/katex.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/KaTeX/0.10.0/contrib/auto-render.min.js"></script>
<script>$(document).ready(function(){renderMathInElement(document.body,{delimiters: [{left: "[[", right: "]]", display: true},{left: "$", right: "$", display: false}]})});</script>
```

MathJaxで表示していた数式も無事表示されてとりあえず問題なしです。
実際に入れてみた感じやっぱり早い。

## 参考
KaTeXによる数式の表示:https://sekika.github.io/2017/05/01/katex-equation/ \\
KaTeXを導入しました:http://nshi.jp/contents/other/katex/ \\
KaTeXのデモ:http://sixthform.info/katex/examples/demo.html
