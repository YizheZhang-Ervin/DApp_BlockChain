# Foundry

## Init
```sh
# 创建
mkdir demo
cd demo
forge init

# 测试
forge test

# 安装库
# 方法1：forge install Openzeppelin/openzeppelin-contracts
# 方法2：github直接下https://github.com/Openzeppelin/openzeppelin-contracts放lib/openzeppelin-contracts下
# foundry.toml改remappings增加"@openzepplin/=lib/openzeppelin=contracts/"
forge build

# 构建
## 指定目标，执行build
make build
## 未指定目标，执行all或者default
make

# 启动本地测试链
yarn add hardhat
yarn hardhat
yarn hardhat node

# 部署合约
forge create StakeContract --private-key 账号私钥 --rpc-url http://127.0.0.1:8545
```