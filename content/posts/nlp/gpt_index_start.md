---
title: "LlamaIndex(GPTIndex)を触る"
slug: "gpt_index_llama_index_start"
tags: ["nlp","deeplearning","python", "huggingface"]
date: "2023-03-04T00:00:00+09:00"
draft: false
---

LlamaIndexを動かしていきます。最近名前がGPTIndexから変わったみたい。

LlamaIndexとは、LLMのPromptの作成などを外部のデータソースと連携して行えるようにしたツールキット。  
https://gpt-index.readthedocs.io/en/latest/guides/primer.html  
データソースにはGoogle DocsやSlackなどが使えるらしい。

メインの機能は、DocsやSlack、Webの情報を体系化したIndexとして保持して、抽出できる機能でしょう。

OpenAIのAPIを使うことが多いと思いますが、今回はHugging faceのモデルを使ってみます。  
LangChainをwrapしている部分がいくつかあるので、LangChainについても知っておくと良いと思う。

## Install
doc通り

`pip install llama-index`


このあたりも使うので入れておく。

`pip install transformers sentencepiece torch langchain`

## とりあえず動かす
大まかな流れは、ドキュメントからIndexを作成、Indexに対してqueryを投げ、抽出する、といった感じ。

ドキュメントからIndexを作成する際に、以下の４つを使う。

- llm_predictor
- embed_model
- prompt_helper
- template

### llm_predictorの作成
llm_predictorは最終的な文章生成の際に使われる。インデックスの構築、挿入、クエリの走査中にも使用される場合がある。

Huggingfaceにあるmodelを使う例。モデルは好きなものを使ってください。

transformersのpipelineをlangchainのHuggingFacePipelineでwrap、  
langchainのHuggingFacePipelineをllama_indexのLLMPredictorでwrapする。

```python
model_name = "facebook/xglm-564M"
tokenizer = XGLMTokenizer.from_pretrained(model_name)
model = XGLMForCausalLM.from_pretrained(model_name)

pipe = pipeline("text2text-generation",
                model=model,
                tokenizer=tokenizer,
                torch_dtype=torch.float16)                
llm = HuggingFacePipeline(pipeline=pipe)

llm_predictor = LLMPredictor(llm=llm)
```

### embed_modelの作成
embed_modelはdocumentをsentense vectorにしindexを作成する際に使われる。　　
(queryによる抽出の方法がいくつかあるが、vectorの類似度から抽出する方法があるので、そこのembeddingでも使ってそう)　　


```python
model_name = "sonoisa/sentence-bert-base-ja-en-mean-tokens"
embeddings = HuggingFaceEmbeddings(model_name = model_name)
embed_model = LangchainEmbedding(embeddings)
```

### prompt helperの作成
tokenの制限に使われる。OpenAIのモデルを使う場合に設定するものだと思う。

```python
prompt_helper=PromptHelper.from_llm_predictor(
    llm_predictor=llm_predictor,
    max_chunk_overlap=0,
    chunk_size_limit=512,
    embedding_limit=1023,
)
```


### promptの作成
日本語のpromptが欲しかったので作成。

```python
QA_PROMPT_TMPL = (
    "以下は文脈情報です。\n"
    "---------------------\n"
    "{context_str}"
    "\n---------------------\n"
    "予備知識ではなく、文脈情報が与えられます。"
    "質問: {query_str}\n"
    "回答:\n"
)
QA_PROMPT = QuestionAnswerPrompt(QA_PROMPT_TMPL)
```

### indexの作成
これまでに作成した４つをあわせてindexを作成

- llm_predictor
- embed_model
- prompt_helper
- template

```python
index = GPTSimpleVectorIndex(documents, 
                            llm_predictor=llm_predictor,
                            embed_model=embed_model,
                            prompt_helper=prompt_helper,
                            text_qa_template=QA_PROMPT,
                            )
```

### query
GPTSimpleVectorIndexに渡すtext_qa_templateと同じものを、queryにも渡します。

```python
query_str = "podについて教えてください。"
response = index.query(query_str, text_qa_template=QA_PROMPT)

print("response:", response.response, "\n")
print("source_nodes:", response.source_nodes, "\n")
```


## Indexについて
documentを読み込み、チャンクに分割、embeddingしたものNodeと呼ぶ。  

このNode郡をIndexと呼ぶ  
Nodeの束ね方はには種類がいくつかあり、sequentialに並べただけのList Indexや階層構造を持つTree Indexがある。  

Indexの種類ごとにqueryの走査が異なる。  
https://gpt-index.readthedocs.io/en/latest/guides/index_guide.html

とりあえず動かす場合、vector store使うのがおすすめらしい  
https://gpt-index.readthedocs.io/en/latest/guides/use_cases.html#use-case-just-starting-out

vector storeは、いろいろなinmemory dbに対応してそう  
https://github.com/jerryjliu/gpt_index/blob/v0.4.20/gpt_index/indices/vector_store/vector_indices.py



作成したindexに対し、追加/削除も可能  
https://gpt-index.readthedocs.io/en/latest/how_to/update.html


## query modeについて
色々試し中  
https://gpt-index.readthedocs.io/en/latest/guides/usage_pattern.html#setting-response-mode



## コードサンプル
https://github.com/jerryjliu/gpt_index/tree/v0.4.20/examples