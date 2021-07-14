---
title: "keybind"
slug: "emacs-keybind"
tags: ["emacs"]
date: "2019-03-23T17:00:00+09:00"
draft: true
---

```lisp
(define-key KEYMAP KEY 'COMMAND)
```

KEYMAPに`global-map`を指定したものは、以下と同義となる。

```lisp
(global-set-key KEY COMMAND)
```


