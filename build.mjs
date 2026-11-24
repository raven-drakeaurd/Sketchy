// Builds the offline single-file HTML and the Electron app folder from index.html.
// Usage: node build.mjs   ->  dist/Sketchy.html, dist/app/
import fs from 'fs';
const src = fs.readFileSync('index.html', 'utf8');
const lib = f => fs.readFileSync('vendor/' + f, 'utf8').replace(/<\/script/gi, '<\\/script');
let html = src
  .replace(/<link rel="stylesheet" href="https:\/\/fonts\.googleapis\.com[^>]*>\n?/, '')
  .replace(/<script src="[^"]*three\.min\.js"><\/script>/, () => '<script>' + lib('three.min.js') + '</script>')
  .replace(/<script src="[^"]*polygon-clipping\.umd\.min\.js"><\/script>/, () => '<script>' + lib('polygon-clipping.umd.min.js') + '</script>')
  .replace('const STANDALONE=false;', 'const STANDALONE=true;');
if (/<script src=/.test(html) || !html.includes('const STANDALONE=true;')) throw new Error('inlining failed');
const page = '<!doctype html>\n<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">\n'
  + '<style>body{margin:0}[hidden]{display:none!important}img{max-width:100%}</style>\n' + html.replace(/<\/style>/, '</style>\n</head><body>') + '\n</body></html>\n';
fs.mkdirSync('dist/app', { recursive: true });
fs.writeFileSync('dist/Sketchy.html', page);
fs.writeFileSync('dist/app/index.html', page);
for (const f of ['main.js', 'preload.js', 'package.json']) fs.copyFileSync('desktop/' + f, 'dist/app/' + f);
for (const f of ['icon.png', 'icon.ico']) fs.copyFileSync('desktop/' + f, 'dist/app/' + f);
console.log('built dist/Sketchy.html (' + (page.length / 1024 | 0) + ' KB) and dist/app/');
