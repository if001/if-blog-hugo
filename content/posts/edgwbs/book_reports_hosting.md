---
title: "Firebase Hostingを使ってみた"
slug: "book-reports-firebase-hosting"
tags: ["firebase", "WebApp"]
date: "2019-10-10T00:00:00+09:00"
draft: false
---

Firebase Authenticationに続いて、Firebase Hostingも使ってみました。備忘録を残しておきます。  
今回は、Vue.jsをデプロイします。

## Firebase Hostingとは
> Firebase Hosting は、ウェブアプリ、静的コンテンツと動的コンテンツ、マイクロサービス向けの高速で安全性の高いホスティングを提供します。

> Firebase Hosting はデベロッパー向けの、本番環境レベルのウェブ コンテンツ ホスティングです。1 つのコマンドですばやくウェブアプリをデプロイすることができ、静的コンテンツと動的コンテンツの両方をグローバル CDN（コンテンツ配信ネットワーク）に配信できます。Firebase Hosting と Cloud Functions または Cloud Run を併用してマイクロサービスを構築し、Firebase にホスティングすることもできます。

引用： https://firebase.google.com/docs/hosting?hl=ja

無料で手軽にアプリケーションを公開するにはすごく便利という印象。  

Firebaseでは、転送量を超えない限り、複数アプリケーションをデプロイできるので、本番環境だけでなく、テスト環境もほしいという場合には有効かと思います。Herokuの無料枠では起動している時間の制限などで実質１アプリケーションしか動かせませんでした。

また、Hostingで利用できる無料のストレージが１GBですが、ブログなどのようにどんどんコンテンツが増えていくサイトでなければ十分な量だと思います。画像などがある場合は、Firebase Storageなどを利用する手もあるかと思います。

参考  
[Firebaseの料金体系](https://firebase.google.com/pricing/?hl=ja)  

[静的サイトホスティングの為のGCS/GAE/Firebase Hosting比較](https://medium.com/google-cloud-jp/%E9%9D%99%E7%9A%84%E3%82%B5%E3%82%A4%E3%83%88%E3%83%9B%E3%82%B9%E3%83%86%E3%82%A3%E3%83%B3%E3%82%B0%E3%81%AE%E7%82%BA%E3%81%AEgcs-gae-firebase-hosting%E6%AF%94%E8%BC%83-e7d406609f2e)

![logo](../../../images/bookreports_edgwbs/logo.png)

Firebase Hostingを使って公開したアプリはこちら  

[三行で読書感想文を書いて、SNSでシェアできるサービスを作った](https://www.if-blog.site/posts/edgwbs/book_reports_review/)  


## 準備
デプロイ用のコマンドラインツールをインストールします。

```bash
$ npm install -g firebase-tools
```

以下のコマンドで、firebaseにログインします。

```bash
$ firebase login
```

プロジェクトで、初めてfirebaseを使う場合には、以下のコマンドでfirebaseを初期化します。

```bash
$ firebase init
```

初期化すると、`firebase.json`が作成されます。Hostingやstorage、functionsなどのその他のfirebaseの設定を記述します。基本的にはここで生成された`firebase.json`を書き換えることなく利用できます。

## デプロイ
生成された`firebase.json`にデプロイ用のディレクトリは、`public`と設定されているので、publicにアプリをビルドします。
Vue.jsのプロジェクトの場合は、以下のようにビルド。

```
$ npm run build
```

`public`以下に生成された成果物は、以下のコマンドでfirebaseにデプロイすることができます。

```
$ firebase deploy
```

## 複数サイトをデプロイする
本番環境とテスト環境がほしい場合などには、複数サイトをデプロイしたです。  
(別のアプリをデプロイする場合は、プロジェクト変えるよね？普通？本番/テスト以外にどう使うんだろう??)   

`firebase.json`のhostingの項目を以下のように書き換えます。  

```json
{
  "hosting": [ {
      "target": "env", // 自分で定義した、一意なアプリの識別子
      "public": "app/public",
      // ...
    },
    {
      "target": "prod", // 自分で定義した、一意なアプリの識別子
      "public": "app/public",
      // ...
    }
  ]
}
```

次に以下のコマンドで、`target`名とプロジェクトのサイト名を対応付けます。

```bash
# $ firebase target:apply hosting target-name resource-name

$ firebase target:apply hosting env myapp-blog
$ firebase target:apply hosting prod myapp-blog
```

あとは、以下のコマンドでデプロイします。  

```bash
# $ firebase deploy --only hosting:target-name

$ firebase deploy --only hosting:env
$ firebase deploy --only hosting:prod
```

## ドメインを設定
Hostingのサイトの管理、「ドメインを接続」からドメインが設定できます。  
手順どおりで簡単に行なえます。  
証明書が入るまでに少し時間がかかったので気長に待ちましょう。  

ちなみに、CNAMEでいけるかと思ったけど無理でした。  

## まとめ
Firebase Hostingを使って、アプリケーションのデプロイを行いました。  
デプロイは驚くほど簡単でした。ローカルで動いているアプリケーションをそのまま、デプロイできるのが良かったです。  
