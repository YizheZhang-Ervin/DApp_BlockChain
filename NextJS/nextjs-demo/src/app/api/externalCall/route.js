import { NextResponse } from "next/server"

export async function GET(request) {
    // 转发第三方API数据
    // const res = await fetch("http://xx.yy.zz.aa:3000/api1/check")
    // const data = await res.json()
    // return NextResponse.json(data)
    return NextResponse.json({ "result": "Call OK" })
}