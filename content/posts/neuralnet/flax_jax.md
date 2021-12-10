---
title: "Flaxに入門してみる"
slug: "flax-jax"
tags: ["deeplearning", "python"]
date: "2021-07-25T09:00:00+09:00"
draft: false
---

Googleが最近力を入れているニューラルネットワークのフレームワークらしい。

一般的に、flaxは亜麻、linenは麻と訳される。flaxは植物で、その植物を加工し繊維状にしたものまでをflax、それを紡いで糸にしたもの及びその製品をlinenと呼ぶらしい。
(参照：日本麻紡績協会)

例えばこのライブラリでのDenseの呼び方は`flax.linen.Dense`となる。

ライブラリの名前の付け方めっちゃおしゃれでかっこいい。

Flax is a high-performance neural network library for JAX that is designed for flexibility

> Flaxは、柔軟性を考慮して設計されたJAX用の高性能ニューラルネットワークライブラリです。

https://flax.readthedocs.io/en/latest/overview.html#flax

## JAX
JAXはAutogradとXLAを用いて、機械学習におけるパフォーマンスを向上させる。AutogradはPythonとNumpyでの自動微分を可能にするライブラリで、XLAはそのコンパイルを行う。

FLAXはJAXの開発チームと近い位置で協力関係にあるらしい。

https://github.com/google/jax#compilation-with-jit

https://github.com/hips/autograd

https://www.tensorflow.org/xla

JAXの使い方については別記事を参照

### 自動微分
Autogradは、自動微分を行うライブラリで、自動微分とは偏微分の値計算するプログラム手法。
自動微分には、前進方と後進方があり、それぞれ、ボトムアップ型自動微分（フォーワードモード、狭義の自動微分）とトップダウン型自動微分（リバースモード、高速自動微分）などと呼ばれる。
特に、トップダウン型自動微分はバックプロパゲーションの計算手法として用いられる。

詳しい話は別記事を参照

## install

```
pip install --upgrade jax jaxlib # CPU-only
pip install flax
```

`pip 19.0.3`だと、flaxのインストールがうまくできなかったので、
`pip install --upgrade pip`で`21.1.3`に上げた。

https://flax.readthedocs.io/en/latest/installation.html

## Flax model example
### シンプルな例

```python
class Module(nn.Module):
  features: Tuple[int] = (16, 4)

  def setup(self):
    self.dense1 = Dense(self.features[0])
    self.dense2 = Dense(self.features[1])

  def __call__(self, x):
    return self.dense2(nn.relu(self.dense1(x)))
```

nn.Moduleは、すべてのneural network modulesのベースクラス。
これを継承して、独自のLayerやmodelを作る。
setupは`__init__`のオーバーライド、`__call__`で任意のforward passを定義する。

https://flax.readthedocs.io/en/latest/flax.linen.html#module

### 3層(12,8,4)のパーセプトロン

```python
from typing import Sequence

import jax
import jax.numpy as jnp
import flax.linen as nn

class MLP(nn.Module):
  features: Sequence[int]

  @nn.compact
  def __call__(self, x):
    for feat in self.features[:-1]:
      x = nn.relu(nn.Dense(feat)(x))
    x = nn.Dense(self.features[-1])(x)
    return x

model = MLP([12, 8, 4])
batch = jnp.ones((32, 10))
variables = model.init(jax.random.PRNGKey(0), batch)
output = model.apply(variables, batch)
```

modelを作る部分は、上記のシンプルな例と同様。

**init**

`variables = model.init(jax.random.PRNGKey(0), batch)`

値を使ってmodelを初期化。返り値のvariablesは、pythonのdictで、例えば以下のような要素を持つ。

```
{
  "params": {
    "Conv1": { "weight": ..., "bias": ... },
    "BatchNorm1": { "scale": ..., "mean": ... },
    "Conv2": {...}
  },
  "batch_stats": {
    "BatchNorm1": { "moving_mean": ..., "moving_average": ...}
  }
}
```

**apply**

`output = model.apply(variables, batch)`

variablesをモデルに適応し、入力値に対する出力値を得る。

上記の例のように、`__call__`内で`nn.Dense(self.features[-1])(x)`のようなflax.linenで定義されたlayerを呼び出す場合は`@nn.compact`デコレータをつける必要がある。
デコレーターを付けない場合は、`setup()`内でlayerを定義する必要がある。

https://flax.readthedocs.io/en/latest/flax.linen.html#flax.linen.Module.apply

### autoencoder

```python
class AutoEncoder(nn.Module):
  encoder_widths: Sequence[int]
  decoder_widths: Sequence[int]
  input_shape: Sequence[int]

  def setup(self):
    input_dim = jnp.prod(jnp.asarray(self.input_shape))
    self.encoder = MLP(self.encoder_widths)
    self.decoder = MLP(self.decoder_widths + (input_dim,))

  def __call__(self, x):
    return self.decode(self.encode(x))

  def encode(self, x):
    assert x.shape[1:] == self.input_shape
    return self.encoder(jnp.reshape(x, (x.shape[0], -1)))

  def decode(self, z):
    z = self.decoder(z)
    x = nn.sigmoid(z)
    x = jnp.reshape(x, (x.shape[0],) + self.input_shape)
    return x

model = AutoEncoder(encoder_widths=[20, 10, 5],
                    decoder_widths=[5, 10, 20],
                    input_shape=(12,))
batch = jnp.ones((16, 12))
variables = model.init(jax.random.PRNGKey(0), batch)
encoded = model.apply(variables, batch, method=model.encode)
decoded = model.apply(variables, encoded, method=model.decode)
```

setupを使い上記で定義したMLPを呼び出している。この場合は、`__call__`にデコレーターは不要。

applyの引数にmethodを与えると、特定のモデルに対してのみ、variablesと入力値を適応できる。

`encoded = model.apply(variables, batch, method=model.encode)`

## trainingを含めた例

以下はMNISの例

https://github.com/google/flax/blob/main/examples/mnist/train.py


## まとめ
Flaxのreadmeなどを眺めてみました。  
柔軟なモデルの作り方や、作成したモデルの汎用性のある使い方ができるような設計になってるような印象を受けました。  

実際に学習させる部分などは少し面倒な部分がありそうです...環境ごとや実行ごとの結果が変わらないようにするという思想のようなので、このあたりはトレードオフですかね。  

実際にモデルを作って、データを学習させるにはJAXの部分の理解も必要になってきそうなので、そのあたりを含め調べて見ようと思います。


