const Contracts = artifacts.require("GetSetList.sol")

module.exports = async function (callback) {
    const gs = await Contracts.deployed()
    await gs.addList("abc", 100)
    let res = await gs.getList()
    console.log(res)
    console.log(await gs.A(0))
    callback()
}