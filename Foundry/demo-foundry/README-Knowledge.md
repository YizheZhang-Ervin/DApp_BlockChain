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
forge create StakeContract --private-key 账号私钥 --rpc-url http://127.0.0.1:8545 --constructor-args xxx
```

## foundry其他命令
```sh
## 初始化
forge init --force --no-commit
forge install OpenZeppelin/openzeppelin-contracts

## 编译
forge compile

## 测试
forge test

## 测试指定测试合约中过的函数
forge test --mt ${函数名称} -vvvvv 

## 部署合约
anvil
forge create src/LuLuCoin.sol:LuLuCoin --private-key ${OWNER_PRIVATE_KEY} --broadcast --constructor-args ${OWNER_ADDRESS}

## 函数选择器
forge selectors find

## 调用mint函数:铸币
source .env
cast send ${LLC_CONTRACT} "mint(uint256)" ${AMOUNT} --private-key ${OWNER_PRIVATE_KEY}
 
## 查看合约中的代币余额
cast call ${LLC_CONTRACT} "balanceOf(address)" ${OWNER_ADDRESS}

## 转换数字
cast to-dec 0x0000...
```