# NFT Marketplace 

1. Indexing (rindexer)
2. Fleek CLI
4. Compliance Engine
5. USDC payment
6. Gashawk

## .env.local
```
NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID=your_project_id
GRAPHQL_API_URL=http://localhost:3001/graphql
ENABLE_COMPLIANCE_CHECK=false
CIRCLE_API_KEY=TEST_API_KEY
```

## Setup

```bash
cd nft-marketplace
pnpm install
```

## Docker .env(./marketplaceIndexer/.env)
```
DATABASE_URL=postgresql://postgres:rindexer@localhost:5440/postgres
POSTGRES_PASSWORD=rindexer
```

## Running the Application
```bash
pnpm anvil
pnpm indexer
pnpm run dev
```

## Database Reset
```bash
pnpm run reset-indexer
```

## Features

- NFT Minting: Create new NFTs with the CakeNFT contract
- NFT Listing: List your NFTs for sale on the marketplace
- NFT Buying: Purchase NFTs that others have listed
- Recently Listed NFTs: View the most recent NFTs available for purchase
- Address Compliance: Integrated with Circle's compliance API to screen addresses
- Wallet Integration: Connect with MetaMask, Rainbow, and other wallets via WalletConnect