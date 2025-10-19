const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("MyCoinModule", (m) => {
    const initialOwner = ""
    const myCoin = m.contract(initialOwner);
    return { myCoin };
});