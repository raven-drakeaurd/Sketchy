#!/usr/bin/env bash
# Removes Sketchy. Your saved .skw files are not touched.
DATA="${XDG_DATA_HOME:-$HOME/.local/share}"
pkill -f "$DATA/sketchy/sketchy" 2>/dev/null || true
rm -rf "$DATA/sketchy" "$HOME/.local/bin/sketchy" \
  "$DATA/applications/sketchy.desktop" "$DATA/mime/packages/sketchy.xml" \
  "$DATA/icons/hicolor/256x256/apps/sketchy.png" "${XDG_CACHE_HOME:-$HOME/.cache}/sketchy"
command -v update-mime-database >/dev/null && update-mime-database "$DATA/mime" >/dev/null 2>&1 || true
command -v update-desktop-database >/dev/null && update-desktop-database "$DATA/applications" >/dev/null 2>&1 || true
echo "Sketchy was removed."
