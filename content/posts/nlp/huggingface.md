---
title: "Hugging Face Transformersのドキュメント読んだ"
slug: "huggingface-doc"
tags: ["nlp","deeplearning", "python"]
date: "2021-12-09T09:00:00+09:00"
draft: false
---

Hugging FaceなのかTransformersなのか呼び方がわからん。

BERTやGPT-2などの様々なモデルが扱えるライブラリ

事前学習済のモデルとタスクが用意されており、そのままモデルを使ったりFine-Tuningが簡単にできる。

https://huggingface.co/docs/transformers/index

Jax、Pytorch、Tensorflowなどのライブラリに対応している。

学習済モデルを使うだけでなく、モデルのカスタマイズもできるらしい。

とりあえず入門編くらいまで読んだ

## install

```
$ pip install transformers
```

## Quick tour
文書のpositive/negative判定を行う。

`sentiment-analysis`というモデルをpipelineに渡す。
戻り値のclassifierに文章を渡すと判定される。

```python
>>> from transformers import pipeline
>>> classifier = pipeline('sentiment-analysis')

>>> classifier('We are very happy to show you the 🤗 Transformers library.')
[{'label': 'POSITIVE', 'score': 0.9998}]
```

https://huggingface.co/docs/transformers/quicktour


## Summary of the tasks
いくつかタスクが用意されている。ここではその使い方を示す。

https://huggingface.co/docs/transformers/task_summary#summarization

### Sequence Classification
文章positive/negativeに分類

### Extractive Question Answering
与えられた文脈を使って、質問に対する答えを出力

```python
>>> from transformers import pipeline

>>> question_answerer = pipeline("question-answering")

>>> context = r"""
... Extractive Question Answering is the task of extracting an answer from a text given a question. An example of a
... question answering dataset is the SQuAD dataset, which is entirely based on that task. If you would like to fine-tune
... a model on a SQuAD task, you may leverage the examples/pytorch/question-answering/run_squad.py script.
... """
```

### Named Entity Recognition
文章に含まれる単語の人や組織、場所などの固有表現の識別を行う

### Summarization
要約

```python
>>> from transformers import pipeline

>>> summarizer = pipeline("summarization")

>>> ARTICLE = """ New York (CNN)When Liana Barrientos was 23 years old, she got married in Westchester County, New York.
... A year later, she got married again in Westchester County, but to a different man and without divorcing her first husband.
... Only 18 days after that marriage, she got hitched yet again. Then, Barrientos declared "I do" five more times, sometimes only within two weeks of each other.
... In 2010, she married once more, this time in the Bronx. In an application for a marriage license, she stated it was her "first and only" marriage.
... Barrientos, now 39, is facing two criminal counts of "offering a false instrument for filing in the first degree," referring to her false statements on the
... 2010 marriage license application, according to court documents.
... Prosecutors said the marriages were part of an immigration scam.
... On Friday, she pleaded not guilty at State Supreme Court in the Bronx, according to her attorney, Christopher Wright, who declined to comment further.
... After leaving court, Barrientos was arrested and charged with theft of service and criminal trespass for allegedly sneaking into the New York subway through an emergency exit, said Detective
... Annette Markowski, a police spokeswoman. In total, Barrientos has been married 10 times, with nine of her marriages occurring between 1999 and 2002.
... All occurred either in Westchester County, Long Island, New Jersey or the Bronx. She is believed to still be married to four men, and at one time, she was married to eight men at once, prosecutors say.
... Prosecutors said the immigration scam involved some of her husbands, who filed for permanent residence status shortly after the marriages.
... Any divorces happened only after such filings were approved. It was unclear whether any of the men will be prosecuted.
... The case was referred to the Bronx District Attorney\'s Office by Immigration and Customs Enforcement and the Department of Homeland Security\'s
... Investigation Division. Seven of the men are from so-called "red-flagged" countries, including Egypt, Turkey, Georgia, Pakistan and Mali.
... Her eighth husband, Rashid Rajput, was deported in 2006 to his native Pakistan after an investigation by the Joint Terrorism Task Force.
... If convicted, Barrientos faces up to four years in prison.  Her next court appearance is scheduled for May 18.
... """
```

```python
>>> print(summarizer(ARTICLE, max_length=130, min_length=30, do_sample=False))
[{'summary_text': ' Liana Barrientos, 39, is charged with two counts of "offering a false instrument for filing in
the first degree" In total, she has been married 10 times, with nine of her marriages occurring between 1999 and
2002 . At one time, she was married to eight men at once, prosecutors say .'}]
```

