#!/bin/bash
# Download So Record binaries for the current platform.
# Fetches pre-built binaries from GitHub Releases.
set -e

SO_DIR="$HOME/.so"
BIN_DIR="$SO_DIR/bin"
REPO="oscarnevarezleal/screen-recorder"
FFMPEG_BASE_URL="https://github.com/eugeneware/ffmpeg-static/releases/latest/download"

mkdir -p "$BIN_DIR"

# Detect platform
OS=$(uname -s)
ARCH=$(uname -m)

case "$OS" in
  Darwin)
    case "$ARCH" in
      arm64)  PLATFORM="darwin-arm64" ;;
      x86_64) PLATFORM="darwin-x64" ;;
      *)      echo "Error: Unsupported macOS architecture: $ARCH" >&2; exit 1 ;;
    esac
    ;;
  Linux)
    case "$ARCH" in
      x86_64) PLATFORM="linux-x64" ;;
      *)      echo "Error: Unsupported Linux architecture: $ARCH" >&2; exit 1 ;;
    esac
    ;;
  MINGW*|MSYS*|CYGWIN*)
    PLATFORM="windows-x64"
    ;;
  *)
    echo "Error: Unsupported OS: $OS" >&2
    exit 1
    ;;
esac

echo "Platform: $PLATFORM"

# Get latest release version (uses gh CLI for auth with private repos)
echo "Checking latest release..."
if command -v gh &>/dev/null; then
  LATEST=$(gh release list --repo "$REPO" --limit 10 2>/dev/null | grep "^cli-v" | head -1 | awk '{print $3}')
else
  LATEST=$(curl -sL "https://api.github.com/repos/$REPO/releases" | \
    python3 -c "import sys,json; releases=json.load(sys.stdin); cli=[r for r in releases if r['tag_name'].startswith('cli-v')]; print(cli[0]['tag_name'] if cli else '')" 2>/dev/null)
fi

if [ -z "$LATEST" ]; then
  echo "No cli-v* releases found. Using development binaries." >&2
  echo "Build from source: cargo build -p so-engine --features cli --release" >&2
  exit 1
fi

echo "Latest: $LATEST"

# Check if already installed
INSTALLED_VERSION=$(python3 -c "import json; print(json.load(open('$SO_DIR/version.json'))['version'])" 2>/dev/null || echo "none")
if [ "$INSTALLED_VERSION" = "$LATEST" ]; then
  echo "Already up to date ($LATEST)"
  exit 0
fi

# Download release archive
if [ "$PLATFORM" = "windows-x64" ]; then
  ARCHIVE="so-record-${PLATFORM}.zip"
else
  ARCHIVE="so-record-${PLATFORM}.tar.gz"
fi
echo "Downloading $ARCHIVE from $LATEST..."

TMPDIR=$(mktemp -d)
if command -v gh &>/dev/null; then
  gh release download "$LATEST" --repo "$REPO" --pattern "$ARCHIVE" --dir "$TMPDIR" 2>/dev/null
else
  DOWNLOAD_URL="https://github.com/$REPO/releases/download/$LATEST/$ARCHIVE"
  curl -sL "$DOWNLOAD_URL" -o "$TMPDIR/$ARCHIVE"
fi

if [ ! -s "$TMPDIR/$ARCHIVE" ]; then
  echo "Error: Download failed or empty file" >&2
  rm -rf "$TMPDIR"
  exit 1
fi

# Extract
echo "Extracting to $BIN_DIR..."
if [ "$PLATFORM" = "windows-x64" ]; then
  unzip -o "$TMPDIR/$ARCHIVE" -d "$BIN_DIR"
else
  tar -xzf "$TMPDIR/$ARCHIVE" -C "$BIN_DIR"
  chmod +x "$BIN_DIR/so" "$BIN_DIR/so-engine-cli" "$BIN_DIR/native-export-cli" "$BIN_DIR/so-compose-ffmpeg" 2>/dev/null || true
fi
rm -rf "$TMPDIR"

# Download ffmpeg if missing
if [ ! -f "$BIN_DIR/ffmpeg" ]; then
  echo "Downloading ffmpeg..."
  case "$PLATFORM" in
    darwin-arm64)  FFMPEG_TARGET="darwin-arm64" ;;
    darwin-x64)    FFMPEG_TARGET="darwin-x64" ;;
    linux-x64)     FFMPEG_TARGET="linux-x64" ;;
    windows-x64)   FFMPEG_TARGET="win32-x64" ;;
  esac
  curl -sL "$FFMPEG_BASE_URL/ffmpeg-$FFMPEG_TARGET" -o "$BIN_DIR/ffmpeg"
  chmod +x "$BIN_DIR/ffmpeg"

  # Also get ffprobe
  curl -sL "$FFMPEG_BASE_URL/ffprobe-$FFMPEG_TARGET" -o "$BIN_DIR/ffprobe"
  chmod +x "$BIN_DIR/ffprobe"
fi

# Write version file
cat > "$SO_DIR/version.json" << EOF
{
  "version": "$LATEST",
  "platform": "$PLATFORM",
  "installed_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "bin_dir": "$BIN_DIR"
}
EOF

# Generate Playwright config with absolute tracker.js path
# Write into the plugin's config directory (where mcp-servers.json references it)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/../config"
TRACKER_PATH="$(cd "$CONFIG_DIR" && pwd)/tracker.js"

cat > "$CONFIG_DIR/playwright-config.json" << PEOF
{
  "browser": {
    "isolated": true,
    "contextOptions": {
      "viewport": { "width": 1920, "height": 1080 },
      "deviceScaleFactor": 1,
      "recordVideo": {
        "dir": "./playwright-videos/",
        "size": { "width": 1920, "height": 1080 }
      }
    },
    "initScript": ["$TRACKER_PATH"]
  },
  "capabilities": ["core", "vision", "devtools"],
  "outputDir": "./playwright-output",
  "outputMode": "file",
  "consoleLevel": "info"
}
PEOF

# Add ~/.so/bin to PATH in shell profiles (idempotent)
for profile in "$HOME/.zprofile" "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.bash_profile"; do
  if [ -f "$profile" ] || [ "$profile" = "$HOME/.zprofile" ]; then
    if ! grep -q '.so/bin' "$profile" 2>/dev/null; then
      echo 'export PATH="$HOME/.so/bin:$PATH"' >> "$profile"
    fi
  fi
done

echo "Installed $LATEST for $PLATFORM"
echo "  so:                 $BIN_DIR/so"
echo "  so-engine-cli:      $BIN_DIR/so-engine-cli"
echo "  so-compose-ffmpeg:  $BIN_DIR/so-compose-ffmpeg"
echo "  native-export-cli:  $BIN_DIR/native-export-cli (macOS only)"
echo "  ffmpeg:             $BIN_DIR/ffmpeg"
echo "  playwright-config:  $CONFIG_DIR/playwright-config.json"
echo "  tracker.js:         $TRACKER_PATH"
