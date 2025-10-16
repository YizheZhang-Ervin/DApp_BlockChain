import Content from '../components/ArticleContent.js'
export default async function ArticleHomeMain() {
    // 请求后端
    let data = null
    const res = await fetch("http://localhost:3000/api/externalCall")
    data = await res.json()
    return (
        <div>
            {/* 子组件 */}
            <Content data="数据1">这是一篇文章1</Content>
            <Content data="数据2">文章2</Content>
            {/* 显示变量 */}
            <div>{data?.result}</div>
        </div>
    )
}
