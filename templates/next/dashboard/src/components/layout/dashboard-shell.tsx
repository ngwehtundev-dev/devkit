import { DashboardHeader } from "@/components/layout/dashboard-header";
import { DashboardSidebar } from "@/components/layout/dashboard-sidebar";

export function DashboardShell({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <div className="min-h-screen bg-background text-foreground">
      <div className="flex">
        <DashboardSidebar />
        <div className="min-w-0 flex-1">
          <DashboardHeader />
          <main className="mx-auto w-full max-w-7xl p-6">{children}</main>
        </div>
      </div>
    </div>
  );
}
