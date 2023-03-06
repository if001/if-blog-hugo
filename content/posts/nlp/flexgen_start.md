---
title: "FlexGenで遊ぶ"
slug: "flexgen_start"
tags: ["nlp","deeplearning","python", "huggingface"]
date: "2023-02-28T00:00:00+09:00"
draft: false
---

くそでかlarge language modelsは一般人の持ってるPCだと動かすこともできない。
FlexGenでは、そんなLLMを限られたリソースで実行できるようにしてくれる。

https://github.com/FMInference/FlexGen

日本語が喋れるモデルでも動かせるように色々と試してみた。

## まずは動かす
installはreadme通り

```
pip install flexgen
```

start

```
python3 -m flexgen.flex_opt --model facebook/opt-1.3b
```

ベンチマークが表示され、モデルを動かせたことがわかる

```
TorchDevice: cuda:0
  cur_mem: 2.6426 GB,  peak_mem: 3.2399 GB
TorchDevice: cpu
  cur_mem: 0.0000 GB,  peak_mem: 0.0000 GB
model size: 2.443 GB    cache size: 0.398 GB    hidden size (p): 0.008 GB
peak gpu mem: 3.240 GB  projected: False
prefill latency: 1.301 s        prefill throughput: 1573.627 token/s
decode latency: 1.797 s decode throughput: 68.991 token/s
total latency: 3.099 s  total throughput: 41.306 token/s
```

OPT-30Bのような大きなモデルを動かす場合は、`--percent`のパラメタを付けてGPUとCPUの割当の設定を行う

```
python3 -m flexgen.flex_opt --model facebook/opt-30b --percent 0 100 100 0 100 0
```

percenteには６つの数字を入力できる。それぞれ、

"the percentage of weight on GPU, "

"the percentage of weight on CPU, "

"the percentage of attention cache on GPU, "

"the percentage of attention cache on CPU, "

"the percentage of activations on GPU, "

"the percentage of activations on CPU"

https://github.com/FMInference/FlexGen/blob/9d092d848f106cd9eaf305c12ef3590f7bcb0277/flexgen/flex_opt.py#L1271-L1279

## 日本語モデルを動かしたい
日本語を喋らせたいので、以前少し触ったxglmで動くか試してみる。  
現状では、FlexGenはOPTのみをサポートしているが、モデルのアーキテクチャが同じであればいけそう。

`flexgen.flex_opt`の処理の流れを見つつ、修正していく。  
クラスOptLMはtransformerをラップしたもので、OptLMが効率的な計算部分を担ってくれている。  
OptLMは、`InputEmbed -> TransformerLayer(SelfAttention -> MLP) -> OutputEmbed`のレイヤーを持つ。  
(sep_layer = trueの場合は異なるがここではスキップ)  
`flexgen.flex_opt`の処理は、既存のOPTのweightをレイヤーごとに分割し、OptLMの持つレイヤーに割り当て、計算といった感じ。


処理の流れのうちモデル変更に関わってきそうな部分はこのあたり

- model用のconfigを作成
- 指定したmodelのweightをHuggingfaceからダウンロード
- weightをレイヤーごとに分割/保存
- OptLMの各レイヤーにweightを割り当て
- model.generateでbenchmarkを生成

### 1. model用のconfigを作成
Opt用のconfigは以下のように作成しているので、xglmに合わせて修正する

https://github.com/FMInference/FlexGen/blob/main/flexgen/opt_config.py#L112-L116


とりあえず、以下のような感じで良さそう

```python
elif arch_name == "xglm-1.7b":
    config = OptConfig(name=name,
            max_seq_len=2048, num_hidden_layers=24, n_head=16,            
            hidden_size=2048, input_dim=2048, ffn_embed_dim=2048 * 4,
            vocab_size=256008, activation_fn='gelu'
        )
```

### 2. 指定したmodelのweightをHuggingfaceからダウンロード
snapshot_downloadでhuggingfaceからモデルのbinファイルを取得できる  
(この機能知らなかったので一応)

```python
from huggingface_hub import snapshot_download
folder = snapshot_download(hf_model_name, allow_patterns="*.bin")
```

### 3. weightをレイヤーごとに分割/保存
bin形式のファイルは、`torch.load`すると、iterでレイヤーごとに取得できる

```python
bin_files = glob.glob(os.path.join(folder, "*.bin"))
for bin_file in tqdm(bin_files, desc="Convert format"):
    state = torch.load(bin_file)
    for name, param in tqdm(state.items(), leave=False):
        print(name)
```

xglmで試すとこんな感じ

