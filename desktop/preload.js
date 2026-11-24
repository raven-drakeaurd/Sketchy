const { contextBridge, ipcRenderer } = require('electron');
contextBridge.exposeInMainWorld('swNative', {
  saveModel: o => ipcRenderer.invoke('save-model', o),
  openModel: () => ipcRenderer.invoke('open-model'),
  exportFile: o => ipcRenderer.invoke('export-file', o),
  initialFile: () => ipcRenderer.invoke('initial-file'),
  setDirty: d => ipcRenderer.send('dirty', !!d),
});
