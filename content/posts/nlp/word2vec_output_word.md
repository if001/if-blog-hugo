---
title: "word2vecでベクトルから単語を出力する"
slug: "word2vec-output-word"
tags: ["python", "word2vec"]
date: "2019-09-24T00:00:00+09:00"
published: true
---

word2vecで単語をベクトルにしたり、類似度判定した記事はたくさんあるが、ベクトルから類似単語を出力する日本語記事を見つけられなかったのでメモ。
stack overflowにあった。
https://stackoverflow.com/questions/32759712/how-to-find-the-closest-word-to-a-vector-using-word2vec

## 結論
結論から言うと、以下のように適当にモデルを作りmost_simlar関数にベクトルを与えるだけ。

```python
sentences = gensim.models.word2vec.Text8Corpus(filename)
model = Word2Vec(sentences, size=100, window=5, min_count=5, workers=4)
model.most_similar( [ vector ], [], 1)[0][0]
``` 
ただし、第3引数は出力する類似単語数を表す。

## 使用例
[青空文庫：江戸川乱歩](http://www.aozora.gr.jp/index_pages/person1779.html)の解析をしたので、その例を示す。

```python
model.wv["ベクトル化したい単語"]
```
で単語をベクトル化できる。

```python
sentences = gensim.models.word2vec.Text8Corpus(filename)
model = Word2Vec(sentences, size=100, window=5, min_count=5, workers=4)
vector = model.wv["犯罪"]
word = model.most_similar( [ vector ], [], 1)
print(vector)
print(word)
```
上記のようなコードを実行すると、

```bash
[-0.01494294 -0.1509463   0.06123272 ...,  0.01335443  0.03439184
  0.05130962]
[('犯罪', 1.0000001192092896)]
```
となり、「犯罪」をベクトル化し、そのベクトルから単語が出力できている。


### 出力数を変更

```python
vector = model.wv["明智"]
word = model.most_similar( [ vector ], [], 5)
```
以下のような結果が得られる。

```bash
[('明智', 1.0000001192092896), ('名', 0.8110731840133667), ('博士',　0.8006758093833923), ('氏', 0.7667115330696106), ('殿村', 0.7487545609474182)]
```

### 単語のみを出力
単語のみを出力するために、以下のようにしておくとよい

```python
model.most_similar( [ vector ], [], 1)[0][0]
```

### 任意のベクトル入力
以下のようにして、任意のベクトルができる。

```python
vec = np.zeros(3000)
vec[2] = 1
vec = np.array(vec,dtype='f')
word = model.most_similar( [ vector ], [], 5)
```
出力結果

```bash
[('点い', 0.04825586825609207), ('ワハハハハハハハハ', 0.04788881167769432), ('珍奇', 0.04669386148452759), ('憎らしい', 0.04500409588217735), ('な', 0.04486800357699394)]
```

## まとめ
`most_similar`使えばいける。ちなみに公式には、`model.wv.most_similar`って書いてあったけど、wvなくてもできた。公式には、ベクトルは、`model.wv`のKeyedVectorsインスタンスに保存されてるって書いてあったけどよくわかってない。
今回は総単語数19002だったのだが、実行時間は1分ほど。word2vec高速すごい。