```
model.embed_tokens.weight
model.layers.0.self_attn.k_proj.weight
model.layers.0.self_attn.k_proj.bias
model.layers.0.self_attn.v_proj.weight
model.layers.0.self_attn.v_proj.bias
model.layers.0.self_attn.q_proj.weight
.
.
.
model.layers.23.final_layer_norm.weight
model.layers.23.final_layer_norm.bias
model.layer_norm.weight
model.layer_norm.bias
```


OPTのweightは、名前にprefixとして`decoder`がついている。
xglmではついていないのでdecoderは外しておく。

```python{ref="https://github.com/FMInference/FlexGen/blob/main/flexgen/opt_config.py#L231"}
name = name.replace("decoder.final_layer_norm", "decoder.layer_norm")
```

分割したweightはnp形式で保存される

```python{ref="https://github.com/FMInference/FlexGen/blob/main/flexgen/opt_config.py#L234"}
   with open(param_path, "wb") as f:
                np.save(f, param.cpu().detach().numpy())
```

xglmを使う場合、取得してきたweightに`embed_positions.weight`が含まれずエラーとなる。
エラーを回避するために、一旦以下を参考にweightを無理やり作り出す。

```python{ref="https://github.com/huggingface/transformers/blob/main/src/transformers/models/xglm/modeling_xglm.py#L169"}
class XGLMSinusoidalPositionalEmbedding(nn.Module):
.
.
 def make_weights(self, num_embeddings: int, embedding_dim: int, padding_idx: Optional[int] = None):
        emb_weights = self.get_embedding(num_embeddings, embedding_dim, padding_idx)
```

(※ ここミスってそうなので要調査)

### 4. OptLMの各レイヤーにweightを割り当て

保存したweightは、レイヤークラスの持つload_weight methodで各レイヤーに割り当てられる

https://github.com/FMInference/FlexGen/blob/main/flexgen/flex_opt.py#L309


### 5. 任意の文章を入力できるようにする

引数に追加

```python{ref="https://github.com/FMInference/FlexGen/blob/main/flexgen/flex_opt.py#L1311-L1312"}
parser.add_argument("--prompt", type=str)
```

ここでサンプルのinputをつくっているので引数からpromptを入力にできるように修正する

```python{ref="https://github.com/FMInference/FlexGen/blob/main/flexgen/flex_opt.py#L1185"}
def get_test_inputs(prompt_len, num_prompts, tokenizer):
    prompts = ["Paris is the capital city of"]
    input_ids = tokenizer(prompts, padding="max_length",
                          max_length=prompt_len).input_ids
    return (input_ids[0],) * num_prompts
```

## 実行
ここまでで実行できるようになっているはず

```bash
$ python flexgen/gen.py \
--model "facebook/xglm-1.7B"  \
--prompt "それは九月初旬のある蒸し暑い晩のことであった。私は、Ｄ坂の大通りの中程にある、"

model size: 3.228 GB, cache size: 0.398 GB, hidden size (prefill): 0.008 GB
init weight...
それは九月初旬のある蒸し暑いのことであった。私は、D坂の大通りの中程にある、,,,,,,,,,,,,,,,,,,..........,,,,
```


```bash
$ python flexgen/gen.py \
--model "facebook/xglm-1.7B"  \
--gpu-batch-size 1 \
--overlap \
--prompt "それは九月初旬のある蒸し暑い晩のことであった。私は、Ｄ坂の大通りの中程にある、"


それは九月初旬のある蒸し暑いのことであった。私は、D坂の大通りの中程にある、 ... У,,  _. «乐”v,总鬼最后 critica,  В越最后cuimen.乐  总.,, ser.,  Um Extra 总ra. Big,, b Palm tags初 (b N  National póspey петmini其实,马
```

とりあえずエラーなく実行はできたがなんかおかしい。

xglmではpositional embeddingは学習してなさそうなので、FlexGenのInputEmbedのforwardの部分もweight使わないように修正しないとダメそう。

```python{ref="https://github.com/FMInference/FlexGen/blob/main/flexgen/flex_opt.py#L180"}
  def forward(self, hidden, cache_read_buf, weight_read_buf, attention_mask,
                cache_write_buf, i, k):
                ...
```


make_weightsって名前だから学習してるのかと思ったけど、そのままの埋込っぽい

```python{ref="https://github.com/huggingface/transformers/blob/main/src/transformers/models/xglm/modeling_xglm.py#L159"}
class XGLMSinusoidalPositionalEmbedding(nn.Module):
    """This module produces sinusoidal positional embeddings of any length."""

    def __init__(self, num_positions: int, embedding_dim: int, padding_idx: Optional[int] = None):
        super().__init__()
        self.offset = 2
        self.embedding_dim = embedding_dim
        self.padding_idx = padding_idx
        self.make_weights(num_positions + self.offset, embedding_dim, padding_idx)  
```
