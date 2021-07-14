---
title: "Hugoのディレクトリ構造やデプロイ方法の備忘録"
slug: "hugo-long-time-no-see"
tags: ["hugo"]
date: "2018-10-16T00:00:00+09:00"
draft: false
---
久しぶりにHugoを触ったら、ディレクトリ構造からデプロイ方法までさっぱり忘れていたので、久しぶりに触った際のために備忘録を残す。  

## ディレクトリ
基本的なディレクトリは以下  
markdownを書いたりと普段触るのはcontentディレクトリになる。  
デプロイ後生成されるpublicディレクトリはサーバーなどで公開する。  

```
archetypes/ ・・・ markdown記事を生成する際のテンプレートなど
config.toml ・・・ 設定ファイル
content/ ・・・　markdownの記事を配置
layouts/　・・・ Htmlの共通部分
public/ ・・・ デプロイ後に生成される静的ファイル群
static/ ・・・ cssなどの静的ファイルを配置
themes/ ・・・ テーマを配置
```

## デプロイ
hugoのプロジェクトルートで以下のコマンドを打つ

```bash
$ hugo -t ./
```

記事を書くときには以下のコマンドを使う。

```
$ hugo server -t ./
```

localにサーバーが立ち上がり、markdownを書きながら生成される記事を確認できる。




