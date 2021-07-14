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
cd theme/havor/
```


```
# for development version
$ npm run build-dev

# for production version
$ npm run build-prod
```


## theme
https://github.com/matsuyoshi30/harbor


## submodule
git submodule add {URL}
submoduleの外側では、submodule内のcommitを指すことになる

### submodule内の変更
submodule内に入って、commit
submoduleの外で、add、commit、push

submoduleの外側で、submoduleをadd、commitで、submoduleの指すcommitがupdateされる



### debug

```
hugo server -v --renderToDisk --gc --cleanDestinationDir -D
```
