---
title: "flan_t5をquick start"
slug: "start-flan-t5"
tags: ["nlp","deeplearning", "python", "huggingface"]
date: "2023-02-04T00:00:00+09:00"
draft: false
---

T5を強化したモデルであるFlan-t5を動かしてみます。

FlanはFinetunedLAnguage Netの略。

ちなみに、Flanはカスタードプリンとかプリンの意味らしい。だからプリンのイラストあったのか

https://huggingface.co/docs/transformers/model_doc/flan-t5


ライブラリはこの辺を入れておく 
```
!pip install torch transformers sentencepiece
```

## modelのロード
google colaboratoryでは、xlは無理だったので、largeを試す。

```python
from transformers import T5Tokenizer, AutoModelForSeq2SeqLM

# model_name = "google/flan-t5-small"
model_name = "google/flan-t5-large"
# model_name = "google/flan-t5-xl"

tokenizer = T5Tokenizer.from_pretrained(model_name)
model = AutoModelForSeq2SeqLM.from_pretrained(model_name)
```

## 生成タスク
色々と生成してみる

```python
def gen(prompt):
    input = tokenizer.encode(prompt, return_tensors="pt")
    generate_kwargs  = {
            'top_p': 0.95,
            'top_k': 50,
            'do_sample':True
    }
    output = model.generate(input, **generate_kwargs)
    result = tokenizer.batch_decode(output, skip_special_tokens=True)
    print(result)
```

```python
prompt = """A step by step recipe to make a sandwich."""
gen(prompt)
```

```
>> ['Cut a hamburger in half. Lay a tortilla open on the serving dish. Fill it']
```

なんとなくあってそう。


```python
prompt = "What is the highest mountain in the world?"
gen(prompt)
```

```
>> ['mount everest']
```

これは大丈夫

## 翻訳タスク
multi languageらしいので試してみる。

```python
prompt = """Translate to German: Good morning"""
get(prompt)
```

```
>> ['Der frankreichischer Sonntag']
```

googleの翻訳によると、`The French Sunday` らしい。なんかおしい。

```python
prompt = "Translate to English: Guten Morgen"
get(prompt)
```

```
>> ['Good morning!']
```

逆はいける、と

## 翻訳タスク2
```python
prompt = "Translate to Japanese: Good morning"
gen(prompt)
```

```
>> ['']
```

日本語はしゃべれないっぽい


```python
prompt = "Translate to English: おはようございます"
gen(prompt)
```

```
>> ['No']
```

逆はなんか拒否されるｗ

