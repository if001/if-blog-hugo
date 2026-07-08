---
title: "emacsのソースビルドメモ"
slug: "emacs-build"
tags: ["emacs"]
date: "2026-06-26T10:30:00+09:00"
draft: false
---

emacs30の使うためのbuildメモ

linuxのGUI利用で、tree-sitter, xwidget, native compile, svg描画あたりを動作させたい想定

## 準備
公式のサイトからzip or tarをダウンロードして展開

https://www.gnu.org/savannah-checkouts/gnu/emacs/download.html

事前に必要そうなものを入れておく
```
sudo apt update
sudo apt install -y \
  build-essential \
  autoconf \
  texinfo \
  libgtk-3-dev \
  webkit2gtk-4.1-dev \
  libgccjit-14-dev \
  librsvg2-dev \
  libpng-dev \
  libjpeg-dev \
  libgif-dev \
  libtiff-dev \
  libxml2-dev \
  libjansson-dev \
  libncurses-dev \
  gnutls-dev
```

`libwebkit2gtk-4.1-dev`がなければ`libwebkit2gtk-4.0-dev`

configの作成

```
./autogen.sh

./configure \
  --with-x-toolkit=gtk3 \
  --with-xwidgets \
  --with-native-compilation=aot \
  --with-modules \
  --with-tree-sitter
```

```
make -j$(nproc)
sudo make install
```
