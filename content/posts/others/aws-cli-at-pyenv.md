---
title: "pyenv環境でaws cli入れたらコマンドが見つからない"
slug: "aws-cli-at-pyenv"
tags: ["python","aws"]
date: "2019-09-24T00:00:00+09:00"
draft: false
---

pyenv環境でaws cli入れたらコマンドが見つからないって言われたので調べたメモ

バージョン：`pyenv:1.0.10`

公式通りにインストールする。

```
$ pip3 install awscli --upgrade --user
```

すると、

```
$ aws
-bash: aws: command not found
```

コマンドが見つからない....

調べると、`$HOME/.local`にインストールされるらしいので、パスを通す。

```
aws --version
aws-cli/1.16.29 Python/2.7.13 Darwin/16.7.0 botocore/1.12.19
```

できた！

pyenvが問題なのかはわからん....


