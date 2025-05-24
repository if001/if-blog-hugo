---
title: "データセット評価指標"
slug: "chat2"
tags: ["nlp","deeplearning", "chat", "データセット指標"]
date: "2025-05-20T20:30:00+09:00"
draft: false
---

以下では LLM 学習用データセットの多様性（あるいは「同質性」を避けられているか）を測る代表的な指標を、**定義 → 計算方法 → 読み取り方 → 長所/限界** の順で簡潔に整理します。

---

### distinct-N

[paper](https://arxiv.org/abs/1510.03055)  
[code](https://github.com/neural-dialogue-metrics/Distinct-N)

**定義**

* 生成コーパス（または学習データ）の中で **重複を除いた n-gram の種類数** を、総 n-gram 数で割った比率。

  $$
  \text{distinct-}n=\frac{\lvert\{\text{unique }n\text{-grams}\}\rvert}{\text{total }n\text{-grams}}
  $$

**読み取り方**

* 値は 0〜1。1 に近いほど語彙的な反復が少なく、表層的に多様。
* **distinct-1 / distinct-2**（1,2-gram）が最も一般的。

**強み**

* 軽量・参照不要・タスク非依存。
  **限界**
* 長文ほど分母が大きくなり過大評価されやすい。
* 内容的（意味的）な多様性は把握できない。

---

### Diversity Coefficient（Task2Vec-DC）

[paper](/posts/paper/paper22/)

**着想** Task2Vec で「サンプル1 バッチ = 1 タスク」と見立て、タスク埋め込み間の平均距離でデータ内部の**潜在概念のばらつき**を定量化する。

**計算フロー（概要）**

1. データセットからランダムに $B$ サンプルを抽出（= 1 タスク）。
2. Task2Vec (Barrett et al., 2019) で各タスクをベクトル化（勾配のFisher情報行列対角を縮約）。
3. タスク埋め込み集合 $\{\mathbf{t}_i\}$ の分散（例：平均コサイン距離や Frobenius ノルム）を取り

   $$
   \text{DC} = \frac{2}{B(B-1)}\sum_{i<j} d(\mathbf{t}_i,\mathbf{t}_j)
   $$
4. 大きいほど「タスクが互いに異なる」= より多様。

**強み** 意味レベルでの多様性を高速に近似。  
**限界** Task2Vecの前提（モデルと層選択）に依存／語順など表層のばらつきは捉えにくい。

---

### Self-BLEU

[paper](https://arxiv.org/pdf/1802.01886)  
[参考](https://www.digitalocean.com/community/tutorials/automated-metrics-for-evaluating-generated-text?utm_source=chatgpt.com#self-bleu)

**定義**

* コーパス内の **各文を「仮説」**、残り全文を **「参照」** とみなして BLEU を計算し、文ごとに平均。
  低いほど多様（互いに似ていない）。

**計算**

$$
\text{Self-BLEU} = \frac1{N}\sum_{i=1}^{N}\text{BLEU}\bigl(\text{sent}_i,\; \mathcal{D}\setminus\{\text{sent}_i\}\bigr)
$$

**読み取り方**

* 0 に近いほど高多様性。
* BLEU ベースなので n-gram 重み付けや平滑化は通常の BLEU と同一。

**長所** distinct-n より“語順を伴う重複”を強くペナルティ。  
**弱点** 計算が $O(N^2)$、BLEU の問題（語義を見ない）を継承。 

---

### LLM Cluster Score

[paper](/posts/paper/paper21/)


**アイデア**

1. LLM に**各サンプルのメタ特徴**（トピックなど）を要約・埋め込みさせる。
2. 埋め込みをクラスタリング（K-means 等）。
3. **クラスタ数 $K$** と **各クラスタのエントロピー** から

   $$
   \text{Cluster Score}=H(\text{cluster labels}) \times \frac{K}{K_{\max}}
   $$

   — 直感的に「サンプルが均等に多くの話題に散らばっているほど高得点」。

**用途** 巨大合成コーパスで従来指標が飽和・不安定になる問題を緩和。  
**注意点** LLM の“まとめ方”がクラスタ品質を左右／高次元でのクラスタ個数設定がハイパーパラメータになる。

---

### **DCScore**

[paper](/posts/paper/paper23/)  
[code](https://github.com/bluewhalelab/dcscore)


**発想** 「もし各サンプルを**分類クラス**だと思って識別器を訓練したら、正解率が高いほど互いに違う＝多様」と捉える。

**手順**

1. $N$ サンプルを N-way 1-shot のようにラベル付け（サンプル $i$ はクラス $i$)。
2. 小型テキスト分類器 $f_\theta$ を数エポックだけ学習。
3. 開発セットでの **分類精度を Diversity Classification Score (DCScore)** として採用。


* **高精度 = サンプルを容易に区別 ⇒ データが互いに異質で多様**
* **低精度 = 似た文が多く誤分類 ⇒ 同質的**

**利点** 語彙・構文・意味差分をまとめて反映しつつ計算コストを抑制（学習回数はごく少ない）。  
**欠点** 分類器設計・学習ハイパラに感度がある。

---

## まとめ

| 指標                    | 捉える多様性    | 軽量 | 意味情報 | 大規模データ適性    | 主な弱点        |
| --------------------- | --------- | -- | ---- | ----------- | ----------- |
| distinct-N            | 表層 n-gram | ◎  | ✕    | ◎           | 長文補正が必要     |
| Self-BLEU             | 表層＋語順     | △  | ✕    | ○ (要サンプリング) | 計算 $O(N^2)$ |
| Diversity Coefficient | 概念・タスク    | ○  | ◎    | ◎           | Task2Vec 依存 |
| LLM Cluster Score     | トピック分布    | ○  | ◎    | ◎           | クラスタ数選定     |
| DCScore               | サンプル識別難度  | △  | ◎    | ○           | 分類器依存       |

* **高速スクリーニング** → distinct-N, Self-BLEU
* **意味レベルの網羅性** → DC, LLM Cluster, DCScore
* **超大規模コーパス** → DC, LLM Cluster（計算がバッチ並列化しやすい）
* **生成モデルの出力評価** → distinct-N + Self-BLEU（表層反復チェック）

これらの指標を併用し、表層と意味の両面からバランス良く評価することが、実際の LLM 学習データ選定では推奨されます。

[1]: https://github.com/neural-dialogue-metrics/Distinct-N?utm_source=chatgpt.com "Compute Distinct-N metric proposed by Jiwei Li et al. - GitHub"
[2]: https://machine-learning-made-simple.medium.com/addressing-one-of-the-biggest-misunderstandings-in-ai-4d6278213a46?utm_source=chatgpt.com "Addressing one of the Biggest Misunderstandings in AI | by Devansh"
[3]: https://www.digitalocean.com/community/tutorials/automated-metrics-for-evaluating-generated-text?utm_source=chatgpt.com "Automated metrics for evaluating the quality of text generation"
[4]: https://arxiv.org/html/2410.15226v2?utm_source=chatgpt.com "On the Diversity of Synthetic Data and its Impact on Training Large ..."
[5]: https://arxiv.org/abs/2502.08512?utm_source=chatgpt.com "Measuring Diversity in Synthetic Datasets"
