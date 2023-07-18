import { defineStore } from 'pinia'

export const useOrderStore = defineStore('order', {
    state: () => ({
        CancelOrders: [],
        FillOrders: [],
        AllOrders: [],
    }),
    actions: {
        setCancelOrders(val) {
            this.CancelOrders = val
        },
        setFillOrders(val) {
            this.FillOrders = val
        },
        setAllOrders(val) {
            this.AllOrders = val
        },
        async fetchAllOrderData(data) {
            const { exchange } = data
            // 获取单个order
            // const orders = await exchange.methods.orders(xx).call()
            // 获取allOrder
            const result = await exchange.getPastEvents("Order", {
                fromBlock: 0, toBlock: "latest"
            })
            const allOrders = result.map(item => item.returnValues)
            this.setAllOrders(allOrders)

        },
        async fetchCancelOrderData(data) {
            const { exchange } = data
            // 获取cancelOrder
            const result = await exchange.getPastEvents("Cancel", {
                fromBlock: 0, toBlock: "latest"
            })
            const cancelOrders = result.map(item => item.returnValues)
            this.setCancelOrders(cancelOrders)
        },
        async fetchFillOrderData(data) {
            const { exchange } = data
            // 获取fillOrder
            const result = await exchange.getPastEvents("Trade", {
                fromBlock: 0, toBlock: "latest"
            })
            const fillOrders = result.map(item => item.returnValues)
            this.setFillOrders(fillOrders)
        },
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