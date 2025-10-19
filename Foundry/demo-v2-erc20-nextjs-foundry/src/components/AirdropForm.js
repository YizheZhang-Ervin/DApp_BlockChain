"use client"

import { useState, useMemo, useEffect } from "react"
import { RiAlertFill, RiInformationLine } from "react-icons/ri"
import {
    useChainId,
    useWriteContract,
    useAccount,
    useWaitForTransactionReceipt,
    useReadContracts,
} from "wagmi"
import { chainsToTSender, tsenderAbi, erc20Abi } from "@/constants"
import { readContract } from "@wagmi/core"
import { useConfig } from "wagmi"
import { CgSpinner } from "react-icons/cg"
import { calculateTotal, formatTokenAmount } from "@/utils"
import { InputForm } from "./ui/InputField"
import { Tabs, TabsList, TabsTrigger } from "./ui/Tabs"
import { waitForTransactionReceipt } from "@wagmi/core"

export default function AirdropForm({ isUnsafeMode, onModeChange }) {
    // token合约的地址
    const [tokenAddress, setTokenAddress] = useState("")
    // 接收方
    const [recipients, setRecipients] = useState("")
    // 输入的数额
    const [amounts, setAmounts] = useState("")
    // 配置
    const config = useConfig()
    // 账号
    const account = useAccount()
    // 链id
    const chainId = useChainId()
    // 读合约
    const { data: tokenData } = useReadContracts({
        contracts: [
            {
                abi: erc20Abi,
                address: `0x${Buffer.from(tokenAddress).toString('hex')}`,
                functionName: "decimals",
            },
            {
                abi: erc20Abi,
                address: `0x${Buffer.from(tokenAddress).toString('hex')}`,
                functionName: "name",
            },
            {
                abi: erc20Abi,
                address: `0x${Buffer.from(tokenAddress).toString('hex')}`,
                functionName: "balanceOf",
                args: [account.address],
            },
        ],
    })
    // 有足够token
    const [hasEnoughTokens, setHasEnoughTokens] = useState(true)
    // 写合约
    const { data: hash, isPending, error, writeContractAsync } = useWriteContract()
    // 等待交易回执
    const { isLoading: isConfirming, isSuccess: isConfirmed, isError } = useWaitForTransactionReceipt({
        confirmations: 1,
        hash,
    })
    // 缓存计算值
    const total = useMemo(() => calculateTotal(amounts), [amounts])
    // 处理提交值
    async function handleSubmit() {
        const contractType = isUnsafeMode ? "no_check" : "tsender"
        // 获取账号地址
        const tSenderAddress = chainsToTSender[chainId][contractType]
        // 获取账号对应允许的数额
        const result = await getApprovedAmount(tSenderAddress)
        // 允许的数额足够
        if (result < total) {
            // 写入合约：允许
            const approvalHash = await writeContractAsync({
                abi: erc20Abi,
                address: `0x${Buffer.from(tokenAddress).toString('hex')}`,
                functionName: "approve",
                args: [`0x${Buffer.from(tSenderAddress).toString('hex')}`, BigInt(total)],
            })
            // 等待回执
            const approvalReceipt = await waitForTransactionReceipt(config, {
                hash: approvalHash,
            })
            // 打印回执结果
            console.log("Approval confirmed:", approvalReceipt)
            // 写入合约：airdrop ERC20
            await writeContractAsync({
                abi: tsenderAbi,
                address: `0x${Buffer.from(tSenderAddress).toString('hex')}`,
                functionName: "airdropERC20",
                args: [
                    tokenAddress,
                    // Comma or new line separated
                    recipients.split(/[,\n]+/).map(addr => addr.trim()).filter(addr => addr !== ''),
                    amounts.split(/[,\n]+/).map(amt => amt.trim()).filter(amt => amt !== ''),
                    BigInt(total),
                ],
            })
        } else {
            // 允许的数额不够
            // 写入合约：airdropERC20
            await writeContractAsync({
                abi: tsenderAbi,
                address: `0x${Buffer.from(tSenderAddress).toString('hex')}`,
                functionName: "airdropERC20",
                args: [
                    tokenAddress,
                    // Comma or new line separated
                    recipients.split(/[,\n]+/).map(addr => addr.trim()).filter(addr => addr !== ''),
                    amounts.split(/[,\n]+/).map(amt => amt.trim()).filter(amt => amt !== ''),
                    BigInt(total),
                ],
            },)
        }

    }
    // 获取允许的额度
    async function getApprovedAmount(tSenderAddress) {
        if (!tSenderAddress) {
            alert("This chain only has the safer version!")
            return 0
        }
        // 读取合约
        const response = await readContract(config, {
            abi: erc20Abi,
            address: `0x${Buffer.from(tokenAddress).toString('hex')}`,
            functionName: "allowance",
            args: [account.address, `0x${Buffer.from(tSenderAddress).toString('hex')}`],
        })
        return response
    }

    // 获取按钮内容
    function getButtonContent() {
        // 挂起中
        if (isPending)
            return (
                <div className="flex items-center justify-center gap-2 w-full">
                    <CgSpinner className="animate-spin" size={20} />
                    <span>Confirming in wallet...</span>
                </div>
            )
        // 确认中
        if (isConfirming)
            return (
                <div className="flex items-center justify-center gap-2 w-full">
                    <CgSpinner className="animate-spin" size={20} />
                    <span>Waiting for transaction to be included...</span>
                </div>
            )
        // 发生错误
        if (error || isError) {
            console.log(error)
            return (
                <div className="flex items-center justify-center gap-2 w-full">
                    <span>Error, see console.</span>
                </div>
            )
        }
        // 已确认
        if (isConfirmed) {
            return "Transaction confirmed."
        }
        // 其他状态(已发送token)
        return isUnsafeMode ? "Send Tokens (Unsafe)" : "Send Tokens"
    }

    // 渲染页面完成后执行：从localstorage获取信息存入state
    useEffect(() => {
        // 从localstorage获取信息
        const savedTokenAddress = localStorage.getItem('tokenAddress')
        const savedRecipients = localStorage.getItem('recipients')
        const savedAmounts = localStorage.getItem('amounts')
        // 将信息存入state
        if (savedTokenAddress) setTokenAddress(savedTokenAddress)
        if (savedRecipients) setRecipients(savedRecipients)
        if (savedAmounts) setAmounts(savedAmounts)
    }, [])

    // 渲染页面完成后执行：token合约的地址 变化后存入localstorage
    useEffect(() => {
        // 从localstorage获取信息
        localStorage.setItem('tokenAddress', tokenAddress)
    }, [tokenAddress])

    // 渲染页面完成后执行：接收方变更后存入localstorage
    useEffect(() => {
        localStorage.setItem('recipients', recipients)
    }, [recipients])

    // 渲染页面完成后执行：数额变化后存入localstorage
    useEffect(() => {
        localStorage.setItem('amounts', amounts)
    }, [amounts])

    // 渲染页面完成后执行：token合约的地址/数额/合约变化后，计算是否有足够token
    useEffect(() => {
        // token合约的地址存在，金额>0，合约余额非空
        if (tokenAddress && total > 0 && tokenData?.[2]?.result !== undefined) {
            // 用户余额
            const userBalance = tokenData?.[2].result;
            // 设置有足够token的state
            setHasEnoughTokens(userBalance >= total);
        } else {
            setHasEnoughTokens(true);
        }
    }, [tokenAddress, total, tokenData]);

    // 页面内容
    return (
        <div
            className={`max-w-2xl min-w-full xl:min-w-lg w-full lg:mx-auto p-6 flex flex-col gap-6 bg-white rounded-xl ring-[4px] border-2 ${isUnsafeMode ? " border-red-500 ring-red-500/25" : " border-blue-500 ring-blue-500/25"}`}
        >
            <div className="flex items-center justify-between">
                <h2 className="text-xl font-semibold text-zinc-900">Transaction Area</h2>
                <Tabs defaultValue={"false"}>
                    <TabsList>
                        {/* 切换安全模式 */}
                        <TabsTrigger value={"false"} onClick={() => onModeChange(false)}>
                            Safe Mode
                        </TabsTrigger>
                        <TabsTrigger value={"true"} onClick={() => onModeChange(true)}>
                            Unsafe Mode
                        </TabsTrigger>
                    </TabsList>
                </Tabs>
            </div>

            <div className="space-y-6">
                {/* token合约地址 */}
                <InputForm
                    label="Token Address"
                    placeholder="0x"
                    value={tokenAddress}
                    onChange={e => setTokenAddress(e.target.value)}
                />
                {/* 接收方地址 */}
                <InputForm
                    label="Recipients (comma or new line separated)"
                    placeholder="0x123..., 0x456..."
                    value={recipients}
                    onChange={e => setRecipients(e.target.value)}
                    large={true}
                />
                {/* 交易数额 */}
                <InputForm
                    label="Amounts (wei; comma or new line separated)"
                    placeholder="100, 200, 300..."
                    value={amounts}
                    onChange={e => setAmounts(e.target.value)}
                    large={true}
                />
                {/* token相关细节 */}
                <div className="bg-white border border-zinc-300 rounded-lg p-4">
                    <h3 className="text-sm font-medium text-zinc-900 mb-3">Transaction Details</h3>
                    <div className="space-y-2">
                        <div className="flex justify-between items-center">
                            <span className="text-sm text-zinc-600">Token Name:</span>
                            <span className="font-mono text-zinc-900">
                                {tokenData?.[1]?.result}
                            </span>
                        </div>
                        <div className="flex justify-between items-center">
                            <span className="text-sm text-zinc-600">Amount (wei):</span>
                            <span className="font-mono text-zinc-900">{total}</span>
                        </div>
                        <div className="flex justify-between items-center">
                            <span className="text-sm text-zinc-600">Amount (tokens):</span>
                            <span className="font-mono text-zinc-900">
                                {formatTokenAmount(total, tokenData?.[0]?.result)}
                            </span>
                        </div>
                    </div>
                </div>
                {/* 非安全模式 */}
                {isUnsafeMode && (
                    // 显示警告
                    <div className="mb-4 p-4 bg-red-50 text-red-600 rounded-lg flex items-center justify-between">
                        <div className="flex items-center gap-3">
                            <RiAlertFill size={20} />
                            <span>
                                Using{" "}
                                <span className="font-medium underline underline-offset-2 decoration-2 decoration-red-300">
                                    unsafe
                                </span>{" "}
                                super gas optimized mode
                            </span>
                        </div>
                        <div className="relative group">
                            <RiInformationLine className="cursor-help w-5 h-5 opacity-45" />
                            <div className="absolute bottom-full left-1/2 -translate-x-1/2 mb-2 px-3 py-2 bg-zinc-900 text-white text-sm rounded-lg opacity-0 invisible group-hover:opacity-100 group-hover:visible transition-all w-64">
                                This mode skips certain safety checks to optimize for gas. Do not
                                use this mode unless you know how to verify the calldata of your
                                transaction.
                                <div className="absolute top-full left-1/2 -translate-x-1/2 -translate-y-1 border-8 border-transparent border-t-zinc-900"></div>
                            </div>
                        </div>
                    </div>
                )}
                {/* 提交按钮 */}
                <button
                    className={`cursor-pointer flex items-center justify-center w-full py-3 rounded-[9px] text-white transition-colors font-semibold relative border ${isUnsafeMode
                        ? "bg-red-500 hover:bg-red-600 border-red-500"
                        : "bg-blue-500 hover:bg-blue-600 border-blue-500"
                        } ${!hasEnoughTokens && tokenAddress ? "opacity-50 cursor-not-allowed" : ""}`}
                    onClick={handleSubmit}
                    disabled={isPending || (!hasEnoughTokens && tokenAddress !== "")}
                >
                    {/* Gradient */}
                    <div className="absolute w-full inset-0 bg-gradient-to-b from-white/25 via-80% to-transparent mix-blend-overlay z-10 rounded-lg" />
                    {/* Inner shadow */}
                    <div className="absolute w-full inset-0 mix-blend-overlay z-10 inner-shadow rounded-lg" />
                    {/* White inner border */}
                    <div className="absolute w-full inset-0 mix-blend-overlay z-10 border-[1.5px] border-white/20 rounded-lg" />
                    {/* 根据交易状态反显结果 */}
                    {isPending || error || isConfirming
                        ? getButtonContent()
                        : !hasEnoughTokens && tokenAddress
                            ? "Insufficient token balance"
                            : isUnsafeMode
                                ? "Send Tokens (Unsafe)"
                                : "Send Tokens"}
                </button>
            </div>
        </div>
    )
}
