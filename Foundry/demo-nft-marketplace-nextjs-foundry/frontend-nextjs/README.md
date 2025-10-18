# NFT Marketplace 

1. Indexing (rindexer)
2. Fleek CLI
4. Compliance Engine
5. USDC payment
6. Gashawk

## .env.local
```
# Project ID from reown cloud
NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID=your_project_id
GRAPHQL_API_URL=http://localhost:3001/graphql
ENABLE_COMPLIANCE_CHECK=false
CIRCLE_API_KEY=TEST_API_KEY
```

## Setup

```bash
# 改esbuild版本
"devDependencies": {"esbuild-wasm":"latest"},
"overrides": {"esbuild": "npm:esbuild-wasm@latest"}

# anvil
## 方法1
curl -L https://foundry.paradigm.xyz | bash
foundryup

## 方法2
https://github.com/foundry-rs/foundry/releases/tag/v1.4.2
下载后解压的文件夹加入PATH

cd nft-marketplace
npm install
```

### Add Anvil to your metamask
```
# Add the following network to your metamask:
- Name: Anvil
- RPC URL: http://127.0.0.1:8545
- Chain ID: 31337
- Currency Symbol: ETH

# Add Anvil accounts to your Metamask
Private Keys
(0) 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 # This one
(9) 0x2a871d0798f97d79848a013d4936a73bf4cc922c825d33c1cf7073dff6d409c6 # This one

# Add private keys `0` and `9` to your Metamask, these will have NFTs already loaded when you run `pnpm anvil` later. 
```

## Docker .env(./marketplaceIndexer/.env)
```
# working with a postgres DB
DATABASE_URL=postgresql://postgres:rindexer@localhost:5440/postgres
POSTGRES_PASSWORD=rindexer
```

## Running the Application
```bash
# components
- Local Ethereum blockchain (anvil)
- Blockchain indexer
- Next.js application

# commands
pnpm anvil
pnpm indexer
pnpm run dev

# add NFT
In your Metamask now, select account 0 which you imported from the step above, and add the following NFT with tokenID 0:
0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0
You should see the NFT in your metamask. Note: This will only work while `pnpm anvil` is running!
```

## Database Reset
```bash
# stop the indexer, remove the volume, and restart it
pnpm run reset-indexer
```

## Features
- NFT Minting: Create new NFTs with the CakeNFT contract
- NFT Listing: List your NFTs for sale on the marketplace
- NFT Buying: Purchase NFTs that others have listed
- Recently Listed NFTs: View the most recent NFTs available for purchase
- Address Compliance: Integrated with Circle's compliance API to screen addresses
- Wallet Integration: Connect with MetaMask, Rainbow, and other wallets via WalletConnect

## Addresses for testing
- usdc: "0x5FbDB2315678afecb367f032d93F642f64180aa3"
- nftMarketplace: "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512"
- cakeNft: "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0"
- moodNft: "0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9"