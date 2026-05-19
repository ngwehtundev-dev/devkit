import { Activity, CreditCard, Users, Zap } from "lucide-react";

import { StatCard } from "@/components/dashboard/stat-card";

const stats = [
  {
    title: "Total Users",
    value: "2,420",
    description: "+12.5% from last month",
    icon: Users,
  },
  {
    title: "Active Sessions",
    value: "1,284",
    description: "Live usage right now",
    icon: Activity,
  },
  {
    title: "Revenue",
    value: "8.4M Ks",
    description: "+18.2% from last month",
    icon: CreditCard,
  },
  {
    title: "System Health",
    value: "99.9%",
    description: "All services operational",
    icon: Zap,
  },
];

export default function DashboardPage() {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-semibold tracking-tight">Dashboard</h1>
        <p className="text-sm text-muted-foreground">Monitor your application performance and activity.</p>
      </div>

      <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
        {stats.map((stat) => (
          <StatCard key={stat.title} {...stat} />
        ))}
      </div>

      <div className="rounded-2xl border bg-card p-6 shadow-sm">
        <h2 className="text-lg font-semibold">Overview</h2>
        <p className="mt-2 text-sm text-muted-foreground">
          Replace this section with charts, tables, recent activity, or business metrics.
        </p>
      </div>
    </div>
  );
}
