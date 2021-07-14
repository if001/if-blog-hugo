---
title: "Hugoにgoogle analyticsを導入する"
slug: "hugo-ga"
tags: ["google-analytics","hugo"]
date: "2018-10-16T00:00:00+09:00"
draft: false
---
Hugoにgoogle analytics(ga)を導入しようと思ったら意外と簡単だった。

まず、gaアカウントを作成。

config.tomlに

```
googleAnalytics = "{ga tracking ID}"
```

を設定するだけ。


