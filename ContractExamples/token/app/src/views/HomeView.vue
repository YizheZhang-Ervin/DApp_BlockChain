<template>
  <main>
    <TheWelcome />
    <div>{{ displayTxt }}</div>
    <div>{{ displayTxt2 }}</div>
  </main>
</template>

<script>
import TheWelcome from '../components/TheWelcome.vue'
import Web3 from 'web3'
import tokenJson from './build/contracts/MyToken.json'
import exchangeJson from './build/contracts/Exchange.json'
import { useBalanceStore } from '@/stores/balance'
import { useOrderStore } from '@/stores/order'
import moment from 'moment'

export default {
  data() {
    return {
      displayTxt: '',
      displayTxt2: ''
    }
  },
  methods: {
    // 整体初始化
    async start() {
      // 获取连接后的合约
      const web = await this.initWeb()
      console.log(web)
      window.web = web
      // 获取资产信息
      const balancer = useBalanceStore()
      balancer.fetchBalanceData(web)
      this.displayTxt = `${this.convert(balancer.TokenWallet)}==${this.convert(
        balancer.TokenExchange
      )}==${this.convert(balancer.EtherWallet)}==${this.convert(balancer.EtherExchange)}`
      // 获取订单信息
      const orderer = useOrderStore()
      orderer.fetchAllOrderData(web)
      orderer.fetchCancelOrderData(web)
      orderer.fetchFillOrderData(web)
      this.displayTxt2 = `${orderer.CancelOrders}==${orderer.FillOrders}==${orderer.AllOrders}`
      // 监听
      web.exchange.events.Order({}, (error, event) => {
        orderer.fetchAllOrderData(web)
      })
      web.exchange.events.Cancel({}, (error, event) => {
        orderer.fetchCancelOrderData(web)
      })
      web.exchange.events.Trade({}, (error, event) => {
        orderer.fetchFillOrderData(web)
        balancer.fetchBalanceData(web)
      })
    },
    // 网络初始化
    async initWeb() {
      const web3 = new Web3(Web3.givenProvider || 'ws://localhost:8545')
      let accounts = await web3.eth.requestAccounts()
      console.log(accounts[0])
      const networkId = await web3.eth.net.getId()

      const tokenAbi = tokenJson.abi
      const tokenAddress = tokenJson.networks[networkId].addrerss
      const token = await new web3.eth.Contract(tokenAbi, tokenAddress)
      console.log(token)

      const exchangeAbi = exchangeJson.abi
      const exchangeAddress = exchangeJson.networks[networkId].addrerss
      const exchange = await new web3.eth.Contract(exchangeAbi, exchangeAddress)
      console.log(exchange)
      return { web3, account: accounts[0], token, exchange }
    },
    // 转换以太币
    convert(n) {
      if (!window.web || !n) return
      return window.web.web3.utils.fromWei(n, 'ether')
    },
    // 转换时间格式
    convertTime() {
      return moment(t * 1000).format('YYYY/MM/DD')
    },
    // 获取订单
    getRendererOrder(orderer, type) {
      if (!window.web) return []
      const account = window.web.account
      // 排除已经完成的/取消的订单
      let filterIds = [...orderer.CancelOrders, ...orderer.FillOrders].map((item) => item.id)
      let pendingOrders = orderer.AllOrders.filter((item) => !filterIds.includes(item.id))
      if (type == 1) {
        return pendingOrders.filter((item) => item.user === account)
      } else {
        return pendingOrders.filter((item) => item.user !== account)
      }
    },
    // 取消订单
    cancelOrder(item) {
      const { exchange, account } = window.web
      exchange.methods.cancelOrder(item.id).send({ from: account })
    },
    // 填充订单
    fillOrder(item) {
      const { exchange, account } = window.web
      exchange.methods.fillOrder(item.id).send({ from: account })
    }
  },
  mounted() {
    this.start()
  }
}
</script>