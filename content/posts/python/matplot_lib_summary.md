---
title: "matplotlibのよく使う記法まとめ"
date: "2019-09-24"
slug: "python-matplotlib-base"
tags: ["python"]
draft: false
toc: true
---

すぐ忘れるので、matplotlibのよく使う記法をまとめておく  
公式：https://matplotlib.org/gallery.html  

普段は散布図とかplotとかしか使わないけど、こうして見るといろんなグラフがかけるみたい  

## matplotlib,pyplot,pylabの違い
matplotlibがパッケージ全体  
pyplotはそのモジュール、スクリプトで作図するときに使う  
pylabのimportは推奨されてない模様、インタラクティブな作図にはこっちを使うらしい  

基本的には、`import matplotlib.pyplot as plt`のように使う  

参考：  
https://matplotlib.org/faq/usage_faq.html#matplotlib-pyplot-and-pylab-how-are-they-related  
https://stackoverflow.com/questions/11469336/what-is-the-difference-between-pylab-and-pyplot  

## グラフを描く
シンプルな例は以下  

```python
import matplotlib.pyplot as plt
import numpy as np

x = np.arange(0,10,0.2)
y = np.sin(x)

plt.plot(x,y)
plt.show()
```

![simple-glaph](https://qiita-image-store.s3.amazonaws.com/0/204896/69d2c0d5-e5bc-fd73-b2f7-a5bd61c363fe.png)

macでmatplotlibを呼ぶと`ValueError: unknown locale: UTF-8`で怒られることがある。  
locale周りの設定がおかしいため。以下を参考に直す。  
Mac で ValueError: unknown locale: UTF-8 のエラーを解決したい  
https://www.lifewithpython.com/2016/09/python-ValueError-unknown-locale-UTF-8.html  

#### インスタンス化する
`plt.figure()`でインスタンス化し、axesに対してプロットしていく  
多分この使い方が多いと思う  

```python
import matplotlib.pyplot as plt
import numpy as np

x = np.arange(0,10,0.2)
y = np.sin(x)

fig = plt.figure()
ax = fig.add_subplot(111)
ax.plot(x,y)
plt.show()
```

以下のように描いても同じ  

```python
fig, ax = plt.subplots(1, 1)
ax.plot(x,y)
plt.show()
```


## 複数のグラフを描く
### 複数のウィンドウに分けて描画
`fig = plt.figure()`の引数に適当にユニークな数字を入れておく。  
figureに引数を与えることで、新たな図が生成される。  
参考： https://matplotlib.org/api/_as_gen/matplotlib.pyplot.figure.html  


```python

import matplotlib.pyplot as plt
import numpy as np

x = np.arange(0,10,0.2)
y = np.sin(x)

fig = plt.figure(1)
ax = fig.add_subplot(111)
ax.plot(x,y)

fig = plt.figure(2)
ax = fig.add_subplot(111)
ax.plot(x,y)
plt.show()
```

### 1つのウィンドウに複数のグラフを描画
1つのウィンドウに複数のグラフを描く場合は以下のようにする。  

```python
fig = plt.figure()
ax1 = fig.add_subplot(211)
ax1.plot(x,y)
ax2 = fig.add_subplot(212)
ax2.plot(x,y)
plt.show()
```

以下のように2つのグラフが描画される。  

![simple-glaph-two](https://qiita-image-store.s3.amazonaws.com/0/204896/0df0947f-bda0-d47d-cac6-2d4a35f91425.png)


以下のように描いても同じ、axesをタプルで受け取るのがちょっと気持ち悪い  

```python
fig, (ax1, ax2) = plt.subplots(1, 2)
ax1.plot(x,y)
ax2.plot(x,y)
plt.show()
```
## グラフの保存
savefigでグラフの保存が可能  

```python
import matplotlib.pyplot as plt
import numpy as np

x = np.arange(0,10,0.2)
y = np.sin(x)

fig = plt.figure()
ax = fig.add_subplot(111)
ax.plot(x,y)
plt.savefig("./test2")
```

複数のグラフを描画した場合には、figureインスタンスに対してもsavefigが使える。  

```python
import matplotlib.pyplot as plt
import numpy as np

x = np.arange(0,10,0.2)
y = np.sin(x)

fig = plt.figure(1)
ax = fig.add_subplot(111)
ax.plot(x,y)
fig.savefig("./test1")

fig = plt.figure(2)
ax = fig.add_subplot(111)
ax.plot(x,y)
fig.savefig("./test2")
```

## グラフを整形する
グラフの線の色、太さ、線の種類などはよく使う。  
それぞれ、color,linewidth,linestyleの引数を与えることで設定できる。  

```python
import matplotlib.pyplot as plt
import numpy as np

x = np.arange(0,10,0.2)
y = np.sin(x)

fig = plt.figure()
ax = fig.add_subplot(111)
ax.plot(x,y,color="red",linewidth=2,linestyle="dashed")
plt.show()
```

![simple-glaph-format](https://qiita-image-store.s3.amazonaws.com/0/204896/534808eb-6257-9ee2-a62d-c956961f3c0e.png)

引数の詳細は公式の以下のページから確認できる。  
https://matplotlib.org/api/_as_gen/matplotlib.pyplot.plot.html  

## タイトルや軸名をつける
シンプルな例は以下  

```python
import matplotlib.pyplot as plt
import numpy as np

x = np.arange(0,10,0.2)
y = np.sin(x)

plt.plot(x,y)
plt.title("test")
plt.xlabel("x")
plt.ylabel("y")
plt.show()
```

![simple-glaph-label](https://qiita-image-store.s3.amazonaws.com/0/204896/91d3b0ae-527f-a608-75a8-777931888b8d.png)

インスタンス化した場合は次のようにする。  

```python
import matplotlib.pyplot as plt
import numpy as np

x = np.arange(0,10,0.2)
y = np.sin(x)

fig = plt.figure()
ax = fig.add_subplot(111)
ax.plot(x,y)
ax.set_title("test")
ax.set_xlabel("x")
ax.set_ylabel("y")
plt.show()
```

## グラフの余白、幅を調整する
`plt.subplots_adjust`で調整可能  

```python
import matplotlib.pyplot as plt
import numpy as np

x = np.arange(0,10,0.2)
y = np.sin(x)

plt.plot(x,y)
plt.subplots_adjust(left=0.1, right=0.95, bottom=0.1, top=0.95)
plt.show()
```

わかりづらいが調整できてる。  

調整前
![simple-glaph-adjest-before](https://qiita-image-store.s3.amazonaws.com/0/204896/40c41033-d9f2-3403-6fab-8c5b34ee73ce.png)

調整後
![simple-glaph-adjest-after](https://qiita-image-store.s3.amazonaws.com/0/204896/45e25765-eb83-52c7-a42f-173379a51edc.png)

デフォルト値は以下  

```
left  = 0.125  # the left side of the subplots of the figure
right = 0.9    # the right side of the subplots of the figure
bottom = 0.1   # the bottom of the subplots of the figure
top = 0.9      # the top of the subplots of the figure
wspace = 0.2   # the amount of width reserved for space between subplots,
               # expressed as a fraction of the average axis width
hspace = 0.2   # the amount of height reserved for space between subplots,
               # expressed as a fraction of the average axis height
```

1つのウィンドウに複数のグラフを描画し軸名など入れた場合、グラフが重なることがある。  
その場合は、`plt.subplots_adjust(hspace=0.4)`のように調整できる。  
横幅は、wspaceで調整可能。  

```python
fig = plt.figure()
plt.subplots_adjust(hspace=0.6)
ax1 = fig.add_subplot(211)
ax1.plot(x,y)
ax2 = fig.add_subplot(212)
ax2.plot(x,y)
plt.show()
```

調整前  
![simple-glaph-adjest-width-before](https://qiita-image-store.s3.amazonaws.com/0/204896/f5978344-7f45-5543-5b48-bff62b7de6a1.png)

調整後  
![simple-glaph-adjest-width-after](https://qiita-image-store.s3.amazonaws.com/0/204896/a9dac675-aaf4-90b5-bcbd-1160960d9605.png)

参考：https://www.haya-programming.com/entry/2018/10/11/030103  

## 軸を設定し直す
ちょっとめんどくさい  

```python
import matplotlib.pyplot as plt
import numpy as np

x = np.arange(0,10,0.2)
y = np.sin(x)

fig = plt.figure()
ax = fig.add_subplot(111)
ax.plot(x,y)
ticks = "abcdefghijklmnopqrstuvwxyz"
plt.xticks(x,list(ticks))
plt.show()
```

<img src="" width="70%">
![simple-glaph-adjest-ziku](https://qiita-image-store.s3.amazonaws.com/0/204896/83dc4fb3-1eaf-0720-21a4-3031890f7c9c.png)


設定し直したい次元と、元の軸の次元が合ってなくても設定できる模様。  

## x軸に時刻を設定、フォーマット
datetimeをそのままx軸に利用できる。  

```python
import matplotlib.pyplot as plt
import pandas as pd
x = [
    '2018/08/08T12:15:45.000',
    '2018/08/08T12:15:45.200',
    '2018/08/08T12:17:45.600'
]
x = pd.to_datetime(x,format='%Y/%m/%dT%H:%M:%S.%f')
y = [1,2,3]
fig = plt.figure()
ax = fig.add_subplot(111)
ax.plot(x,y)
plt.show()
```

<img src="https://qiita-image-store.s3.amazonaws.com/0/204896/18a163b1-a001-d5a6-5543-1a4eb6d3a890.png" width="70%">

フォーマットは、`ax.xaxis.set_major_formatter(mdates.DateFormatter('%m/%d\n%H:%M'))`を使って行う。  

```python
import matplotlib.pyplot as plt
import pandas as pd
import matplotlib.dates as mdates

x = [
    '2018/08/08T12:15:45.000',
    '2018/08/08T12:15:45.200',
    '2018/08/08T12:17:45.600'
]
x = pd.to_datetime(x,format='%Y/%m/%dT%H:%M:%S.%f')

y = [1,2,3]
fig = plt.figure()
ax = fig.add_subplot(111)
ax.plot(x,y)
ax.xaxis.set_major_formatter(mdates.DateFormatter('%m/%d\n%H:%M'))
plt.show()
```

![simple-glaph-format-time](https://qiita-image-store.s3.amazonaws.com/0/204896/01b8a12d-d6af-2093-e2e1-55df4f68411a.png)

参考：https://hack-le.com/matplotlib-x-date-format/


