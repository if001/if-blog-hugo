---
title: "falconでアップロードサーバーを作る"
slug: "falcon-img-upload"
tags: ["hugo","python", "falcon"]
date: "2018-10-16T20:48:42+09:00"
draft: false
---
## はじめに
現在、サーバー上にHugoとHugoが生成した静的ファイルを置いてブログを公開している。
静的ファイルの生成とmdファイルや画像ファイルのアップロードのためfalconを使ってapiサーバーを作った。
falconをつかったのは、flaskやbottleは使ったことあったので、使ったことないものをということで。


## クライアント
クライアントにはpythonの[requests](https://requests-docs-ja.readthedocs.io/en/latest/user/quickstart/#post)を使います。

fileにタプルでファイル名を明示的に渡せる。
postの引数にfilesで渡すと、contents-typeもよしなにしてくれるんですね。

```python
image_name = "test.png"
with open(image_file_path, "rb") as image:
	files = {'file': (image_name, image)}
	response = requests.post(url, files=files)
	print(response.text)
```


## サーバー
falconはコンテナ上で動かします。ファイルアップロードのリクエストを受けると、
サーバー上のストレージに画像を保存します。

なんかできないと思ってたら、middlewareにMultipartMiddlewareを指定しないとだめだった。

fileは次のようにrequestから取得できる

```python
image = req.get_param('file')
raw = image.file.read()
```

ファイル名は次のように取得

```
image_name = image.filename
```

実際は、corsとかあるがそれを省いた、アップロードだけの全体は以下のようになる。

```python
from falcon_multipart.middleware import MultipartMiddleware
import falcon
import json

class UploadImage(object):
    def on_post(self, req, resp):
        image = req.get_param('file')
        raw = image.file.read()
        image_name = image.filename
        filepath = os.path.join(BASE_DIR, "static", image_name)
        try:
            with open(filepath, 'wb') as f:
                f.write(raw)
        except IOError:
            print("save file faild :" + filepath)
			resp.body = to_resp(200, "save img " + filepath)
			
def to_resp(status_code, contents):
    resp = {
        "status": status_code,
        "contents": contents
    }
    return json.dumps(resp)

app = falcon.API(middleware=[MultipartMiddleware()])
app.add_route("/image", UploadImage())

if __name__ == "__main__":
    from wsgiref import simple_server
    httpd = simple_server.make_server("0.0.0.0", 8000, app)
    httpd.serve_forever()
```



