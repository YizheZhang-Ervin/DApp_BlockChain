const Contract1 = artifacts.require("GetSet.sol")
module.exports = function (deployer) {
    deployer.deploy(Contract1)
}