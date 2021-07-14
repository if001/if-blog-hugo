---
title: "Firebaseを使ってwebアプリを公開した"
slug: "book-reports-firebase"
tags: ["firebase", "WebApp"]
date: "2019-09-22T00:00:00+09:00"
published: false
---

firebaseのみで三行で読書感想文をSNSにシェアできるwebアプリケーションを作ってみました。  

画像
 
構築の備忘録を残しておきます。  

今回使ったのは、以下のサービス

- hosting
- authentication
- storage
- database
- function

authenticateは以前使ったことがあり、大変便利だったので他のサービスを使ってみようと言うのが動機です。  

## ロジックの概要
1. vuejsで本の感想を入力するフォームを作り、プレビュー画面を表示  
1. 表示されたhtmlを画像に変換  
1. 画像をストレージに保存  
1. ストレージのURLとその他諸々をDBに保存  
1. Hostingだけでは、TwitterのOGPに対応できなかったので、Twitterのクローラーの時は、
1. OGP用のヘッダーをつけたHTML、そうでない時はHostingのページを表示する  

## Authentication
Google、Twitterを用いてのログインができる様にします。

firebase

## Hosting
Vuejs(typescript)をHostingで配信します。  
まず、それっぽくコードを書きます。  

CSSのフレームワークはマテリアルデザインのVuetifyを使いました。  


