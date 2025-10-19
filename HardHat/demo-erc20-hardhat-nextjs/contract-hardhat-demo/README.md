# Hardhat

## Hardhat
```sh
# 安装
mkdir xxProject
cd xxProject
npm init
npm install --save-dev hardhat@2

# 初始化
npx hardhat init

# 查看命令
npx hardhat

# 编译
npx hardhat compile

# 测试
npx hardhat test
REPORT_GAS=true npx hardhat test

# 部署
npx hardhat ignition deploy ./ignition/modules/Lock.js
npx hardhat ignition deploy ./ignition/modules/Lock.js --network localhost

# 独立运行network
npx hardhat node
npx hardhat node --hostname 127.0.0.1 --port 8545

# 帮助
npx hardhat help
```
