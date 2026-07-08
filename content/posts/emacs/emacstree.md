---
title: "treemacsを使う"
slug: "treemacs"
tags: ["emacs"]
date: "2026-07-07T10:30:00+09:00"
draft: false
---

これまでneotreeを使っていたが、treemacsに変えてみたのでメモ

https://github.com/Alexander-Miller/treemacs
https://github.com/rainstormstudio/treemacs-nerd-icons


使う機能はこのあたり
- treeをダブルクリックでopne/close
- 右クリックでメニュー表示
- `treemacs-project-dir`を作成し、現在のディレクトリのプロジェクトルートからtreeを表示、表示していれば閉じる
- 開いているファイルをtree側でもハイライト
- ネストしたディレクトリやファイルなどのindentを狭くする
- 変更されたファイルやignoreファイルなどを表示


設定例

```
(defun treemacs-project-dir ()
  "現在のプロジェクトをルートとしてTreemacsを開閉する。"
  (interactive)
  (require 'treemacs)

  (if (eq (treemacs-current-visibility) 'visible)
      (treemacs)
    (treemacs-add-and-display-current-project-exclusively)))

(use-package treemacs
  :ensure t
  :defer t
  :custom
  (treemacs-indentation 1)
  :bind
  (("<f8>" . treemacs-project-dir))
  :hook
  (treemacs-mode
   . (lambda ()
       (display-line-numbers-mode -1)))
  ;; :config
  ;; (treemacs-follow-mode 1) ;; 現在選択中のファイルへ追従
  ;; (treemacs-project-follow-mode 1) ;; 現在のバッファに対応するプロジェクトへ切り替える
  )
(use-package treemacs-nerd-icons
  :after (treemacs nerd-icons)
  )
```

開いているファイルをtree側でもハイライトはneotreeでは自作してたので入っていると便利

neotreeだとファイルが多い場合、ネストしたディレクトリやファイルなどのindentが広く見ずらかったが調整できなかった。treemacsでは、treemacs-indentationで調整可能。

標準のproject.elのみで、projectileは使っていない。
