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

module.exports = async function (callback) {
    const mt = await MyToken().deployed()
    const ex = await Exchange.deployed()
    const accounts = await web3.eth.getAccounts()

    // await ex.withdrawEther(toWei(5), { from: accounts[0] })
    // let res = await ex.tokens(ETHER_ADDRESS, accounts[0])
    // console.log(fromWei(res))

    // 取款
    await ex.withdrawToken(mt.address, toWei(100000), { from: accounts[0] })
    let res = await ex.tokens(mt.address, accounts[0])
    console.log(fromWei(res))
    callback()
}