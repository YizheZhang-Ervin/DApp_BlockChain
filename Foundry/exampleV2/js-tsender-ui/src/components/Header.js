"use client"

import { ConnectButton } from "@rainbow-me/rainbowkit"
import Image from "next/image"

// 页头
export default function Header() {
    return (
        <nav className="px-8 py-4.5 border-b-[1px] border-zinc-100 flex flex-row justify-between items-center bg-white xl:min-h-[77px]">
            <div className="flex items-center gap-2.5 md:gap-6">
                <a href="/" className="flex items-center gap-1 text-zinc-800">
                    <Image src="/favicon.ico" alt="TSender" width={36} height={36} />
                    <h1 className="font-bold text-2xl hidden md:block">Web3 Demo🐎</h1>
                </a>
            </div>
            <h3 className="italic text-left hidden text-zinc-500 lg:block">
                nextjs + with + wagmi + viem + rainbowkit
            </h3>
            <div className="flex items-center gap-4">
                {/* rainbowkit提供的连接钱包的按钮 */}
                <ConnectButton />
            </div>
        </nav>
    )
}
