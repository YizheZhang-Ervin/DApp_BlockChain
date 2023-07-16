const myToken = artifacts.require("MyToken.sol")
const fromWei = (bn) => {
    return web3.utils.fromWei(bn, "ether")
}
const toWei = (num) => {
    return web3.utils.toWei(num.toString(), "ether")
}
module.exports = async function (callback) {
    const mt = await myToken().deployed()
    let res1 = await mt.balanceOf("账号公钥地址");
    console.log(fromWei(res1))
    await mt.transfer("to地址", "转钱数", { from: "from地址" })
    let res2 = await mt.balanceOf("to地址")
    console.log(res2)
    callback()
}