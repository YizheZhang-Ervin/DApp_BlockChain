import "./globals.css"
import Header from "@/components/Header"
import { Providers } from "./providers"

// 网页标题
export const metadata = {
  title: "Web3 Demo",
  description: "Hyper gas-optimized bulk ERC20 token transfer",
}

export default function RootLayout(props) {
  return (
    <html lang="en">
      <head>
        <link rel="icon" href="/favicon.ico" sizes="any" />
      </head>
      <body className="bg-zinc-50">
        {/*  wagmi，rainbowkit等导入 */}
        <Providers>
          {/* 页头 */}
          <Header />
          {/* 中间主体内容 */}
          {props.children}
        </Providers>
      </body>
    </html>
  )
}
