---
title: "xglmをquick start"
slug: "start-xglm-t5"
tags: ["nlp","deeplearning", "python", "huggingface"]
date: "2023-02-05T00:00:00+09:00"
draft: false
---

多言語モデルであるxglmを動かしてみます。

最も大きいもので7.5Bのparameterを持つ。

同等のサイズのGPT3のモデルを上回るらしい。

>  Our largest model with 7.5 billion parameters sets new state of the art in few-shot learning in more than 20 representative languages, outperforming GPT-3 of comparable size in multilingual commonsense reasoning (with +7.4% absolute accuracy improvement in 0-shot settings and +9.4% in 4-shot settings) and natural language inference (+5.4% in each of 0-shot and 4-shot settings).

https://huggingface.co/docs/transformers/model_doc/xglm#overview


ライブラリはこの辺を入れておく 
```
!pip install torch transformers sentencepiece
```

## modelのロード
multi languegeのxglmも試してみる。1.7Bは展開できなかったので、小さいやつを動かす。

https://huggingface.co/facebook/xglm-564M

```python=
from transformers import XGLMTokenizer, XGLMForCausalLM

# model_name = "facebook/xglm-1.7B"
model_name = "facebook/xglm-564M"

tokenizer = XGLMTokenizer.from_pretrained(model_name)
model = XGLMForCausalLM.from_pretrained(model_name)
```

## 生成
```python
def gen(prompt):
    input = tokenizer.encode(prompt, return_tensors="pt")
    generate_kwargs  = {
            'top_p': 0.95,
            'top_k': 50,
            'do_sample':True,
            'max_length': 1024,
            'min_length:200'
    }
    output = model.generate(input, **generate_kwargs)
    result = tokenizer.batch_decode(output, skip_special_tokens=True)
    print(result)
```

T5より日本語を話せそうだったので、長文を生成させてみる。

```python
prompt = "それは九月初旬のある蒸し暑い晩のことであった。私は、Ｄ坂の大通りの中程にある、"
gen(prompt)
```

```
['それは九月初旬のある蒸し暑いのことであった。私は、D坂の大通りの中程にある、美術館の中からD坂町へ行ってみることにした。それまで、日本橋方面に行ったら、桜並木を眺めていると、気が引けるような景色だ。こんな景色を、見ることができたら、私もれるはずだ。そう思うと、いつも思う「桜は咲かないのだろうか」という気持ちが、どこかに蘇ってきていたのだ。花を咲かせよう!と、いつまでも思っていた桜を見るのが、今になって一気に楽しい。桜並木は、歩いていると、その姿に、一目れしてしまう。それが、私の周りに、桜を眺めている人を、きっとたくさんいるんじゃないか?と思うほど。そしてその姿を見ると、自分自身も、桜の世界に入り、自分が咲かせよう。桜の美しさに、今から一生懸命追いつめられて、桜の中をいてみようと、思っています。']
```

思ったより日本語生成できててすごい。

```python
prompt = "If you really want to hear about it,  "
gen(prompt)
```

```
['If you really want to hear about it, I’m currently working on a book titled, When the Time Comes, (which is now on sale in paperback, at Amazon) which tells the story of one of the people I have not talked to in weeks, but who, in her own words, “gave me back the joy of being a part of the culture of my own home and country”. I had been told by my doctor about the book, but she had only mentioned it as “a collection of essays and thoughts by people who I’ve met in my life” (with a few exceptions: my husband and the person who got me to know this woman, the guy I was with when I met the guy he was with, which I’ll get to in a later chapter). So I asked her if she’d like to write about it for me. She said yes, so I took her through the process. When I talked to her, she explained how much she’d enjoyed the process of writing about it, and asked me if I could write her a bio on that process.']
```

意味はよくわかんないことになっているが、崩壊せず生成できてそう。


ライ麦畑でつかまえての日本語も与えてみる。

```python
prompt = "もしも君が、ほんとにこの話を聞きたいんならだな、"
gen(prompt)
```

なんか様子がおかしいｗ

```
>> ['もしも君が、ほんとにこの話を聞きたいんならだな、きっと。でも、あのときのは、ほんとに、本当の自分を語りたいんでしょ。まぁ、そっちの方が、説得力のある話じゃないけどね。でも、この話を聞いて、の力が分かってきたよ、きっと。でも、の力が解けるまでは、この話は、やむを得ない話。とにかく、の力が解けたときの出来事や、が、と共に語れるようにして、本当に楽しく読ませてあげれば。それなら。ま、を、もうちょっと詳しく読んでくれたら...。と、願って。 最後まで読んでね。『の力が解けた世界』...。 の力が、解けても、僕の愛するあの人には、もう終わらない、そんな話だから。 『の力が解けた世界』...。']

>> ['もしも君が、ほんとにこの話を聞きたいんならだな、って思うのは俺だけかもしれんしな。でもなんか。でも、もしも君が知りたい事あるなら、俺はこのスレの住人だということに感謝しようぜ。ありがとう、俺。俺。 次スレは、こっちに置いとこう。#俺も。 #こっちは。 #いい #いいこと言いたい #いいところ聞きたい #いいこと言ってみたい #いい話したい #いい時 #いい時間 #いい話 #いい話聞いてみたい #いい話たくさんいる #いい話だけ #好きな人 #友達 #アダルト #アダルト作家 #アダルト作家ブログ #アダルト作家好きな人と繋がりたい #アダルト作家さんと繋がりたい #アダルト作家さんと繋がろう #アダルト系#アダルト漫画 #アダルト漫画好きな人と繋がりたい #アダルト系アダルト作家 #アダルト女 #アダルト漫画好きな人と繋がりたい']

>> ['もしも君が、ほんとにこの話を聞きたいんならだな、なんて思ってもらえるまでねぇよ」とか言った後が怖くて、もたもたして最後だけは無理して聞くことを決めた。あれ? って思う事はないんじゃないかな? まぁそんな事でも、それは、この話を始めて「お前の話を聞いてくれた!」って事だよね? なにかいい話があれば、また聞いてもらえるね!と、に落ちた。だって、この話を聞いてくれたなら、本当にこの話を「誰か」が話してくれているんだもん! なんて信じたら、さっぱり分からないんだよ! だって「あの話は俺が話さなくても」が「この話で、きっと俺の話になるんだ」だって! なんて信じてこそ、いい話の続くんだよ! そうやって、この話を続けている。さあ、次はお前が、私をしてやって来いよ! 君ももういいんだ!']
```


## まとめ
xglmを試した。colaboratoryでは564Mだと動く。

思ったより日本語生成できて驚いた。

gpt2の日本語モデルが1024までで困ってたけど、

`"max_position_embeddings": 2048` ってことは割りと長文いけるってことかな。

https://huggingface.co/facebook/xglm-564M/blob/main/config.json#L17



