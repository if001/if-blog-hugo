---
title: "HuggingfaceのDataLoaderとDatacollatorのソースコードを眺める"
slug: "hf_dataloader_datacollator"
tags: ["python", "nlp", "huggingface"]
date: "2023-09-21T00:00:00+09:00"
draft: false
---



ちょっとエラーでハマったので、datasetからbatche_sizeごとのinput_idsやlabelsにするあたりの実装、特にDataLoaderとDataCollatorあたりをちゃんと確認しておく  
https://github.com/huggingface/transformers/blob/v4.30.2/src/transformers/trainer.py#L1566

train loopの主な部分は_inner_training_loop関数となる  


```python{ref="https://github.com/huggingface/transformers/blob/v4.30.2/src/transformers/trainer.py#L1652"}
    def _inner_training_loop(
        self, batch_size=None, args=None, resume_from_checkpoint=None, trial=None, ignore_keys_for_eval=None
    ):
        self.accelerator.free_memory()
        self._train_batch_size = batch_size
        logger.debug(f"Currently training with a batch size of: {self._train_batch_size}")
        # Data loader and number of training steps
        train_dataloader = self.get_train_dataloader()
```

train_dataloaderがdatasetをbatch sizeに揃えたり、paddingを行う  
https://github.com/huggingface/transformers/blob/v4.30.2/src/transformers/trainer.py#L1659  


## DataLoader
transformersでは以下のようにインスタンスを作っている  

```python{ref="https://github.com/huggingface/transformers/blob/v4.30.2/src/transformers/trainer.py#L921-L930"}
return DataLoader(
            train_dataset,
            batch_size=self._train_batch_size,
            sampler=train_sampler,
            collate_fn=data_collator,
            drop_last=self.args.dataloader_drop_last,
            num_workers=self.args.dataloader_num_workers,
            pin_memory=self.args.dataloader_pin_memory,
            worker_init_fn=seed_worker,
        )
```

例として、以下のような配列をtransfomers.Trainerの引数として渡すと`from torch.utils.data import DataLoader`がreturnされる

```json
[
  {
    'input_ids': [0, 0, 0, 0, 0...],
    'labels': [0, 0, 0, 0, 0...],
    'attention_mask': [0, 0, 0, 0, 0...]
  }, 
  {
    'input_ids': [0, 0, 0, 0, 0...],
    'labels': [0, 0, 0, 0, 0...],
    'attention_mask': [0, 0, 0, 0, 0...]
  }
]
```

**※ 配列のまま使うのではなく、DataSet Classとして扱う方が都合良いです。**
`train_data = Dataset.from_list(配列データ)`のような感じ



DataLoaderはイテレーターとして、train.pyでは以下の様に使われる。
epoch_iteratorはdataloaderから作られるDataLoader型

```python{ref="https://github.com/huggingface/transformers/blob/v4.30.2/src/transformers/trainer.py#L1916"}
 for step, inputs in enumerate(epoch_iterator):
```

このときのループ変数であるinputsは、input_idsとlabelsとattention_maskでbatchごとにまとめたものとなる  

```json
{
  'input_ids': tensor(batch_size, embedding_len),
  'labels': tensor(batch_size, embedding_len),
  'attention_mask': tensor(batch_size, embedding_len)
}
```

DataLoaderに引数として渡したdata_collatorが1 loopごとに呼び出される。  
このdata_collatorは`transformers.Trainer`に渡したものが使われる。  
例えば、data_collatorは以下のようになる。

```python
data_collator=DataCollatorForSeq2Seq(
            tokenizer, 
            pad_to_multiple_of=None,
            return_tensors="pt",
            padding=True, 
            label_pad_token_id=tokenizer.pad_token_id,
        ),
```

## DataLoaderの実装
どのようにbatch_sizeごとのデータをとりだしているか確認する

DataLoader Classの実装は以下  

```python{ref="https://github.com/pytorch/pytorch/blob/v2.0.1/torch/utils/data/dataloader.py#L129"}
class DataLoader(Generic[T_co]):
```

iterator部分の実装は以下  

```python{ref="https://github.com/pytorch/pytorch/blob/v2.0.1/torch/utils/data/dataloader.py#L428-L441"}
    def __iter__(self) -> '_BaseDataLoaderIter':
        # When using a single worker the returned iterator should be
        # created everytime to avoid reseting its state
        # However, in the case of a multiple workers iterator
        # the iterator is only created once in the lifetime of the
        # DataLoader object so that workers can be reused
        if self.persistent_workers and self.num_workers > 0:
            if self._iterator is None:
                self._iterator = self._get_iterator()
            else:
                self._iterator._reset(self)
            return self._iterator
        else:
            return self._get_iterator()
```
　
いくつかの分岐があるが、よくあるパターンでは最後の_get_iterator()が呼び出される  

