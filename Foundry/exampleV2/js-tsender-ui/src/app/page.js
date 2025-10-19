"use client"

import dynamic from "next/dynamic"

// 导入组件
const HomeContent = dynamic(() => import("@/components/HomeContent"), {
  ssr: false,
})

// layout的children的内容
export default function Home() {
  return <HomeContent />
}