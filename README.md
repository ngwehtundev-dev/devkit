# Ngwe Htun DevKit

Professional starter scripts and project templates for modern application development.

## Next.js Installer

### Linux / macOS / WSL

```bash
curl -fsSL https://raw.githubusercontent.com/ngwehtundev-dev/devkit/main/scripts/next/install.sh \
  | bash -s -- my-app --preset standard --lang en
```

### Windows PowerShell

```powershell
irm https://raw.githubusercontent.com/ngwehtundev-dev/devkit/main/scripts/next/install.ps1 | iex; Install-NextDevKit my-app -Preset standard -Lang en
```

## Options

### Bash

```bash
--preset standard
--pm pnpm|npm|bun|yarn
--lang en|mm
--no-install
```

### PowerShell

```powershell
-Preset standard
-PackageManager pnpm|npm|bun|yarn
-Lang en|mm
-NoInstall
```

## Presets

| Preset | Status | Description |
|---|---:|---|
| standard | Available | Professional Next.js starter |
| minimal | Planned | Lightweight Next.js starter |
| enterprise | Planned | CI, Docker, hooks, testing |

## Author

Ngwe Htun
