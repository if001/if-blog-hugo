---
title: "RedPajamaをLoRaで日本語fine tuning"
slug: "redpajama_lora_start"
tags: ["nlp","deeplearning","python", "huggingface"]
date: "2023-05-09T00:00:00+09:00"
draft: true
---

RedPajamaの3BをLoraでfine tuningしていく

https://huggingface.co/togethercomputer/RedPajama-INCITE-Base-3B-v1


## fine tuning
RedPajamaはgpt_neoxベースなので、このあたりを参考にしつつ調整する。

https://github.com/tloen/alpaca-lora/blob/main/finetune.py

https://github.com/satani99/alpaca-lora_gpt_neox_20b/blob/main/finetune.py


パラメーターはこんな感じ

```
learning_rate: float = 3e-4
LORA_R=8
LORA_ALPHA=16
LORA_DROPOUT=0.05
```

日本語のデータセットはこれをありがたく使わせて頂く.

https://huggingface.co/datasets/kunishou/databricks-dolly-15k-ja


