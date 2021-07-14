---
title: "Hugoの記事にdescriptionを追加する"
slug: "hugo-add-site-description"
tags: ["hugo"]
date: "2018-10-16T00:00:00+09:00"
published: true
---
Hugoで書いた記事が検索で引っかからないなと思っていたら、descriptionタグが設定されていませんでした。
これでは検索に引っかからないのでdescriptionタグをつけましょう!

html側で次のように書くと、markdownに書いたdescriptionが参照できます。

```html
{{ .Description }}
```

markdown側では、ヘッダーに次のように記述します。

```
description="hogehoge"
```

これまで書いた記事全てに、descriptionをつけていくのは面倒ですね。

次のようにサイトサマリーを参照することも可能です

```html
{{ .Summary }}
```

ただし、デフォルトでサマリーが大きくなりすぎるので、config.tomlに次のような記述を追加します。

```yaml
hasCJKLanguage = true
```

こうすることでサマリーがいい感じのサイズになります。

参考：https://blog.awm.jp/2016/01/02/hugo/


最終的に、header.htmlなどに次のように記述しておけば、descriptionを書いておくとそちらが使われるようになります。

```html
{{ if .Description }}
<meta name="description" content="{{ .Description }}">
{{ else }}
<meta name="description" content="{{ .Summary }}">
{{ end }}
```


## サイトのディスクリプションと記事のディスクリプションを分ける(追記)
`{{ if .IsHome }}`でトップページかどうか判定できるので、トップページならば、configのディスクリプションを使い、記事内ならば記事に設定してあるディスクリプションを使う。

html側は次のように記述する。

```html
{{ if .IsHome }}
{{ with .Site.Params.description }}
<meta name="description" content="{{ . }}">
{{ end }}
{{ end }}

{{ if .Description }}
<meta name="description" content="{{ .Description }}">
{{ else }}
<meta name="description" content="{{ .Summary }}">
{{ end }}
```

configに次のように記述する。

```yaml
[params]
description="hogehoge"
```

configで任意の変数を指定するのは、paramsの中じゃないとだめなので注意。
参考：https://gohugo.io/getting-started/configuration/

他のもっとスマートな方法があれば教えてください。
