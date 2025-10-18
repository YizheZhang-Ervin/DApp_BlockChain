# nextjs

## usage
```
npm create next-app@latest
npm run dev
npm install @rainbow-me/rainbowkit wagmi viem@2.x  @wagmi/core
npm install @tanstack/react-query @radix-ui/react-tabs react-icons
npm install @tailwindcss/postcss postcss
```

## .env.local
```sh
NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID: Project ID from reown cloud
```

# anvil
```sh
## 方法1
curl -L https://foundry.paradigm.xyz | bash
foundryup

## 方法2
https://github.com/foundry-rs/foundry/releases/tag/v1.4.2
下载后解压的文件夹加入PATH
```

## Setup
```bash
# 安装
npm install

# 本地区块链
npm anvil

# 本地七点
npm run dev

# 单元测试
npm test:unit
```

## Test
```sh
npm cache
npm test:e2e

## Error: Cache for xxxx does not exist. Create it first!
The xxx is your `CACHE_NAME`
In your `.cache-synpress` folder, rename the folder that isn't `metamask-chrome-***` to your `CACHE_NAME`.
```

## Contract
```
https://github.com/Cyfrin/TSender/
```