---
title: "とりあえずtypescriptを書きたいときのinit"
slug: "typescript-init"
tags: ["typescript"]
date: "2021-07-29T00:00:00+09:00"
draft: true
---


typescript 

https://basarat.gitbook.io/typescript/nodejs


## package.json

```
npm init
```

package.jsonのscriptに追加

```json
 "start":"./node_modules/.bin/ts-node ./src/index.ts"
```



## typescript

```
npm install -D typescript
npm install -D ts-node
```

## run
`src/index.ts`を追加、`npm run start`で起動

index.ts

```typescript
const main = () => {
      console.log("hello")
}
main()
```



## jest

```
npm i jest @types/jest ts-jest -D
```


```javascript
// jest.config.ts
import type {Config} from '@jest/types';

// Sync object
const config: Config.InitialOptions = {
  verbose: true,
};
export default config;

// Or async function
export default async (): Promise<Config.InitialOptions> => {
  return {
    verbose: true,
  };
};
```

https://jestjs.io/ja/docs/configuration
