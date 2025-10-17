// 格式化token数量
export function formatTokenAmount(weiAmount, decimals) {
    const tokenAmount = weiAmount / Math.pow(10, decimals)
    return tokenAmount.toLocaleString(undefined, {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2,
    })
}
