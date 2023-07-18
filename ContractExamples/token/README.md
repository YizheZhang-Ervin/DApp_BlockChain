# 前后端整合Steps

1. 初始化项目
```
npm init vue
npm install
npm i @openzeppelin/contracts
npm i web3
```

2. 移动文件
```
把contracts，migrations，scripts，test，truffle-config.js移到app下
```

3. 打包
```
改truffle-config.js
truffle migrate --reset
```