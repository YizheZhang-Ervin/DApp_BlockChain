import { defineWalletSetup } from '@synthetixio/synpress'
import { MetaMask } from '@synthetixio/synpress/playwright'

// 初始化钱包
const SEED_PHRASE = 'test test test test test test test test test test test junk'
const PASSWORD = 'SynpressIsAwesomeNow!!!'

export default defineWalletSetup(PASSWORD, async (context, walletPage) => {
    const metamask = new MetaMask(context, walletPage, PASSWORD)

    await metamask.importWallet(SEED_PHRASE)
})
