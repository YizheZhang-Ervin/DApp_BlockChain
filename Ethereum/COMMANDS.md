# 命令

## Truffle
```
# 安装
npm i truffle -g

# vscode安装solidity插件

# 脚手架
truffle init 
- /contracts存放智能合约
- /migrations控制合约部署
    - 部署文件以数字开头
- /test测试文件
- /truffle-config.js配置文件
    - networks配置development，from指定付gas账号(不写默认第一个)
	- compilers配置optimizer

# 建协议和测试
truffle create contract xxContractName
truffle create test xxTestName

# 编译
truffle compile

# 部署 (--reset全部重新部署)
truffle migrate

# 控制台
truffle console
> const obj = await xx.deployed()
> obj.address
> obj.setData("abc",100)
> obj.getData()
> obj.age()

# 执行测试
truffle exec .\scripts\test.js
```

## Ganache
```
npm install -g ganache-cli

ganache -d
```