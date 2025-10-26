# RWA

## RWA
```sh
# RWA构成
## 1）发行人（用RealEstateToken）
contract Issuer is FunctionsClient, FunctionsSource, OwnerIsCreator
## 2）房地产代币
contract RealEstateToken is CrossChainBurnAndMintERC1155, RealEstatePriceDetails
## 2-1）ERC1155跨链销毁和铸造
contract CrossChainBurnAndMintERC1155 is ERC1155Core, IAny2EVMMessageReceiver, ReentrancyGuard, Withdraw
## 2-2）房地产价格细节
contract RealEstatePriceDetails is FunctionsClient, FunctionsSource, OwnerIsCreator
## 2-1-1）代币协议
contract ERC1155Core is ERC1155Supply, OwnerIsCreator
## 2-1-2）取钱
contract Withdraw is OwnerIsCreator
## 1-1）及 2-2-1）链下函数源
abstract contract FunctionsSource

# RWA应用
## 英式拍卖
contract EnglishAuction is IERC1155Receiver, ReentrancyGuard
## 借出借入
contract RwaLending is IERC1155Receiver, OwnerIsCreator, ReentrancyGuard
```

## Foundry Scripts
```sh
# Forge/Cast/Anvil/Chisel

# 1）Forge
forge init
forge install OpenZeppelin/openzeppelin-contracts
forge build
forge test
$ forge fmt
$ forge --help
## Gas Snapshots
$ forge snapshot 
## Deploy
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>

# 2）Anvil
$ anvil
$ anvil --help

# 3）Cast
$ cast <subcommand>
$ cast --help
```