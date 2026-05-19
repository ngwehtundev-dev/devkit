import { siteConfig } from "@/config/site";

export function SiteFooter() {
  return (
    <footer className="border-t py-6">
      <div className="mx-auto flex max-w-6xl items-center justify-between px-4 text-sm text-muted-foreground">
        <p>© {new Date().getFullYear()} {siteConfig.name}</p>
        <p>Built with Ngwe Htun DevKit</p>
      </div>
    </footer>
  );
}
