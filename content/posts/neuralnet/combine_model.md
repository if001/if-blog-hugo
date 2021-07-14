---
title: "kerasでモデルを結合する"
slug: "combine-model"
tags: ["keras","deeplearning"]
date: "2019-09-24T00:00:00+09:00"
published: true
---

autoencoderなどを作っていると、保存や推論を行う上での再利用性を考え、encoderとdecoderは分けてModelを作りたいことがある。

autoencoderの学習の際には、作成したencoderのModelとdecoderのModelを結合する。

Modelの結合は前はできなかった気がするが、できるようになっていたのでメモ。

Kerasのバージョンは、2.1.1

まずは、シンプルなモデルを2つ作る。input→model1→model2→outputを作る。

```python
def model1():
    layer_input = Input(shape=(None, 10))
    layer_output = Dense(10)(layer_input)
    model = Model(layer_input, layer_output)
    model.summary()
    return model

def model2():
    layer_input = Input(shape=(None, 10))
    layer_output = Dense(10)(layer_input)
    model = Model(layer_input, layer_output)
    model.summary()
    return model
```

まず、model1へのインプットを作る。model1のアウトプットをmodel2のインプットにし、Modelのインスタンスを作る。


```python
m1 = model1()
m2 = model2()

inp = Input(shape=(None, 10))
model1_output = m1(inp)
out = m2(model1_output)
model = Model(inp, out)
model.summary()
```

すると、こんな感じでモデルが結合できたのが確認できる。

```bash
Using TensorFlow backend.
_________________________________________________________________
Layer (type)                 Output Shape              Param #
=================================================================
input_1 (InputLayer)         (None, None, 10)          0
_________________________________________________________________
dense_1 (Dense)              (None, None, 10)          110
=================================================================
Total params: 110
Trainable params: 110
Non-trainable params: 0
_________________________________________________________________
_________________________________________________________________
Layer (type)                 Output Shape              Param #
=================================================================
input_2 (InputLayer)         (None, None, 10)          0
_________________________________________________________________
dense_2 (Dense)              (None, None, 10)          110
=================================================================
Total params: 110
Trainable params: 110
Non-trainable params: 0
_________________________________________________________________
_________________________________________________________________
Layer (type)                 Output Shape              Param #
=================================================================
input_3 (InputLayer)         (None, None, 10)          0
_________________________________________________________________
model_1 (Model)              (None, None, 10)          110
_________________________________________________________________
model_2 (Model)              (None, None, 10)          110
=================================================================
Total params: 220
Trainable params: 220
Non-trainable params: 0
_________________________________________________________________
```

コード全体はこんな感じ。

```python
from keras.layers import Dense
from keras.models import Model

def model1():
    layer_input = Input(shape=(None, 10))
    layer_output = Dense(10)(layer_input)
    model = Model(layer_input, layer_output)
    model.summary()
    return model

def model2():
    layer_input = Input(shape=(None, 10))
    layer_output = Dense(10)(layer_input)
    model = Model(layer_input, layer_output)
    model.summary()
    return model

def main():
    m1 = model1()
    m2 = model2()

    inp = Input(shape=(None, 10))
    x = m1(inp)
    out = m2(x)
    model = Model(inp, out)
    model.summary()

if __name__ == '__main__':
   main()
```

モデルインスタンスの再利用性が上がってて使いやすくなってる。  
