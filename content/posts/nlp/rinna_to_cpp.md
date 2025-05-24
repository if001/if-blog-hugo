---
title: "rinna 3Bをcppで動かす"
slug: "rinna_3B_cpp"
tags: ["nlp","deeplearning","python","huggingface"]
date: "2023-05-18T00:00:00+09:00"
draft: false
---

rinnaをcppで動かせるように色々試して見ました。
instructionもあり、そのままlangchainなどに突っ込んでも動かせそうということで、
ローカルで遊ぶならcppしてないと遊べないので色々試してみました。

https://huggingface.co/rinna/japanese-gpt-neox-3.6b-instruction-sft

** コード的な動作をさせただけです。**  
** 量子化はあまり追いつけてないので、色々と間違っていればツッコミお願いします。** 

実行環境は、colab T4 ハイメモリ

## 調査
以下で中身を確認

```python
from transformers import AutoModelForCausalLM
base_model = 'rinna/japanese-gpt-neox-3.6b-instruction-sft'
model = AutoModelForCausalLM.from_pretrained(base_model)

for v in model.state_dict().items():
  print(v[0])
```

アーキテクチャはgpt-neox

```
gpt_neox.embed_in.weight
gpt_neox.layers.0.input_layernorm.weight
gpt_neox.layers.0.input_layernorm.bias
gpt_neox.layers.0.post_attention_layernorm.weight
gpt_neox.layers.0.post_attention_layernorm.bias

(省略)

gpt_neox.layers.35.mlp.dense_4h_to_h.weight
gpt_neox.layers.35.mlp.dense_4h_to_h.bias
gpt_neox.final_layer_norm.weight
gpt_neox.final_layer_norm.bias
embed_out.weight
```

redpajamaがgpe-neoxベースだったので、以下がそのまま使えそう。

https://github.com/togethercomputer/redpajama.cpp/tree/master/examples/redpajama


## ggml形式に変換
packageなどinstallして、以下のコードを参考に実行。

https://github.com/togethercomputer/redpajama.cpp/blob/master/examples/redpajama/scripts/convert_gptneox_to_ggml.py

```bash
python convert_gptneox_to_ggml.py 'rinna/japanese-gpt-neox-3.6b-instruction-sft' ./output_dir
```

convert_gptneox_to_ggml.pyの中で、以下のようにモデルの中身を全部見てるので多少redpajamaと違ってもいけてそう

```python
hparams = model.config.to_dict()
print("Model loaded: ", model_name)
```

## quantize
README通りにコンパイル

```bash
make quantize-gptneox
```

README通りにquantize

q8_0が対応していたので、q8_0を指定

> Generate the quantized model, the supported types include: q4_0, q4_1, q4_2, q5_0, q5_1, and q8_0. For example, to run q4_1, you need to do the following convertion:

```bash
model="./output_dir/ggml-japanese-gpt-neox-3.6b-instruction-sft-f16.bin"
python ./examples/redpajama/scripts/quantize-gptneox.py $model --quantize-output-type q8_0
```

## 動作確認
実行用のスクリプトをコンパイル

```bash
make redpajama
```

実行

```bash
model="/content/drive/MyDrive/models/rinna_3B_cpp/ggml-rinna-3B-q8_0.bin"
prompt = [
    {
        "speaker": "ユーザー",
        "text": "日本のおすすめの観光地を教えてください。"
    },
    {
        "speaker": "システム",
        "text": "どの地域の観光地が知りたいですか？"
    },
    {
        "speaker": "ユーザー",
        "text": "渋谷の観光地を教えてください。"
    }
]
prompt = [
    f"{uttr['speaker']}: {uttr['text']}"
    for uttr in prompt
]
prompt = "<NL>".join(prompt)
prompt = (
    prompt
    + "<NL>"
    + "システム: "
)


!./redpajama -m "$model" \
  -c 1024 \
  -b 128 \
  -n 1 \
  -t 8 \
  --color \
  --top_k 30 \
  --top_p 0.95 \
  --temp 0.8 \
  --repeat_last_n 3 \
  --repeat_penalty 1.1 \
  --seed 0 \
  --n_predict 256 \
  --verbose-prompt \
  -p "$prompt"
```

出力

```
> ユーザー:<0x1C>日本のおすすめの観光地を教えてください。<NL>システム:<0x1C>どの地域の観光地が知りたいですか<0xEB><0xB8><0x9B><NL>ユーザー:<0x1C>渋谷の観光地を教えてください。<NL>システム:<0x1C>

東京の観光地について知りたいですか?</s>(注)この記事は、私が作成したものではなく、記事の著者は、この記事の作成に同意していません。</s>この記事は、
```

だいぶあほになってそうだが、とりあえず日本語は出力できている。
(半角スペースや改行コードはおそらくスクリプト側で出力？)

## python bindingで動かす
llama.cppのpython bindingであるllama-cpp-pythonを使う。
このライブラリ経由だと、langchainから簡単に呼び出せる。

https://github.com/abetlen/llama-cpp-python

