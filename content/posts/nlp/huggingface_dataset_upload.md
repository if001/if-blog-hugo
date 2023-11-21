---
title: "複数ファイルに分割されたデータセットをHuggingface Hubにアップロードするメモ"
slug: "hf_ds_upload"
tags: ["python", "nlp", "huggingface"]
date: "2023-11-21T00:00:00+09:00"
draft: false
---

データセットなどサイズの大きいデータをHuggingface Hubにアップロードして使う場合のメモ。  
公式ドキュメントにはアップロードする方法が様々あるが、いまいちどれを使えば良いか分かりづらかったのでメモ。

今回作成したデータセットは以下。  
https://huggingface.co/datasets/if001/oscar_2023_filtered

## repositoryの作成
以下を参考にnew datasetからdatasetを作成  
https://huggingface.co/docs/datasets/upload_dataset

readmeを修正することになるので、sshの設定などgitのコマンドからアクセスできるようにしておく。

接続テスト  
`ssh -T git@hf.co`

clone  
`git clone git@hf.co:datasets/if001/oscar_2023_filtered`

`GIT_LFS_SKIP_SMUDGE=1`をつけておくと、大きいファイルを除いてpullできる。  
readmeの修正は一度でうまくできないのでつけておくと便利。  

## datasetcardの作成
readmeにdatasetcardというデータセットの情報を記述する

templateはこんな感じ  
https://github.com/huggingface/hub-docs/blob/main/datasetcard.md?plain=1

train dataとtest dataなどを別けておく事もできる。  
loadした後にスクリプト側でわけると、splitを書いたらうまくいかなかったのでわけなかったが予め別けておくほうが良さそう

repositoryの構造については以下を参照  
https://huggingface.co/docs/datasets/repository_structure#custom-filename-split

dataset cardについては以下も参照  
https://github.com/huggingface/datasets/blob/main/templates/README_guide.md


## Datasetの作成
今回はoscarをフィルタリングしたものをuploadする。  
https://huggingface.co/datasets/oscar-corpus/OSCAR-2301/viewer/ja/train

HojiCharを使い以下のフィルタリングを行う。  
https://github.com/HojiChar/HojiChar  


フィルターで以下の文章を取り出す
- 100文字 < 文章 < 50000文字
- 日本語の文章であること
- oscarのmeta dataのうち、header, footer, noisy以外のもの
- 半角や全角のスペースが少ないこと
- 指定されたNG wordを含まないこと
- KenLMのスコア

Oscarをフィルタリングした記事はこっちを参照  
https://zenn.dev/if001/articles/cc262413e69e3d

フィルタリングの詳細は以下  
https://github.com/if001/HojiChar_OSCAR_sample/blob/0.0.4/pre_filter.py

重複削除に関しては、pythonだと重かったのでcppで行う  
https://github.com/if001/dedup_sentence/tree/0.0.6

フィルターとdedupの結果、119個のファイルができる。  
サイズは元の約半分程度。

## Datasetのupload
huggingfaceへのファイルのuploadは色々方法があるが、今回はupload_file関数を使う  
指定されたディレクトリにあるファイルを圧縮し、アップロードする。  

```python
from huggingface_hub import upload_file  
upload_file(
            path_or_fileobj=zst_file_path,
            path_in_repo=zst_file_name,
            repo_id=f"{hf_username}/{dataset_name}",
            repo_type="dataset"
)
```

ここでは、jsonlファイルをzstに圧縮してuploadしている。  
サンプルはこんな感じ。  
https://github.com/if001/HojiChar_OSCAR_sample/blob/0.0.4/upload_to_hf.py

oscarの場合、言語の選択やmeta dataの設定などを行う。  
https://huggingface.co/datasets/oscar-corpus/OSCAR-2301/blob/main/OSCAR-2301.py

## Datasetのdownload
基本的にはいつもと同じように使える

```python
from datasets import load_dataset
ds=load_dataset("if001/oscar_2023_filtered")
ds['train']

Dataset({
    features: ['text'],
    num_rows: 312396
})
```

今回は使わなかったが、downloadする前にデータに対し処理を行えるscriptが配置できる。  
https://huggingface.co/docs/datasets/dataset_script  

uploadしたjsonl.zstファイルを解凍して色々したい場合は、以下のように特定のディレクトリにダウンロードできる。

```python
from huggingface_hub import snapshot_download

snapshot_download(repo_id=repo_id, allow_patterns="*.jsonl.zst", local_dir="./download_dir")
```

local_dir(download_dir)にjsonl.zstファイルがダウンロードされる。
