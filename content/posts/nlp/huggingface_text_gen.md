---
title: "Huggingfaceのtext generation pipelineとtext2text generation pipeline"
slug: "huggingface-text-gen"
tags: ["nlp","deeplearning", "python", "huggingface"]
date: "2023-02-06T00:00:00+09:00"
draft: false
---

HuggingfaceのpipelineでTextGenerationPipelineとText2TextGenerationPipelineがあるが、
何が違うのかよくわからなかったので軽く調査。

https://huggingface.co/docs/transformers/main_classes/pipelines#transformers.TextGenerationPipeline

https://huggingface.co/docs/transformers/main_classes/pipelines#transformers.Text2TextGenerationPipeline


exampleを見ると、text-generationは与えた文章に続く文章を生成、
text2text-generationは質問や文脈を与えて、それに対する回答を生成することを期待している。

```
## text-generation
>> generator("I can't believe you did such a ", do_sample=False)
```


```
## text2text-generation
>> generator(
    "answer: Manuel context: Manuel has created RuPERTa-base with the support of HF-Transformers and >> Google"
)
```

## 比較
genereate時、`preprocess -> _forward -> postprocess`の順で動く

それぞれ`__call__`の引数の被ってないものをみると以下のような感じ

text_generation
- prefix
- handle_long_generation 
- return_full_text 

text2text_generation
- truncation 

https://github.com/huggingface/transformers/blob/v4.26.0/src/transformers/pipelines/text_generation.py#L169

https://github.com/huggingface/transformers/blob/v4.26.0/src/transformers/pipelines/text2text_generation.py#L136


preprocessを見ると、入力文章が長すぎる場合
- text2text_generation: 引数によってtokenize時にtruncate
- text_generation: errorをthrow

postprocessを見ると、返す文章は
- text2text_generation: 質疑応答のようなタスクに対する回答のみを返す。
- text_generation: return_full_textで指定できるように、与えた文章を除き生成した文章のみを返すようなことができる。

## まとめ
exampleの通り、text_generationは不完全な文章からそれに続くある程度長い文章を文章を生成することを期待している。
text2text_generationは、truncateできることから長い文章の生成というより、タスクに対する回答を重視しているように見える。

kwargsでgenerateに対して引数を渡せるので、ここからも調整できる。

https://huggingface.co/docs/transformers/v4.26.0/en/main_classes/text_generation#transformers.GenerationMixin.generate

