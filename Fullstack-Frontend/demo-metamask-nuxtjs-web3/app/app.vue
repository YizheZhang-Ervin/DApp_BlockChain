<!-- <template>
  <div>
    <NuxtRouteAnnouncer />
    <NuxtWelcome />
  </div>
</template> -->

<template>
  <div class="container mx-auto p-8">
    <Metamask @connect="initWeb3" class="mb-4" />

    <div v-if="errorMessage" class="text-red-600 italic mb-4">
      {{ errorMessage }}
    </div>

    <div v-if="web3.coinbase" class="bg-gray-100 p-6 rounded-md shadow-md">
      <h3 class="text-xl font-semibold mb-2">Account Details</h3>
      <ul class="list-disc list-inside space-y-1">
        <li>Network: {{ web3.networkId }}</li>
        <li>Address: {{ web3.coinbase }}</li>
        <li>Balance: {{ web3.balance }}</li>
      </ul>

      <Deposit @submit="deposit" class="mt-6" />
    </div>
  </div>
</template>
<script>
import Web3 from "web3";
import Deposit from "./components/Deposit.vue";
import Metamask from "./components/Metamask.vue";
import { useMainStore } from "./store";

export default {
  name: "Homepage",
  data() {
    return {
      errorMessage: "",
    };
  },
  components: { Deposit, Metamask },
  computed: {
    web3() {
      const mainStore = useMainStore();
      return mainStore.getInstance;
    },
  },
  methods: {
    async initWeb3() {
      // Check for web3 provider
      if (typeof window.ethereum !== "undefined") {
        try {
          await window.ethereum.send("eth_requestAccounts");
          const instance = new Web3(window.ethereum);
          // Get necessary info on your node
          const networkId = await instance.eth.net.getId();
          const coinbase = await instance.eth.getCoinbase();
          const balance = await instance.eth.getBalance(coinbase);
          // Save it to store
          const mainStore = useMainStore();
          mainStore.registerWeb3Instance({
            networkId,
            coinbase,
            balance,
          });
          this.errorMessage = "";
        } catch (error) {
          // User denied account access
          console.error("User denied web3 access", error);
          this.errorMessage =
            "Please connect to your Ethereum address on Metamask before connecting to this website";
          return;
        }
      }
      // No web3 provider
      else {
        console.error("No web3 provider detected");
        this.errorMessage =
          "No web3 provider detected. Did you install the Metamask extension on this browser?";
        return;
      }
    },

    async deposit(amount, destinationAddress) {
      console.log("Deposit being executed", amount, destinationAddress);
      const web3 = new Web3(window.ethereum);
      try {
        const transactions = await web3.eth.sendTransaction({
          from: this.web3.coinbase,
          to: destinationAddress,
          value: web3.utils.toWei(amount, "ether"),
        });
      } catch (error) {
        console.error(error);
        this.errorMessage = error.message;
      }
    },
  },
};
</script>

