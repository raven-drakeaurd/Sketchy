// Sets the icon and version details on the Windows Sketchy.exe (no Wine needed).
const ResEdit = require('resedit'), PE = require('pe-library'), fs = require('fs'), path = require('path');
const exe = process.argv[2];
const e = PE.NtExecutable.from(fs.readFileSync(exe), { ignoreCert: true }); const res = PE.NtExecutableResource.from(e);
const ico = ResEdit.Data.IconFile.from(fs.readFileSync(path.join(__dirname, '../desktop/icon.ico')));
for (const g of ResEdit.Resource.IconGroupEntry.fromEntries(res.entries)) ResEdit.Resource.IconGroupEntry.replaceIconsForResource(res.entries, g.id, g.lang, ico.icons.map(i => i.data));
const vi = ResEdit.Resource.VersionInfo.fromEntries(res.entries)[0];
vi.setStringValues({ lang: 1033, codepage: 1200 }, { FileDescription: 'Sketchy', ProductName: 'Sketchy', CompanyName: 'Sketchy', OriginalFilename: 'Sketchy.exe', InternalName: 'Sketchy', LegalCopyright: '' });
vi.setFileVersion(1, 0, 0, 0, 1033); vi.setProductVersion(1, 0, 0, 0, 1033); vi.outputToResourceEntries(res.entries);
res.outputResource(e); fs.writeFileSync(exe, Buffer.from(e.generate())); console.log('stamped', exe);
