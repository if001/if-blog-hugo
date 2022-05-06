---
title: "Hugging Faceのpipelineで会話モデルを動かす"
slug: "huggingface-conv"
tags: ["nlp","deeplearning", "python"]
date: "2022-05-05T09:00:00+09:00"
draft: false
---

Hugging Faceのpipelineを’使って会話モデルを動かしたのでメモ。  
あまり日本語記事がなかったので残しておく。  

huggingfaceについてはこっちの記事を参照  
https://www.if-blog.site/posts/nlp/huggingface-doc/


## pipelineを作る
transformersはインストールしておく

pipelineインスタンスを作る。

```python
tokenizer = AutoTokenizer.from_pretrained("microsoft/DialoGPT-small")
model = AutoModelForCausalLM.from_pretrained("microsoft/DialoGPT-small")
gen_pipeline = pipeline(task, model=model, tokenizer=tokenizer)
```

今回はDialogGPT-smallというモデルを使う

https://huggingface.co/microsoft/DialoGPT-small

modelによってはtokenizerを自動で選択してくれるが、一応tokenizerも引数で指定しておく。

## conversational
pipeline用のconversationalがあるのでそれを使う。

https://huggingface.co/transformers/v4.8.2/_modules/transformers/pipelines/conversational.html


会話のコンテキストを渡す方法が２つ


１つ目。

conversationクラスのコンストラクタ引数の
- text: 現在のユーザーの入力
- `past_user_inputs`: 過去のユーザーの入力
- `generated_residence`: 過去の返答

をセットする。

```python
p = pipeline(task, model=model, tokenizer=tokenizer)

ui = ["Does money buy happiness?", "What is the best way to buy happiness ?"]
gr = ["Depends how much money you spend on it .", "You just have to be a millionaire by your early 20s, then you can be happy ."]
current_input = "This is so difficult !"
conversation = Conversation(text=current_input, past_user_inputs=ui, generated_responses=gr)
r = p(conversation)

print('result', r)
```

結果

```
result Conversation id: 9be5d5e0-33c7-477a-940b-8c4bb73f6152 
user >> Does money buy happiness? 
bot >> Depends how much money you spend on it . 
user >> What is the best way to buy happiness ? 
bot >> You just have to be a millionaire by your early 20s, then you can be happy . 
user >> This is so difficult ! 
bot >> I'm not sure if I can afford to buy a house.
```

---

2つ目。

conversationクラスのメソッドからも会話のコンテキストをセットできる。

```python
p = pipeline(task, model=model, tokenizer=tokenizer)

conversation = Conversation()

# ユーザー入力/返答を追加
conversation.add_user_input("Does money buy happiness?")
conversation.mark_processed()
conversation.append_response("Depends how much money you spend on it .")

# ユーザー入力/返答を追加
conversation.add_user_input("What is the best way to buy happiness ?")
conversation.mark_processed()
conversation.append_response("You just have to be a millionaire by your early 20s, then you can be happy .")

# 現在のユーザーの入力をセット
conversation.add_user_input("This is so difficult !")
r = p(conversation)
```

`add_user_input`でユーザーの入力をセット、`mark_processed`でセットしたユーザーの入力をコンテキスト(履歴)にセットする。
`append_response`で返答を追加。


`add_user_input`と`append_response`は以下の用に、どの順番でも大丈夫。


```python
conversation = Conversation()

# ユーザー入力の履歴を追加 
conversation.add_user_input("Does money buy happiness?")
conversation.mark_processed()
conversation.add_user_input("What is the best way to buy happiness ?")
conversation.mark_processed()

# 返答の履歴を追加
conversation.append_response("Depends how much money you spend on it .")
conversation.append_response("You just have to be a millionaire by your early 20s, then you can be happy .")
    
conversation.add_user_input("This is so difficult !")
```


結果は１つ目の方法と同じ。

```
result Conversation id: 9be5d5e0-33c7-477a-940b-8c4bb73f6152 
user >> Does money buy happiness? 
bot >> Depends how much money you spend on it . 
user >> What is the best way to buy happiness ? 
bot >> You just have to be a millionaire by your early 20s, then you can be happy . 
user >> This is so difficult ! 
bot >> I'm not sure if I can afford to buy a house.
```

## まとめ
`Conversation`クラスを使うと簡単にpipelineで会話モデルを試せて良い感じ。

日本語モデルでいくつか試したけど、この方法だとうまくいかなかった。
別のモデルを探すか、会話タスクを学習させるか...
