Sketchy - Linux setup
=====================

Install (x86_64 or ARM64, any modern distro, no root needed)
  tar xzf Sketchy-Linux-Setup.tar.gz
  cd Sketchy-Linux-Setup
  ./install.sh

Setup downloads the Electron runtime (about 105 MB) from GitHub, checks
its SHA-256 checksum, and installs to ~/.local/share/sketchy. It adds:
  - "Sketchy" to your applications menu, with its icon
  - the command  sketchy  (in ~/.local/bin)
  - a file association, so double-clicking a .skw file opens it
An older "Sketchwork 2017" install is removed automatically.

On Ubuntu 23.10 and later, setup may ask for your password once to set up
Chromium's sandbox helper. If you say no, the app still runs without it.

Files
- File > Save / Save As writes .skw model files anywhere.
- File > Import STL brings in STL meshes; you choose the units the file uses.
- File > Export saves STL (3D printing), OBJ (other 3D programs) or a PNG.

Uninstall
  ~/.local/share/sketchy/uninstall.sh
(Your .skw files are kept.)

No internet? Open app/index.html in Chrome or Firefox; it runs fully offline.

Not affiliated with or endorsed by Trimble or SketchUp.
Built on Electron (MIT), three.js (MIT) and polygon-clipping (MIT).
