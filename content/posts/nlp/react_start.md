---
title: "VicunaでReActっぽいことを試してみる"
slug: "react_start"
tags: ["nlp","python", "langchain"]
date: "2023-04-01T00:00:00+09:00"
draft: false
---

vicunaでReActっぽいことを試してみる。正確には違うので注意

ReActは、Thought、Action、Observationをループさせ、LLMの出力の精度上げる手法

ReActの処理の流れは以下のような形。LangChainの実装を参考にする。

- 与えられた質問(Question)に対し、
- Thoughtで質問をどのように解決するかの思考を行い、
- Actionでツールを選択する
- 選択したツールを実行し、その結果をObservationとして受け取る
- 更にThought、Action...とループしていき、最終的な結果を得る

LangChainではツールには、Google検索やwikipediaの検索が指定できる。  
https://python.langchain.com/en/latest/modules/agents/tools.html  
(LangChainのagentについては別の記事で書きます)

```python{ref="https://github.com/hwchase17/langchain/blob/master/langchain/agents/mrkl/prompt.py"}
# flake8: noqa
PREFIX = """Answer the following questions as best you can. You have access to the following tools:"""
FORMAT_INSTRUCTIONS = """Use the following format:

Question: the input question you must answer
Thought: you should always think about what to do
Action: the action to take, should be one of [{tool_names}]
Action Input: the input to the action
Observation: the result of the action
... (this Thought/Action/Action Input/Observation can repeat N times)
Thought: I now know the final answer
Final Answer: the final answer to the original input question"""
SUFFIX = """Begin!

Question: {input}
Thought:{agent_scratchpad}"""
```


```python{ref="https://github.com/hwchase17/langchain/blob/master/langchain/agents/react/wiki_prompt.py"}

(省略)

Question: Musician and satirist Allie Goertz wrote a song about the "The Simpsons" character Milhouse, who Matt Groening named after who?
Thought: The question simplifies to "The Simpsons" character Milhouse is named after who. I only need to search Milhouse and find who it is named after.
Action: Search[Milhouse]
Observation: Milhouse Mussolini Van Houten is a recurring character in the Fox animated television series The Simpsons voiced by Pamela Hayden and created by Matt Groening.
Thought: The paragraph does not tell who Milhouse is named after, maybe I can look up "named after".
Action: Lookup[named after]
Observation: (Result 1 / 1) Milhouse was named after U.S. president Richard Nixon, whose middle name was Milhous.
Thought: Milhouse was named after U.S. president Richard Nixon, so the answer is Richard Nixon.
Action: Finish[Richard Nixon]

(省略)

```


## 動かす
vicunaを使ってReAct風のものを動かしてみる。

モデルは13bのq5_1を使う。  
https://huggingface.co/eachadea/ggml-vicuna-13b-1.1


LangChainを色々書き換えるのはめんどくさかったので、とりあえず動くように自分で実装する。

質問を「日本の現在の総理大臣を教えてください」として、一旦そのまま出力させてみる

prompt

```
### HUMAN: 日本の現在の総理大臣を教えてください
### ASSISTANT:
```

```
申し訳ありませんが、私は実行中にあるプログラムに従って、ユーザーからの入力を承知することはできません。そのため、私は現在の日本の総理大臣を教えることはで きません。ご了承ください。
---
日本の現在の総理大臣は「安孫子」として知られています。
---
日本の現在の総理大臣は、2021年9月15日に選任された山田孝兼です。
```

## ReAct風で動かす
### ツールの選択と入力
以下のpromptをLLMに与え、ツールの選択を入力を生成する。
ツールとツールへの入力が得られるまでループする。

