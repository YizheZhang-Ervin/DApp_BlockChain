const MyToken = artifacts.require("MyToken.sol")
const Exchange = artifacts.require("Exchange.sol")
// 40个0
const ETHER_ADDRESS = '0x0000000000000000000000000000000000'

const fromWei = (bn) => {
    return web3.utils.fromWei(bn, "ether")
}
const toWei = (num) => {
    return web3.utils.toWei(num.toString(), "ether")
}

const wait = (seconds) => {
    const milliseconds = seconds * 1000
    return new Promise((resolve) => setTimeout(resolve, milliseconds))
}

module.exports = async function (callback) {
    try {
        const mt = await MyToken().deployed()
        const ex = await Exchange.deployed()
        const accounts = await web3.eth.getAccounts()

        // 给第账号1转100000
        await mt.transfer(accounts[1], toWei(100000), { from: accounts[0] })

        // 账号0交易所存入100ether
        await ex.depositEther({ from: accounts[0], value: toWei(100) })
        let res1 = await ex.tokens(ETHER_ADDRESS, accounts[0])
        console.log(fromWei(res1))
        // 账号0交易所存100000token
        await mt.approve(ex.address, toWei(100000), { from: accounts[0] })
        await ex.depositToken(mt.address, toWei(100000), { from: accounts[0] })
        let res2 = await ex.tokens(mt.address, accounts[0])
        console.log(fromWei(res2))

        // 账号1交易所存入50ether
        await ex.depositEther({ from: accounts[1], value: toWei(50) })
        let res3 = await ex.tokens(ETHER_ADDRESS, accounts[1])
        console.log(fromWei(res3))
        // 账号1交易所存50000token
        await mt.approve(ex.address, toWei(50000), { from: accounts[1] })
        await ex.depositToken(mt.address, toWei(50000), { from: accounts[1] })
        let res4 = await ex.tokens(mt.address, accounts[1])
        console.log(fromWei(res4))

        // 订单
        let orderId = 0;
        let res;
        // 创建订单
        res = await ex.makeOrder(mt.address, toWei(1000), ETHER_ADDRESS, toWei(0.1), { from: accounts[0] });
        orderId = res.logs[0].args.id;
        await wait(1)
        // 取消订单
        res = await ex.makeOrder(mt.address, toWei(2000), ETHER_ADDRESS, toWei(0.2), { from: accounts[0] });
        orderId = res.logs[0].args.id;
        await ex.cancelOrder(orderId, { from: accounts[0] })
        await wait(1)
        // 完成订单
        res = await ex.makeOrder(mt.address, toWei(3000), ETHER_ADDRESS, toWei(0.3), { from: accounts[0] });
        orderId = res.logs[0].args.id;
        await ex.fillOrder(orderId, { from: accounts[1] })

        let ret1 = fromWei(await exchange.tokens(mt.address, accounts[0]))
        let ret2 = fromWei(await exchange.tokens(ETHER_ADDRESS, accounts[0]))
        let ret3 = fromWei(await exchange.tokens(mt.address, accounts[1]))
        let ret4 = fromWei(await exchange.tokens(ETHER_ADDRESS, accounts[1]))
        console.log(`${ret1}\n${ret2}\n${ret3}\n${ret4}`)
        callback()
    } catch (error) {
        console.log(error)
    }
}