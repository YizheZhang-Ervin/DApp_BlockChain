<template>
  <button
    @click="$emit('connect')"
    class="group flex flex-row items-center justify-center p-3 rounded-md border-2 border-blue-600 text-blue-600 font-semibold hover:text-white hover:bg-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-500 transition duration-300 ease-in-out transform hover:scale-105"
    aria-label="Connect to Metamask"
  >
    <img
      src="https://upload.wikimedia.org/wikipedia/commons/3/36/MetaMask_Fox.svg"
      alt="Metamask"
      class="h-5 mr-2 group-hover:brightness-150 transition duration-300"
    />
    Connect to Metamask
  </button>
</template>

<script>
export default {
  name: "Metamask",
  data() {
    return {};
  },
  computed: {},
  methods: {}
};
</script>
