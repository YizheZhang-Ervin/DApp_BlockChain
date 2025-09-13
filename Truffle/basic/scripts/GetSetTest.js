const Contracts = artifacts.require("GetSet.sol")

module.exports = async function (callback) {
    const gs = await Contracts.deployed()
    await gs.setData("abc", 100)
    let res = await gs.getData()
    console.log(res)
    console.log(await gs.age())
    callback()
}