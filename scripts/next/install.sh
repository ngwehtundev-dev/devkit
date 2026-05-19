#!/usr/bin/env bash

set -euo pipefail

DEVKIT_REPO="ngwehtundev-dev/devkit"
DEVKIT_BRANCH="main"
BASE_URL="https://raw.githubusercontent.com/${DEVKIT_REPO}/${DEVKIT_BRANCH}"

PROJECT_NAME=""
PRESET="standard"
LANGUAGE="en"
PACKAGE_MANAGER="pnpm"
SKIP_INSTALL="false"

BOLD="\033[1m"
DIM="\033[2m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
BLUE="\033[34m"
RESET="\033[0m"

log() {
  echo -e "${BLUE}▶${RESET} $1"
}

success() {
  echo -e "${GREEN}✓${RESET} $1"
}

warn() {
  echo -e "${YELLOW}!${RESET} $1"
}

error() {
  echo -e "${RED}✗${RESET} $1"
  exit 1
}

print_help() {
  cat <<HELP
Ngwe Htun DevKit — Next.js Installer

Usage:
  install.sh <project-name> [options]

Options:
  --preset <standard>       Project preset. Default: standard
  --pm <pnpm|npm|bun|yarn>  Package manager. Default: pnpm
  --lang <en|mm>            Output language. Default: en
  --no-install              Skip dependency installation
  -h, --help                Show help

Example:
  curl -fsSL ${BASE_URL}/scripts/next/install.sh | bash -s -- my-app --preset standard --lang en
HELP
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --preset)
      PRESET="${2:-}"
      shift 2
      ;;
    --pm)
      PACKAGE_MANAGER="${2:-}"
      shift 2
      ;;
    --lang)
      LANGUAGE="${2:-}"
      shift 2
      ;;
    --no-install)
      SKIP_INSTALL="true"
      shift
      ;;
    -h|--help)
      print_help
      exit 0
      ;;
    -*)
      error "Unknown option: $1"
      ;;
    *)
      if [[ -z "$PROJECT_NAME" ]]; then
        PROJECT_NAME="$1"
      else
        error "Unexpected argument: $1"
      fi
      shift
      ;;
  esac
done

[[ -z "$PROJECT_NAME" ]] && {
  print_help
  exit 1
}

[[ "$PRESET" != "standard" ]] && error "Only --preset standard is supported in this version."
[[ "$LANGUAGE" != "en" && "$LANGUAGE" != "mm" ]] && error "--lang must be en or mm."
[[ ! "$PACKAGE_MANAGER" =~ ^(pnpm|npm|bun|yarn)$ ]] && error "--pm must be pnpm, npm, bun, or yarn."

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

need_cmd() {
  command_exists "$1" || error "$1 is required but not installed."
}

download_file() {
  local remote_path="$1"
  local target_path="$2"

  mkdir -p "$(dirname "$target_path")"
  curl -fsSL "${BASE_URL}/${remote_path}" -o "$target_path"
}

copy_template_file() {
  local file="$1"
  download_file "templates/next/${PRESET}/${file}" "${PROJECT_NAME}/${file}"
}

title() {
  echo
  echo -e "${BOLD}Ngwe Htun DevKit${RESET}"
  echo -e "${DIM}Professional Next.js starter installer${RESET}"
  echo
}

title

log "Checking required tools..."
need_cmd node
need_cmd npx
need_cmd curl

if ! command_exists "$PACKAGE_MANAGER"; then
  if [[ "$PACKAGE_MANAGER" == "pnpm" ]]; then
    warn "pnpm not found. Trying to enable Corepack..."
    corepack enable >/dev/null 2>&1 || true
    corepack prepare pnpm@latest --activate >/dev/null 2>&1 || true
  fi
fi

command_exists "$PACKAGE_MANAGER" || error "$PACKAGE_MANAGER is required but not installed."

if [[ -e "$PROJECT_NAME" ]]; then
  error "Directory already exists: $PROJECT_NAME"
fi

log "Creating Next.js project: ${PROJECT_NAME}"

npx create-next-app@latest "$PROJECT_NAME" \
  --ts \
  --tailwind \
  --eslint \
  --app \
  --src-dir \
  --import-alias "@/*" \
  --use-${PACKAGE_MANAGER}

cd "$PROJECT_NAME"

log "Creating professional folder structure..."

mkdir -p \
  src/components/ui \
  src/components/shared \
  src/config \
  src/constants \
  src/features \
  src/hooks \
  src/lib \
  src/providers \
  src/server \
  src/styles \
  src/types \
  src/utils \
  src/app/api/health

log "Applying standard preset files..."

cd ..

copy_template_file "env.example"
copy_template_file "README.template.md"
copy_template_file "prettier.config.mjs"
copy_template_file ".prettierignore"
copy_template_file "src/app/api/health/route.ts"
copy_template_file "src/app/robots.ts"
copy_template_file "src/app/sitemap.ts"
copy_template_file "src/config/site.ts"
copy_template_file "src/lib/utils.ts"
copy_template_file "src/components/shared/site-footer.tsx"

mv "${PROJECT_NAME}/env.example" "${PROJECT_NAME}/.env.example"
mv "${PROJECT_NAME}/README.template.md" "${PROJECT_NAME}/README.md"

cd "$PROJECT_NAME"

log "Installing standard dependencies..."

if [[ "$SKIP_INSTALL" != "true" ]]; then
  case "$PACKAGE_MANAGER" in
    pnpm)
      pnpm add zod clsx tailwind-merge lucide-react class-variance-authority
      pnpm add -D prettier
      ;;
    npm)
      npm install zod clsx tailwind-merge lucide-react class-variance-authority
      npm install -D prettier
      ;;
    bun)
      bun add zod clsx tailwind-merge lucide-react class-variance-authority
      bun add -d prettier
      ;;
    yarn)
      yarn add zod clsx tailwind-merge lucide-react class-variance-authority
      yarn add -D prettier
      ;;
  esac
else
  warn "Dependency installation skipped."
fi

log "Updating package scripts..."

node <<'NODE'
const fs = require("fs");

const pkgPath = "package.json";
const pkg = JSON.parse(fs.readFileSync(pkgPath, "utf8"));

pkg.scripts = {
  ...pkg.scripts,
  "typecheck": "tsc --noEmit",
  "format": "prettier --write .",
  "format:check": "prettier --check .",
  "check": "npm run lint && npm run typecheck && npm run format:check"
};

fs.writeFileSync(pkgPath, JSON.stringify(pkg, null, 2) + "\n");
NODE

success "Project created successfully."

echo
echo -e "${BOLD}Summary${RESET}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Project:          ${PROJECT_NAME}"
echo "Preset:           ${PRESET}"
echo "Package Manager:  ${PACKAGE_MANAGER}"
echo "Language:         ${LANGUAGE}"
echo
echo "Included:"
echo "  ✓ Next.js App Router"
echo "  ✓ TypeScript"
echo "  ✓ Tailwind CSS"
echo "  ✓ ESLint"
echo "  ✓ Prettier"
echo "  ✓ Professional src structure"
echo "  ✓ Health check route"
echo "  ✓ SEO starter files"
echo "  ✓ Environment example"
echo
echo "Next steps:"
echo "  cd ${PROJECT_NAME}"
echo "  ${PACKAGE_MANAGER} dev"
echo
