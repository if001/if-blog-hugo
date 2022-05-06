---
title: "プログラミングTypeScript――スケールするJavaScriptアプリケーション開発"
slug: "typescript-oreilly"
tags: ["typescript"]
date: "2021-12-26T00:00:00+09:00"
draft: false
---

オライリーのtypescriptの本を読んだ。
typescriptのジェネリクスなど基本的な動作は知ってたがいくつか知らないことが合ったので
それだけメモしておく。

## 4章 関数
### 4.1.4 thisの型付け
> javascriptではすべての関数に対してthisが定義される。
> これによりコードが脆弱になり、理解しづらくなる。

これを無効にするにはTSLintで、以下のようにしておく。

```
{
  // note you must disable the base rule as it can report incorrect errors
  "no-invalid-this": "off",
  "@typescript-eslint/no-invalid-this": ["error"]
}
```



基本的にthisは(.)ドットの左側を指す。
以下のようなコードがあるとき、thisはxになる。

```typescript
let x = {
  a() {
    return this;
  }
}
x.a()
```

しかし、どこかの時点でaが再割り当てし、呼び出すとundefinedになる

```typescript
let a = x.a
a()
```


### 4.2.6 ジェネリック型のデフォルトの型
デフォルトの型使えるの知らなかった

```typescript
type MyEvent<T = HTMLElement> = {
  target: T
  type: string
}
```


## 5章 クラスとインターフェース
### 5.4 インターフェース
型(type)とインターフェースの違い

- 型エイリアスは右辺に任意の型を指定できるという点で汎用的

（型エイリアスだと、合併型(Union Types)と交差型(Intersection Types)が使える）  
以下のような、型エイリアスはインターフェースとして書き直すことができない。

```typescript
type A = number
type B = A | string
```

- インターフェースを拡張する際に割り当て可能かをチェックする

インターフェースの場合、interface AとBのもつメソッドbadの引数の型が異なるのでエラーとなる。

型エイリアスの場合、extendsを＆に変えると、拡張元と拡張先の型を結合したbadメソッドのオーバーロードされたシグネチャを生み出し、
コンパイルエラーが回避される。

```typescript
interface A {
  good(x: number): string
  bad(s: number): string
}

interface B extends A {
  good(x: number): string
  bad(s: string): string
}
```

- 同じスコープ内に同じ名前のインターフェースがあるとマージ

interfaceの場合、自動でマージされる。

```typescript
interface User {
  name: string
}

// この時点でUserは、nameとageを持つ
interface User {
  age: number
}
```

型エイリアスだと、同じ名前の定義があるとコンパイルエラーになる

### 5.8 ミックスイン
いくつか知らない書き方合った

debugしづらいUserクラスがあるとき、debug機能をmixinすることでdebug機能を追加する。

```typescript
type Constructor<T> = new (...arg: any[]) => T

const WithEZDebug = <C extends Constructor<{
    getClass(): string
}>> (Class: C) => {
    return class extends Class {
        debug() {
            const name = this.constructor.name;
            const c = this.getClass();
            return `debug:  ${c}, ${name}`;
        }
    }
}

class User {
    name: string
    constructor(name: string) {
        this.name = name
    }

    getClass(): string {
        return "User";
    }
}

const main = () => {
    const u = WithEZDebug(User)
    const user = new u("name")
    user.debug()
}
```


この書き方初めて知った

```typescript
class extends Class
```

型引数にそのままobject書けるのも初めて知った。

```typescript
 <C extends Constructor<{
    getClass(): string
}>>
```

TypeScript Deep Dive:
https://typescript-jp.gitbook.io/deep-dive/type-system/mixins

## 6章 高度な型
### 6.1.5.1 タグ付き合併型
ユーザーのイベントを定義している場合を例にする。
handleのif文の分岐で、event.valueはそれぞれstring/[number, number]になる。

```typescript
type UserTextEvent = { value: string }
type UserMouseEvent = { value: [number, number] }

type UserEvent = UserTextEvent | UserMouseEvent

const handle = (event: UserEvent) => {
    if(typeof event.value === 'string') {
        //event.valueはstring
    }
    // event.valueは[number, number]
}

```


UserTextEventとUserMouseEventにtargetを追加する。

```typescript
type UserTextEvent = { value: string, target: HTMLInputElement }
type UserMouseEvent = { value: [number, number], target: HTMLElement }

type UserEvent = UserTextEvent | UserMouseEvent

const handle = (event: UserEvent) => {
    if(typeof event.value === 'string') {
        // event.valueはstring
        // event.targetは HTMLInputElement or HTMLElement
    }
    // event.valueは[number, number]
    // event.targetは HTMLInputElement or HTMLElement
}
```

