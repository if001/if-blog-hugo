# readme
## run server

```
$ hugo serve -D
```

## add content

```
$ hugo new {content title}
```

## fix theme css
```
themes/ifblog/assets/css/style.css
```

コードブロックの色は `themes/ifblog/assets/css/chroma.css` で管理しています。
`markup.highlight.style` を変更した場合は以下で再生成してください。

```
$ hugo gen chromastyles --style=monokai > themes/ifblog/assets/css/chroma.css
```

## theme
`themes/ifblog`（自作テーマ）
- デザイン: Editorial / Paper
- ヒーローマーク: Neural brain
- テンプレート: `themes/ifblog/layouts/`
- テーマの説明: `themes/ifblog/README.md`

旧テーマ（`themes/my_harbor`）は submodule として残しています。


## submodule
git submodule add {URL}
submoduleの外側では、submodule内のcommitを指すことになる

## clone
git submodule update --init --recursive

### submodule内の変更
submodule内に入って、commit
submoduleの外で、add、commit、push

submoduleの外側で、submoduleをadd、commitで、submoduleの指すcommitがupdateされる

### submoduleの指すcommit hash確認
$ git submodule

### debug

```
hugo server -v --renderToDisk --gc --cleanDestinationDir -D
```
