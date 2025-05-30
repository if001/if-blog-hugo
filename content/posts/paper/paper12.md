---
title: "Transformer2 : Self-adaptive LLMs (AI論文要約)"
slug: "paper12"
tags: ["nlp","deeplearning", "paper_summary"]
date: "2025-01-18T14:00:00+09:00"
draft: false
katex: true
---

AIを使った論文要約です。簡単なサーベイ用で詳細は論文を参照してください。

https://arxiv.org/abs/2501.06252

## どんなもの

Transformer2は、未学習のタスクに対してリアルタイムでLarge Language Models (LLMs) を適応させるための自己適応フレームワークです。重み行列の特異値成分のみを選択的に調整することで、計算コストの高い従来のファインチューニング手法の課題を解決します。推論時には、まずディスパッチシステムがタスクのプロパティを識別し、次に強化学習 を用いて訓練されたタスク固有の「専門家」ベクトルを動的に混合して、入力プロンプトに対するターゲットとなる動作を得ます。


## 先行研究と比べてどこがすごいの？

Transformer2は、LoRAなどの従来手法と比べて、より少ないパラメータ数と高い効率性で、優れた性能を発揮します。  従来のファインチューニングは計算コストが高く、多様な タスクへの対応が静的なのに対し、Transformer2はリアルタイムで適応できる点が優れています。また、異なるLLMアーキテクチャやモダリティ（ビジョン言語タスクなど）にも対応できる汎用性を持ちます。先行研究のMixture of Experts (MoE)とは異なり、サンプルレベルのモジュール選択戦略を採用し、強化学習を用いてドメイン固有の知識を獲得した 「専門家」ベクトルを生成する点が異なります。  さらに、Singular Value Fine-tuning (SVF)という新しいパラメータ効率の良いファインチューニング手法を用いることで、少 ないデータ量でも過学習のリスクを抑え、計算コストを削減しています。


## 技術や手法のきもはどこにある？

Transformer2の核となる技術は、**Singular Value Fine-tuning (SVF)** と **二段階推論メカニズム** です。

SVFは、モデルの重み行列$W \in \mathbb{R}^{n \times m}$の特異値分解$W = U\Sigma V^T$を利用し、特異値$\Sigma$のスケールのみを調整する手法です。  これにより、学習パラメータ数を大幅に削減し、過学習を防ぎ、かつ、各特異値成分が独立に処理されるため、構成可能性が高まります。  学習されたベクトル$z \in \mathbb{R}^r$を用いて、新し い重み行列$W' = U\Sigma'V^T$ ($\Sigma' = \Sigma \otimes \text{diag}(z)$) を生成します。

強化学習を用いて、タスクパフォーマンスを直接最適化することで、効率的にドメイン特異的な「専門家」ベクトルを学習します。目的関数は以下の通りです。



$$
J(\theta_z) = \mathbb{E} \left[ \log \pi_{\theta_{W'}}(\hat{y}_i | x_i) \right] r(\hat{y}_i, y_i)
$$

$$
\- \lambda D_{KL}(\pi_{\theta_{W'}} \| \pi_{\theta_W})
$$

ここで、$\theta_z = \{z_1, \dots, z_{N \times M}\}$ は学習するSVFベクトルの集合、$\theta_W = \{W_1, \dots, W_{N \times M}\}$は重み行列の集合、$r(\hat{y}_i, y_i)$ は報酬、$\lambda$はKLペナルティの係数です。


二段階推論メカニズムでは、第一段階でモデルを実行し、タスク特性を識別します。第二段階で、第一段階で得られた情報に基づいて、学習済みの「専門家」ベクトルを組み合わ せ、LLMの基本的な重みを調整します。  論文では、プロンプトエンジニアリング、分類器ベース、Few-shot適応の3つの適応戦略が提案されています。


## どうやって有効だと検証した？

様々なLLM (LLAMA3-8B-INSTRUCT, MISTRAL-7B-INSTRUCT-V0.3, LLAMA3-70B-INSTRUCT)とタスク(GSM8K, MBPP-pro, ARC-Easy, MATH, Humaneval, ARC-Challenge, OKVQA)を用いて、SVFとTransformer2の有効性を検証しました。

SVFは、LoRAと比較して、少ないパラメータ数で高い性能を示しました。Transformer2は、様々な適応戦略を用いて、未学習のタスクに対しても高い適応能力を示しました。特に、Few-shot適応戦略では、テスト時の条件へのアクセスが増えるにつれて性能が向上することが確認されました。  ビジョン言語タスクに対しても、言語タスクで学習した専門家ベ クトルを用いて性能向上を確認しています。


## 議論はあるか

* **CEMベースの適応戦略の効率性:**  CEMを用いたFew-shot適応は、性能向上に寄与しますが、多くの専門ドメインへの拡張には、一度限りの計算コストの増加が課題となります。しかし、性能向上と自己適応能力の向上によるメリットによって相殺されると主張されています。
* **SVF専門家の能力の限界:** SVF専門家の能力は、ベースモデルの潜在的な成分に依存します。モデルの統合技術が、この問題を解決する可能性があると示唆されています。
* **クロスモデル互換性:** 異なるLLM間でのSVF専門家ベクトルの転移可能性は、モデルアーキテクチャの類似性に依存する可能性があり、さらなる研究が必要です。