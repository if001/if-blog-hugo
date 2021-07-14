---
title: "ボタン以外のコンポーネントに波紋エフェクト(ripple effect)つける"
slug: "book-reports-firebase"
tags: ["android"]
date: "2020-02-28T00:00:00+09:00"
published: false
---

図

TextViewなどのbackgroudに以下を指定すればおk   

`android:background="?attr/selectableItemBackground"`

backgroundで色などをすでに指定している場合は、以下のようにする。
foregroundに指定する。  

```xml
 <Button
        android:layout_width="match_parent"
        android:layout_height="200dp"
        android:padding="0dp"
        android:background="#bbffbb"
        android:foreground="?android:selectableItemBackground"
        android:text="Hello World!"/>
```
