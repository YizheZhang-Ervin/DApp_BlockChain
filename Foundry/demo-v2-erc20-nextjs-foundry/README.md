# nextjs

## Init
```sh
npm create next-app@latest
npm run dev
npm anvil
npm install @rainbow-me/rainbowkit wagmi viem@2.x  @wagmi/core
npm install @tanstack/react-query @radix-ui/react-tabs react-icons
npm install @tailwindcss/postcss postcss

# 端到端测试e2e
pnpm add @synthetixio/synpress
pnpm create playwright@latest
pnpm exec playwright test
pnpm exec playwright show-report

# anvil本地链
## 安装方法1
curl -L https://foundry.paradigm.xyz | bash
foundryup

## 安装方法2
https://github.com/foundry-rs/foundry/releases/tag/v1.4.2
下载后解压的文件夹加入PATH
```

## Deploy
```sh
# add .env.local
NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID: Project ID from reown cloud

# 安装
npm install

# 启动
npm anvil
npm run dev

# 单元测试
npm test:unit
npm cache
npm test:e2e
## Error: Cache for xxxx does not exist. Create it first!
## The xxx is your `CACHE_NAME`
## In your `.cache-synpress` folder, rename the folder that isn't `metamask-chrome-***` to your `CACHE_NAME`.

# 部署fleek
npm install -g @fleek-platform/cli
fleek login
fleek sites init
fleek sites deploy
```

## Contract
```
https://github.com/Cyfrin/TSender/
```