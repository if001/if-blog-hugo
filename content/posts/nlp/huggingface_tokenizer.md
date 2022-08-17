---
title: "Hugging Faceのtokenizerで迷ったのでまとめておく"
slug: "huggingface-tokenizer"
tags: ["nlp","deeplearning", "python", "huggingface"]
date: "2022-08-16T09:00:00+09:00"
draft: false
---


tokeninzerとかencodeとか色々あって毎回調べることになるのでメモ。

以下の日本語tokenizerを使わせてもらう。

```python
tokenizer = T5Tokenizer.from_pretrained("sonoisa/t5-base-japanese")
```


## よく見る書き方

```python
sentence = "私は走ります。"
tokenizer(sentence)

>> {'input_ids': [5, 4378, 6368, 998, 4, 1], 'attention_mask': [1, 1, 1, 1, 1, 1]}
```

input_idsとmaskどっちも簡単にとれる

## encode

```python
sentence = "私は走ります。"
tokenizer.encode(sentence)

>> [5, 4378, 6368, 998, 4, 1]
```

input_idsだけがとれる


## convert_tokens_to_ids

```python
sentence = "私は走ります。"
splited = tokenizer.tokenize(sentence)
 
 >> ['▁', '私は', '走り', 'ます', '。']

 
tokenizer.convert_tokens_to_ids(splited)
 
>>  [5, 4378, 6368, 998, 4]
```

分かち書きしてからidにする


## encode_plus
tokeninzerの`__call__`と同じ


```python
sentence = "私は走ります。"
tokenizer.encode_plus(sentence)

>> {'input_ids': [5, 4378, 6368, 998, 4, 1], 'attention_mask': [1, 1, 1, 1, 1, 1]}
```


## batch_encode_plus
batchに対応

```python
sentence = "私は走ります。"
tokenizer.batch_encode_plus([sentence, sentence])

>> {'input_ids': [[5, 4378, 6368, 998, 4, 1], [5, 4378, 6368, 998, 4, 1]], 'attention_mask': [[1, 1, 1, 1, 1, 1], [1, 1, 1, 1, 1, 1]]}
```


## max_length, paddingとか
`max_lenght`と`padding`が指定できる

```python
sentence = "私は走ります。"
tokenizer(sentence, max_length=20, truncation=True, padding="max_length")

>> {'input_ids': [5, 4378, 6368, 998, 4, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 'attention_mask': [1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}
```

paddingのデフォルトはpaddingしないっぽい(padding="do_not_pad")

https://github.com/huggingface/transformers/blob/v4.21.1/src/transformers/utils/generic.py#L255-L263


```python
# 最大長にあわせてpadding
tokenizer.batch_encode_plus(["私は今日も走ります。", "私は走る。"], padding="longest")

>> {'input_ids': [[5, 4378, 4634, 28, 6368, 998, 4, 1], [5, 4378, 9050, 4, 1, 0, 0, 0]], 'attention_mask': [[1, 1, 1, 1, 1, 1, 1, 1], [1, 1, 1, 1, 1, 0, 0, 0]]}


# max_lengthにあわせてpadding
tokenizer.batch_encode_plus(["私は今日も走ります。", "私は走る。"], padding="max_length", max_length=15)

>> {'input_ids': [[5, 4378, 4634, 28, 6368, 998, 4, 1, 0, 0, 0, 0, 0, 0, 0], [5, 4378, 9050, 4, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]], 'attention_mask': [[1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0], [1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]}


# defaultではpaddingしない
tokenizer.batch_encode_plus(["私は今日も走ります。", "私は走る。"])

>> {'input_ids': [[5, 4378, 4634, 28, 6368, 998, 4, 1], [5, 4378, 9050, 4, 1]], 'attention_mask': [[1, 1, 1, 1, 1, 1, 1, 1], [1, 1, 1, 1, 1]]}
```


## メモ
コード見てて気付いたけど、pythonでabstract classのmethodの実装を強制させるパターンが以下のように書ける。


```python
class PreTrainedTokenizerBase():
	def encode_plus(self, ...):
		return self._encode_plus()
		
		
	def _encode_plus(self, ...):
        raise NotImplementedError
		
		
class PreTrainedTokenizer(PreTrainedTokenizerBase):
	def _encode_plus(self,...):
		...
```


