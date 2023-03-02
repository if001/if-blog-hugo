---
title: "code blockにrefarenceをつける"
slug: "hugo-render-block"
tags: ["hugo"]
date: "2023-02-28T00:00:00+09:00"
draft: false
---

Hugoでコードブロックを使うときは、GitHubからの引用が多くその下に参照元のURLを貼り付けることが多い。
コードブロックの下にそのままURLが表示されるの若干見づらかったので、コードブロックとセットでいい感じに表示したい。

HugoにMarkdown Render Hooksにcodeblockが追加されてたのでこれが使えそう。

https://gohugo.io/templates/render-hooks/#render-hooks-for-code-blocks

v0.93.0からなので注意

やり方は簡単で、`layouts/_default/_markup/render-codeblock.html`を追加するだけ。

特定の言語に対応させるために`rendor-codeblock-bash.html`のようなこともできるらしい。


コードブロックにrefを渡すと

````
```python{ref="this is ref"}
def hello():
    print("hello world")
```
````

このように参照元をつけることができる

```python{ref="this is ref", name="test.js"}
def hello():
    print("hello world")
````

render-codeblock.htmlの例はこのような感じ

```html
<div class="code-block">
    <div>
      {{- highlight (.Inner | safeHTML) .Type .Options }}  
    </div>
    {{- $ref := .Attributes.ref -}}
    {{ with $ref }}<div class="ref">参照: <a href={{ . }} target="_black">{{ . }}</a></div>{{ end }}
</div>
```

`.Attributes`で設定した値が取り出せる。