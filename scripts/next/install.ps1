function Install-NextDevKit {
  <#
  .SYNOPSIS
    Scaffold a production-ready Next.js dashboard project.

  .PARAMETER ProjectName
    Name of the project directory to create.

  .PARAMETER Preset
    Project preset to apply. Currently only "dashboard" is supported.

  .PARAMETER Lang
    Locale hint (en | mm). Reserved for future i18n preset support.

  .PARAMETER PackageManager
    Package manager to use: pnpm (default), npm, bun, or yarn.

  .PARAMETER NoInstall
    Skip dependency installation (scaffold files only).

  .EXAMPLE
    Install-NextDevKit my-app
    Install-NextDevKit my-app -PackageManager bun -NoInstall
  #>

  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$ProjectName,

    [string]$Preset = "dashboard",

    [ValidateSet("en", "mm")]
    [string]$Lang = "en",

    [ValidateSet("pnpm", "npm", "bun", "yarn")]
    [string]$PackageManager = "pnpm",

    [switch]$NoInstall
  )

  # ── Constants ──────────────────────────────────────────────────────────────

  $ErrorActionPreference = "Stop"

  $Repo    = "ngwehtundev-dev/devkit"
  $Branch  = "main"
  $BaseUrl = "https://raw.githubusercontent.com/$Repo/$Branch"

  $DashboardDeps = @(
    "zod",
    "clsx",
    "tailwind-merge",
    "lucide-react",
    "class-variance-authority"
  )

  $DevDeps = @("prettier")

  # Packages that compile native binaries and must be explicitly allowed by pnpm
  $NativeBuildPackages = @("sharp", "unrs-resolver")

  $FolderStructure = @(
    "src/app/(dashboard)/dashboard",
    "src/app/(dashboard)/settings",
    "src/app/api/health",
    "src/components/dashboard",
    "src/components/layout",
    "src/components/shared",
    "src/components/ui",
    "src/config",
    "src/constants",
    "src/features",
    "src/hooks",
    "src/lib",
    "src/providers",
    "src/server",
    "src/types",
    "src/utils"
  )

  $TemplateFiles = @(
    "env.example",
    "README.template.md",
    "prettier.config.mjs",
    ".prettierignore",
    "src/app/(dashboard)/layout.tsx",
    "src/app/(dashboard)/dashboard/page.tsx",
    "src/app/(dashboard)/settings/page.tsx",
    "src/app/api/health/route.ts",
    "src/app/robots.ts",
    "src/app/sitemap.ts",
    "src/components/layout/dashboard-header.tsx",
    "src/components/layout/dashboard-shell.tsx",
    "src/components/layout/dashboard-sidebar.tsx",
    "src/components/dashboard/stat-card.tsx",
    "src/config/site.ts",
    "src/lib/utils.ts",
    "pnpm-workspace.yaml"
  )

  # ── Helpers ────────────────────────────────────────────────────────────────

  function Write-Step($Message)    { Write-Host "▶ $Message" -ForegroundColor Cyan }
  function Write-Success($Message) { Write-Host "✓ $Message" -ForegroundColor Green }
  function Write-Warn($Message)    { Write-Host "! $Message" -ForegroundColor Yellow }
  function Fail($Message)          { Write-Host "✗ $Message" -ForegroundColor Red; throw $Message }

  function Test-CommandExists($Command) {
    return [bool](Get-Command $Command -ErrorAction SilentlyContinue)
  }

  function Assert-Command($Command) {
    if (-not (Test-CommandExists $Command)) {
      Fail "$Command is required but was not found. Please install it and try again."
    }
  }

  function Download-File($RemotePath, $TargetPath) {
    $Url = "$BaseUrl/$RemotePath"
    $Dir = Split-Path $TargetPath -Parent
    if ($Dir -and -not (Test-Path $Dir)) {
      New-Item -ItemType Directory -Force -Path $Dir | Out-Null
    }
    Invoke-WebRequest -Uri $Url -OutFile $TargetPath -ErrorAction Stop
  }

  function Copy-TemplateFile($File) {
    Download-File "templates/next/$Preset/$File" "$ProjectName/$File"
  }

  function Edit-PackageJson([scriptblock]$Mutate) {
    $Json = Get-Content "package.json" -Raw | ConvertFrom-Json
    & $Mutate $Json
    $Json | ConvertTo-Json -Depth 20 | Set-Content "package.json"
  }

  # ── Banner ─────────────────────────────────────────────────────────────────

  Write-Host ""
  Write-Host "  Ngwe Htun DevKit" -ForegroundColor White
  Write-Host "  Professional Next.js dashboard installer" -ForegroundColor DarkGray
  Write-Host ""

  # ── Validation ─────────────────────────────────────────────────────────────

  if ($Preset -ne "dashboard") {
    Fail "Only -Preset dashboard is supported in this version."
  }

  if (Test-Path $ProjectName) {
    Fail "Directory already exists: $ProjectName. Choose a different project name."
  }

  # ── Prerequisites ──────────────────────────────────────────────────────────

  Write-Step "Checking required tools..."

  Assert-Command "node"
  Assert-Command "npx"

  if (-not (Test-CommandExists $PackageManager)) {
    if ($PackageManager -eq "pnpm") {
      Write-Warn "pnpm not found — attempting to enable via Corepack..."
      try {
        corepack enable | Out-Null
        corepack prepare pnpm@latest --activate | Out-Null
        Write-Success "pnpm activated via Corepack."
      } catch {
        Write-Warn "Corepack setup failed. Install pnpm manually: https://pnpm.io/installation"
      }
    }
    Assert-Command $PackageManager
  }

  # ── Scaffold Next.js App (skip internal install) ──────────────────────────
  # We pass --skip-install so create-next-app does NOT run pnpm install itself.
  # This gives us a chance to patch package.json with the native build allowlist
  # BEFORE pnpm ever runs — otherwise ERR_PNPM_IGNORED_BUILDS fires immediately.

  Write-Step "Scaffolding Next.js project: $ProjectName"

  npx create-next-app@latest $ProjectName `
    --ts `
    --tailwind `
    --eslint `
    --app `
    --src-dir `
    --import-alias "@/*" `
    "--use-$PackageManager" `
    --skip-install

  if ($LASTEXITCODE -ne 0) { Fail "create-next-app failed. See output above." }

  # ── Folder Structure ───────────────────────────────────────────────────────

  Write-Step "Creating folder structure..."

  foreach ($Folder in $FolderStructure) {
    New-Item -ItemType Directory -Force -Path "$ProjectName/$Folder" | Out-Null
  }

  # ── Template Files ─────────────────────────────────────────────────────────

  Write-Step "Applying $Preset preset files..."

  foreach ($File in $TemplateFiles) {
    Copy-TemplateFile $File
  }

  # Rename files that need to live at a different path than the template name
  Move-Item "$ProjectName/env.example"        "$ProjectName/.env.example" -Force
  Move-Item "$ProjectName/README.template.md" "$ProjectName/README.md"    -Force

  # ── Enter project dir ──────────────────────────────────────────────────────

  Push-Location $ProjectName

  try {

    # ── pnpm native build allowlist ─────────────────────────────────────────
    # pnpm 10 dropped the "pnpm" field from package.json — settings now live in
    # pnpm-workspace.yaml. onlyBuiltDependencies must go there so pnpm allows
    # sharp and unrs-resolver to compile native binaries; otherwise every install
    # raises ERR_PNPM_IGNORED_BUILDS.
    # Must be written BEFORE the first `pnpm install` call.

    Write-Step "Configuring pnpm native build allowlist..."

    $WorkspaceFile = "pnpm-workspace.yaml"
    $AllowLines    = @("", "onlyBuiltDependencies:") + ($NativeBuildPackages | ForEach-Object { "  - $_" })
    $AllowBlock    = $AllowLines -join "`n"

    if (Test-Path $WorkspaceFile) {
      $Existing = Get-Content $WorkspaceFile -Raw
      if ($Existing -notmatch "onlyBuiltDependencies") {
        Add-Content $WorkspaceFile $AllowBlock
      }
    } else {
      Set-Content $WorkspaceFile $AllowBlock
    }

    # ── Extra npm scripts ────────────────────────────────────────────────────

    Write-Step "Updating package.json scripts..."

    Edit-PackageJson {
      param($Pkg)
      if (-not $Pkg.scripts) {
        $Pkg | Add-Member -MemberType NoteProperty -Name "scripts" -Value ([PSCustomObject]@{})
      }
      $Scripts = $Pkg.scripts
      $Scripts | Add-Member -Force -MemberType NoteProperty -Name "typecheck"    -Value "tsc --noEmit"
      $Scripts | Add-Member -Force -MemberType NoteProperty -Name "format"       -Value "prettier --write ."
      $Scripts | Add-Member -Force -MemberType NoteProperty -Name "format:check" -Value "prettier --check ."
      $Scripts | Add-Member -Force -MemberType NoteProperty -Name "check"        -Value "npm run lint && npm run typecheck && npm run format:check"
    }

    # ── Install dependencies ─────────────────────────────────────────────────
    # Now that package.json is patched, it's safe to run pnpm install.

    if (-not $NoInstall) {
      $DepArgs    = $DashboardDeps -join " "
      $DevDepArgs = $DevDeps -join " "

      Write-Step "Running base install..."
      switch ($PackageManager) {
        "pnpm" { pnpm install }
        "npm"  { npm install }
        "bun"  { bun install }
        "yarn" { yarn install }
      }

      Write-Step "Installing dashboard dependencies..."
      switch ($PackageManager) {
        "pnpm" {
          Invoke-Expression "pnpm add $DepArgs"
          Invoke-Expression "pnpm add -D $DevDepArgs"
        }
        "npm" {
          Invoke-Expression "npm install $DepArgs"
          Invoke-Expression "npm install -D $DevDepArgs"
        }
        "bun" {
          Invoke-Expression "bun add $DepArgs"
          Invoke-Expression "bun add -d $DevDepArgs"
        }
        "yarn" {
          Invoke-Expression "yarn add $DepArgs"
          Invoke-Expression "yarn add -D $DevDepArgs"
        }
      }
    } else {
      Write-Warn "Dependency installation skipped (-NoInstall)."
    }

  } finally {
    Pop-Location
  }

  # ── Summary ────────────────────────────────────────────────────────────────

  Write-Host ""
  Write-Success "Project created successfully!"
  Write-Host ""
  Write-Host "  Summary" -ForegroundColor White
  Write-Host "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  Write-Host "  Project:         $ProjectName"
  Write-Host "  Preset:          $Preset"
  Write-Host "  Package Manager: $PackageManager"
  Write-Host "  Language:        $Lang"
  Write-Host ""
  Write-Host "  Included:"
  Write-Host "    ✓ Next.js App Router"
  Write-Host "    ✓ TypeScript"
  Write-Host "    ✓ Tailwind CSS"
  Write-Host "    ✓ Dashboard layout"
  Write-Host "    ✓ Sidebar + header shell"
  Write-Host "    ✓ Dashboard + settings pages"
  Write-Host "    ✓ Health check route"
  Write-Host "    ✓ SEO starter files"
  Write-Host "    ✓ Environment example"
  Write-Host "    ✓ Prettier config"
  Write-Host "    ✓ pnpm native build allowlist"
  Write-Host ""
  Write-Host "  Next steps:"
  Write-Host "    cd $ProjectName"
  Write-Host "    $PackageManager dev"
  Write-Host ""
}