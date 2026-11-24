#!/usr/bin/env bash
# Builds every release file into release/:
#   Sketchy.html                 offline single-file app (any browser)
#   Sketchy-Windows-Setup.zip    small Windows installer kit (downloads Electron)
#   Sketchy-Linux-Setup.tar.gz   small Linux installer kit (downloads Electron)
#   Sketchy-Windows-x64.zip      full portable Windows app (only if ELECTRON_WIN_ZIP is set;
#                                needs the resedit npm package on NODE_PATH to stamp the icon)
set -euo pipefail
cd "$(dirname "$0")"
node build.mjs
rm -rf release dist/Sketchy-Windows-Setup dist/Sketchy-Linux-Setup && mkdir -p release

W=dist/Sketchy-Windows-Setup; mkdir -p $W
cp -r dist/app $W/app
cp installers/windows/{install.ps1,uninstall.ps1,README.txt} "installers/windows/Install Sketchy.cmd" "installers/windows/Uninstall Sketchy.cmd" $W/
(cd dist && zip -qr -9 ../release/Sketchy-Windows-Setup.zip Sketchy-Windows-Setup)

L=dist/Sketchy-Linux-Setup; mkdir -p $L
cp -r dist/app $L/app
cp installers/linux/{install.sh,uninstall.sh,README.txt} $L/ && chmod +x $L/*.sh
tar czf release/Sketchy-Linux-Setup.tar.gz --owner=0 --group=0 -C dist Sketchy-Linux-Setup

cp dist/Sketchy.html release/

if [ -n "${ELECTRON_WIN_ZIP:-}" ]; then
  P=dist/portable/Sketchy; rm -rf dist/portable && mkdir -p $P
  unzip -q "$ELECTRON_WIN_ZIP" -d $P
  mv $P/electron.exe $P/Sketchy.exe && rm -f $P/resources/default_app.asar
  cp -r dist/app $P/resources/app && cp installers/windows/README-portable.txt $P/README.txt
  node tools/stamp-exe.js $P/Sketchy.exe
  (cd dist/portable && zip -qr -9 ../../release/Sketchy-Windows-x64.zip Sketchy)
fi
ls -la release
