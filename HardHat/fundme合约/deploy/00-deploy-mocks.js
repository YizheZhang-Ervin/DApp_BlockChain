const { DECIMAL, INITIAL_ANSWER, devlopmentChains } = require("../helper-hardhat-config")

module.exports = async ({ getNamedAccounts, deployments }) => {

    // 如果是部署在本地网络
    if (devlopmentChains.includes(network.name)) {
        const { firstAccount } = await getNamedAccounts()
        const { deploy } = deployments
        // 模拟喂价合约（两个构造函数入参），在contracts/mocks下导入
        await deploy("MockV3Aggregator", {
            from: firstAccount,
            args: [DECIMAL, INITIAL_ANSWER],
            log: true
        })
    } else {
        console.log("environment is not local, mock contract depployment is skipped")
    }
}

module.exports.tags = ["all", "mock"]