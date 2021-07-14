---
title: "Vue.js+typescriptでVuetifyを使いマテリアルデザインに入門する"
slug: "book-storage-vue"
tags: ["vue.js", "WebApp", "vuetify"]
date: "2019-11-09T00:01:00+09:00"
published: true
---

## はじめに
Vuetifyは、Vue.jsで使えるマテリアルデザインのフレームワークです。  
https://vuetifyjs.com/ja/

マテリアルデザインに入門すべく、Vuetifyを使って読んだ本を管理するサービスを作ってみました。

[Book Storage](https://bookstrage.edgwbs.net)

<img width="500" height="300" alt="bookstrage-test.mov.gif" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/204896/b07210d9-39e5-9f8f-44b2-313055068483.gif">

簡単にマテリアルデザインを使えるVuetifyですが、以下のような特徴があります。

- ボタンやカードなどのマテリアルデザインのコンポーネントが用意してあり、簡単に利用できる
- flexboxをラップしたグリッドシステムがあり、レスポンシブ対応が容易
- コンポーネントとグリッドシステムを用いることで、cssを(ほとんど)書く必要がない
- マテリアルデザインの仕様であるフォント(Roboto Font)、アイコンが利用できる

ドキュメントが充実しており、基本的にドキュメントを見ると簡単に使えるという印象です。ドキュメントはjavascriptで書かれているため、typescriptで使う場合には、読み換える必要があります。

サポートブラウザはドキュメントを参照  
https://vuetifyjs.com/ja/getting-started/quick-start#supported-browsers

2019年7月にv2.0.0がリリースされ、旧バージョン(v1.5.0)から記法が大きく変わったので、その際に注意する点も含め紹介していきます。

## インストール
`vue cli 3`を使うと楽ということなのでvue cliを使ってインストールします。

```bash

$ vue --version
3.9.1
```

typescriptのプロジェクトを作成します. 

```bash

$ vue create my-app
```

vuetifyを追加する.

```bash=
$ cd my-app
$ vue add vuetify
```

すると以下のような選択肢が表示される. Defaultを選択すると、ツリーシェイキングなどの機能が追加された形で追加される.

```bash=
$ ? Choose a preset: (Use arrow keys)
$ > Default (recommended)
$   Prototype (rapid development)
$   Configure (advanced)
```

ツリーシェイキングについては、こちらの記事がわかりやすかったです。  
https://qiita.com/genshun9/items/4a00aa6c709b9f024821

ツリーシェイキングはwebpack4から利用でき、`vue cli3`はwebpack4上に構築されるため、`vue cli3`を利用していると自動で利用できるようになります。vuetifyのバージョンは`2.0.0`。

package.json

```json

  "dependencies": {
    "vuetify": "^2.0.0",
    ..
    },
```

フォントの追加も行います。

```bash

$ npm install @mdi/font -D
```

vuetifyを追加すると、新たに`src/plugins/vuetify.ts`が追加されます。

```typescript

import Vue from 'vue';
import Vuetify from 'vuetify/lib';

Vue.use(Vuetify);

export default new Vuetify({
  icons: {
    iconfont: 'mdi',
  },
});
```

ここで起動すると、コンパイルエラーが出ていたので、tsconfigに以下を追加すると、うまく動くようになりました。

```json
"compilerOptions": {
    "types": ["vuetify"],
```

### 既存のプロジェクトへの追加
yarnもしくはnpmを使いインストールします。

```bash=
$ yarn add vuetify
// OR
$ npm install vuetify --save
```

上記の`src/plugins/vuetify.ts`を新たに作成。

詳しくはドキュメントを参考  
https://vuetifyjs.com/ja/getting-started/quick-start

## Grid System
vuetifyを使うには、全体を`<v-app>`で囲みます。

はじめに読み込まれるコンポーネントに以下のように書けば良いかと思います。

```haml

<template>
    <v-app>
        <v-header></v-header>
        <router-view/>
        <v-footer></v-footer>
    </v-app>
</template>
```



基本的には、以下の例のように`v-container`、`v-row`、`v-col`の順番で囲む形になります。旧バージョンで利用していた`v-flex`や`v-layout`などの記法の代わりに、`v-row`、`v-col`を使うので注意です。

```html

<template>
    <v-container>
      <v-row>
        <v-col cols=12>
          コンテンツ
        </v-col>
      </v-row>
    </v-container>
</template>

```

`v-container`はコンテンツを中央揃えおよび水平方向にパディングにします。 

gridは、Bootstrapと同様、12個のgridがあります。

```html

<v-col cols=12>
    ...
</v-col>
```

colsプロパティを使い、gridを指定します。また、スマホ、PC用など、5つのブレークポイントが用意されており、colsに加え、ブレークポイントごとにgridが設定可能です。

```html

<v-col cols="12" lg="6" md="6" sm="6">
    ...
</v-col>
```

各ブレイクポイントは以下

<img width="912" alt="スクリーンショット 2019-08-24 22.19.08.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/204896/f5e7c331-b67c-e639-9b38-adf75d9fb55f.png">

gridの指定でハマったポイントは、こちらの記事を参考  
https://qiita.com/iss-f/items/a86586de095368cdd9a3

詳しい部分は、grid system ドキュメントを参照  
https://vuetifyjs.com/ja/components/grids


## コンポーネント
マテリアルデザイン仕様のカードやボタンなどのコンポーネントが用意されています. 色やサイズ、アニメーションなどcssを書かずに設定ができます。 各コンポーネントが受け取れるプロパティやイベントなどは、ドキュメントに詳しく記載してあります。

ここでは、 基本的なコンポーネントをいくつか挙げていきます。

### card

<img width="364" alt="スクリーンショット 2019-08-25 19.16.21.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/204896/9e372d1d-5940-c116-bd5d-b484706e32ec.png">

マテリアルデザインでよく見るカードは以下のように作ることができます。

```html

 <v-card
    max-width="344"
    class="mx-auto"
  >
    <v-card-title>I'm a title</v-card-title>
    <v-card-text>I'm card text</v-card-text>
    <v-card-actions>
      <v-btn text>Click</v-btn>
    </v-card-actions>
  </v-card>
```

`v-card-title`、`v-card-text`には、それぞれタイトル用本文用に、フォントサイズやpaddingが設定してあります。 `v-card-action`には、クリックイベントなどのアクションを設定します。 

### Button
`v-btn`タグを使い、波紋の広がるアニメーションがついたボタンが作成できます。

<img width="120" alt="vuetify-button-1.mov.gif" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/204896/0a2998e9-1b92-691a-10da-1ac8b41b3ca9.gif">

シンプルな例は以下の通り。

```html

<v-btn medium color="warning" dark>Normal Button</v-btn>
```

`small`, `medium` などのプロパティでボタンサイズが指定可能です。bootstrap同様、`info`、`primary`などで色の指定も可能。

<img width="170" alt="スクリーンショット 2019-08-25 19.18.00.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/204896/0605dce5-0905-aeb8-43b2-16266533ddad.png">

また、その他タグを使い細かい色の指定も可能です。これらのタグは、ボタン以外のコンポーネントでも使用可能です。

<img width="763" alt="スクリーンショット 2019-08-25 19.49.17.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/204896/5d0aa9c3-a0a6-ea8e-6d9a-39787a2bfbec.png">

その他の色は、ドキュメントを参照  
https://vuetifyjs.com/ja/styles/colors

#### outlined button
色抜きのボタンにする場合には、outlinedプロパティを使います。

```html

<v-btn medium color="warning" dark outlined>Normal Button</v-btn>
```

v2.0.0からoutlinedとなり、outlineプロパティは廃止されたので注意です。

#### floating button

`fab`プロパティを追加することで、フローティングボタンを作成することができます。

<img width="441" alt="スクリーンショット 2019-08-25 19.29.29.png" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/204896/8af6da08-4cf2-3913-95bc-fd2f9bacf87c.png">

```html

<v-btn fab dark color="indigo">
      <v-icon dark>mdi-plus</v-icon>
</v-btn>
```

#### loading button
loadingプロパティにboolean値を設定することで、trueの場合にローディングアニメーションが現れるようにすることもできます。

<img width="220" height="80" alt="vuetify-button-loading.mov.gif" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/204896/b06e729d-2e15-5245-b81c-cd035403b093.gif">

```html

<v-btn 
    :loading="loading"
    medium 
    color="warning" 
    dark
    >
        Loading Button
</v-btn>

```

その他の設定は、ドキュメントを参照  
https://vuetifyjs.com/ja/components/buttons

## Pagination

<img width="260" height="60" alt="vuetify-pagenation.mov.gif" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/204896/0492897b-eb87-16ac-7b39-d291c2fef14a.gif">

```html

<v-pagination
    v-model="page"
    :length="15"
    :total-visible="7"
    @input="paginate()"
></v-pagination>
```

v-modelに現在のページ番号を設定します。lengthプロパティは全ページ数、total-visibleで表示するページングボタンの数を指定。クリックイベントで、ページングボタン押下時の挙動を設定して使うことが多いかと思います。 

## まとめ
Vue.jsのマテリアルデザインのフレームワークである、Vuetifyを使ってサービスを作って見ました。簡単にマテリアルデザインに入門できて、おすすめです。

ここで紹介した以外にも便利なコンポーネントが多数用意してあるのでドキュメント読んでみてください。


