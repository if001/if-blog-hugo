---
title: "Open AI Gymをとりあえず動かす"
date: "2021-07-14T02:00:00+09:00"
slug: "open-ai-gym-quick"
tags: ["python"]
draft: false
---

Open AI Gymのquick startです。とりあえず動かしてみます。

document  
https://gym.openai.com/docs/

## Install

```
pip install gym
```

## Run

```python
import gym
env = gym.make('CartPole-v0')
env.reset()
for _ in range(1000):
    env.render()
    env.step(env.action_space.sample()) # take a random action
env.close()
```

- gym.make()で環境を選択
- env.reset()で環境を初期化
- env.render()で描画
- env.action_space.sample()が行動。今回はランダム
- env.step()で行動を引数にして状態遷移

今回は環境にCartPoleを選択。Cartの上でPoleを倒さないように動くやつ。  
環境はClassic controlだと特に描画の設定などせずに使えたはず。  

用意されてる環境はここ  
https://gym.openai.com/envs/#classic_control

CartPoleで環境に対して取れる行動は、左に動く、動かない、右に動くの三種類。  
CartPoleでの環境から得られる情報は、potisionとvelocity  

それぞれgithubを参照  
https://github.com/openai/gym/wiki/MountainCar-v0#actions


## custome env
環境を作成できる  
https://github.com/openai/gym/blob/master/docs/creating-environments.md

環境用にディレクトリを作成

```
gym-foo/
  README.md
  setup.py
  gym_foo/
    __init__.py
    envs/
      __init__.py
      foo_env.py
      foo_extrahard_env.py
```

`setup.py`と`__init__.py`を環境に合わせて書いておく。  
githubのドキュメント通り。  

Envを継承して、いろいろと実装する。

```python
import gym
from gym import error, spaces, utils
from gym.utils import seeding

class FooEnv(gym.Env):
  metadata = {'render.modes': ['human']}

  def __init__(self):
    ...
  def step(self, action):
    ...
  def reset(self):
    ...
  def render(self, mode='human'):
    ...
  def close(self):
    ...
```



インストールすると、
```
pip install -e gym-foo
```

Cartpoleみたいに呼び出せる

```
gym.make('gym_foo:foo-v0')
```

`gym.envs.classic_control.rendering`以下にclassic_controlで使ってる便利なのが入ってるので参考になりそう。

```python
from gym.envs.classic_control import rendering

self.viewer = rendering.Viewer(screen_width, screen_height)

circle = rendering.make_circle()
```


