import { defineStore } from 'pinia'

const ETHER_ADDRESS = '0x0000000000000000000000000000000000'
export const useBalanceStore = defineStore('balance', {
    state: () => ({
        TokenWallet: "0",
        TokenExchange: "0",
        EtherWallet: "0",
        EtherExchange: "0"
    }),
    actions: {
        setTokenWallet(val) {
            this.TokenWallet = val
        },
        setTokenExchange(val) {
            this.TokenExchange = val
        },
        setEtherWallet(val) {
            this.EtherWallet = val
        },
        setEtherExchange(val) {
            this.EtherExchange = val
        },
        async fetchBalanceData(data) {
            const { web3, account, token, exchange } = data
            // 获取钱包的token
            const tWallet = await token.methods.balanceOf(account).call()
            this.setTokenWallet(tWallet)
            // 获取交易所的token
            const tExchange = await exchange.methods.balanceOf(token.options.address, account).call()
            this.setTokenExchange(tExchange)
            // 获取钱包的ether
            const eWallet = await web3.eth.getBalance(account)
            this.setTokenWallet(eWallet)
            // 获取交易所的ether
            const eExchange = await exchange.methods.balanceOf(ETHER_ADDRESS, account).call()
            this.setTokenExchange(eExchange)
        }
    }
})

// 使用
// import { useBalanceStore } from '@/stores/balance'

// export default {
//   setup() {
//     const balancer = useBalanceStore()
//     balancer.setTokenWallet("1")
//   },
// }