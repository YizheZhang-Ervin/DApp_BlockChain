export default function Content({ data, children }) {
    return (
        <div>
            {/* 元素属性传值 */}
            <div>{data}</div>
            {/* 元素内部内容传值 */}
            <div>{children}</div>
        </div>
    )
}
