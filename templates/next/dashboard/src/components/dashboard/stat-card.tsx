import type { LucideIcon } from "lucide-react";

export function StatCard({
  title,
  value,
  description,
  icon: Icon,
}: Readonly<{
  title: string;
  value: string;
  description: string;
  icon: LucideIcon;
}>) {
  return (
    <div className="rounded-2xl border bg-card p-5 shadow-sm">
      <div className="flex items-center justify-between gap-4">
        <p className="text-sm font-medium text-muted-foreground">{title}</p>
        <div className="grid size-10 place-items-center rounded-xl bg-muted">
          <Icon className="size-5" />
        </div>
      </div>
      <div className="mt-4">
        <p className="text-2xl font-semibold tracking-tight">{value}</p>
        <p className="mt-1 text-xs text-muted-foreground">{description}</p>
      </div>
    </div>
  );
}
