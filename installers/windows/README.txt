Sketchy - Windows setup
=======================

Install
1. Extract this whole zip to a folder (right-click > Extract All).
2. Double-click "Install Sketchy.cmd".
   If Windows SmartScreen appears, click "More info" > "Run anyway".
3. Setup downloads the Electron runtime (about 110 MB) from GitHub, checks
   its SHA-256 checksum, installs to %LOCALAPPDATA%\Programs\Sketchy,
   adds Desktop and Start menu shortcuts, and starts the app.
   No administrator rights are needed. An older "Sketchwork 2017" install
   is removed automatically.

Files
- File > Save / Save As writes .skw model files anywhere on your PC.
- File > Open reads .skw files (and .json models from the web version).
- File > Import STL brings in STL meshes; you choose the units the file uses.
- File > Export saves STL (for 3D printing), OBJ (for other 3D programs)
  or a PNG of the view.
- Your current model is also autosaved; the Welcome screen offers
  "Continue last model" next time.

Uninstall
- Double-click "Uninstall Sketchy.cmd". Your .skw files are kept.

No internet? Open app\index.html in Chrome or Edge instead; it runs fully
offline in the browser (saves become downloads).

Not affiliated with or endorsed by Trimble or SketchUp.
Built on Electron (MIT), three.js (MIT) and polygon-clipping (MIT).
