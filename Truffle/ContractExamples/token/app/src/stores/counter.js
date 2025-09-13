import { ref, computed } from 'vue'
import { defineStore } from 'pinia'

export const useCounterStore = defineStore('counter', () => {
  const count = ref(0)
  const doubleCount = computed(() => count.value * 2)
  function increment() {
    count.value++
  }

  return { count, doubleCount, increment }
})

// 使用
// import { useCounterStore } from '@/stores/counter'

// export default {
//   setup() {
//     const counter = useCounterStore()

//     counter.count++
//     // 带自动补全 ✨
//     counter.$patch({ count: counter.count + 1 })
//     // 或使用 action 代替
//     counter.increment()
//   },
// }