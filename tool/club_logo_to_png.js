// Превращает SVG-эмблему в PNG для assets/club_logos.
//
// Использование (нужен Node.js):
//   npm install @resvg/resvg-js        (один раз, в корне проекта)
//   node tool/club_logo_to_png.js "Real Madrid" path/to/logo.svg
//
// Скрипт сам вычисляет имя файла из названия клуба (как ClubLogos.normalize),
// сохраняет PNG (до 256 px по большей стороне, прозрачный фон) в
// assets/club_logos и напоминает добавить ключ в ClubLogos.available.
// Тест test/club_logos_test.dart проверит, что список и файлы согласованы.
const fs = require('fs');
const path = require('path');
const { Resvg } = require('@resvg/resvg-js');

const [clubName, svgPath] = process.argv.slice(2);
if (!clubName || !svgPath) {
  console.error('Использование: node tool/club_logo_to_png.js "Название клуба" logo.svg');
  process.exit(1);
}

const key = clubName.trim().toLowerCase().replace(/[^a-z0-9]/g, '');
if (!key) {
  console.error('Из названия не получился ключ (нужны латинские буквы или цифры).');
  process.exit(1);
}

const SIZE = 256;
const svg = fs.readFileSync(svgPath);
const probe = new Resvg(svg);
const fitTo = probe.width >= probe.height
  ? { mode: 'width', value: SIZE }
  : { mode: 'height', value: SIZE };
const png = new Resvg(svg, { fitTo, background: 'rgba(0,0,0,0)' }).render().asPng();

const target = path.join('assets', 'club_logos', `${key}.png`);
fs.mkdirSync(path.dirname(target), { recursive: true });
fs.writeFileSync(target, png);

console.log(`Сохранено: ${target} (${Math.round(png.length / 1024)} КБ)`);
console.log(`Добавьте '${key}' в ClubLogos.available (lib/models/club_logos.dart).`);
