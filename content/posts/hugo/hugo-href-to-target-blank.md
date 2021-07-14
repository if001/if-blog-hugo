---
title: "Hugoでリンクを新しいウィンドウで開く"
slug: "hugo-href-to-target-blank"
tags: ["hugo"]
date: "2018-10-16T00:00:00+09:00"
published: true
---
リンクは新しいウィンドウで開いて欲しい派なんだけど、Hugoではデフォルトで通常のリンクの開きかた(?)をする。

hrefでは`target='_blank'`を指定すれば良いのだが、markdownでどうすれば良いのか調べた。
Hugoでは次のようにconfig.tomlするといける。

```toml
[blackfriday]
   hrefTargetBlank = true
```

簡単！

参考：

- https://gohugo.io/getting-started/configuration/
- https://www.meganii.com/blog/2017/02/25/hugo-markdown-href-target-blank/

