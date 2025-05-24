---
title: "Hugoでkatexを使った数式が表示されなくて困った"
slug: "hugo-katex"
tags: ["hugo"]
date: "2025-05-20T19:00:00+09:00"
draft: false
---

Hugoで数式を表示するために`katex@0.16.22`を利用している。

https://katex.org/docs/browser


基本的に表示されるが表示されないこともあり困っていた。


## 結論
[shortcode](https://gohugo.io/content-management/shortcodes/)を作る


以下のようなpassthroughするだけのショートコードを作る

```html{name="themes/shortcodes/math.html"}
{{- .Inner -}}
```

記事のmarkdown内で数式をショートコードで囲んで呼び出すだけ

```
{{< math >}}
$X_{n_1}$
{{< /math >}}

```


## 原因

https://discourse.gohugo.io/t/one-of-several-latex-equations-is-not-rendered-by-katex/47790

markdownのレンダラーが失敗してるらしい。確かに少し長めの数式が失敗してた。


