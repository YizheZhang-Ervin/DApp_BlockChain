const GetSet = artifacts.require("GetSet.sol");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("GetSet", function (/* accounts */) {
  it("should assert true", async function () {
    const gs = await GetSet.deployed();

    await gs.setData("abc", 100)
    let res = await gs.getData()
    console.log(res)
    console.log(await gs.age())

    return assert.isTrue(true);
  });
});
