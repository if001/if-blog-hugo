---
title: "huggingfaceのgenerationの関数をtorch modelから使えるようにしたい"
slug: "hf_generation_wrap"
tags: ["python", "nlp", "huggingface","torch", "pre_training"]
date: "2023-12-05T00:00:00+09:00"
draft: false
---

torchなどのライブラリを使いpre_trainingを行い文章生成させる際、文章生成の計算は基本的に自分で実装する必要がある。
huggingface用のmodelに変換しても良いが、おれおれアーキテクチャにした場合、変換も面倒...

そこで、huggingfaceにあるtop_kやtop_pなどの便利な実装を使えるようにするメモ。

文章生成についての手法は以下がわかりやすくておすすめ  
https://huggingface.co/blog/how-to-generate


## logits_processの実装
logits_processの処理は、以下にまとまっている。  
https://github.com/huggingface/transformers/blob/v4.35.2/src/transformers/generation/logits_process.py


例えば、top_kは以下のような実装となっている。

```python{ref="https://github.com/huggingface/transformers/blob/v4.35.2/src/transformers/generation/logits_process.py#L448-L453C22"}
def __call__(self, input_ids: torch.LongTensor, scores: torch.FloatTensor) -> torch.FloatTensor:
    top_k = min(self.top_k, scores.size(-1))  # Safety check
    # Remove all tokens with a probability less than the last token of the top-k
    indices_to_remove = scores < torch.topk(scores, top_k)[0][..., -1, None]
    scores = scores.masked_fill(indices_to_remove, self.filter_value)
    return scores
```

よく使うのは、top_pやtop_k、NoRepeatNGramLogitsProcessor、RepetitionPenaltyLogitsProcessorあたり

NoRepeatNGramLogitsProcessor  
https://github.com/huggingface/transformers/blob/v4.35.2/src/transformers/generation/logits_process.py#L718

RepetitionPenaltyLogitsProcessor  
https://github.com/huggingface/transformers/blob/v4.35.2/src/transformers/generation/logits_process.py#L270


## huggingfaceでの実装

よく使うのは、`model.generate` だが、generateからsampleが選択される部分はここ  
https://github.com/huggingface/transformers/blob/v4.35.2/src/transformers/generation/utils.py#L1706


sample関数の実装   
https://github.com/huggingface/transformers/blob/v4.35.2/src/transformers/generation/utils.py#L2612


huggingfaceのsampleでは、logits_processorは次のように使われている

```python{ref="https://github.com/huggingface/transformers/blob/v4.35.2/src/transformers/generation/utils.py#L2813-L2816"}
next_token_scores = logits_processor(input_ids, next_token_logits)
next_token_scores = logits_warper(input_ids, next_token_scores)

...

probs = nn.functional.softmax(next_token_scores, dim=-1)
next_tokens = torch.multinomial(probs, num_samples=1).squeeze(1)
```

greedy searchの実装はここ  
https://github.com/huggingface/transformers/blob/v4.35.2/src/transformers/generation/utils.py#L2353


argmaxを使っているのがわかる

```python{ref="https://github.com/huggingface/transformers/blob/v4.35.2/src/transformers/generation/utils.py#L2555"}
next_tokens = torch.argmax(next_tokens_scores, dim=-1)
```


## torchのmodelの出力に対して使う
modelの作り方にも依るが、基本的にはlogitが出力されるように作るはず。

使い方は、`LogitsProcessorList`を定義して、ここまでの入力xとlogitを渡すだけ。
xはtokenizerされた単語のlist、例えば`[20, 15, 1, 1120, ....]`のようなtensorとなる。

用途によってtensorの次元を合わせてください。

```python
from transformers.generation.utils import (
    LogitsProcessorList, 
    TopKLogitsWarper,
    TopPLogitsWarper,
    TemperatureLogitsWarper,
    RepetitionPenaltyLogitsProcessor
)

logits_processor = LogitsProcessorList([
    RepetitionPenaltyLogitsProcessor(repetition_penalty),
])

logits_wraper = LogitsProcessorList([
        TemperatureLogitsWarper(temperature),
        TopPLogitsWarper(top_p),
        TopKLogitsWarper(top_k),
])

## modelからlogitsを得る
logits = model(x, input_pos)

logits = logits[:, -1, :] ## sequenceの最後のlogit
next_token_scores = logits_processor(x, logits)
next_token_scores = logits_wraper(x, next_token_scores)
next_token_scores = next_token_scores.squeeze(0) ## 次元の調整

## next_token_scoresに対してsoftmaxで確率にして、次のtokenのindexを出力する
probs = torch.nn.functional.softmax(next_token_scores, dim=-1)
next_idx = torch.multinomial(probs, num_samples=1)
```

## 所感
top_k, temperatureくらいだと自分で実装しても良いが、RepetitionPenaltyはここまでのindexも見る必要がありめんどうだったので、huggingfaceの実装を使った。  
他にも便利な処理もあるので、一度使えるようにしておくと便利。
