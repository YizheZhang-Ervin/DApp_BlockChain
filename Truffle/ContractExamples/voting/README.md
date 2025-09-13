# Steps

```
# 安装脚手架
npm install -g truffle
truffle -v

# 更新nodejs
sudo npm install -g n  
sudo n stable  

# 初始化项目
truffle unbox webpack

# 编译
truffle compile

# 部署
truffle migrate

# 控制台
truffle console
> let instance = await Voting.deployed()
> instance

# 启动前端
npm run dev
浏览器打开127.0.0.1:8080
```