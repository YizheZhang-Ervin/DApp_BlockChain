<template>
  <div class="deposit-container p-8 rounded shadow-md bg-white">
    <h2 class="text-2xl font-semibold mb-4">Deposit</h2>

    <form
      @submit.prevent="$emit('submit', amount, destinationAddress)"
      class="space-y-4"
    >
      <div class="form-group">
        <label for="amount" class="block text-gray-700 font-medium mb-2"
          >Amount (USDT):</label
        >
        <input
          type="number"
          id="amount"
          v-model="amount"
          class="border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
          min="0"
          step="0.01"
          required
        />
      </div>

      <div class="form-group">
        <label for="address" class="block text-gray-700 font-medium mb-2"
          >Destination Address:</label
        >
        <input
          type="text"
          id="address"
          v-model="destinationAddress"
          class="border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
          required
        />
      </div>

      <button
        type="submit"
        class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline"
      >
        Deposit
      </button>
    </form>
  </div>
</template>

<script>
export default {
  data() {
    return {
      amount: "",
      destinationAddress: ""
    };
  },
  methods: {}
};
</script>
