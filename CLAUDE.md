# Working on Sketchy

Sketchy is a browser 3D modeler in the style of SketchUp 2017: one big `index.html`
(HTML, CSS and JS), wrapped as an Electron desktop app and an offline single-file build.
See README.md for the project layout and build commands.

## How changes are made (agreed with the owner)

1. Never commit to `main` directly. Make a branch per change (`fix/...`, `feature/...`).
2. Push the branch and open a pull request against `main` with a plain-language
   description of what changed and how it was tested.
3. The owner tests the build. The "Build check" workflow attaches the built files to
   each PR run (Actions tab > the run > Artifacts). Also send the owner
   `release/Sketchy-Windows-Setup.zip`, `release/Sketchy-Linux-Setup.tar.gz` and
   `release/Sketchy.html` directly.
4. Merge only after the owner says the change works.
5. Releases: tags and releases can't be created from a Claude session. After a merge
   the owner publishes a release on GitHub (Releases > Draft a new release, new tag
   such as `v1.1.0` on `main`), and the "Release files" workflow builds and attaches
   all files, including the portable Windows app.

## Web version (claude.ai artifact)

The web version is published from `index.html` to
https://claude.ai/artifact/9HW75JmJkKAjgc5U97fRGx with the `downloads` capability.
Republish it after a change is merged, not before.

## Testing changes

- Build with `node build.mjs` (or `./package.sh`), then drive `dist/Sketchy.html` in
  headless Chromium with Playwright using `--use-gl=swiftshader --enable-unsafe-swiftshader`.
- `window.__sw` exposes test hooks (model `M`, `addFace`, `pushPull`, `addEdge`,
  `getPick`, `scr`, `buildSTL`, `importMesh`, ...). Use real mouse and keyboard input for
  tool behaviour, and check geometry is watertight (every edge used by two faces in
  opposite directions) after Push/Pull changes.
- Model units are inches internally; display units come from Model Info.
- The desktop app can be run with Linux Electron 33.2.1 under `xvfb-run`.
