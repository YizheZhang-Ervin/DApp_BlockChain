# SimpleStorage Commands
```sh
# 本地测试链
anvil

# 编译合约
forge compile

# 部署合约
forge create SimpleStorage --private-key <PRIVATE_KEY>
forge create SimpleStorage --private-key <PRIVATE_KEY> --rpc-url <ALCHEMY_URL>

# 脚本方式部署
forge script script/DeploySimpleStorage.s.sol --private-key <PRIVATE_KEY> --rpc-url <ALCHEMY_URL>

# 私钥加密方式部署
cast wallet import defaultKey --interactive
cast wallet list
forge script script/DeploySimpleStorage.s.sol --rpc-url <ALCHEMY_URL> --account defaultKey --sender xxx

# 本地部署zksync
npx zksync-cli dev config
npx zksync-cli dev start

# 本地zksync部署合约
forge create src/SimpleStorage.sol:SimpleStorage --rpc-url  http://127.0.0.1:8011 --private-key xxx --legacy --zksync
forge script script/DeploySimpleStorage.s.sol --private-key xxx --rpc-url http://127.0.0.1:8011 --legacy --zksync --broadcast
```