```python
return self._get_iterator()
```


`self._get_iterator()`により、`_SingleProcessDataLoaderIter`がiteratorの実装として返される。  
`_SingleProcessDataLoaderIter`は`_BaseDataLoaderIter`を継承したもの

```python{ref="https://github.com/pytorch/pytorch/blob/v2.0.1/torch/utils/data/dataloader.py#L385"}
 def _get_iterator(self) -> '_BaseDataLoaderIter':
     ...
     return _SingleProcessDataLoaderIter(self)
```

`_SingleProcessDataLoaderIter`の実装は以下を参照  

```python{ref="https://github.com/pytorch/pytorch/blob/v2.0.1/torch/utils/data/dataloader.py#L660"}
class _SingleProcessDataLoaderIter(_BaseDataLoaderIter):
    def __init__(self, loader):
```


iteratorの1要素の作成は、`_SingleProcessDataLoaderIter`の`self._dataset_fetcher`によって作成される。

```python{ref="https://github.com/pytorch/pytorch/blob/v2.0.1/torch/utils/data/dataloader.py#L672-L673"}
self._dataset_fetcher = _DatasetKind.create_fetcher(
        self._dataset_kind, 
        self._dataset, 
        self._auto_collation, 
        self._collate_fn, 
        self._drop_last)
```

fetcherを使ってindexをもとにデータを取り出す。

```python{ref="https://github.com/pytorch/pytorch/blob/v2.0.1/torch/utils/data/dataloader.py#L676-L677"}
def _next_data(self):
    index = self._next_index()  # may raise StopIteration
    data = self._dataset_fetcher.fetch(index)  # may raise StopIteration
```

ここのindexについては後述

`self._dataset_fetcher`は、`create_fetcher`により`_MapDatasetFetcher`クラスをインスタンス化したもの

```python{ref="https://github.com/pytorch/pytorch/blob/v2.0.1/torch/utils/data/dataloader.py#L70"}
@staticmethod
def create_fetcher(kind, dataset, auto_collation, collate_fn, drop_last):
...
return _utils.fetch._MapDatasetFetcher(dataset, auto_collation, collate_fn, drop_last)
```

`_MapDatasetFetcher`のfetch methodでDataCollatorが呼び出される

```python{ref="https://github.com/pytorch/pytorch/blob/v2.0.1/torch/utils/data/_utils/fetch.py#L54"}
class _MapDatasetFetcher(_BaseDatasetFetcher):
    def fetch(self, possibly_batched_index):
        ...
        return self.collate_fn(data)
```


### index
`next_index`の実装は、`_BaseDataLoaderIter`が持つ。  
`_BaseDataLoaderIter`は、`_SingleProcessDataLoaderIter`の継承元。

indexの中身は、長さがbatch_sizeのarrayでindexが要素である。   
`e.g. [4, 128, 20, 10....]`  

```python{ref="https://github.com/pytorch/pytorch/blob/v2.0.1/torch/utils/data/dataloader.py#L622-L623"}
def _next_index(self):
    return next(self._sampler_iter)  # may raise StopIteration
```


ここのindexは、DataLoaderのbatch_samplerが作り出す  

```python{ref="https://github.com/pytorch/pytorch/blob/v2.0.1/torch/utils/data/dataloader.py#L448"}
@property
def _index_sampler(self):
    # The actual sampler used for generating indices for `_DatasetFetcher`
    # (see _utils/fetch.py) to read data at each time. This would be
    # `.batch_sampler` if in auto-collation mode, and `.sampler` otherwise.
    # We can't change `.sampler` and `.batch_sampler` attributes for BC
    # reasons.
    if self._auto_collation:
        return self.batch_sampler
    else:
        return self.sampler
```


batch_samplerは、DataLoaderのインスタンスを作ったときに渡したものが使われる。  
ここでは、`sampler=train_sampler,`

```python{ref="https://github.com/huggingface/transformers/blob/v4.30.2/src/transformers/trainer.py#L921"}
return DataLoader(
    train_dataset,
    batch_size=self._train_batch_size,
    sampler=train_sampler,
    collate_fn=data_collator,
    drop_last=self.args.dataloader_drop_last,
    num_workers=self.args.dataloader_num_workers,
    pin_memory=self.args.dataloader_pin_memory,
    worker_init_fn=seed_worker,
)
```

transformersでは、シンプルなパターンの場合train_samplerとしてRandomSamplerが用いられる

```python{ref="https://github.com/huggingface/transformers/blob/v4.30.2/src/transformers/trainer.py#L861"}
return RandomSampler(self.train_dataset, generator=generator)
```

