---
title: "Hugoの記事を更新順にソートする"
slug: "hugo-date-sort"
tags: ["hugo"]
date: "2018-10-16T00:00:00+09:00"
draft: false
---

Hugoの記事を更新順にソートするメモです。  
まず、Hugoの記事に更新時刻情報を付与します。markdownのヘッダーにdate情報を書いても良いのですが、gitで管理している場合には、[Lastmod](https://gohugo.io/functions/format/)で更新時刻が取得できるのでそれを使います。  
そのほかにもgitから情報が取得できます。https://gohugo.io/variables/git/  

config.tomlに以下のように記述します。  

```toml
enableGitInfo=true
```

以下のように使う。  

```
{{ .Lastmod.Format "2006/01/02" }}
```

この更新事項を使って、記事を並び替えます。  
記事のリストを表示するhtmlはもともと以下のように記述してありました。  

```
{{ $paginator := .Paginate (where .Data.Pages "Type" "post") 10 }}
{{ range $paginator.Pages }}
```
以下のリンクを参考にします。  
https://gohugo.io/templates/lists/  
lastmod以外にも並び替えが行えます。  

結局、以下のように記述しました。  

```
{{ $paginator := .Paginate (where .Data.Pages "Type" "post").ByLastmod.Reverse 10 }}
{{ range $paginator.Pages }}
```


