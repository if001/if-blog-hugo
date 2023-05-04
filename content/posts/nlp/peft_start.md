---
title: "Parameter-Efficient Fine-Tuning (PEFT)"
slug: "gpt_index_llama_index_start"
tags: ["nlp","deeplearning","python", "huggingface"]
date: "2023-03-04T00:00:00+09:00"
draft: true
---

Hugging FaceがParameter-Efficient Fine-Tuning (PEFT)を公開していたので、軽く調べる。

https://github.com/huggingface/peft


## PEFT
巨大なLLMのすべてのweightを学習することなく、少数のパラメタを微調整することで、計算コストやリソースコストを削減する手法。

現在、4つの手法がサポートされている
- LoRA
- Prefix Tuning
- P-Tuning
- Prompt Tuning

### LoRa(LOW-RANK ADAPTATION OF LARGE LANGUAGE MODELS)
weightをSDVで分解し、分解したものを学習



facebook/OPTをfinetuningしたサンプル

https://colab.research.google.com/drive/1jCkpikz0J2o20FBQmYmAGdiKmJGOMo-o?usp=sharing