`RandomSampler`Classの実装はpytorchが持つ

```python{ref="https://github.com/pytorch/pytorch/blob/v2.0.1/torch/utils/data/sampler.py#L82"}
class RandomSampler(Sampler[int]):
```

## DataCollator
DataCollatorの実装は以下  

```python{ref="https://github.com/huggingface/transformers/blob/v4.30.2/src/transformers/data/data_collator.py#L517"}
@dataclass
class DataCollatorForSeq2Seq:
```

DataLoaderがiteratorとして呼び出された場合は、`DataCollator`の`__call__`が呼び出される。

```python{ref="https://github.com/huggingface/transformers/blob/v4.30.2/src/transformers/data/data_collator.py#L559"}
def __call__(self, features, return_tensors=None):
```

引数のfeaturesは、batche_sizeごとのinput_idsとlabels、attention_maskとなる。  
batch_sizeが2の場合は以下のようになる。

```json
[
  {
    'input_ids': [...],
    'labels': [...],
    'attention_mask': [...]
  },
  {
    'input_ids': [...],
    'labels': [...],
    'attention_mask': [...]
  }
]
```

feturesに対してpaddingが行われる

```python{ref="https://github.com/huggingface/transformers/blob/v4.30.2/src/transformers/data/data_collator.py#L586"}
  features = self.tokenizer.pad(
            features,
            padding=self.padding,
            max_length=self.max_length,
            pad_to_multiple_of=self.pad_to_multiple_of,
            return_tensors=return_tensors,
        )
```

paddingしたことによって、以下のような形になる

```json
{
  'input_ids': tensor(batch_size, embedding_len),
  'labels': tensor(batch_size, embedding_len),
  'attention_mask': tensor(batch_size, embedding_len)
}
```

このデータがinputsで受け取れるものとなる。

```python
for step, inputs in enumerate(epoch_iterator):
  ...
```

stepごとに`DataCollator.__call__`が呼び出されることになる。


## まとめ
DataLoaderがiteratorの実装を持っており、batch_size単位でループが回る。
ループの1要素である以下のobjectは、ループごとにDataCollatorが整形する

```json
{
  'input_ids': tensor(batch_size, embedding_len),
  'labels': tensor(batch_size, embedding_len),
  'attention_mask': tensor(batch_size, embedding_len)
}
```

## 追記
`transformers.Trainer`のtrain_datasetとして配列を渡すと、2epoch目からdata_setがおかしくなる。例えば、`DataCollatorForSeq2Seq`はbatchごとにpaddingを追加する処理を行うが、1epoch目で追加したpaddingに対し更にpaddingを行うため、input_idsとlabelsの長さが異なってしまう。

これは、epochのループの中でepoch_iteratorつまりDataLoaderを呼び出しループしているため。datasetが参照渡しになり、前回の変更が残ってしまう。

```python
for epoch in range(epochs_trained, num_train_epochs):
  ...
  for step, inputs in enumerate(epoch_iterator):
     ...
```

`transformers.Trainer`のtrain_datasetに渡すのは、DataSet Classを使うのが良さそう。

```python
data = load_dataset("json", data_files=data_path)  
train_val = data["train"].train_test_split(test_size=val_set_size, shuffle=True, seed=42)
train_data = (tokenizerなどの処理)
## listからDatasetに変換
train_data = Dataset.from_list(train_data)

or 

data = load_dataset("json", data_files=data_path)  
train_val = data["train"].train_test_split(test_size=val_set_size, shuffle=True, seed=42)

## mapを使う
train_data = train_val["train"].shuffle().map(generate_and_tokenize_prompt)
```


## 確認用サンプル

```python
from torch.utils.data.dataloader import DataLoader
from torch.utils.data.sampler import RandomSampler
import torch
import transformers
from datasets import load_dataset

data = load_dataset('json', data_files="./sample.json")
train_val = data["train"].train_test_split(
            test_size=1, shuffle=True, seed=42
)
train_data = train_val["train"].shuffle().map(any_function)
# mapを使うとDataSet型のまま
# train_dataが配列の場合はDataSet型にしておく
# train_data = Dataset.from_list(train_data)

sampler = RandomSampler(train_data, generator=torch.Generator())

data_collator=transformers.DataCollatorForSeq2Seq(
    tokenizer, pad_to_multiple_of=8, return_tensors="pt", padding=True
)
data_loader=DataLoader(
    train_data,
    batch_size=4,
    collate_fn=data_collator,
    sampler=sampler,    
)
for steps, input in enumerate(data_loader):    
    print(steps, input['input_ids'].shape, input['labels'].shape)
print('end')
```