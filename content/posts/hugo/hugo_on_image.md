---
title: "Hugoの記事に画像を載せる"
slug: "hugo-on-image"
tags: ["hugo"]
date: "2018-10-16T00:00:00+09:00"
published: true
---

Hugoに画像を載せるときは、[shortcodes](https://gohugo.io/content-management/shortcodes/)を使うと良いらしい。

画像を配置するディクトリを以下のように作っておく。

```
{root}/content/post/images/
```

以下のように記述すると表示できる。   

```
{{</* figure src="../../images/test.png" title="test" width="320" height="640" */>}}
```

or

```
[!tag](path)
```


相対パスで記述でき、width、heightも設定可能。  
生成されるHTMLは以下のようになる。

```
<figure>
  <img src="../../images/test.png"  />
  <figcaption>
      <h4>test</h4>
  </figcaption>
</figure>
```

画像を実際に表示  
{{< figure src="../../../images/pa14039476984952.jpg" width="100" height="100">}}

記事と同じディレクトリに画像を配置しておくと、シンプルなパスで記述できるので、その辺は好みで。  
画像が多くなりすぎるとgitで管理したくないので、クラウドストレージとかに移行するとかしないとな...  
