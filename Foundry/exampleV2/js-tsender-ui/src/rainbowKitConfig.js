"use client"

import { getDefaultConfig } from "@rainbow-me/rainbowkit"
import { arbitrum, base, mainnet, optimism, anvil, zksync, sepolia } from "wagmi/chains"

// rainbowkit的配置
export default getDefaultConfig({
    appName: "nextjs-wagmi-demo",
    projectId: process.env.NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID,
    chains: [mainnet, optimism, arbitrum, base, zksync, sepolia, anvil],
    ssr: false,
})
