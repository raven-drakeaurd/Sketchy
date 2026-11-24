// Renders desktop/icon.png (256px) and desktop/icon.ico (16-256px) from the logo SVG.
// Usage: node tools/make-icons.js   (needs Playwright with Chromium)
const { chromium } = require(process.env.PLAYWRIGHT || 'playwright');
const fs = require('fs'), path = require('path');
const out = path.join(__dirname, '../desktop');
(async () => {
  const b = await chromium.launch(); const p = await b.newPage({ viewport: { width: 256, height: 256 } });
  const svg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="256" height="256"><path d="M12 1.5l9.5 5.3v10.4L12 22.5l-9.5-5.3V6.8z" fill="#D8442E"/><path d="M12 1.5l9.5 5.3L12 12 2.5 6.8z" fill="#F07A4F"/><path d="M12 12v10.5l9.5-5.3V6.8z" fill="#A9301F"/><path d="M12 1.5l9.5 5.3v10.4L12 22.5l-9.5-5.3V6.8zM12 12l9.5-5.2M12 12L2.5 6.8M12 12v10.5" fill="none" stroke="#5a1408" stroke-width=".5" stroke-linejoin="round"/></svg>';
  await p.setContent('<html><body style="margin:0;background:transparent">' + svg + '</body></html>');
  const sizes = [16, 32, 48, 256], imgs = [];
  for (const s of sizes) {
    await p.setViewportSize({ width: s, height: s });
    await p.evaluate(s => { const e = document.querySelector('svg'); e.setAttribute('width', s); e.setAttribute('height', s); }, s);
    imgs.push(await p.screenshot({ omitBackground: true }));
  }
  await b.close();
  const head = Buffer.alloc(6 + 16 * imgs.length); head.writeUInt16LE(0, 0); head.writeUInt16LE(1, 2); head.writeUInt16LE(imgs.length, 4);
  let off = head.length;
  imgs.forEach((im, i) => { const s = sizes[i], o = 6 + 16 * i; head.writeUInt8(s >= 256 ? 0 : s, o); head.writeUInt8(s >= 256 ? 0 : s, o + 1); head.writeUInt16LE(1, o + 4); head.writeUInt16LE(32, o + 6); head.writeUInt32LE(im.length, o + 8); head.writeUInt32LE(off, o + 12); off += im.length; });
  fs.writeFileSync(path.join(out, 'icon.ico'), Buffer.concat([head, ...imgs]));
  fs.writeFileSync(path.join(out, 'icon.png'), imgs[3]);
  console.log('wrote desktop/icon.png and desktop/icon.ico');
})();