### libllama.soの作成
まずはredpajama.cpp側でコンパイルして共有ライブラリを作る。   
llama-cpp-pythonでgptneox_token_nlを呼び出しているので、以下のコメントを解除

```cpp{ref="https://github.com/togethercomputer/redpajama.cpp/blob/master/examples/redpajama/gptneox.h#L196"}
GPTNEOX_API gptneox_token gptneox_token_nl(); 
```

以下を参考に、Makefile必要なファイルを加えて少し書き換える。  
https://github.com/togethercomputer/redpajama.cpp/blob/master/Makefile#L193

```
libllama.so: ggml.o gptneox.o common-gptneox.o $(OBJS)
$(CXX) $(CXXFLAGS) -shared -fPIC -o $@ $^ $(LDFLAGS)
```

コンパイル

```
make libllama.so
```

llama-cpp-pythonをinstallしたディレクトリ(多分こんな感じ `lib/python3.8/site-packages/llama_cpp`)の
`libllama.so`を今作った`libllama.so`に置き換える。

### pythonからcppを呼び出す箇所の修正

次に、cppをpythonから呼び出している部分を修正

https://github.com/abetlen/llama-cpp-python/blob/main/llama_cpp/llama_cpp.py

`_lib.llama` → `_lib.gptnexo`を置き換え

例えば、以下のような感じ

```python
def llama_context_default_params() -> llama_context_params:
    return _lib.llama_context_default_params()

_lib.llama_context_default_params.argtypes = []
_lib.llama_context_default_params.restype = llama_context_params
```

↓

```python
def llama_context_default_params() -> llama_context_params:
    return _lib.gptneox_context_default_params()

_lib.gptneox_context_default_params.argtypes = []
_lib.gptneox_context_default_params.restype = llama_context_params
```

## langchainから呼び出す

```python
from langchain.llms import LlamaCpp

model_path='../llama.cpp/models/ggml-rinna-3B-q8_0.bin'
stop = [
    '\nシステム: ',
    '\n\tシステム: ',
    '</s>'
]
llm = LlamaCpp(
    model_path=model_path,
    n_ctx=1024,
    max_tokens=256,
    seed=1,
    stop=stop,
    f16_kv=True
)
prompt="""ユーザー: 日本のおすすめの観光地を教えてください。<NL>
システム: どの地域の観光地が知りたいですか？<NL>
ユーザー: 渋谷の観光地を教えてください。<NL>
システム:"""

r = llm(prompt)
print(r)
```

以下は4回実行した結果。

```bash
gptneox.cpp: loading model from ./models/ggml-rinna-3B-q8_0.bin
gptneox_model_load_internal: format     = ggjt v1 (latest)
gptneox_model_load_internal: n_vocab    = 32000
gptneox_model_load_internal: n_ctx      = 1024
gptneox_model_load_internal: n_embd     = 2816
gptneox_model_load_internal: n_head     = 22
gptneox_model_load_internal: n_layer    = 36
gptneox_model_load_internal: n_rot      = 128
gptneox_model_load_internal: use_parallel_residual = 0
gptneox_model_load_internal: ftype      = 7 (mostly Q8_0)
gptneox_model_load_internal: n_parts    = 1
gptneox_model_load_internal: model size = 12B
gptneox_model_load_internal: ggml ctx size = 3966856.19 KiB
gptneox_model_load_internal: mem required  = 5921.88 MiB (+ 1608.00 MiB per state)
warning: failed to mlock 4062064640-byte buffer (after previously locking 0 bytes): Cannot allocate memory
Try increasing RLIMIT_MLOCK ('ulimit -l' as root).
..................................................................................................
.
.
gptneox_init_from_file: kv self size  =  396.00 MiB
AVX = 1 | AVX2 = 1 | AVX512 = 0 | AVX512_VBMI = 0 | AVX512_VNNI = 0 | FMA = 1 | NEON = 0 | ARM_FMA = 0 | F16C = 1 | FP16_VA = 0 | WASM_SIMD = 0 | BLAS = 0 | SSE3 = 1 | VSX = 0 |

わかりました、具体的に何の情報を探していますか?

-- 

東京のどの部分を訪れますか?

--

ああ、あなたは東京のことですね?私は「日本の首都」または「日本の首都」という言葉の意味を理解できないかもしれません。

--

ああ、これは難しい質問ですね!私は東京の観光地について専門家ではありませんが、調べてみますか?
```

とりあえず、それっぽいことは返せているが、ちょっとあほになってそう。

## まとめ
rinna 3.6b-instructionをquantizeしてみました。
少しあほになってそうだが、一旦動かせるところまでできた。
もうちょっと調査してforkかPR作るかなぁ...


## 追記
rinnaの場合、勝手にeosを付けないようにtokenize時に`add_special_tokens=False`とする必要がある。

```python
token_ids = tokenizer.encode(prompt, add_special_tokens=False, return_tensors="pt")
```

cppだと勝手にeos付けてそうな気がするので、確認しないと
