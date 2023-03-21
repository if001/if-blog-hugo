---
title: "BloomをLoRaで日本語finetuning"
slug: "bloom_lora_start"
tags: ["nlp","deeplearning","python", "huggingface"]
date: "2023-03-20T00:00:00+09:00"
draft: false
---

LlamaをAlpacaデータセットを使いLoRaでfine tuneしたものが良い感じだったので、Bloomを日本語で学習させてみようと思う。

https://github.com/tloen/alpaca-lora

とりあえず動かすまででしっかりfine tuneしきってないので注意

hugging faceのpeftも見ておくと良さそう

https://github.com/huggingface/peft

## finetune
fine tune対象をBloomに変更

```python{ref="https://github.com/tloen/alpaca-lora/blob/main/finetune.py#L47-L54", name="finetune.py"}
model = LlamaForCausalLM.from_pretrained(
    "decapoda-research/llama-7b-hf",
    load_in_8bit=True,
    device_map=device_map,
)
tokenizer = LlamaTokenizer.from_pretrained(
    "decapoda-research/llama-7b-hf", add_eos_token=True
)
```

こんな感じで良さそう。一旦動かしたいので小さいモデルを使う

```python
model_name = "bigscience/bloom-1b1"
model = AutoModelForCausalLM.from_pretrained(
    model_name,
    load_in_8bit=True,
    device_map=device_map,
)
tokenizer = AutoTokenizer.from_pretrained(
    model_name,add_eos_token=True
)
```

LoraConfigのtarget_modulesをBloom用に変更

```python{ref="https://github.com/tloen/alpaca-lora/blob/main/finetune.py#L58-L65", name="finetune.py"}
config = LoraConfig(
    r=LORA_R,
    lora_alpha=LORA_ALPHA,
    target_modules=TARGET_MODULES,
    lora_dropout=LORA_DROPOUT,
    bias="none",
    task_type="CAUSAL_LM",
)
```

huggingfaceのpeftを見ると、以下を指定すれば良さそう。

```python{ref="https://github.com/huggingface/peft/blob/main/src/peft/mapping.py#L46", name="mapping.py"}
  "bloom": ["query_key_value"],
```

llamaやOPTだと、queryとvalue layerのみを指定しているが、Bloomの場合query_key_valueすべて指定してしまって良いのかわからない。
Bloomのlayerがそもそもquery, key, valueが１つになってるからしょうがなさそうだけどこの辺、key layerはできるだけ低ランクにしないほうが良いとかある？？？？


このあたりも日本語にしとく
```python{ref="https://github.com/tloen/alpaca-lora/blob/main/finetune.py#L112", name="finetune.py"}
user_prompt = (
        (
            f"""Below is an instruction that describes a task, paired with an input that provides further context. Write a response that appropriately completes the request.
```

あとは、`python finetune.py`を動かすだけ

データセットは、DeepLを使って翻訳  
とりあえず動かしたかったので、一部のみ

```json
{
    "instruction": "波ではなく、神の手を見る」の意味を説明する。", 
    "input": "", 
    "output": "私は波を見ず、神の手を見る」という言葉は、しばしば信仰の力を表現するために使われます。これは、どんな逆境に立たされても、最終的には神が支配し、激動の時代を導いてくれることを意味しています。困難に目を向けるのではなく、信仰を強く持ち、神の計画を信じるべきだということを示唆しています。"
    }, 
{
    "instruction": "平均年齢を算出する。", 
    "input": "ジェームズ - 22\nマルティナ - 18\nジョニー - 26", 
    "output": "22.3"
}, 
{
    "instruction": "xが4、yが7のとき、x÷yを計算する。", 
    "input": "", 
    "output": "0.5714285714285714"
}
```

## generate

以下を参考に、Bloomとfinetuneしたweightをロードする

```python{ref="https://github.com/tloen/alpaca-lora/blob/main/generate.py#L28-L34", name="finetune.py"}
  model = LlamaForCausalLM.from_pretrained(
        BASE_MODEL,
        load_in_8bit=True,
        torch_dtype=torch.float16,
        device_map="auto",
    )
    model = PeftModel.from_pretrained(model, LORA_WEIGHTS, torch_dtype=torch.float16)
```


デフォルトで`./lora-alpaca`以下に`adapter_config.json`と`adapter_model.bin`が生成される。
`PeftModel`のロードには、`./lora-alpaca`を指定する。

こんな感じで良さそう

```python
BASE_MODEL = "bigscience/bloom-1b1"
model = AutoModelForCausalLM.from_pretrained(
    BASE_MODEL,
    load_in_8bit=True,
    torch_dtype=torch.float16,
    device_map="auto",
)
LORA_WEIGHTS = './lora-alpaca'
model = PeftModel.from_pretrained(
    model,
    LORA_WEIGHTS,
    torch_dtype=torch.float16,   
)
```

## まとめ
alpaca data setを使ってLoRaでBloomをfine tuneしてみた。
ここまでで、とりあえずfine tuneはできた。

Bloom用のparameterの調整やモデルサイズ、alpaca data setを全体を使ったfine tuneはこれから試す