---
title: "OpenCALM-7Bをloraで学習して、quantizeするまで"
slug: "calm_lora_quantize"
tags: ["nlp","deeplearning","python", "huggingface"]
date: "2023-05-22T00:00:00+09:00"
draft: false
---

`cyberagent/open-calm-7b`をLoraを用いて学習し、quantizeするまでやっていきます

https://huggingface.co/cyberagent/open-calm-7b

gpt-neoxのlora weight mergeの記事が見つからなかったのでメモとして


動作環境はcolab T4 ハイメモリ

## lora学習
rinnaと同様に、gpt-neoxベースなので、以下を使ってfinetuningしていく。

https://github.com/leehanchung/lora-instruct/blob/main/finetune.py


templateをそれっぽく直す

```
{
    "description": "Template used by Alpaca-LoRA.",
    "prompt_input": "以下は、タスクを記述する命令と、さらなるコンテキストを提供する入力の組み合わせです。依頼を適切に完了させる応答を書きなさい。\n\n### 指示:\n{instruction}\n\n### 入力:\n{input}\n\n### 応答:\n",
    "prompt_no_input": "以下は、ある作業を記述した指示です。依頼を適切に完了させる応答を書きなさい\n\n### 指示:\n{instruction}\n\n### 応答:\n",
    "response_split": "### 応答:"
}
```

trainingはいつも通り  
パラメタはそれぞれの環境に合わせて調整  

```
base_model="cyberagent/open-calm-7b"
data_path="kunishou/databricks-dolly-15k-ja"
template = 'dolly_ja'

!python3 finetune.py \
--base_model=$base_model \
--batch_size=128 \
--micro_batch_size=2 \
--prompt_template_name=$template \
--cutoff_len=1024 \
--output_dir=$output_path \
--num_epochs=2 \
--data_path=$data_path
```


(trainingはcolab T4 ハイメモリで試してないので動かないかも)

## lora weightをmerge
以下を参考にmerge

https://github.com/tloen/alpaca-lora/blob/main/export_hf_checkpoint.py

huggingfaceのpeftライブラリがmerge用のメソッドを提供しているので、それを使う  

```python
lora_model = PeftModel.from_pretrained(
    'base_model',
    'lora_weight_dir',
    device_map={"": "cpu"},
    torch_dtype=torch.float16,
)
lora_model = lora_model.merge_and_unload()
```

mergeのコードはここを参照  
https://github.com/huggingface/peft/blob/main/src/peft/tuners/lora.py#L343



`export_hf_checkpoint.py`の中で、モデルをロードしている部分をGPTNeoXに変更  
`AutoModelForCausalLM`は`save_pretrained`が呼び出せないので、ここだけ`GPTNeoXForCausalLM`を利用する。

```python
tokenizer = LlamaTokenizer.from_pretrained(BASE_MODEL)

base_model = LlamaForCausalLM.from_pretrained(
    BASE_MODEL,
    load_in_8bit=False,
    torch_dtype=torch.float16,
    device_map={"": "cpu"},
)
(省略)
LlamaForCausalLM.save_pretrained(
    base_model, "./hf_ckpt", state_dict=deloreanized_sd, max_shard_size="400MB"
)
```

↓

```python
from transformers import AutoModelForCausalLM, AutoTokenizer, GPTNeoXForCausalLM
tokenizer = AutoTokenizer.from_pretrained(BASE_MODEL)

base_model = AutoModelForCausalLM.from_pretrained(
    BASE_MODEL,
    load_in_8bit=False,
    torch_dtype=torch.float16,
    device_map={"": "cpu"},
)
(省略)
GPTNeoXForCausalLM.save_pretrained(
    base_model,
    save_directory=f"./hf_ckpt", state_dict=deloreanized_sd, max_shard_size="400MB"
)
```


## ggml形式に変換
gpt-neoxのggml形式への変換とquantizeは以下を参考にする  
https://github.com/togethercomputer/redpajama.cpp/blob/master/examples/redpajama/scripts/convert_gptneox_to_ggml.py


`convert_gptneox_to_ggml.py`のモデルのロードを修正
tokenizerはベースモデルを指定、AutoModelForCausalLMはマージしたモデルが保存されたdirを指定

```python
merged_weight_dir = "./hf_ckpt"

tokenizer = AutoTokenizer.from_pretrained('cyberagent/open-calm-7b')
model = AutoModelForCausalLM.from_pretrained(merged_weight_dir, torch_dtype=torch.float16 if ftype == 1 else torch.float32)                                             
```


## quantize
ここはreadme通り

compile

```
!make quantize-gptneox
```

q8_0を指定してrun

```
%cd (project_dir)/redpajama.cpp

model_name="ggml形式のmodelを指定"
!python ./examples/redpajama/scripts/quantize-gptneox.py $model_name --quantize-output-type q8_0
```


## infarence
動作確認  
ここもreadme通り  
このスクリプトだとgpu使わないみたいなので遅い、動作確認用

```
%cd (project_dir)/redpajama.cpp
!make redpajama
```

run

```
%cd (project_dir)/redpajama.cpp


instruction = "日本で1番高い山を教えてください。"
prompt=f"""
以下は、ある作業を記述した指示です。依頼を適切に完了させる応答を書きなさい

### 指示:
{instruction}

### 応答:
"""

!./redpajama -m "$model" \
  -c 1024 \
  -b 128 \
  -n 1 \
  -t 8 \
  --color \
  --top_k 30 \
  --top_p 0.95 \
  --temp 0.2 \
  --repeat_last_n 3 \
  --repeat_penalty 1.1 \
  --seed 0 \
  --n_predict 256 \
  --verbose-prompt \
  -p "$prompt"
```


出力

```
以下は、ある作業を記述した指示です。依頼を適切に完了させる応答を書きなさい

### 指示:
日本で��番高い山を教えてください。

### 応答:
山は、富士山と北アルプスです。富士山と北アルプスの標高は、3300m、北アルプスの標高は、3180mです。富士山は、3867m、北アルプスは、3180mです。

```

一部文字化けしているが、それっぽい回答

ちなみに、正解は

> 富士山の標高 3,776 m

> 北アルプスは，日本で3番目に高い奥穂高岳 (標高3190m) や4番目の槍ヶ岳 (同3180m) などを含めて2500～3000m級の峰が連なる日本有数の山岳地帯を形成している．


