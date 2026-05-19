# Ngwe Htun DevKit

Professional dashboard starter scripts and templates for Next.js.

## Next.js Dashboard Installer

### Linux / macOS / WSL

```bash
curl -fsSL https://raw.githubusercontent.com/ngwehtundev-dev/devkit/main/scripts/next/install.sh \
  | bash -s -- my-dashboard --preset dashboard --lang en
```

### Windows PowerShell

```powershell
irm https://raw.githubusercontent.com/ngwehtundev-dev/devkit/main/scripts/next/install.ps1 | iex; Install-NextDevKit my-dashboard -Preset dashboard -Lang en
```

## Options

### Bash

```bash
--preset dashboard
--pm pnpm|npm|bun|yarn
--lang en|mm
--no-install
```

### PowerShell

```powershell
-Preset dashboard
-PackageManager pnpm|npm|bun|yarn
-Lang en|mm
-NoInstall
```

## Dashboard preset includes

- Next.js App Router
- TypeScript
- Tailwind CSS
- Dashboard layout
- Sidebar shell
- Header shell
- Dashboard home page
- Settings page
- Health check route
- SEO starter files
- Environment example
- Prettier config
- Professional folder structure

## Author

Ngwe Htun
