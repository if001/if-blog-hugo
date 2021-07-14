---
title: "ニューラルネットワークを用いた対話モデルのための多様性を促進する目的関数"
slug: "diversity-neural-conversation-model"
tags: ["deeplearning", "seq2seq","nlp","論文"]
date: "2019-09-24T00:00:00+09:00"
draft: false
---

Qiitaに投稿した記事、[kerasでHREDを構築してみる](https://qiita.com/iss-f/items/0b5a2766e789213b42c1)の記事で、こちらの論文が参考になるとのコメント頂いて、読んで見たので簡単にまとめました。

A Diversity-Promoting Objective Function for Neural Conversation Models
https://arxiv.org/abs/1510.03055


会話タスクにおける、入力文章(メッセージ)とそれに対する応答に多様性をもたせる手法を提案した論文です。
モデル周りをメインにそれ以外は軽く流し読みしているので、悪しからず。

## はじめに
sequence to sequece(seq2seq)などの対話モデルでは、多様で文法的な応答が求められる。このモデルでは、入力される文章と出力される文章の対応のみを考慮しているため、I'm OKやI'dont knowのような高頻度フレーズを生成しがちである。したがって、メッセージに関する応答の依存性だけでなく、応答とメッセージの関係性についても考慮すべきである。

そこで、私たちは、Maximum Mutual Information（MMI）を目的関数とする対話モデルを提案する。私たちは、MMIを使用することで、多様で興味深い文章を生成することを示します。

## MMIモデル
seq2seqモデルの標準的な目的関数は以下のように表される。

$$\hat{T} = argmax_T\{\log p(T|S)\}$$

$N$は単語数を表し、入力文章(メッセージ)$S$とそれに対する応答$T$は以下のように表される。
$S = \{s_1, s_2, ..., s_{N_s} \}$
$T = \{t_1, t_2, ..., t_{N_t}, EOS\}$

seq2seqモデルの目的関数を以下のように修正する。

$$\hat{T} = argmax_T \{\log p(T|S) - \log p(T)\}$$

このとき、argmaxの中身は、以下のように式変形から、[相互情報量(wikipedia)](https://ja.wikipedia.org/wiki/%E7%9B%B8%E4%BA%92%E6%83%85%E5%A0%B1%E9%87%8F) を表していることがわかる。

$$\{\log p(T|S) - \log p(T)\} = \frac{\log p(S,T)}{\log p(S) \log p(T)}$$

したがって、この式は、相互情報量を最大化(MMI)する応答を出力することとなる。

また、$\log p(T)$は、seq2seqの標準的な目的関数に対するペナルティ項とみなすことができる。メッセージに対するありふれた応答に対してペナルティを与えることで、応答の多様性を保つことを期待している。

このペナルティー項を調節できるように、(2)式に対して、パラメタ$\lambda$を追加する。これを、**MMI-antiLM**と呼ぶ。

$$\hat{T} = argmax_T \{\log p(T|S) - \lambda \log p(T)\} --(1)$$

式(3)をベイズの定理を用いて変形すると、以下のようになる。これを**MMI-bidi**と呼ぶ

$$\hat{T} = argmax_T \{(1-\lambda)\log p(T|S) + \lambda \log p(S|T)\} --(2)$$

MMI-bidiでは、$p(T|S)$と$p(S|T)$がトレードオフの関係にあることがわかる。

seq2seqモデルの学習にMMIを適応させることは、重要ではない。さらに、モデルの訓練に時間がかかるので、訓練なしに$\lambda$を調整したい。そこで、モデルを訓練するのではなく、学習時には最尤モデルを、テスト時にMMI基準を使用する。



## 実用的な考察
MMI-antiLMとMMI-bidiを適応するにあたり、

- 文法的におかしな応答 (MMI-antiLM)
- デコードを困難にする (MMI-bidi)

という問題があり、直接decodingに適応するのは困難である。

そこで、これらの問題について、以下で解決策を説明する。

### MMI-antiLM(an anti-language model)
式(1)の第2項の$p(T)$は、次のように表される。

$$ p(T) = \prod_ {k=1}^{N_ t} p(t_ k \mid t_ 1 , \cdots , t_ {k-1} ) $$

anti-language modelでは、流暢な応答にもペナルティを与えるので、誤った文法の出力に繋がる可能性がある。そこで、$P(T)$に現在の単語$k$に基づく重み$g(k)$を乗算した、$U(T)$を導入する。

$$ U(T)=\prod_ {k=1}^{N_ t} p(t_ k \mid t_ 1 \cdots t_ {k-1} )・g(k) $$

\begin{eqnarray}
g(k)
 =
  \begin{cases}
    1 & ( k \leq \gamma ) \\\\\\
    0 & ( k \gt \gamma )
  \end{cases}
\end{eqnarray}

ここで、$\gamma$は文頭から数えて何単語目かを表す閾値である。

式（1）は、以下のように書き直すことができる。

$$\hat{T} = argmax_T \{\log p(T|S) - \lambda \log U(T) \}$$

こうすることで、メッセージにおける全ての単語に対して、ペナルティを与えるわけではなく、初めの何単語かにだけペナルティを与えることで、典型的なパターンがくるのを避けることを期待する。


### MMI-bidi
式（2）の第2項には、$p(S|T)$が含まれている。

$$\hat{T} = argmax_T \{(1-\lambda)\log p(T|S) + \lambda \log p(S|T)\}$$

$p(S|T)$は、応答$T$の生成後でないと計算することはできない。また、応答$T$の探索空間が広すぎるために、全てを探索するのは難しい。したがって、この式を用いて直接decodeすることはできない。

そこで、近似的なアプローチを行う。

 - MMI-bidiの第1項である$p(T|S)$ (すなわち、標準的なseq2seqの目的関数)を与えられた第1世代N-bestリストを生成
 - MMI-bidiの第2項を使ってN-bestリストをrerankする
 - 一般的に、標準的なseq2seqモデルから得られるN-bestは文法的であるため、最終的に選択されるoptionsは適切な文法である可能性が高い。



## Training
- encoderとdecoderはそれぞれ4層のLSTMから構成
- 隠れ層は1000個の素子、単語埋め込み数の次元は1000次元
- LSTMパラメタと埋め込みは a uniform distribution in [−0.08, 0.08]で初期化
- SGDの学習率は0.1
- バッチサイズは256
- Gradient clipping is adopted by scaling gradients when the norm exceeded a threshold of 1

## decoding
### MMI-antiLM
MMI-antiLMの式は簡単に実装できる。
実験において、応答の長さも重要だと気づいた。そこで、損失関数に応答の長さのパラメタを加えた。

$$ Score(T) = p(T|S) - \lambda U(T) + \gamma N_t$$

ここで、$N_t$はターゲットの長さ、$\gamma$はその重みを表す。
応答の候補のN-best listに関するMERTを使って、$\gamma$と$\lambda$を最適化した。

### MMI-bidi



## 結果
評価には、BLEUを使う。さらに、生成された応答における異なるユニグラムおよびバイグラムの数を計算し、多様性を評価する。

### Twitter Conversation Triple Dataset
129Mのメッセージと応答の集合から、2300万の会話スニペットを使用。

statistical machine translation (SMT)とseq2seqとの比較を行った。　MMI-bidiのBLEU評価値が一番高い。

### OpenSubtitles Dataset
60M、70Mのノイズを多く含む、映画キャラクターの対話データ

他のモデルに比べ、MMI-antiLMモデルがBLEUの評価値と多様性の評価値どちらにおいても最も高くなった。MMI-bidiがMMI-antiLMより低い性能となったのは、N-bestリストの初期世代に左右されるからである。

## まとめ
seq2seqを使った対話モデルでは、メッセージに対する応答が、一般的でありふれたものになる傾向があるという問題点があった。我々の分析では、これは、入力（メッセージ）を与えられた出力（応答）の単方向尤度の使用に起因することを示唆している。そこで目的関数に最大相互情報量(MMI)を使用することを提案した。実験の結果、提案されたMMIモデルでは、より多様で興味深い応答を生成することができた。


