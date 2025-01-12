---
title: "Mixture of expertsのサンプル実装"
slug: "mixture_of_experts_sample"
tags: ["python", "nlp","torch"]
date: "2023-12-16T00:00:00+09:00"
draft: false
---

mixture of expertsを実装してみる。
並列化や計算効率の向上などの部分は複雑なので、それら取り除いた簡単な実装を行ってみる。

## Mixture of expertsとは
特定のタスクに特化したexpertを複数用意し、入力に対してexpertを切り替えることで性能を上げる手法。
expertを選択するgate部分とexpert部分からなる。

decoder型のtransformer、特にcausal modelの場合、Mixture of expertsはattention層のあとのFFNに対して適応される。
(学習時では、attention層とexpertやgate部分は同時に進行していくが、expertにちゃんとわかれるのかがよくわからん...
一応loss関数でとあるexpertだけに集中しないようになどの工夫はあるが)

図

https://arxiv.org/abs/2101.03961


gate関数やexpert層の違いによりいくつかのMoEの種類が提案されているが、sparse MoEを使ったものが多く見られる

### sparse MoE
gate関数が上位n個のexpertを選択するような出力を行う。選択するexpert以外の部分は0になるようなスパース性を持つ。  
0が含まれることで選択されないexpertでは計算する必要がないため、計算コストが削減される

mixtralの実装はこんな感じ  
https://github.com/huggingface/transformers/blob/238d2e3c44366aba9dc5c770c95475765a6725cb/src/transformers/models/mixtral/modeling_mixtral.py#L688


通常のMoEでは、特定のexpertが多く選択されてしまうことがあり、学習が非効率なものとなってしまう。
これを軽減するため、auxiliary lossを導入する。


図


$f_i$は$expert_i$に割り振られたトークンの割合
$P_i$は$expert_i$に割り振られる可能性の確率

$f_i$と$P_i$が均等であれば、ルーティングも均等になるというlossになる


mixtralのlossの実装はこんな感じ  
https://github.com/huggingface/transformers/blob/238d2e3c44366aba9dc5c770c95475765a6725cb/src/transformers/models/mixtral/modeling_mixtral.py#L76


## ST-MoE
Stable and Transferable Mixture-of-Expertsの提案
(設計ガイドとして良さそうなのであとでちゃんと読む)



https://arxiv.org/abs/2202.08906

実装が以下で公開されている  
https://github.com/tensorflow/mesh/blob/master/mesh_tensorflow/transformer/moe.py

## 実装
今回はsparseでなく、もっと単純なもので動きを確認する。


```python
import torch
import torch.nn as nn
import torch.nn.functional as F

class MoE(nn.Module):
    def __init__(self, 
                 embed_size=128, 
                 num_experts=4, 
                 expert_hidden_size=256, 
                 gate_hidden_size=256,
                 device="auto",
                 ):
        super(MoE, self).__init__()
        self.embed_size = embed_size
        self.num_experts = num_experts

        expert = nn.Sequential(
                nn.Linear(embed_size, expert_hidden_size),
                nn.ReLU(),
                nn.Linear(expert_hidden_size, embed_size)
            )
        
        self.experts = nn.ModuleList([expert for _ in range(num_experts)])

        self.gate =  nn.Sequential(
            nn.Linear(embed_size, gate_hidden_size),
            nn.ELU(),
            nn.Linear(gate_hidden_size, num_experts),
        )

    def forward(self, x):
        """
        Forward pass for MoE
        :param x: Input tensor of shape (batch_size, seq_len, embed_size)
        :return: Output tensor. shape (batch_size, seq_len, embed_size)
        """
        # batch_size, seq_len, _ = x.size()
        
        gating_scores = self.gate(x)
        gating_weights = F.softmax(gating_scores, dim=2) # (batch_size, seq_len, num_experts)
        print('gating_weights', gating_weights.shape, gating_weights)
        
        expert_outputs = torch.stack([expert(x) for expert in self.experts], dim=2) # (batch_size, seq_len, num_experts, embed_size)
        ## gating_weights.unsqueeze(-1) # (batch_size, seq_len, num_experts, 1)
        output = torch.sum(gating_weights.unsqueeze(-1) * expert_outputs, dim=2) #  (batch_size, seq_len, embed_size)        
        return output
```

実装自体はシンプルで、gate関数の出力をsoftmaxを取ったもので、各expertを割合で増減させるイメージ。

例えば、以下のような例を入力とする
(実際には埋め込んだ状態でなく、attention weightを計算したあとのtensorになるので注意)

sequence_length=3
埋め込みサイズ=4

```
[I am running] => [[0.4081, 0.7244, 0.0221, 0.1677],[0.2508, 0.8103, 0.3783, 0.0399],[0.6584, 0.4243, 0.5941, 0.6102]]
```

expert=2, batch_size=1の例を入力する

入力shapeは(batch_size,sequence_length, 埋め込みサイズ)  
gating_weightsは、sequence_length毎にどのexpertに割り振られるかの確率となっている  

```
input: torch.Size([1, 3, 4]) 
tensor([[[0.4081, 0.7244, 0.0221, 0.1677],
         [0.2508, 0.8103, 0.3783, 0.0399],
         [0.6584, 0.4243, 0.5941, 0.6102]]])

gating_weights torch.Size([1, 3, 2]) 
tensor([[[0.5903, 0.4097],
         [0.6000, 0.4000],
         [0.6028, 0.3972]]], grad_fn=<SoftmaxBackward0>)

output: torch.Size([1, 3, 4]) 
tensor([[[ 0.5622, -0.0714,  0.0197, -0.2871],
         [ 0.6389, -0.1067, -0.0396, -0.2993],
         [ 0.4812, -0.0484,  0.0448, -0.4018]]], grad_fn=<SumBackward1>)
```



## 参考
### MoEについて
https://huggingface.co/blog/moe

https://deeplearning.hatenablog.com/entry/moe

### moe実装例
https://github.com/huggingface/transformers/blob/238d2e3c44366aba9dc5c770c95475765a6725cb/src/transformers/models/mixtral/modeling_mixtral.py#L688

https://hungyuling.com/blog/fast-mixture-of-experts-in-pytorch/

https://github.com/laekov/fastmoe/blob/master/README.md

https://github.com/lucidrains/mixture-of-experts/blob/master/mixture_of_experts/mixture_of_experts.py

