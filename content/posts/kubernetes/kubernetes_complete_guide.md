---
title: "Kubernetes完全ガイド 第２版"
slug: "kubernetes-complete-guide"
tags: ["book"]
date: "2020-09-08T17:00:00+09:00"
published: false
---

## 3.2.3 ローカル kubernetes kind


## 4.5.8 リソースの状態のチェックと待機
目的の状態になるまで、待機する

```bash
kubectl wait --for=condition=Readey pod/label
```


## 5.2.1 PODのデザインパターン
