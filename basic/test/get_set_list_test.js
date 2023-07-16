const GetSetList = artifacts.require("GetSetList.sol");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("GetSetList", function (/* accounts */) {
  it("should assert true", async function () {
    const gs = await GetSetList.deployed();

    await gs.addList("abc", 100)
    let res = await gs.getList()
    console.log(res)
    console.log(await gs.A(0))

    return assert.isTrue(true);
  });
});
