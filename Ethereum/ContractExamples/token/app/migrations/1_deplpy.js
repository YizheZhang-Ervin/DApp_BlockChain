const MyToken = artifacts.require("MyToken.sol");
const Exchange = artifacts.require("Exchange.sol");

module.exports = async function (deployer) {
    const accounts = await web3.eth.getAccounts()
    await deployer.deploy(MyToken);
    await deployer.deploy(Exchange, accounts[0], 10);
}