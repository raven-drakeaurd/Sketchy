// Sketchy desktop shell (Electron)
const { app, BrowserWindow, ipcMain, dialog, shell } = require('electron');
const path = require('path');
const fs = require('fs');

if (process.platform === 'linux') {
  // Match the .desktop entry so the window groups with its menu entry and icon.
  app.commandLine.appendSwitch('class', 'sketchy');
  if (app.setDesktopName) app.setDesktopName('sketchy.desktop');
}

// Carry over settings and autosave from the app's previous name.
try {
  const appData = app.getPath('appData'), oldDir = path.join(appData, 'Sketchwork 2017'), newDir = path.join(appData, 'Sketchy');
  if (fs.existsSync(oldDir) && !fs.existsSync(newDir)) fs.cpSync(oldDir, newDir, { recursive: true });
} catch (e) { /* first run without old data */ }

let win = null;
let dirty = false;
const initialArg = process.argv.slice(app.isPackaged ? 1 : 2).find(a => /\.(skw|json)$/i.test(a) && fs.existsSync(a));

function createWindow() {
  win = new BrowserWindow({
    width: 1400, height: 900, minWidth: 820, minHeight: 560,
    title: 'Sketchy', backgroundColor: '#ECEEF1',
    icon: path.join(__dirname, 'icon.png'),
    autoHideMenuBar: true,
    webPreferences: { preload: path.join(__dirname, 'preload.js'), contextIsolation: true, nodeIntegration: false, sandbox: true },
  });
  win.setMenu(null);
  win.loadFile(path.join(__dirname, 'index.html'));
  win.webContents.setWindowOpenHandler(({ url }) => { if (/^https?:/i.test(url)) shell.openExternal(url); return { action: 'deny' }; });
  win.webContents.on('will-navigate', e => e.preventDefault());
  win.on('close', e => {
    if (!dirty) return;
    const r = dialog.showMessageBoxSync(win, {
      type: 'question', buttons: ['Close without saving', 'Cancel'], defaultId: 1, cancelId: 1,
      title: 'Sketchy', message: 'This model has unsaved changes.',
      detail: 'Your work is also autosaved and can be restored from the Welcome screen next time.',
    });
    if (r === 1) e.preventDefault();
  });
}

const MODEL_FILTERS = [{ name: 'Sketchy Model', extensions: ['skw'] }, { name: 'JSON', extensions: ['json'] }];
const EXPORT_FILTERS = {
  skw: [{ name: 'Sketchy Model', extensions: ['skw'] }],
  obj: [{ name: 'Wavefront OBJ', extensions: ['obj'] }],
  png: [{ name: 'PNG Image', extensions: ['png'] }],
  stl: [{ name: 'STL (3D printing)', extensions: ['stl'] }],
};

ipcMain.handle('save-model', async (_e, { path: p, name, data }) => {
  if (!p) {
    const r = await dialog.showSaveDialog(win, { defaultPath: name, filters: MODEL_FILTERS });
    if (r.canceled || !r.filePath) return null;
    p = r.filePath;
  }
  fs.writeFileSync(p, data, 'utf8');
  return { path: p, name: path.basename(p) };
});
ipcMain.handle('open-model', async () => {
  const r = await dialog.showOpenDialog(win, { properties: ['openFile'], filters: [{ name: 'Sketchy Model', extensions: ['skw', 'json'] }] });
  if (r.canceled || !r.filePaths[0]) return null;
  const p = r.filePaths[0];
  return { path: p, name: path.basename(p), data: fs.readFileSync(p, 'utf8') };
});
ipcMain.handle('export-file', async (_e, { name, data, kind }) => {
  const r = await dialog.showSaveDialog(win, { defaultPath: name, filters: EXPORT_FILTERS[kind] || [] });
  if (r.canceled || !r.filePath) return null;
  const buf = kind === 'png' ? Buffer.from(String(data).split(',')[1], 'base64')
    : ArrayBuffer.isView(data) ? Buffer.from(data.buffer, data.byteOffset, data.byteLength)
    : Buffer.from(String(data), 'utf8');
  fs.writeFileSync(r.filePath, buf);
  return { name: path.basename(r.filePath) };
});
ipcMain.handle('initial-file', () => {
  if (!initialArg) return null;
  return { path: initialArg, name: path.basename(initialArg), data: fs.readFileSync(initialArg, 'utf8') };
});
ipcMain.on('dirty', (_e, d) => { dirty = !!d; });

app.whenReady().then(createWindow);
app.on('window-all-closed', () => app.quit());
