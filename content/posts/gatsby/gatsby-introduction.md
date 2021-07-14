---
title: "技術ブログ用にGatsbyを整える"
slug: "gatsby-intro"
tags: ["react", "gatsby"]
date: "2019-10-14T12:00:00+09:00"
published: true
---

これまでHugoを使っていたが、gatsbyを使ってみようと思います。
https://www.gatsbyjs.org/

gatsbyは、react製の静的サイトジェネレーターです。PWAやOGPなどがあらかじめ設定してあり(themeによる？)便利です。また、記事などの任意のデータ取得のためのインターフェスとしてGraphQLを使用しているのが特徴です。(GraphQLは別途用意する必要はなく、gatsbyのbuild時に作成されます。)  
[GraphQL Concepts](https://www.gatsbyjs.org/docs/graphql-concepts/)  

静的サイトジェネレーター一覧はここがすごいわかりやすかった  
https://www.staticgen.com/

gatsbyを選んだのは、reactに入門したかったのと、Hugoのテーマがスマホ対応していなかったので手を加えたかったということでタイミングがよかったからです。

以下に、今回使ったものを備忘録として残しておきます。  
ここにあげるもの一通り導入し、デザインを入れれば、基本的な技術ブログが作れるかと思います。

## theme
今回は、テーマに変更を加える形で作ります。

テーマは以下から選びます。
https://www.gatsbyjs.org/starters/?v=2

以下のコマンドでテーマ入った状態で、gatsbyのプロジェクトが生成されます。

`$ gatsby new gatsby-starter-default`  
https://github.com/gatsbyjs/gatsby-starter-default

gatsbyのチュートリアルに目を通しつつ、themeに手を加えていきます。

## Markdownで記事を書く
以下のページを参考にしました。

https://www.gatsbyjs.org/docs/adding-markdown-pages/  
ある程度試して使い方がわかれば、markdownに対応したthemeがあるので、そちらを使った方が楽かと思います。

以下のようなqueryで一覧が取得できます。

```
{
  allMarkdownRemark {
    edges {
      node {
        html
        headings {
          depth
          value
        }
        frontmatter {
          # Assumes you're using title in your frontmatter.
          title
        }
      }
    }
  }
}
```

日付順にソート、limit、skipを与えることで、ページング処理もできます。

```
   allMarkdownRemark(
      sort: { fields: [frontmatter___date], order: DESC }
      limit: $limit
      skip: $skip
    ) {
    .
    .
```


## icons
以下のものがすぐに使えてよかったです。

https://react-icons.netlify.com/#/  
(emacsがないのが解せぬ…)

## コードのハイライト
技術ブログなので、コードのハイライトは必須です。Gatsbyで使えるものがいくつかあるようですが、自分の使う言語に対応していたので以下を使いました。

Prism: https://prismjs.com/

Prismを使ったGatsbyのプラグイン: https://www.gatsbyjs.org/packages/gatsby-remark-prismjs/

gatsby-config.jsには、プラグインの記事に従ってプラグインを追加。  
また、gatsby-browser.jsに以下を追加

`require("prismjs/themes/prism-solarizedlight.css");`

行数を表示するには、更に以下を追加

`require("prismjs/plugins/line-numbers/prism-line-numbers.css");`

その他のthemeもあるので好きなのを使う。単一のラインのハイライトや、ハイライト開始/終了の行数指定も可能だが、自前でcssを調節する必要がある。

コードハイライトにファイル名やタイトルを表示させたかったので、以下を使いました。  
https://www.gatsbyjs.org/packages/gatsby-remark-code-titles/?=gatsby-remark-code-titles

例
```json:title=test.json
{
    "test": "test"
}
```

## katex
記事中に数式を書くことがあるので、必要でした。以下のプラグインを使うと簡単にできます。

https://www.gatsbyjs.org/packages/gatsby-remark-katex/

`\tags` 使うとparse errorで怒られる。(v3.1.13)

前に使って重い印象があったので、使いませんでしたが、mathjaxもあるみたいです。  
https://www.gatsbyjs.org/packages/gatsby-remark-mathjax/

## 画像表示
markdonwの記事に画像を追加します。
一般的には、`![画像タイトル](URL)`のように画像を追加しますが、gatsbyではプラグインを入れる必要があります。

https://www.gatsbyjs.org/docs/working-with-images-in-markdown/

ただ、markdownで画像をリサイズして表示したいときは、どうするのかわからない。自前で作るしかない？？

## 目次
プラグインgatsby-remark-tocを使うことで目次をつけることができます。ただ、記事のトップにしかつけることができず、Qiitaのようなサイドバーに目次をつけたかったので、以下のようにしました。

queryに`tableOfContents`を加えると、目次が取得できます。

例

```
markdownRemark(fields: { slug: { eq: $slug } }) {
      html
      frontmatter {
        title
        date(formatString: "YYYY-MM-DD")
        tags
      }
      tableOfContents
    }
  }
```

取得したものを表示します。

```javascript
const tableOfContens = props.data.markdownRemarks.tableOfContents;
<div dangerouslySetInnerHTML={{__html: tableOfContens}}/>
```

参考  
https://nakawork.net/posts/gatsby-toc

スクロールで目次のハイライトもスクロールも試したかったけど、それはまた今度

## google analytics
https://www.gatsbyjs.org/packages/gatsby-plugin-google-analytics/

## google adsense
`$ npm install --save gatsby-plugin-google-adsense
`

```jsonld=
// In your gatsby-config.js file
plugins: [
    {
      resolve: `gatsby-plugin-google-adsense`,
      options: {
        publisherId: `ca-pub-xxxxxxxxxx`
      },
    },
]
```

プロジェクトのrootディレクトリにstaticディレクトリを作成。  
staticディレクトリ以下に、CNAMEファイル、ads.txtを追加。  

## サイトマップ
以下のプラグインを使うことで、build時にsitemap.xmlが生成されます。

https://www.gatsbyjs.org/packages/gatsby-plugin-sitemap/

## 関連記事の表示
プラグインがないみたいです。以下の記事が参考になりそうです。今後試してみます。

参考  
https://khalilstemmler.com/articles/gatsby-related-posts-component/

## github pages
参考  
https://www.gatsbyjs.org/docs/how-gatsby-works-with-github-pages/

subdomainの場合は、以下の手順

gh-pagesをインストール

`$ npm install gh-pages --save-dev`

以下を追加

```json:title=package.json
{
  "scripts": {
    "deploy": "gatsby build && gh-pages -d public"
  }
}
```

デプロイ

`$ npm run deploy`

## まとめ
プラグインが豊富で基本的なことは全てプラグインを使えば実現できるので便利。ただ、プラグインに依存しすぎて、バージョン依存の問題とかで盛大に死にそうな未来がうっすら見える。

GraphQLのコンセプトは面白いし使いやすいけど、コードの中にquery書くのはインデントあわなさすぎてしんどい。`localhost:8000___graphql`でqueryが確認できるのでなんとか頑張れるけど、APIほしかった。

今後は以下の記事がチューニングの参考になりそう

GatsbyでGoogle Lighthouseで満点を取るブログを一から作る  
https://qiita.com/so99ynoodles/items/87e136d09644baac634c

Gatsbyプラグイン45選  
https://takumon.github.io/gatsby-starter-qiita/f18d04ac-9b1a-5ac8-8d43-8aa3d8f746a7/
