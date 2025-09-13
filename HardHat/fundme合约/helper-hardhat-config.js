// 模拟预言机喂价的参数
const DECIMAL = 8
const INITIAL_ANSWER = 300000000000
// 开发测试链
const devlopmentChains = ["hardhat", "local"]
// 合约参数
const LOCK_TIME = 180
// 等待5个区块，代表交易完成
const CONFIRMATIONS = 5
// 喂价测试链地址
const networkConfig = {
    // 以太坊
    11155111: {
        ethUsdDataFeed: "0x694AA1769357215DE4FAC081bf1f309aDC325306"
    },
    // BNB
    97: {
        ethUsdDataFeed: "0x143db3CEEfbdfe5631aDD3E50f7614B6ba708BA7"
    }
}

module.exports = {
    DECIMAL,
    INITIAL_ANSWER,
    devlopmentChains,
    networkConfig,
    LOCK_TIME,
    CONFIRMATIONS
}