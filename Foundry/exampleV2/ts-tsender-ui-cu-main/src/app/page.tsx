"use client"

import dynamic from "next/dynamic"

const HomeContent = dynamic(() => import("@/components/HomeContent"), {
    ssr: false,
})

export default function Home() {
    return <HomeContent />
}

// // Why do we need the dynamic import here instead of just hosting the HomeContent here?
// This is happening because of how wagmi (and other Web3 libraries) interact with Next.js's server-side rendering (SSR). Let me explain why:

// By default, Next.js pages are server-side rendered, meaning the initial HTML is generated on the server.
// wagmi hooks (like useAccount, useConnect, etc.) need access to the browser's window object and Web3 functionality, which only exists on the client side. When Next.js tries to render these components on the server, it can't access these browser-specific features.
// When the page loads in the browser, React tries to "hydrate" the server-rendered HTML with the client-side JavaScript. However, the state of your Web3 components on the client side (with actual wallet connections, etc.) doesn't match the server-rendered version (which couldn't access Web3 features), causing hydration errors.

// Your current solution using dynamic with ssr: false works because it:

// Skips server-side rendering for the component entirely
// Only loads and renders the component on the client side
// Prevents any hydration mismatches since there's no server-rendered content to hydrate

// You could alternatively keep the components in page.tsx if you:

// Use React's useEffect to handle any Web3 interactions
// Handle loading states appropriately
// Use wagmi's useMounted hook

// But the dynamic import approach is cleaner and more reliable for Web3 components. It's a common pattern in Next.js Web3 applications.

// Example:

// // Without dynamic - Still processes import on server
// 'use client'
// import HomeContent from '@/components/HomeContent'  // ← Server still sees this
// export default function Page() {
//   return <HomeContent />  // ← Attempts initial server render
// }

// // With dynamic - Server completely ignores the component
// 'use client'
// const HomeContent = dynamic(
//   () => import('@/components/HomeContent'),
//   { ssr: false }
// )  // ← Server skips this entirely
// export default function Page() {
//   return <HomeContent />  // ← Only renders on client
// }
