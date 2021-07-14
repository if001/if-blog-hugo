---
title: "Hugoでブログを作る"
slug: "hugo-start-article"
tags: ["hugo"]
date: "2018-10-16T00:00:00+09:00"
draft: false
---
## はじめに
[Hugo](https://gohugo.io/)とは、go言語で書かれた、静的なwebサイトをbuildingするためのframeworkです。
Hugoを使ってブログを作ってみたので構築方法を簡単にまとめておきます。

## サイトの作成
### インストール

```
brew install hugo
```

### テンプレートの作成

```
hugo new site hugo-test
```

これで、次のようにテンプレートが作成されます。

```
$ ls hugo-test/
archetypes/  config.toml  content/     data/        layouts/     static/      themes/
```

### テーマの適応

https://themes.gohugo.io/ ここからテーマを探す。

例として、https://themes.gohugo.io/hugo-theme-learn/ を使います。

```
$ cd hugo-test/themes
$ git clone https://github.com/matcornic/hugo-theme-learn.git
```

テーマを適応させるために、config.tomlにthemeを記述します。

```
theme = "hugo-theme-learn"
```

### サーバーの起動
```
$ hugo server -D -t hugo-theme-learn
```

オプションDでDraftフラグのついた記事の確認、オプションtでテーマの適応です。
cloneしてきたtheme内の、layoutとstaticなどを、作成したテンプレート内のlayout、staticに移動しておくと、templateのマイナーチェンジが行えます。

デフォルトで`http://localhost:1313/`で起動するのでアクセスしてみる。

## 記事の追加

記事の作成
```
$ hugo new post/test.md
hugo_test/content/post/test.md created
```

以下のようなmarkdownファイルが作成される
```
cat content/post/test.md
---
title: "Test"
date: 2018-10-15T18:51:47+09:00
draft: false
---
```

ここで、draftは記事を後悔するかのフラグ
この出力フォーマットも、独自に設定が可能

```
$ hugo server --watch
```

watchフラグをつけると、mdファイルが更新されるたびに、web側に更新が反映される。
markdownの記事を書きながら、フォーマットを確認するのに使えそう。

## デプロイ

以下のコマンドで実際にpublic以下にstaticファイルが吐き出される

```
$ hugo -t hugo-theme-learn
```

```
$ ls public/
404.html    categories  css         fonts       images      index.html  index.xml   js          mermaid     sitemap.xml tags        webfonts
```

このpublicディレクトリをwebサーバーに与えるだけでおk。

## まとめ
Hugoのインストールからデプロイまでをまとめました。
html内で使える変数や、数式、画像の表示はまた別でまとめます。


