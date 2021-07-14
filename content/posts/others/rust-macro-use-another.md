---
title: "Rustでmodule間にまたがるmacro呼び出し"
slug: "rust-macro-use-another"
tags: ["rust"]
date: "2019-09-24T00:00:00+09:00"
published: true
---
Rustのmacroをモジュール化して、別のモジュールから呼ぼうと思ったらうまくいかなかった。

日本語の記事があまりなかったのと、自分の備忘録ようにメモを残しておく。

rustのバージョンは`1.27.0`

参考
https://github.com/rust-lang/book/issues/401

マクロの書き方とか、rustのimport周りは意外と日本語記事があったので、そっちを参考に

## ファイル構成
lib.rsでmodをまとめて、main.rsで呼ぶようなファイル構成にする。
このようにしておくと、main.rsのなかでmodを宣言しなくてよくなるし、また誰が誰を公開しているかわかりやすくなる（たぶん）。

```
crate/
  src/
    main.rs
    lib.rs
    mod1/
      mod.rs
      macro.rs
    mod2/
      mod.rs
      macro_run.rs
```


この時、main.rsを実行すると、macro_run.rsの中の関数が呼ばれ、この関数内でmacro.rsに定義してあるマクロが呼び出されるとする。

簡単に言うと、モジュール間に跨ったマクロ呼び出しが行いたい。

## 書き方
main.rsでは、macro_run内にあるrun関数を呼ぶ。

```rust
// main.rs

extern crate rust_test2;
use rust_test2::mod2::macro_run;

fn main() {
    macro_run::run();
}
```


run関数内では、foo!というマクロを使う。

```rust
// macro_run.rs

#[macro_use]
use mod1::macro_test::*;

pub fn run() {
    let foo = foo!(1);
    println!("{}",foo);
}
```

fooマクロは、引数をそのまま返す単純なマクロ。

```rust
// macro.rs

#[macro_use]
macro_rules! foo {
      ($e: expr) => {
             $e
         }
     }
```

macro_useをつける。

```rust
// mod1/lib.rs

#[macro_use]
pub mod macro_test;
```

ここのlibにもmacro_useが必要。

```rust
// lib.rs

#[macro_use]
pub mod mod1;
pub mod mod2;
```

次のように#[macro use]の順番が入れ変わるとだめ
(参考：https://www.ncameron.org/blog/macros-in-rust-pt4/)

```rust
// lib.rs

pub mod mod2;
#[macro_use]
pub mod mod1;
```

## まとめ

- #[macro_use]をいっぱいかく
- lib.rsに書く順番が大切
- コードの一部はネットの情報としてあったが、コードの全体がわからずハマったので全体をgithubにあげておく

https://github.com/if001/rust_macro_test

