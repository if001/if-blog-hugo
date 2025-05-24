---
title: "reactのrender propsをtypescriptでやる"
slug: "react-render-prop-typescript"
tags: ["typescript", "react"]
date: "2022-02-19T00:00:00+09:00"
draft: false
---


childrenに引数渡したい時、render propを使えばできる。
functional componentでのやり方がわからなくていろいろハマったのでメモ

https://reactjs.org/docs/render-props.html


## 結論

```typescript

// children
interface ChildrenSampleProps {
    userName: string
}
const ChildrenSample: React.FC<ChildrenSampleProps> = ({ userName }) => {
    return <>user: {userName}</>
}

// parent
interface ParentProps {
    children: (props: ChildrenSampleProps) => JSX.Element
}
const Parent: React.FC<ParentProps> = ({ children }) => {
    const userName = 'user!!!'
    return <>{children({ userName })}</>
}

// sample to use
const Sample: React.FC = () => {
    return (
        <Parent>
            {(props) => <ChildrenSample {...props} />}
        </Parent>
    );
}
```

childrenの型を`children: (props: ChildrenSampleProps) => JSX.Element`のようにするといける