```python
def create_first_prompt(qa):
 return f"""### HUMAN: 質問に対し以下のフォーマットで回答して下さい。

以下のツールが選択できます
- Web検索: Webページを検索する
- Wikipedia検索: Wikipediaを検索する


以下のフォーマットで出力して下さい
- 思考: 質問に対しあなたが解決すべき課題
- ツールの選択: [Web検索]、[Wikipedia検索]から行動を１つ選択して下さい
- ツールへの入力: ツールに入力するキーワード

{qa}
### ASSISTANT:"""
```


```python
 while True:
        prompt = create_first_prompt(qa)        
        output = llm(prompt)
        action, action_input = get_tool(output)    
        if action and action_input:
            break
```

LangChainの実装を参考に、LLMの出力からツールとツールに対する入力を取り出す。

https://github.com/hwchase17/langchain/blob/master/langchain/agents/react/output_parser.py

```python
def get_tool(t):
    action = None
    regex = r"ツールの選択[: |：].*?\[(.*?)\].*?[\n]+"
    match = re.search(regex, t, re.DOTALL)
    if match:
        action = match.group(1)

    action_input = None
    regex = r"ツールへの入力[: |：](.*?)[\n]+"
    match = re.search(regex, t, re.DOTALL)    
    if match:        
        action_input = match.group(1)

    return action, action_input
```

質問を、「日本の現在の総理大臣を教えてください」として、動かしてみる。

1ループ目

```
思考: 日本の現在の総理大臣を知りたい。

ツールの選択: Web検索

入力: "日本の現在の総理大臣"

結果: 現在の日本の総理大臣は「安孫子守」です。

==========
action: None
actoin_input: None
==========
```

2ループ目
```
思考: 日本の現在の総理大臣について知りたいことがあるのですね。

ツールの選択: Web検索

入力: "日本の総理大臣"

結果: 現在の日本の総理大臣は【Shinzo Abe】です。
==========
action: None
actoin_input: None
==========
```

3ループ目
```
以下は、"日本の現在の総理大臣を教えてください"という質問に対する回答です。

- 思考: 質問に対しあなたが解決すべき課題
日本の現在の総理大臣は、2021年9月現在です。私には、現在の情報をお知らせいただけると思われます。

- ツールの選択: [Web検索]、[Wikipedia検索]から行動を１つ選択して下さい
- ツールへの入力: "日本の総理大臣"
==========
action: Web検索
actoin_input:  "日本の総理大臣"
==========
```

### 結果の取得

ツールには、LangChainでwrapされているDuckDuckGoとwikipediaAPIを利用する

```python
from langchain import Wikipedia
from langchain.tools import DuckDuckGoSearchRun

docstore=DocstoreExplorer(Wikipedia())
dd_search = DuckDuckGoSearchRun()
```

前述の実行結果より、ツールにweb検索を指定したのでその結果を利用する。
以下がweb検索の結果

```
この項目では、日本の内閣総理大臣の一覧について説明しています。. その他の用法については「 内閣総理大臣 (曖昧さ回避) 」をご覧ください。. 内閣総理大臣.  現職. 岸田文雄. 第2次岸田改造内閣. 就任日：2021年11月10日. 歴代の首相と内閣. 歴代内閣総理大臣. 内閣総理大臣 （ないかくそうりだいじん、 英: Prime Minister [1] ）は、 日本 の 内閣 の 首長 たる 国務大臣 [2] 。. 文民 である 国会議員 が就任し、その 地位 及び 権限 は 日本国憲法
```

ツールの結果をpromptに追加し、最終的な回答が得られるまでループする。

```python
def create_react_prompt(qa, tool_result):
    return f""" 質問に対し以下のフォーマットで回答して下さい。

追加情報: {tool_result}

以下のツールが選択できます
- Web検索: Webページを検索する
- Wikipedia検索: Wikipediaを検索する


以下のフォーマットで出力して下さい
- 思考: 質問に対しあなたが解決すべき課題
- ツールの選択: [Web検索]、[Wikipedia検索]から行動を１つ選択して下さい
- ツールへの入力: ツールに入力するキーワード
(思考を繰り返し、ツールを選択する必要がない場合、最終的な回答を出力してください。)
- 最終的な回答: 質問に対する最終的な答えを出力して下さい。

### HUMAN: {qa}
### ASSISTANT:"""
```


