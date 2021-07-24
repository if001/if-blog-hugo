---
title: "github actionsでarxivの論文をsummaryを翻訳して、日々slackに送る"
date: "2021-07-18T02:00:00+09:00"
slug: "arxiv-translate"
tags: ["python", "arxiv"]
draft: true
---

arxivの新着論文のアブストラクトを翻訳したものを、slackに送る。
これをgithub actionsを使って毎朝実行されるようにします。

朝の空いた時間などに眺めて面白いものがあれば読む、といったようなことをしたい

## 流れ
arxivはAPIを公開しているのでそこから、アブストや論文のタイトル、リンクなどを取得します。
Google Apps Script（GAS）を使うと、google translateが簡単に使え、翻訳ができます。
タイトルや翻訳したものをslackに送り、これをgithub actionsで定期実行させます。

- arxivからsubmittedDate順に上から10件を取得
- GASへリクエストを送り、アブストを翻訳
- slackに送る
- 以上の処理をgithub actionsを使って毎朝実行されるようにします

## arxivから記事を取得

