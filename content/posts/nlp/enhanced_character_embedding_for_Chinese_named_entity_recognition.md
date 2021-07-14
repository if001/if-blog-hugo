---
title: "Enhanced character embedding for Chinese named entity recognition"
slug: "enhanced-character-embedding-for-chinese-named-entity-recognition"
tags: ["deeplearning", "nlp","論文"]
date: "2020-12-30T00:00:00+09:00"
draft: false
---


# Enhanced character embedding for Chinese named entity recognition
https://journals.sagepub.com/doi/pdf/10.1177/0020294020952456

> 従来の名前付き実体認識方法では、主に手作業による特徴の応用を模索しています。現在では、ディープラーニングの普及に伴い、名前付き実体認識のための深い特徴を捕捉するためにニューラルネットワークが導入されている。しかし、既存の手法の多くは、現代のコーパスを対象としたものに限られている。古文献の名前付き実体認識は、名前が時間の経過とともに進化してきたために困難である。本論文では、文字や筆跡の特徴を探ることで実体認識を試みる。トランスフォーマーとストロークからの双方向エンコーダ表現に基づいて、ECEMと名付けられた拡張文字埋め込みモデルを提案する。第一に、ECEMは単語の文脈に応じて動的に意味ベクトルを生成することができる。第二に、提案するアルゴリズムは、中国語の単語の形態素レベルの情報を導入する。最後に、強化された文字埋め込みは、学習のために双方向性の長期短期記憶条件付きランダムフィールドモデルに供給される。提案したアルゴリズムの効果を調べるために，実験 を古文と現代文の両方のコーパスで実施した．その結果，我々のアルゴリズムが非常に有効であることがわかった．従来のものと比較して、強力である。


## The proposed recognition algorithm
提案アルゴリズムであるECEMでは、前処理、embedding、BiLSTM Layer、CRF Layerの４つのコンポーネントからなる。

embeddingでは、cw2vecとBERTを用いる。
NERには、BIO schemeを用いる。

### Data pre-processing
固有表現抽出/the named entity recognition (NER)
### Enhanced character embedding

### BERT

### BiLSTM layer
### CRF layer
input sequence: `X = (x_1, x_2, ... x_n)`

predictin sequence: `y = (y_1, y_2, ... y_n)`

the equence yの確率は、softmaxを使って計算される。

```
p(y | X) softmax(e^f(X, y))
 ```


ここで、f(X,y)は、以下の用に計算される。

```
f(X,y)=
```

ただし、PはBiLSTMの出力した行列である。


