---
title: "Rust TokenizerをC++から呼び出す"
slug: "rs-tokenizer"
tags: ["nlp","deeplearning","python", "huggingface"]
date: "2023-03-31T00:00:00+09:00"
draft: false
---

Bloomz.cppのtokenizerが日本語でうまく動かなかったので、
Rust製のHuggingface TokenizerをC++から呼び出せるようにしました。


## 初めに
「応答」の応の文字には２つのIDが振られている。

```python
model_name = "bigscience/bloomz-1b1"
tokenizer = AutoTokenizer.from_pretrained(model_name)
r = tokenizer.encode("応")

>> [1148, 240]

r = tokenizer.decode(r)
>> 応
```

C++の実装では、tokenとidのmapを保持しておいて、tokenをidに変換するので、文字とIDが１対１対応になっていることが前提となる。

https://github.com/NouamaneTazi/bloomz.cpp/blob/main/utils.h#L43-L49


C++でうまくやればこの辺も実装できそうだけど、書きなれてなさすぎて無理だったので、HuggingfaceのRust実装のtokenizerを呼び出すようにした。


## Rust実装
Rust側でTokenizerを呼び出し

```rs
use tokenizers::tokenizer::{Tokenizer};
const MODEL: &str = "bigscience/bloomz-560m";

fn _encode(text: &str) -> Vec<u32> {
    let t = Tokenizer::from_pretrained(MODEL, None).unwrap();
    match t.encode(text, false) {
        Ok(en) => {
            return en.get_ids().to_owned();
        },
        Err(_e) => {            
            return Vec::new()
        }
    };
}
```

structとかで良い感じにするのがめんどくさかったので、
`from_pretrained`のcacheを頼って毎回呼び出す。
エラーも死んで問題ないので無理やり取り出す。

decodeも同じように

```rust
fn _decode(ids: Vec<u32>) -> String {
    let t = Tokenizer::from_pretrained(MODEL, None).unwrap();
    match t.decode(ids, true) {
        Ok(st) => {            
            return st            
        },
        Err(_e) => {
            // error
            return String::from("");
        }
    };
}
```


C++から呼び出せるようにするには、`#[no_mangle]`や型をC++ように合わせておく。

```rust
use std::os::raw::c_char;
use std::ffi::{CString, CStr};

#[no_mangle]
pub extern "C" fn decode(ids: *const u32, len: usize) -> *const c_char {
    let ids = unsafe { slice::from_raw_parts(ids, len) };    
    let text = _decode(ids.to_vec());
    CString::new(text).unwrap().into_raw()
}

#[no_mangle]
pub extern "C" fn encode(text: *const c_char) ->  *const u32 {    
    let text = unsafe { CStr::from_ptr(text).to_string_lossy().into_owned() };    
    let ids = _encode(text.as_str());    
    let arr = ids.as_ptr();
    std::mem::forget(ids);
    arr    
}
```

cargo.tomlを以下の様にしておくと、`libtokenizer.so`が生成される

```toml
[lib]
name = "tokenizer"
crate-type = ["cdylib"]
```




## C++実装
C++の実装はまじでわからないので、見様見真似

`dlopen`でrust側で生成した`libtokenizer.so`を呼び出す。

```C++
const std::vector<int32_t> encode(std::string input) {
    const char *LIB = "./tokenizer_rs/target/debug/libtokenizer.so";

    const char *text = input.c_str();
    void* handle = dlopen(LIB, RTLD_LAZY);
    if (!handle) {
        std::cerr << "Error loading library: " << dlerror() << std::endl;
        return {};
    }

    using EncodeFn = int32_t* (*)(const char*);
    EncodeFn encode = reinterpret_cast<EncodeFn>(dlsym(handle, "encode"));
    if (!encode) {
        std::cerr << "Error loading symbol: " << dlerror() << std::endl;
        return {};
    }

    const int32_t *ids = encode(text);    
    dlclose(handle);
    size_t l = size_of_array(ids);
    return to_vector(ids, l);
}
```

