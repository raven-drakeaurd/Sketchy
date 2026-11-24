#!/usr/bin/env bash
# Sketchy installer for Linux (per-user, no root needed).
# Downloads the Electron runtime from GitHub, verifies its SHA-256, installs the app,
# and adds a menu entry, an icon and a .skw file association.
set -euo pipefail

VER=33.2.1
case "$(uname -m)" in
  x86_64|amd64)  ARCH=x64;   SHA=3b66a507ece29684a105b0f9609db50c88235333ddad696d01eefebefd4b1aab ;;
  aarch64|arm64) ARCH=arm64; SHA=61ef1182fcbcaaf0b9036243216747eb9be186491b79aa6576b482212a928d2e ;;
  *) echo "Sorry, $(uname -m) is not supported (needs x86_64 or arm64)." >&2; exit 1 ;;
esac

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA="${XDG_DATA_HOME:-$HOME/.local/share}"
DEST="$DATA/sketchy"
BIN="$HOME/.local/bin"
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/sketchy"
ZIP="$CACHE/electron-v$VER-linux-$ARCH.zip"
URL="https://github.com/electron/electron/releases/download/v$VER/electron-v$VER-linux-$ARCH.zip"

say() { printf '\033[1;36m%s\033[0m\n' "$*"; }
sha_ok() { [ -f "$ZIP" ] && [ "$(sha256sum "$ZIP" | cut -d' ' -f1)" = "$SHA" ]; }

say "Sketchy setup ($ARCH)"
mkdir -p "$CACHE" "$BIN"
OLDZIP="${XDG_CACHE_HOME:-$HOME/.cache}/sketchwork-2017/electron-v$VER-linux-$ARCH.zip"
[ -f "$OLDZIP" ] && [ ! -f "$ZIP" ] && mv "$OLDZIP" "$ZIP" || true
if ! sha_ok; then
  echo "Downloading Electron $VER runtime (about 105 MB)..."
  if command -v curl >/dev/null; then curl -fL --progress-bar -o "$ZIP" "$URL"
  elif command -v wget >/dev/null; then wget -q --show-progress -O "$ZIP" "$URL"
  else echo "Please install curl or wget, then run this again." >&2; exit 1; fi
fi
echo "Verifying download..."
if ! sha_ok; then rm -f "$ZIP"; echo "The download did not match the expected checksum. Run setup again." >&2; exit 1; fi

# Remove the earlier "Sketchwork 2017" install, if present
if [ -d "$DATA/sketchwork-2017" ]; then
  echo 'Removing the previous "Sketchwork 2017" install...'
  rm -rf "$DATA/sketchwork-2017" "$BIN/sketchwork-2017" "$DATA/applications/sketchwork-2017.desktop" \
    "$DATA/mime/packages/sketchwork-2017.xml" "$DATA/icons/hicolor/256x256/apps/sketchwork-2017.png" \
    "${XDG_CACHE_HOME:-$HOME/.cache}/sketchwork-2017"
fi
echo "Installing to $DEST ..."
rm -rf "$DEST.tmp"; mkdir -p "$DEST.tmp"
if command -v unzip >/dev/null; then unzip -q "$ZIP" -d "$DEST.tmp"
elif command -v python3 >/dev/null; then python3 -m zipfile -e "$ZIP" "$DEST.tmp"
elif command -v bsdtar >/dev/null; then bsdtar -xf "$ZIP" -C "$DEST.tmp"
else echo "Please install unzip (or python3), then run this again." >&2; exit 1; fi
mv "$DEST.tmp/electron" "$DEST.tmp/sketchy"
rm -f "$DEST.tmp/resources/default_app.asar"
cp -r "$HERE/app" "$DEST.tmp/resources/app"
cp "$HERE/uninstall.sh" "$DEST.tmp/"
chmod +x "$DEST.tmp/sketchy" "$DEST.tmp/chrome_crashpad_handler" "$DEST.tmp/chrome-sandbox" "$DEST.tmp/uninstall.sh" 2>/dev/null || true
rm -rf "$DEST"; mv "$DEST.tmp" "$DEST"

# Chromium's sandbox needs either unprivileged user namespaces or a setuid helper.
SANDBOX_FLAG=""
if ! unshare --user --map-root-user true 2>/dev/null; then
  echo
  echo "This system blocks unprivileged user namespaces (common on Ubuntu 23.10+)."
  echo "Sketchy can use Chromium's setuid sandbox helper instead; that needs your password once."
  read -r -p "Set up the sandbox helper with sudo? [Y/n] " ans || ans=n
  if [[ ! "$ans" =~ ^[Nn] ]] && sudo chown root:root "$DEST/chrome-sandbox" && sudo chmod 4755 "$DEST/chrome-sandbox"; then
    echo "Sandbox helper ready."
  else
    SANDBOX_FLAG="--no-sandbox"
    echo "Continuing without the Chromium sandbox. Sketchy only loads its own local files, but you can rerun setup to enable it."
  fi
fi

cat > "$BIN/sketchy" <<LAUNCH
#!/bin/sh
exec "$DEST/sketchy" $SANDBOX_FLAG "\$@"
LAUNCH
chmod +x "$BIN/sketchy"

mkdir -p "$DATA/icons/hicolor/256x256/apps" "$DATA/applications" "$DATA/mime/packages"
cp "$HERE/app/icon.png" "$DATA/icons/hicolor/256x256/apps/sketchy.png"
cat > "$DATA/applications/sketchy.desktop" <<DESK
[Desktop Entry]
Type=Application
Name=Sketchy
GenericName=3D Modeler
Comment=Push/pull 3D modeler in the style of SketchUp 2017
Exec="$BIN/sketchy" %f
Icon=sketchy
Terminal=false
Categories=Graphics;3DGraphics;
MimeType=application/x-sketchy;
StartupWMClass=sketchy
DESK
cat > "$DATA/mime/packages/sketchy.xml" <<'MIME'
<?xml version="1.0" encoding="UTF-8"?>
<mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
  <mime-type type="application/x-sketchy">
    <comment>Sketchy model</comment>
    <glob pattern="*.skw"/>
  </mime-type>
</mime-info>
MIME
command -v update-mime-database >/dev/null && update-mime-database "$DATA/mime" >/dev/null 2>&1 || true
command -v update-desktop-database >/dev/null && update-desktop-database "$DATA/applications" >/dev/null 2>&1 || true
command -v gtk-update-icon-cache >/dev/null && gtk-update-icon-cache -q -t "$DATA/icons/hicolor" >/dev/null 2>&1 || true
command -v xdg-mime >/dev/null && xdg-mime default sketchy.desktop application/x-sketchy >/dev/null 2>&1 || true

say "Done. Start Sketchy from your applications menu, or run: sketchy"
case ":$PATH:" in *":$BIN:"*) ;; *) echo "(Add $BIN to your PATH to use the sketchy command.)";; esac