この場合、if文の分岐の中でtargetの型が絞られない。

これを解決するには、タグ付けを行う。

タグ付けは、以下のようになっているのが良い

- 同じフィールド名
- リテラル型
- ジェネリックではない
- 合併型で一意

stringとか使うと無難。

書き直すとこんな感じ

```typescript
type UserTextEvent = { type: 'TextEvent',value: string, target: HTMLInputElement }
type UserMouseEvent = { type: 'MouseEvent', value: [number, number], target: HTMLElement }

type UserEvent = UserTextEvent | UserMouseEvent

const handle = (event: UserEvent) => {
    if(event.type === 'TextEvent') {
        // event.valueはstring
        // event.targetは HTMLInputElement
    }
    // event.valueは[number, number]
    // event.targetは HTMLElement
}
```


### 6.3.4 コンパニオンオブジェクトパターン
typescriptでは、型と値が別々の名前空間が異なる。
これを使ったして、コンパニオンオブジェクトパターンができる。

```typescript
type Currency = {
    price: number
}

const Currency = {
    from(value: number): Currency {
        return {
            price: value
        }
    }
}

const main = () => {
    Currency.from(1)
}
```

言われると確かにって感じだけど、やろうと思わなかった。
いまいちメリットがわからん。


### 6.4.2 ユーザー定義型ガード
typescriptだと、isStringがbooleanを返すことしかわからない。

```typescript
const isString = (s: string | number): boolean => {
    return typeof s === 'string'
}

const parseInt = (s: string | number) => {
    if(isString(s)) {
        // sはstring | numberと推論される
        return s.toLocaleUpperCase()
    }
    // なんかの処理
}
```

その場合、ユーザー定義型ガードを使う

```typescript
const isString = (s: string | number): s is string => {
    return typeof s === 'string'
}

const parseInt = (s: string | number) => {
    if(isString(s)) {
        // sはstring | numberと推論される
        return s.toLocaleUpperCase()
    }
    // なんかの処理
}
```

### 6.5 条件型
`U :< V`であれば、TをAに、そうでなければTをBに割り当てるようなこと。

```typescript
type IsString<T> = T extends string ? true : false;
type A = IsString<string>
type B = IsString<number>
```

### 6.7 名前的型をシミュレートする
UserIDとCustomerIDのような型エイリアスしている場合

```typescript
type UserID = string
type CustomerID = string

const userID = (id: string): UserID => id as UserID
const customerID = (id: string): CustomerID => id as CustomerID
```


UserIDを引数に取る、checkIDを使ってもエラーにならない。

```typescript
const checkID = (id: UserID) => {
    console.log(id)
}

const main = () => {
    const uID = userID('001')
    checkID(uID)

    const cID = customerID('002')
    checkID(cID) // エラーにならない
}
```

これはUserIDはstringのエイリアスにすぎないから。

型のブランド化で解決できる。

型エイリアスを次のように書き直す。

```typescript
type UserID = string & { readonly brand: unique symbol }
type CustomerID = string & { readonly brand: unique symbol }
```

すると、checkIDでエラーになる。

```typescript
const main = () => {
    const uID = userID('001')
    checkID(uID)

    const cID = customerID('002')
    checkID(cID) // エラーになる
}
```


## 付録
tsconfig

- alwaysStrict
- noEmitOnError: コードにエラーがある場合、JavaScriptを出力しない
- noFallthroughCasesInSwitch: すべてのswitchのcaseが値を返しているか、またはbreakしているか
- noImplicitAny: 変数の型がanyと推論される場合、エラー
- noImplicitReturn: すべての関数内のコードパスが明示的にreturnしているか
- noImplicitThis: this型を明示的にアノテートせずに関数内でthisを使用する場合エラー
- noUnusedLocals: 使われてないローカル変数について警告
- noUnusedParameter: 使われてない関数パラメタについて警告。エラーを無視するにはアンダースコアをつける
- strictBindCallApply: bind、call、applyについて型安全を強制する
- strictFunctionTypes: 関数がそのパラメタ及び、this型に関して普遍であることを強制する
- strictNullChecks: nullを型に昇格させる
- strictPropertyInitialization: クラスのプロパティがnull許容であるか、または初期化されていることを強制する




