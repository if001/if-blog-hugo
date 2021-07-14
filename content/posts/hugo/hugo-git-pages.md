---
title: "HugoをGitHub Pagesで公開する"
slug: "hugo-git-pages"
tags: ["hugo"]
date: "2018-10-16T00:00:00+09:00"
draft: false
---
GitHub Pagesを使ってHugoを公開する手順をメモ  
やりたいこととしては、

- Hugoのプロジェクトを丸ごとgitで管理
- プロジェクトの下に作られるpublicをGitHub Pagesで公開
- 独自ドメインの設定

の3つです。

## GitHub Pagesで公開
まずは、Hugoのプロジェクトルートをgitで管理します。  
GitHub Pagesで公開するために、GitHubのリポジトリの設定からPagesで公開するための設定を行います。このとき、そのまま公開すると、Hugoをビルドして生成されるファイルはプロジェクトルート直下のpublic以下に生成されるので、

```bash
 https://{ユーザー名}.github.io/{リポジトリ名}/{public}
```

というように、URLにpublicが付いてしまいます。これは嫌なので、git subtreeを使います。  
gh-pagesという新しいブランチを作成し、public以下のファイルのみをpushしています。github pagesではgh-pagesを公開するよう設定します。  

```bash
$ git subtree push --prefix public/ . gh-pages
$ git push origin gh-pages:gh-pages
```

GitHubから独自ドメインの設定をすると、ブランチgh-pagesにCNAMEファイルが追加、commitされるのですが、この変更をローカルのmasterに取り込めないという問題が発生しました。このため、ローカルで記事を追加したときなど、non-fast-forwardでpush、pullもできなくなりました。そこで、しょうがなくmaster側にローカルからCNAMEファイルを追加しました。  

それでもうまくいかないときは、エラー文のcommitのハッシュを使って無理やりpushしてとりあえず回避してます。


例

```bash
 $ git subtree push --prefix public/ . gh-pages
 git push using:  . gh-pages
 To .     59 (58)
  ! [rejected]        95625bda7b4247ff0d05b2e76c8db1cbb7e87dad -> gh-pages (non-fast-forward)
 error: failed to push some refs to '.'
 hint: Updates were rejected because a pushed branch tip is behind its remote
 hint: counterpart. Check out this branch and integrate the remote changes
 hint: (e.g. 'git pull ...') before pushing again.
 hint: See the 'Note about fast-forwards' in 'git push --help' for details.
```

```bash
 $ git push origin 95625bda7b4247ff0d05b2e76c8db1cbb7e87dad:gh-pages
```

## 独自ドメインの設定
今回は、お名前.comでドメインを取得しました。お名前.comでDNSの設定をします。  
GitHub Pagesのドメインは

```bash
 https://{ユーザー名}.github.io/{リポジトリ名}
```

なので、取得したドメインでGitHub PagesのドメインがひけるようにCNAMEの設定を行います。  

GitHub側では、リポジトリの設定からCustom domainを取得したドメインで設定します。Custom domainを設定すると、Enforce HTTPSにチェックを入れることができるので、設定するとhttpsで通信が行えるようになります。  


