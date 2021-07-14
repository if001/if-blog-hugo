---
title: "falconを使ってみた"
slug: "falcon-tips"
tags: ["python", "falcon"]
date: "2018-10-16T20:48:42+09:00"
draft: false
---

## はじめに
Hugoをおいているwebサーバーに画像や、mdファイルをアップロードするためのapiサーバーとして[falcon](https://falconframework.org/)を使ってみた。ORMなど必要なく、簡単なアップロードができれば良いということで、軽量さとシンプルさが特徴のfalconを使う。

簡単なtipsをメモしておく。

## シンプルな例
falconの公式に乗っているように、シンプルな例は次のようになる。

```python
# sample.py

import falcon

class QuoteResource:
    def on_get(self, req, resp):
        """Handles GET requests"""
        quote = {
            'quote': (
                "I've always been more interested in "
                "the future than in the past."
            ),
            'author': 'Grace Hopper'
        }

        resp.media = quote

api = falcon.API()
api.add_route('/quote', QuoteResource())
```

## 処理シーケンス
falconにはmiddlewareの他に、hooksというものが使える。
hooksを含めた処理シーケンスは次のようになる。

```
Middleware's process_request
Middleware's process_resource
Hook's before
Resource's on_****
Hook's after
Middleware's process_response
```

引用：https://qiita.com/yohjizzz/items/f46bb3bc7b7c40768836

middlewareを使った、認証系の共通処理はよく見るが、hookが使えるのは良いですね。

## hooks
hooksは以下のように使う。([公式](https://falcon.readthedocs.io/en/stable/api/hooks.html))

```python
def validate_image_type(req, resp, resource, params):
	....

@falcon.before(validate_image_type)
def on_post(self, req, resp):
    pass
```

処理を差し込みたいメソッドにでコレーターでつけるだけ。


## middleware
corsくらいしか使わなかったが、dbのconnection poolとかに使うようのものとかあるんだろう。([公式](https://falcon.readthedocs.io/en/stable/api/middleware.html))

```python
class CORSMiddleware:
    def process_request(self, req, resp):
        resp.set_header('Access-Control-Allow-Origin', '*')
```

## エラーハンドリング
routeが見つからなかった時に、エラーリスポンスを返したいときは以下のようにする。([公式](https://falcon.readthedocs.io/en/stable/api/errors.html))


```python
class Index(object):
    def on_get(self, req, resp):
        resp.body = json.dumps({"message":"ok"})

app = falcon.API()
app.add_route("/", Index())
app.add_sink(handle_404, '')

if __name__ == "__main__":
    from wsgiref import simple_server
    httpd = simple_server.make_server("127.0.0.7", 8000, app)
    httpd.serve_forever()

```

exceptionなどが起きた場合でも、200のリスポンスを返し、レスポンスボディの中でエラーコードとメッセージを返したかったが、うまく行かなかったので、これは次の機会にやる。


## requestの取得
requsetの取得は以下のようになる。([公式](https://falcon.readthedocs.io/en/stable/api/request_and_response.html))

```python
class HealthCheck(object):
def on_get(self, req, resp):
	print(req.headers) # headerの取得
	print(req.params['name']) # request paramの取得

   # request bodyの取得
    body = req.stream.read().decode("utf-8")
    data = json.loads(body)
    name = data['name']

app = falcon.API()
app.add_route("/", index())

if __name__ == "__main__":
    from wsgiref import simple_server
    httpd = simple_server.make_server("127.0.0.7", 8000, app)
    httpd.serve_forever()
```


