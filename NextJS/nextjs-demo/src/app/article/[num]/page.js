'use client'
import { useState, useEffect } from
    "react"
import React from 'react'

export default function ArticleNumMain({ params }) {
    // 状态
    const [count, setCount] = useState(0)
    const [post, setPost] = useState(null)
    // 调用后端获取数据
    const fetchData = async () => {
        console.log("trigger fetch")
        // 直接外呼
        // const res = await fetch("http://xx.yy.zz.aa:3000/api/check")
        // 调用本地api
        const res = await fetch("http://localhost:3000/api/externalCall")
        const data = await res.json()
        // 存入state
        setPost(data)
    }

    // 渲染后调用，每次count变更时调用
    useEffect(() => {
        fetchData()
        console.log([count, post])
    }, [count])

    return (
        <div>
            {/* url路径传值 */}
            <div>当前num是：{React.use(params).num}</div>
            {/* state值 */}
            <div>Count: {count}</div>
            {/* state触发变量变更 */}
            <button onClick={() => setCount(count + 1)}>+1</button>
            {/* state值 */}
            <p>{post?.result}</p >
        </div>
    )
}