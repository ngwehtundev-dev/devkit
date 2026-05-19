import Link from "next/link";
import { BarChart3, LayoutDashboard, Settings } from "lucide-react";

import { siteConfig } from "@/config/site";

const navItems = [
  { href: "/dashboard", label: "Dashboard", icon: LayoutDashboard },
  { href: "/dashboard/reports", label: "Reports", icon: BarChart3 },
  { href: "/settings", label: "Settings", icon: Settings },
];

export function DashboardSidebar() {
  return (
    <aside className="hidden min-h-screen w-72 border-r bg-muted/30 lg:block">
      <div className="flex h-16 items-center border-b px-6">
        <Link href="/dashboard" className="text-lg font-semibold tracking-tight">
          {siteConfig.name}
        </Link>
      </div>

      <nav className="space-y-1 p-4">
        {navItems.map((item) => (
          <Link
            key={item.href}
            href={item.href}
            className="flex items-center gap-3 rounded-xl px-3 py-2 text-sm font-medium text-muted-foreground transition hover:bg-background hover:text-foreground"
          >
            <item.icon className="size-4" />
            {item.label}
          </Link>
        ))}
      </nav>
    </aside>
  );
}
