function Install-NextDevKit {
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

  $ErrorActionPreference = "Stop"
  $Repo = "ngwehtundev-dev/devkit"
  $Branch = "main"
  $BaseUrl = "https://raw.githubusercontent.com/$Repo/$Branch"

  function Write-Step($Message) { Write-Host "▶ $Message" -ForegroundColor Cyan }
  function Write-Success($Message) { Write-Host "✓ $Message" -ForegroundColor Green }
  function Write-Warn($Message) { Write-Host "! $Message" -ForegroundColor Yellow }
  function Fail($Message) { Write-Host "✗ $Message" -ForegroundColor Red; throw $Message }
  function Test-Command($Command) { return [bool](Get-Command $Command -ErrorAction SilentlyContinue) }
  function Require-Command($Command) { if (-not (Test-Command $Command)) { Fail "$Command is required but not installed." } }
  function Download-File($RemotePath, $TargetPath) {
    $Url = "$BaseUrl/$RemotePath"
    $Dir = Split-Path $TargetPath -Parent
    if ($Dir -and -not (Test-Path $Dir)) { New-Item -ItemType Directory -Force -Path $Dir | Out-Null }
    Invoke-WebRequest -Uri $Url -OutFile $TargetPath
  }
  function Copy-TemplateFile($File) { Download-File "templates/next/$Preset/$File" "$ProjectName/$File" }

  Write-Host ""
  Write-Host "Ngwe Htun DevKit" -ForegroundColor White
  Write-Host "Professional Next.js dashboard installer" -ForegroundColor DarkGray
  Write-Host ""

  if ($Preset -ne "dashboard") { Fail "Only -Preset dashboard is supported in this version." }
  if (Test-Path $ProjectName) { Fail "Directory already exists: $ProjectName" }

  Write-Step "Checking required tools..."
  Require-Command node
  Require-Command npx

  if (-not (Test-Command $PackageManager)) {
    if ($PackageManager -eq "pnpm") {
      Write-Warn "pnpm not found. Trying to enable Corepack..."
      try { corepack enable | Out-Null; corepack prepare pnpm@latest --activate | Out-Null } catch { Write-Warn "Corepack setup failed." }
    }
  }
  Require-Command $PackageManager

  Write-Step "Creating Next.js dashboard project: $ProjectName"
  npx create-next-app@latest $ProjectName `
    --ts `
    --tailwind `
    --eslint `
    --app `
    --src-dir `
    --import-alias "@/*" `
    "--use-$PackageManager"

  Write-Step "Creating dashboard folder structure..."
  $Folders = @(
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
  foreach ($Folder in $Folders) { New-Item -ItemType Directory -Force -Path "$ProjectName/$Folder" | Out-Null }

  Write-Step "Applying dashboard preset files..."
  Copy-TemplateFile "env.example"
  Copy-TemplateFile "README.template.md"
  Copy-TemplateFile "prettier.config.mjs"
  Copy-TemplateFile ".prettierignore"
  Copy-TemplateFile "src/app/(dashboard)/layout.tsx"
  Copy-TemplateFile "src/app/(dashboard)/dashboard/page.tsx"
  Copy-TemplateFile "src/app/(dashboard)/settings/page.tsx"
  Copy-TemplateFile "src/app/api/health/route.ts"
  Copy-TemplateFile "src/app/robots.ts"
  Copy-TemplateFile "src/app/sitemap.ts"
  Copy-TemplateFile "src/components/layout/dashboard-header.tsx"
  Copy-TemplateFile "src/components/layout/dashboard-shell.tsx"
  Copy-TemplateFile "src/components/layout/dashboard-sidebar.tsx"
  Copy-TemplateFile "src/components/dashboard/stat-card.tsx"
  Copy-TemplateFile "src/config/site.ts"
  Copy-TemplateFile "src/lib/utils.ts"

  Move-Item "$ProjectName/env.example" "$ProjectName/.env.example" -Force
  Move-Item "$ProjectName/README.template.md" "$ProjectName/README.md" -Force

  Push-Location $ProjectName

  if (-not $NoInstall) {
    Write-Step "Installing dashboard dependencies..."
    switch ($PackageManager) {
      "pnpm" { pnpm add zod clsx tailwind-merge lucide-react class-variance-authority; pnpm add -D prettier }
      "npm" { npm install zod clsx tailwind-merge lucide-react class-variance-authority; npm install -D prettier }
      "bun" { bun add zod clsx tailwind-merge lucide-react class-variance-authority; bun add -d prettier }
      "yarn" { yarn add zod clsx tailwind-merge lucide-react class-variance-authority; yarn add -D prettier }
    }
  } else {
    Write-Warn "Dependency installation skipped."
  }

  Write-Step "Updating package scripts..."
  $Pkg = Get-Content "package.json" -Raw | ConvertFrom-Json
  if (-not $Pkg.scripts) { $Pkg | Add-Member -MemberType NoteProperty -Name scripts -Value ([PSCustomObject]@{}) }
  $Pkg.scripts | Add-Member -Force -MemberType NoteProperty -Name "typecheck" -Value "tsc --noEmit"
  $Pkg.scripts | Add-Member -Force -MemberType NoteProperty -Name "format" -Value "prettier --write ."
  $Pkg.scripts | Add-Member -Force -MemberType NoteProperty -Name "format:check" -Value "prettier --check ."
  $Pkg.scripts | Add-Member -Force -MemberType NoteProperty -Name "check" -Value "npm run lint && npm run typecheck && npm run format:check"
  $Pkg | ConvertTo-Json -Depth 20 | Set-Content "package.json"

  Pop-Location

  Write-Success "Dashboard project created successfully."
  Write-Host ""
  Write-Host "Summary" -ForegroundColor White
  Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  Write-Host "Project:          $ProjectName"
  Write-Host "Preset:           $Preset"
  Write-Host "Package Manager:  $PackageManager"
  Write-Host "Language:         $Lang"
  Write-Host ""
  Write-Host "Included:"
  Write-Host "  ✓ Next.js App Router"
  Write-Host "  ✓ TypeScript"
  Write-Host "  ✓ Tailwind CSS"
  Write-Host "  ✓ Dashboard layout"
  Write-Host "  ✓ Sidebar + header shell"
  Write-Host "  ✓ Dashboard + settings pages"
  Write-Host "  ✓ Health check route"
  Write-Host "  ✓ SEO starter files"
  Write-Host "  ✓ Environment example"
  Write-Host ""
  Write-Host "Next steps:"
  Write-Host "  cd $ProjectName"
  Write-Host "  $PackageManager dev"
  Write-Host ""
}
