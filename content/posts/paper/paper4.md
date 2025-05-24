---
title: "Leave No Context Behind: Efficient Infinite Context Transformers with Infini-attention (AI論文要約)"
slug: "paper4"
tags: ["nlp","deeplearning", "paper_summary"]
date: "2025-01-02T12:00:00+09:00"
draft: false
---

AIを使った論文要約です。簡単なサーベイ用で詳細は論文を参照してください。

https://arxiv.org/abs/2404.07143

## どんなもの

Transformerベースの大規模言語モデル(LLMs)を、**bounded memory**とcomputationで無限長の入力にスケールするための効率的な手法である**Infini-attention**を提案する。**Infini-attention**は、従来のAttention機構に圧縮メモリを取り込み、**masked local attention**と**long-term linear attention**機構を単一のTransformerブロックに統合している。10億パラメータと80億パラメータのLLMを用いて、長文脈言語モデリングベンチマーク、100万トークン長のパスキーコンテキストブロック検索タスク、50万トークン長の書籍要約タスクで有効性を示した。

## 先行研究と比べてどこがすごいの？

先行研究であるTransformer-XLやCompressive Transformer、Memorizing Transformers、RMT、AutoCompressorsと比較して、**Infini-attention**は、**bounded memory**で無限長の文脈を処理できる点が優れている。具体的には、メモリサイズはMemorizing Transformersと比べて114倍小さく、かつ、より低いperplexityを達成する。また、10億パラメータのLLMにおいて、100万トークン長のパスキー検索タスクを解き、80億パラメータのLLMにおいて、50万トークン長の書籍要約タスクでSOTAを達成した。先行研究では、メモリサイズが 文脈長に比例して増加したり、圧縮に依存して効率が低下したりする問題があったが、本手法ではこれらの問題を解決している。

## 技術や手法のきもはどこにある？

**Infini-attention**の核心は、従来のAttention機構にcompressive memoryを統合し、**masked local attention**と**long-term linear attention**を組み合わせている点 にある。compressive memoryには、AttentionのKeyとValueの状態を再利用し、過去のKV状態を破棄するのではなく保存することで、無限長の文脈履歴を保持する。**long-term linear attention**を用いてメモリから値を検索し、**masked local attention**による局所的な文脈情報と統合することで、最終的な文脈出力を計算する。メモリ更新には、associative matrixとdelta ruleを採用し、計算効率と安定性を両立している。さらに、gating scalar βを用いて、長期記憶と局所的情報のバランスを学習する。

## どうやって有効だと検証した？

長文脈言語モデリングベンチマーク、100万トークン長のパスキーコンテキストブロック検索タスク、50万トークン長の書籍要約タスクの3つのタスクで検証を行った。言語モデリングタスクでは、Infini-TransformerがTransformer-XLやMemorizing Transformersを上回る性能を示した。パスキー検索タスクでは、10億パラメータのLLMに**Infini-attention**を適用することで、100万トークン長の入力に対しても高い精度でパスキーを検索できた。書籍要約タスクでは、80億パラメータのLLMに**Infini-attention**を適用することで、SOTAを達成した。

## 議論はあるか

論文では、**Infini-attention**におけるgating scoreの挙動について、専門化されたヘッドとミキサーヘッドの2種類が存在することを示している。しかし、この挙動がどの ようなメカニズムで生じるのか、さらなる分析が必要である。また、異なる種類のcompressive memoryやmemory update、memory retrieval手法を用いた場合の性能比 較についても、今後の研究課題として挙げられる。さらに、極端に長いシーケンスに対する汎化性能についても、より詳細な検証が必要である。