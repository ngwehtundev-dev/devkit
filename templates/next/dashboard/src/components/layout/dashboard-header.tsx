import { Search } from "lucide-react";

export function DashboardHeader() {
  return (
    <header className="sticky top-0 z-30 border-b bg-background/90 backdrop-blur">
      <div className="flex h-16 items-center gap-4 px-6">
        <div className="relative max-w-md flex-1">
          <Search className="pointer-events-none absolute left-3 top-1/2 size-4 -translate-y-1/2 text-muted-foreground" />
          <input
            className="h-10 w-full rounded-xl border bg-background pl-9 pr-3 text-sm outline-none transition focus:ring-2 focus:ring-ring"
            placeholder="Search..."
            type="search"
          />
        </div>
        <div className="ml-auto flex items-center gap-3">
          <div className="text-right">
            <p className="text-sm font-medium">Admin</p>
            <p className="text-xs text-muted-foreground">Owner</p>
          </div>
          <div className="grid size-9 place-items-center rounded-full border bg-muted text-sm font-semibold">A</div>
        </div>
      </div>
    </header>
  );
}
