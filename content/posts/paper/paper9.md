---
title: "Phi-4 Technical Report (AI論文要約)"
slug: "paper9"
tags: ["nlp","deeplearning", "paper_summary"]
date: "2025-01-11T14:00:00+09:00"
draft: false
---

AIを使った論文要約です。簡単なサーベイ用で詳細は論文を参照してください。

https://arxiv.org/abs/2412.08905


## どんなもの

140億パラメータの言語モデルphi-4。データの質に重点を置いたトレーニングレシピで開発された。ウェブコンテンツやコードなどのオーガニックデータだけでなく、トレーニングプロセス全体を通して戦略的に合成データを取り入れている。


## 先行研究と比べてどこがすごいの？

Phiファミリーの以前のモデル（特にGPT-4）の能力を蒸留するだけでなく、STEMに特化したQA能力において教師モデルであるGPT-4oを大幅に上回る。データ生成とトレーニング後の手法が蒸留を超えたことを示している。phi-3アーキテクチャへの変更は最小限だが、改良されたデータ、トレーニングカリキュラム、トレーニング後のスキームの革新により、特 に推論に焦点を当てたベンチマークでサイズに対して高い性能を達成している。  Llama-3.1-405Bなどのはるかに大きなモデルに匹敵する、あるいはそれを超える推論関連タスクにおける性能を示す。


## 技術や手法のきもはどこにある？

phi-4の開発は3つの柱に基づいている。

1. **事前学習と中間学習のための合成データ:** 推論と問題解決を優先する高品質の合成データセットを設計。多様性と関連性を確保するために注意深く生成されている。トレー ニングカリキュラムとデータの混合を変更し、以前の世代のphiと比較して合成トークンの割り当てを増やしている。
2. **高品質なオーガニックデータのキュレーションとフィルタリング:** ウェブコンテンツ、ライセンス付き書籍、コードリポジトリなどのオーガニックデータソースを注意深く キュレーションし、フィルタリング。合成データパイプラインのシードとして、高度な推論と教育的価値を優先して抽出している。これらの合成データセットを補完するために、事前学習で直接使用するための高品質なデータ（知識と推論の観点から）もウェブからフィルタリングしている。
3. **トレーニング後:** 新しい改良版のSFTデータセットを作成し、主要トークン検索に基づいてDPOペアを作成する新しい手法を開発することにより、phi-4のトレーニング後レシピをさらに進歩させている。


合成データは、多様な手法（マルチエージェントプロンプティング、自己修正ワークフロー、命令の反転など）を使用して生成。従来の教師なしデータセットの弱点に対処し、モデルの推論能力と問題解決能力を高めるデータセットを構築する。合成データはトレーニング後にも重要な役割を果たし、棄却サンプリングやDirect Preference Optimization (DPO)への新しいアプローチを使用してモデルの出力を洗練する。  Pivotal Token Search (PTS)という手法を用いて、DPOペアを生成。これは、モデル応答の成功確率に大きな影響を与 える主要なトークン（pivotal tokens）を特定し、それらを重点的に最適化することで、効率的な学習を促進する。


## どうやって有効だと検証した？

様々な標準ベンチマーク（MMLU、GPQA、MATH、HumanEval、MGSMなど）と、トレーニングデータ収集後に実施されたAMC-10/12数学コンテストを用いて性能を評価。GPT-4oを教師モデルとして、GPQAとMATHベンチマークにおいてphi-4がGPT-4oを大幅に上回ったことを示している。  また、AMC-10/12コンテストでは、同規模のモデルだけでなく、はるかに大きな最先端モデルをも凌駕するスコアを達成。これは、過学習やデータ汚染によるものではないことを示唆している。  さらに、内部ベンチマークPhiBenchを用いて、データ混合やハイパーパラメータの選択、トレーニング後の手法の最適化に役立てている。


## 議論はあるか

* **データ汚染:** 多くのベンチマークは、事前学習コーパスと重複するデータセットに依存しているため、データ汚染のリスクがある。phi-4ではデータの重複除去と汚染除去に 広範な対策を講じているが、言い換えなどに対しては効果がない可能性があり、一般化の真の程度には不確実性が残る。
* **ベンチマークのスキル範囲の限定:** 多くのベンチマークは、特定のスタイルの数学問題を特定の学年レベルで解いたり、独立したPython関数を実装したりするなど、狭く定義されたスキルをモデルで評価する。この狭い範囲では、モデルのより広範な能力や弱点をとらえることができない可能性がある。
* **生成ベースのベンチマークにおけるバイアス:** 一部のベンチマークは、生成された出力を評価するためにLLMをジャッジとして使用している。これらの判断では、正確性や推 論の妥当性よりも、スタイル、流暢さ、表面的な品質を優先することがあり、採点にバイアスが生じる可能性がある。
* **多肢選択式タスクの限界:** 多肢選択式の問題に依存するベンチマークは、多くの場合、モデルが推論を通じて基礎となる概念を効果的に利用するのではなく、パターンマッチングによって巧妙な推測を行う能力をテストする。
* **SimpleQA、DROP、IFEvalにおける低いスコア:** これらのベンチマークにおけるphi-4の低いスコアは、simple-evalsの評価指標が不十分であること、およびphi-4が厳格な指示に従うことに苦労していることを示唆している。


これらの問題に対処するために、オリジナルの質問、多様なスキル、厳格な採点方法を備えた内部ベンチマークPhiBenchを使用。PhiBenchは、phi-4の開発において中心的な役割を 果たした。


さらに、phi-4はサイズが限られているため、特に事実に関する知識の幻覚において、特定のタスクでは依然として根本的に制限されている。また、詳細な指示、特に特定の書式要 件を含む指示を厳密に守る能力は低い。  RAI（Responsible AI）の取り組みにもかかわらず、バイアスの再現または増幅、不適切なコンテンツの生成、安全上の問題に関する課題 が残っている。