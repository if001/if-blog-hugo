---
title: "Hugoの記事に関連記事を表示させる"
slug: "hugo-related-posts"
tags: ["hugo"]
date: "2021-07-18T00:00:00+09:00"
draft: false
---

記事の最後に関連記事を表示する方法が簡単になってた。

https://gohugo.io/content-management/related/

これで関連記事を取れる

```
.Site.RegularPages.Related
```

以下のような感じで記事の最後につけるとおｋ

```html
{{ $related := .Site.RegularPages.Related . | first 5 }}
{{ with $related }}
<h3>See Also</h3>
<ul>
	{{ range . }}
	<li><a href="{{ .RelPermalink }}">{{ .Title }}</a></li>
	{{ end }}
</ul>
{{ end }}
```

関連記事の設定も少しできるみたい。

```toml
[related]
  includeNewer = false
  threshold = 80
  toLower = false

  [[related.indices]]
    name = "keywords"
    weight = 100

  [[related.indices]]
    name = "date"
    weight = 10
```

設定はそれぞれ、

- threshold  
しきい値。0-100の値。低くするとよりマッチするけど、あんまり関連性無くなる

- includeNewer  
現在の記事より新しい記事を含めるかどうか。新しい記事を追加すると関連記事一覧も変わる。

- toLower  
indexesとクエリに小文字を含めるかどうか。より正確な関連記事が出る場合もある。

