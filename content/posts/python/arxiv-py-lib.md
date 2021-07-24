---
title: "pythonでarxivのAPIを使う"
date: "2021-07-23T02:00:00+09:00"
slug: "arxiv-py-lib"
tags: ["python", "arxiv"]
draft: false
---

arxivで公開されているAPIを使っていきます

https://arxiv.org/

APIを直接呼び出しても良いですが、responseがxmlで使いづらかったので
pythonのライブラリを使わせてもらいます。

https://github.com/lukasschwab/arxiv.py

pipでインストール

```
$ pip install arxiv
```

## 使い方

```python
import arxiv

search = arxiv.Search(
  query = "quantum",
  max_results = 10,
  sort_by = arxiv.SortCriterion.SubmittedDate
)

for result in search.results():
  print(result.title)
```



arxiv.Searchでリクエストを送ります。  
results()で結果の一覧を取得  

結果用にResult Classが用意されており、  
中身はそれぞれ以下のような形です。

| field  | Description |
| - | - |
| entry_id| A url http://arxiv.org/abs/{id}. |
| updated| When the result was last updated. |
| published| When the result was originally published. |
| title| The title of the result. |
| authors| The result's authors, as arxiv.Authors. |
| summary| The result abstract. |
| comment| The authors' comment if present. |
| journal_ref| A journal reference if present. |
| doi| A URL for the resolved DOI to an external resource if present. |
| primary_category| The result's primary arXiv category. See arXiv: Category Taxonomy. |
| categories| All of the result's categories. See arXiv: Category Taxonomy. |
| links| Up to three URLs associated with this result, as arxiv.Links. |
| pdf_url| A URL for the result's PDF if present. Note: this URL also appears among result.links. |

