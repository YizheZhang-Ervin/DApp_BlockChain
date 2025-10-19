# include .env file and export its env vars
#(-include to ignore error if it does not exist)
-include .env

all:clean remove install update solc build

# Install proper solc version.
solc:; nix-env -f https://github.com/dapphub/dapptools/archive/master.tar.gz -iA solc-static-versions.solc_0_8_13

# Clean the repo
clean :; forge clean

# Remove modules
remove :: r -rf .gitmodules &&rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "rm" && git push

# Install the Modules
install :;
	forge install 0penZeppelin/openzeppelin-contracts

# Update Dependencies
update:;forge update

# Builds
build :;forge clean && forge build --optimize --optimize-runs 1000000

setup-yarn:
	yarn

local-node:setup-yarn
	yarn hardhat node

deploy:
	forge create StakeContract --private-key ${PRIVATE KEY} # --rpc-url