### Translation
翻訳

### Language Modeling
Masked language modelingとは、モデルをドメイン固有コーパスにfitさせるタスクである。
例えば、BERTだとmasked language modeling、GPT-2だとcausal language modelingが使われている。

#### Masked Language Modeling
maskされた単語を予想する
    
#### Causal Language Modeling
与えられた単語列から次の単語を予測する

#### Text Generation
文章の書き出しを入力すると、その後の文章を生成する。

```python
from transformers import pipeline

text_generator = pipeline("text-generation")

print(text_generator("As far as I am concerned, I will", max_length=50, do_sample=False))
[{'generated_text': 'As far as I am concerned, I will be the first to admit that I am not a fan of the idea of a "free market." I think that the idea of a free market is a bit of a stretch. I think that the idea'}]
```
    


## preprocessing data

https://huggingface.co/docs/transformers/master/en/preprocessing

### tokeninze

```python
encoded_input = tokenizer("Hello, I'm a single sentence!")
>>> print(encoded_input)
{'input_ids': [101, 138, 18696, 155, 1942, 3190, 1144, 1572, 13745, 1104, 159, 9664, 2107, 102], 
 'token_type_ids': [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 
 'attention_mask': [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]}
```

### decode

```python
tokenizer.decode(encoded_input["input_ids"])
"[CLS] Hello, I'm a single sentence! [SEP]"
```


## pairs of sentences
文章のtokenizeや文章のペアのtokeninzeをやってくれる

### tokeninze

```python
encoded_input = tokenizer("How old are you?", "I'm 6 years old")
>>> print(encoded_input)
{'input_ids': [101, 1731, 1385, 1132, 1128, 136, 102, 146, 112, 182, 127, 1201, 1385, 102], 
 'token_type_ids': [0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1], 
 'attention_mask': [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]}
 ```
 
### decode

```python
>>> tokenizer.decode(encoded_input["input_ids"])
"[CLS] How old are you? [SEP] I'm 6 years old [SEP]"
```


## summary of the models
利用可能なモデル

https://huggingface.co/docs/transformers/model_summary


モデルは以下のカテゴリに分類される

- autoregressive-models
- autoencoding-models
- seq-to-seq-models
- multimodal-models
- retrieval-based-models



## Fine-tuning (for Keras)
https://huggingface.co/docs/transformers/training#finetuning-with-keras

サンプルのデータセットを準備


```python
from datasets import load_dataset

raw_datasets = load_dataset("imdb")

def tokenize_function(examples):
    return tokenizer(examples["text"], padding="max_length", truncation=True)

tokenized_datasets = raw_datasets.map(tokenize_function, batched=True)


small_train_dataset = tokenized_datasets["train"].shuffle(seed=42).select(range(1000)) 
small_eval_dataset = tokenized_datasets["test"].shuffle(seed=42).select(range(1000)) 
full_train_dataset = tokenized_datasets["train"]
full_eval_dataset = tokenized_datasets["test"]
```



モデルをロード

```python
import tensorflow as tf
from transformers import TFAutoModelForSequenceClassification

model = TFAutoModelForSequenceClassification.from_pretrained("bert-base-cased", num_labels=2)
```

keras用にデータセットを使うには少しformatする必要がある

```python
tf_train_dataset = small_train_dataset.remove_columns(["text"]).with_format("tensorflow")
tf_eval_dataset = small_eval_dataset.remove_columns(["text"]).with_format("tensorflow")


train_features = {x: tf_train_dataset[x] for x in tokenizer.model_input_names}
train_tf_dataset = tf.data.Dataset.from_tensor_slices((train_features, tf_train_dataset["label"]))
train_tf_dataset = train_tf_dataset.shuffle(len(tf_train_dataset)).batch(8)

eval_features = {x: tf_eval_dataset[x] for x in tokenizer.model_input_names}
eval_tf_dataset = tf.data.Dataset.from_tensor_slices((eval_features, tf_eval_dataset["label"]))
eval_tf_dataset = eval_tf_dataset.batch(8)
```

あとはいつもどおり

```python
model.compile(
    optimizer=tf.keras.optimizers.Adam(learning_rate=5e-5),
    loss=tf.keras.losses.SparseCategoricalCrossentropy(from_logits=True),
    metrics=tf.metrics.SparseCategoricalAccuracy(),
)

model.fit(train_tf_dataset, validation_data=eval_tf_dataset, epochs=3)
```
