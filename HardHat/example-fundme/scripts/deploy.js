// import the ethers from hardhat
// write a main function
// call the main function

const { ethers } = require("hardhat");

// 部署合约（本地测试链）
async function main() {
  const fundMeFacotry = await ethers.getContractFactory("FundMe");
  console.log("deploiying the contract...");

  const fundMe = await fundMeFacotry.deploy(10);
  await fundMe.waitForDeployment();
  console.log(`contract fundme is deployed successfully at addree ${fundMe.target}`)

  if (hre.network.config.chainId == 11155111 && process.env.ETHERSCAN_API_KEY) {
    console.log("wait for 3 confirmations")
    await fundMe.deploymentTransaction().wait(3)
    console.log("verifying contract on etherscan...")
    // 验证合约部署
    await verify(fundMe.target, [10])
  } else {
    console.log("skipping verification")
  }

  // 捐款
  console.log("fund the contract...")
  const fundTx = await fundMe.fund({
    value: ethers.parseEther("0.1")
  })
  await fundTx.wait()
  console.log("funded the contract")

  // 查询合约余额
  const fundMeBalance = await ethers.provider.getBalance(fundMe.target);
  console.log(`balance of the fundme is ${fundMeBalance}`)

  // 获取账号
  const [firstAccount, secondAccount] = await ethers.getSigners();
  console.log(`first account address is ${firstAccount.address}`)
  console.log(`second account address is ${secondAccount.address}`)

  // 获取捐款人
  console.log("fetching the funds of the first account...")
  const fundsOfFirstAccount = await fundMe.listOfFunders(firstAccount.address);
  console.log(`Current funds of first account is ${fundsOfFirstAccount}`)

  console.log("fund the contract on behalf of the second account...")
  const secondFundTx = await fundMe.connect(secondAccount).fund({
    value: ethers.parseEther("0.1")
  })
  await secondFundTx.wait()

  console.log("fetching the funds of the second account...")
  const fundsOfSecondAccount = await fundMe.listOfFunders(secondAccount.address);
  console.log(`Current funds of second account is ${fundsOfSecondAccount}`)
}

// 验证合约
async function verify(address, args) {
  await hre.run("verify:verify", {
    address: address,
    constructorArguments: args,
  });
}

// 入口
main().then().catch((error) => {
  console.log(`error is ${error}`)
  process.exit(1)
})