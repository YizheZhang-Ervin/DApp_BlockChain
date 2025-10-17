"use client"

import { useState } from "react"
import AirdropForm from "@/components/AirdropForm"
import { useAccount } from "wagmi"

// 主体内容
export default function HomeContent() {
    const [isUnsafeMode, setIsUnsafeMode] = useState(false)
    const { isConnected } = useAccount()

    return (
        <main>
            {!isConnected ? (
                // 非连接状态
                <div className="flex items-center justify-center">
                    <h2 className="text-xl font-medium text-zinc-600">
                        Please connect a wallet...
                    </h2>
                </div>
            ) : (
                // 连接状态
                <div className="flex items-center justify-center p-4 md:p-6 xl:p-8">
                    {/* 操作页 */}
                    <AirdropForm isUnsafeMode={isUnsafeMode} onModeChange={setIsUnsafeMode} />
                </div>
            )}
        </main>
    )
}
