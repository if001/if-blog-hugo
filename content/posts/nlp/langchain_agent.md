---
title: "LangChainのAgentを調べる"
slug: "lang_chain_agent"
tags: ["nlp","langchain","python"]
date: "2023-04-20T00:00:00+09:00"
draft: true
---

LangChainにAgentsという機能がある。
AgentとはLLMを利用して、実行するactionとその順序を決定できる。

https://python.langchain.com/en/latest/modules/agents/getting_started.html

いまいちピンとこなかったので、コードを読んでみる


## Tools
toolには、Google Search APIやその他いくつかのAPIが指定できる

https://python.langchain.com/en/latest/modules/agents/tools.html


## サンプル
AgentとToolsを定義し、AgentExecutorに渡し、実行するという流れ


```python
## Agent
agent = CustomAgent(llm_chain=llm_chain,
                        tools=tools,
                        verbose=True)

## Tools
from langchain import Wikipedia
from langchain.agents.react.base import DocstoreExplorer
docstore=DocstoreExplorer(Wikipedia())
tools = [
    Tool(
        name="Search",
        func=docstore.search,
        description="searchに利用する"
    ),
    Tool(
        name="Lookup",
        func=docstore.lookup,
        description="lookupに利用する"
    )
]

## AgentExecutor
agent_chain = AgentExecutor.from_agent_and_tools(
    agent=agent,
    tools=tools,
    verbose=True    
)
r = agent_chain.run(input="日本の人口を教えて下さい")
print('result', r)
```


## コードをよむ
AgentはReAct形式のpromptを扱う。
ReActは、Thought、Action、Observationをループさせ、LLMの出力の精度上げる手法

今回は例として、ZeroShotAgentを見る。
Agentを継承したClassは他にもあるが、promptの作り方の実装が異なる感じっぽい。

継承関係は以下

```python
BaseModel <- BaseSingleActionAgent <- Agent <- ZeroShotAgent
```


promptはこんな感じ
{input}にはユーザからの入力、{agent_scratchpad}にはagentからの入力が入る

```
Answer the following questions as best you can, but speaking as a pirate might speak. You have access to the following tools:

Search: useful for when you need to answer questions about current events

Use the following format:

Question: the input question you must answer
Thought: you should always think about what to do
Action: the action to take, should be one of [Search]
Action Input: the input to the action
Observation: the result of the action
... (this Thought/Action/Action Input/Observation can repeat N times)
Thought: I now know the final answer
Final Answer: the final answer to the original input question

Begin! Remember to speak as a pirate when giving your final answer. Use lots of "Args"

Question: {input}
{agent_scratchpad}
```

`langchain/agents/mrkl/prompt.py`


大まかな流れは、AgentExecutor._callを見るとわかる

https://github.com/hwchase17/langchain/blob/master/langchain/agents/agent.py#L777




- should_continueがTrueの間ループ
  - ループ数がmax_iterations(default=15)に到達するまでループ
  - take_next_step  
  - ループを抜ける判定

- take_next_step
  - agent.plan
    次のアクションを取り出す

- agent.plan
  - 