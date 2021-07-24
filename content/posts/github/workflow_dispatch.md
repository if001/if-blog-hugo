---
title: "GitHub Actionsを手動実行する"
slug: "workflow-dispatch"
tags: ["github"]
date: "2020-07-19T00:00:00+09:00"
draft: false
---

GitHub Actionsをcronとして定期実行していたが、動作の確認のために手動実行もしたかったのでメモ

## 結論
`on`ワークフロー構文に、`workflow_dispatch`を指定する

```sh
name: Manually triggered workflow
on:
  workflow_dispatch:
```

`workflow_dispatch`のdoc  
https://docs.github.com/ja/actions/reference/events-that-trigger-workflows#workflow_dispatch