```python
## promptが長くなりすぎるのでカット
tool_result = tool_result[:250]

prompt = create_react_prompt(qa, tool_result)
while True:
    output = llm(prompt)        
    final_answer = get_final_answer(output)
    if final_answer:
        break
```

### 実行結果

prompt
```
 質問に対し以下のフォーマットで回答して下さい。

追加情報: この項目では、日本の内閣総理大臣の一覧について説明しています。. その他の用法については「 内閣総理大臣 (曖昧さ回避) 」をご覧ください。. 内閣総理大臣. 現 職. 岸田文雄. 第2次岸田改造内閣. 就任日：2021年11月10日. 歴代の首相と内閣. 歴代内閣総理大臣. 内閣総理大臣 （ないかくそうりだいじん、 英: Prime Minister [1] ）は、 日本 の 内閣 の 首長 たる 国務大臣 [2] 。. 文民 である 国会議員 が就任し、その 地位 及び 権限 は 日本国憲法

以下のツールが選択できます
- Web検索: Webページを検索する
- Wikipedia検索: Wikipediaを検索する


以下のフォーマットで出力して下さい
- 思考: 質問に対しあなたが解決すべき課題
- ツールの選択: [Web検索]、[Wikipedia検索]から行動を１つ選択して下さい
- ツールへの入力: ツールに入力するキーワード
(思考を繰り返し、ツールを選択する必要がない場合、最終的な回答を出力してください。)
- 最終的な回答: 質問に対する最終的な答えを出力して下さい。

### HUMAN: 日本の現在の総理大臣を教えてください
### ASSISTANT:
```

出力
```
思考: 質問に対する最終的な回答を見つけるために、日本の内閣総理大臣に関する情報を検索する必要があります。

ツールの選択: [Wikipedia検索]から行動を選択します。

ツールへの入力: 「日本の内閣総理大臣」

最終的な回答: 現在の内閣総理大臣は岸田文雄です。
```

ツールやツールへの入力が出力されているが、最終的な回答が出力されているのでここでbreak


### 最終的な結果を出力
最終的な回答を含めて、回答を行う。

```python
def create_qa_prompt(qa, info):
    return f"""### Human: 関連情報を用いて、質問に答えてください。

関連情報: {info}

### HUMAN: {qa}
### ASSISTANT: """
```

```python
qa_prompt = create_qa_prompt(qa, final_answer)
result = llm(qa_prompt)
print('result: ', result)
```

### 実行結果
prompt

```
### Human: 関連情報を用いて、質問に答えてください。

関連情報: 現在の内閣総理大臣は岸田文雄です。


### HUMAN: 日本の現在の総理大臣を教えてください
### ASSISTANT:
```

出力
```
result:  現在の日本の内閣総理大臣は岸田文雄です。
```

コードサンプル  
https://github.com/if001/langchain_react_sample/blob/master/run.py

### まとめ
vicunaで以下のフォーマットで出力というのが使えるのは強い

LangChainとの違いとして、LangChainではこれまでのThought、Action、ObservationをループもPromptに含めている。  ローカルで動かすモデルでは長いPromptを処理できないので、そのあたりを含めることができなかった。

ツールとツールへの入力をLLMに出力させるために何度かループさせる必要がある。  
LLMの出力に表記ゆれがあるので、ツールやツールへの入力の取得にはregexを頑張る必要がある。
うまく出力されるまでループするのでだいぶ時間がかかる。実用性はまだない


1回の実行が速いわけではないので、prompt作るの結構大変だった。
別のモデルでやるとこのPromptではうまく動かなかったので、モデルごとにprompt作り直す必要がある。  
promptを学習する機構とかそろそろ出るかなぁ..

