---
title: "End-to-End Text Classification via Image-basedEmbedding using Character-level Networks"
slug: "end-to-end_text_Classification_via_Image-based_embedding_using_character-level_networks"
tags: ["deeplearning", "nlp","論文"]
date: "2020-12-30T00:00:00+09:00"
draft: false
---

> 日本語、中国語、タイ語など、形態素解析に基づく単語境界を持たない言語の分析や理解のためには、単語の埋め込みの前に適切な単語分割を行うことが望まれるが、これらの言語では本質的に困難である。しかし、これらの言語では、それは本質的に困難である。近年、ディープラーニングに基づく様々な言語モデルの進歩は目覚ましく、文字レベルの特徴量を利用した手法の中には、このような困難な問題を回避することに成功しているものもある。しかし，上記の言語の文字レベル特徴量をモデルに与えると，文字種の数が多いためにオーバーフィッティングが発生することが多い．本論文では，これらの問題を解決するために，文字エンコーダを用いた文字レベル畳み込みニューラルネットワークであるCE-CLCNNを提案する．提案するCE-CLCNNは、エンドツーエンド学習モデルであり、画像ベースの文字エンコーダー、すなわち、対象文書中の各文字を画像として扱う。様々な実験を行った結果，提案するCE-CLCNNは，視覚的にも意味的にも類似した文字に対しても密接に埋め込まれた特徴を捉えることができ，いくつかのオープン文書の分類タスクにおいて最先端の結果を達成することを確認した．本論文では、Wikipediaのタイトル推定タスクを用いたCE-CLCNNの性能を報告し、内部挙動を分析した。

www.DeepL.com/Translator（無料版）で翻訳しました。

## II. CE-CLCNN
CE-CLNCCは、2つの異なるCNNからなる。

１つ目のCNNは、文字画像を入力としcharacter encoderとして振る舞う。
２つ目のCNNは、document classificationに用いられる。

### A. Character encoder by CNN
入力文字列を36×36 pixelの画像に変換する。

```
Layer # CE configuration
1 Conv(k=(3, 3), o=32) → ReLU
2 Maxpool(k=(2, 2))
3 Conv(k=(3, 3), o=32) → ReLU
4 Maxpool(k=(2, 2))
5 Conv(k=(3, 3), o=32) → ReLU
6 Linear(800, 128) → ReLU
7 Linear(128, 128) → ReLU
```


### B. Document classifier by CLCNN

```
Layer # CLCNN configuration
1 Conv(k=(1, 3), o=512, s=3) → ReLU
2 Conv(k=(1, 3), o=512, s=3) → ReLU
3 Conv(k=(1, 3), o=512) → ReLU
4 Conv(k=(1, 3), o=512)
5 Linear(5120, 1024)
6 Linear(1024, # classes)
```

### データセット
Wikipediaタイトルデータセットを使う。
これには、以下の12個のラベルが含まれており、これを文章分類のラベルに使う。

Geography, Sports, Arts, Military, Economics, Transportation, Health Science, Education, Food Culture, Religion and Belief, Agriculture and Electronics. 

### Analysis of Character Encoder
cnn encoderを用いて文字の特徴量を抽出した。特徴量は、意味が類似している文字ごとに近い値となった。
形状特徴を明示的にを学習させたわけではなく、文章分類タスクを行うことが原因と考えられる。



