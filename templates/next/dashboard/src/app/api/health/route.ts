import { NextResponse } from "next/server";

export function GET() {
  return NextResponse.json({
    status: "ok",
    service: process.env.NEXT_PUBLIC_APP_NAME ?? "dashboard-app",
    timestamp: new Date().toISOString(),
  });
}
