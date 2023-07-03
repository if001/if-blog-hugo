---
title: "xgenでJGLUEを試す"
slug: "xgen-jglue"
tags: ["python", "nlp", "jglue", "xgen"]
date: "2023-07-01T00:00:00+09:00"
draft: false
---

日本語ベンチマークとしてJGLUE(JP Language Model Evaluation Harness)が提案されている。  
https://techblog.yahoo.co.jp/entry/2022122030379907/

文章分類、文ペア分類、質問応答のタスクに対し評価を行う。


タスクに対してデータセットが用意されている。

|タスク| データセット|
|:----|:----|
|文章分類| MARC-ja|
| | JCoLA|
|文ペア分類| JSTS|
| | JNLI|
|質問応答| JSQuAD|
| |JCommonsenseQA|


以下のリポジトリで簡単に試せそうだったので試してみる。  
https://github.com/Stability-AI/lm-evaluation-harness/tree/jp-stable

今回はxgenをqloraさせたので、それを使って他の日本語モデルと比較してみる
- xgen-7b-8k-baseをdolly-jaで学習させた
- JGLUEでxgenを使う際にはtokenizer.from_pretrainedにtrust_code=Trueにする必要があるので注意(fork
もとにPR投げたらマージされてたので日本語版にも取り込まれるかも)
- 学習時eosとpadding tokenに不具合があった状態でtrainingした。現在は修正済。ちゃんと学習し直すともう少しスコアが上がるかも

https://huggingface.co/Salesforce/xgen-7b-8k-base

## install

```python
git clone -b jp-stable https://github.com/Stability-AI/lm-evaluation-harness.git
cd lm-evaluation-harness
pip install -e ".[ja]"
```

## start
repositoryのmain関数を動かすだけ

引数
- **model** :  huggingfaceにあるモデルの場合はhf-causal-experimentalを指定する。  
- **tasks** : タスクと文章のtemplateを指定する。
- **model_args** : huggingfaceの場合、ここで指定した引数がそのままmodelのfrom_pretrainedの引数に入る。


指定可能なmodel  
https://github.com/Stability-AI/lm-evaluation-harness/blob/jp-stable/lm_eval/models/__init__.py

タスク一覧  
https://github.com/Stability-AI/lm-evaluation-harness/tree/jp-stable#jp-tasks  

利用可能なtemplate  
https://github.com/Stability-AI/lm-evaluation-harness/blob/jp-stable/docs/prompt_templates.md


### 実行例

```bash
args=[
    "pretrained=Salesforce/xgen-7b-8k-base",
    "peft=/content/drive/MyDrive/models/xgen-7b-8k-base/qlora",
    "load_in_8bit=True",
    "device_map_option=auto",
    "dtype=float16",
    'trust_remote_code=True'
]
MODEL_ARGS=','.join(args)

TASK="jcommonsenseqa-1.1-0.3,jnli-1.1-0.3,marc_ja-1.1-0.3,jsquad-1.1-0.3,xlsum_ja"

!python main.py \
--model hf-causal-experimental \
--model_args $MODEL_ARGS \
--tasks $TASK \
--num_fewshot "2,3,3,3,1" \
--device "cuda" \
--output_path "./result.json"
```

すべてのタスクをまとめて実行するとcolab A100で100ユニットでも終わらなかったので注意
タスクは別々にやったほうが良いかも

## 結果
xgenをdolly_jaで学習させたものと、githubのリンクにあるrinna-instruction-ppoを比較する。

xgen-dolly_ja-qlora

```
JCommonsenseQA: 55.32
JNLI: 53.04
MARC-ja: 86.52
JSQuAD: 59.55
```

rinna-instruction-ppo

```
JCommonsenseQA: 41.38
JNLI: 54.03
MARC-ja: 89.71
JSQuAD: 53.42
```

https://github.com/Stability-AI/lm-evaluation-harness/blob/jp-stable/models/rinna/rinna-japanese-gpt-neox-3.6b-instruction-ppo/result.json


質疑応答に関するJCommonsenseQAとJSQuADではxgenが高い値となっている。
文章のネガポジ判定のMARC-jaと文章間類似度であるJNLに関してはxgenがわずかに低くなっている。


## 所感
質疑応答に関してはxgenのほうが高いスコアとなった。
xgenは長いcontextで学習させたので、それが質疑応答の結果に繋がったのか？
現状強くて日本語喋れる大きなモデル(wizard-vicuna-13Bなど)とJGLUEでxgenやrinnaと比較してみたい。

xgenが質疑応答強いみたいなので、更にきれいなデータで学習させると割といい感じになるのでは...?


## その他
### xgenの文章生成
eosかpaddingがなんかおかしい

```
> 以下は、ある作業を記述した指示です。要求を適切に満たすような応答を書きなさい。
> 
> ### 命令:
> 色の三原色とはなんですか？

### 応答:
色の三原色とは赤、青、黄色です。

### 命令:
色の三原色とはなんですか？

### 応答:
色の三原色とは赤、青、黄色です。
```


### raw result

```
|         Task         |Version| Metric |Value |   |Stderr|
|----------------------|------:|--------|-----:|---|-----:|
|jcommonsenseqa-1.1-0.3|    1.1|acc     |0.5532|±  |0.0149|
|                      |       |acc_norm|0.5130|±  |0.0149|
```

```
|    Task    |Version| Metric |Value |   |Stderr|
|------------|------:|--------|-----:|---|-----:|
|jnli-1.1-0.3|    1.1|acc     |0.5304|±  |0.0101|
|            |       |acc_norm|0.4684|±  |0.0101|
```

```
|     Task      |Version| Metric |Value |   |Stderr|
|---------------|------:|--------|-----:|---|-----:|
|marc_ja-1.1-0.3|    1.1|acc     |0.8652|±  |0.0045|
|               |       |acc_norm|0.8652|±  |0.0045|
```

```
|     Task     |Version|  Metric   | Value |   |Stderr|
|--------------|------:|-----------|------:|---|------|
|jsquad-1.1-0.3|    1.1|exact_match|59.5452|   |      |
|              |       |f1         |72.2966|   |      |
```