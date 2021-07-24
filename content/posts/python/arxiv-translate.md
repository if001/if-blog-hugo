---
title: "Github Actionsでrxivの論文をsummaryを翻訳して、日々slackに送る"
date: "2021-07-24T02:00:00+09:00"
slug: "arxiv-translate"
tags: ["python", "arxiv", "github"]
draft: false
---

朝の空いた時間などにarxivの新着論文を読みたくて、
アブストラクトを翻訳したものをslackに送るようにしました。

流れは以下のような感じ。

arxivはAPIを公開しているのでそこから、アブストや論文のタイトル、リンクなどを取得します。  
Google Apps Script（GAS）を使うと、google translateが簡単に使え、翻訳ができます。  
タイトルや翻訳したものをslackに送り、これをgithub actionsで定期実行させます。  

- arxivからsubmittedDate順に上から10件を取得
- GASへリクエストを送り、アブストを翻訳
- slackに送る
- 以上の処理をgithub actionsを使って毎朝実行されるようにします

全体はこれ

https://github.com/if001/arXiv_translate

## arxivから記事を取得

pythonのライブラリを使います。

https://github.com/lukasschwab/arxiv.py

詳細は以下

[pythonでarxivのAPIを使う](../arxiv-py-lib/)

## Google Apps Scriptでアブストを翻訳

Google TranslateはAPIを公開してますが、GASを使うと比較的簡単に翻訳が行えます。

GASを使って翻訳用のエンドポイントを作ります。

その後、arxivのAPIの結果から、タイトルとアブストを翻訳します。

詳細は以下

[Google Apps ScriptでGoogle Translateを使う](../../others/gas-translate/)

## Slackに送信

Incoming Webhooksを使うと簡単にslackにメッセージを送れます。

https://api.slack.com/messaging/webhooks

諸々登録を済ませると、メッセージsend用のURLが吐き出されるので、  
そのURLに対してメッセージをPOSTします。

翻訳/原文タイトル、翻訳/原文アブスト、arxivのリンクを送ります。


## Github Actionsで定期実行

Github Actionsでcron実行するにはこんな感じ。

```yaml
name: cron sample
on:
  schedule:
    - cron: '0 6 * * *'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - name: hello
      run: |
        echo "hello world"
```

https://docs.github.com/ja/actions/reference/events-that-trigger-workflows#schedule


確認用に手動実行したい場合は、`workflow_dispatch`を指定する。

```yaml
on:
  workflow_dispatch:
```


作成したscriptを実行させる。

```yaml

jobs:
  notify:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: [3.7]
    steps:
    - uses: actions/checkout@v2
    - name: Set up Python ${{ matrix.python-version }}
      uses: actions/setup-python@v2
      with:
        python-version: ${{ matrix.python-version }}
        
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip    
        if [ -f requirements.txt ]; then pip install -r requirements.txt; fi      
    - name: Run Main
      env:
        APP_GAS_URL: ${{ secrets.APP_GAS_URL }}
        APP_SLACK_URL: ${{ secrets.APP_SLACK_URL }}
      run: |
        python main.py
```


前日にslackにPOSTした論文と同じものがPOSTされないように、  
arxivの各論文の持つid(entry_id)をsave.logというファイル名で書き出して、  
同じリポジトリにpushしておきます。  

ファイルの中身と、arxivから取得した論文の差分を取り、slackに送ります。

Github Actionsで、自信の変更を自信のリポジトリにpushするのは、以下のようにできる。

```yaml
 - name: Run Change push
      run: |
        s=`git status -s`
        if [ -z "$s" ]; then
          exit 0
        fi
        git config --global user.email "workflow@example.com"
        git config --global user.name "workflow user"
        git add save.log
        git commit -m "update save.log"
        git status
        git push https://${{github.actor}}:${{secrets.GITHUB_TOKEN}}@github.com/${{github.repository}}.git
```


