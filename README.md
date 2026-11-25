# Sketchy

A push/pull 3D modeler in the style of SketchUp 2017 that runs in the browser, as a desktop app on Windows and Linux, or as a single offline HTML file.

Not affiliated with or endorsed by Trimble or SketchUp.

## Features

- Drawing: Line, Rectangle, Circle, Polygon and 2 Point Arc tools. Closed loops become faces, and a line drawn across a face splits it.
- Push/Pull, Move, Rotate, Scale, Offset, Tape Measure, Paint Bucket and Eraser.
- Inference snapping to endpoints, midpoints, circle and arc centers, edges, faces, the red/green/blue axes, parallel edges and equal lengths. Arrow keys lock an axis or, for Circle/Polygon/Arc, a drawing plane.
- Select, Lasso Select, groups, hide/unhide, undo/redo.
- Materials with procedural textures, styles (X-ray, wireframe, hidden line, shaded, textured, monochrome), shadows with time of day, and fog.
- Units in feet and inches, meters or millimeters, with adjustable display precision (Window > Model Info).
- Files: `.skw` models, STL import (you choose the file's units), STL/OBJ/PNG export.

## Project layout

| Path | What it is |
| --- | --- |
| `index.html` | The whole app (HTML, CSS and JavaScript in one file). Loads three.js and polygon-clipping from CDNs. |
| `vendor/` | Local copies of three.js r128 and polygon-clipping 0.15.7, inlined into the offline and desktop builds. |
| `desktop/` | Electron wrapper: `main.js` (window, native Save/Open dialogs), `preload.js`, `package.json`, app icons. |
| `installers/windows/` | PowerShell installer and uninstaller, `.cmd` launchers, READMEs. |
| `installers/linux/` | Bash installer and uninstaller, README. |
| `build.mjs` | Builds `dist/Sketchy.html` (offline, libraries inlined) and `dist/app/` (Electron app folder). |
| `package.sh` | Builds every release file into `release/`. |
| `tools/make-icons.js` | Renders `desktop/icon.png` and `desktop/icon.ico` from the logo (needs Playwright). |
| `tools/stamp-exe.js` | Sets the icon and version info on the Windows `.exe` (needs the `resedit` npm package). |

## Building

Requires Node.js 18 or later, plus `zip` and `tar`.

```sh
node build.mjs     # dist/Sketchy.html and dist/app/
./package.sh       # release/: Sketchy.html, Sketchy-Windows-Setup.zip, Sketchy-Linux-Setup.tar.gz
```

To also build the full portable Windows app (`release/Sketchy-Windows-x64.zip`), download `electron-v33.2.1-win32-x64.zip` from the [Electron releases](https://github.com/electron/electron/releases/tag/v33.2.1), install `resedit` and `pe-library` with npm, then:

```sh
ELECTRON_WIN_ZIP=/path/to/electron-v33.2.1-win32-x64.zip NODE_PATH=/path/to/node_modules ./package.sh
```

The Windows and Linux installers download Electron 33.2.1 from GitHub and check it against the SHA-256 checksums written in `installers/windows/install.ps1` and `installers/linux/install.sh`. Update those if you change the Electron version.

## Running the desktop app from source

```sh
node build.mjs
npx electron@33.2.1 dist/app
```

## Releases

Download the latest version from the [Releases page](https://github.com/raven-drakeaurd/Sketchy/releases).
Publishing a release on GitHub runs the **Release files** workflow, which builds and attaches
the Windows installer, the portable Windows app, the Linux installer and the offline HTML.

## Making changes

Changes go through pull requests: one branch per change, a pull request against `main`,
and a merge once the change is tested. The **Build check** workflow builds every pull request
and keeps the built files as a downloadable artifact on the run's page.

## Licenses

three.js and polygon-clipping are MIT licensed; their license files are in `vendor/`. Electron is MIT licensed.
