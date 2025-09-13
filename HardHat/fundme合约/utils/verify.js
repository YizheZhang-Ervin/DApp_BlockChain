// 验证已部署的合约(需要用到etherscan的apikey)
async function verify(address, args) {
  await hre.run("verify:verify", {
    address: address,
    constructorArguments: args,
  });
}


module.exports = { verify } 