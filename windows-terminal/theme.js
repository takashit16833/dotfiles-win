'use strict';
const fs = require('node:fs');
const { cleanJsonc } = require('./apply.js');
const palette = require('./noctis-blue-one-dark.scheme.json');

function skipSpace(s, i) { while (i < s.length && /\s/.test(s[i])) i++; return i; }
function valueEnd(s, start) {
  let quoted = false, escape = false, depth = 0;
  const begins = s[start];
  if (begins !== '{' && begins !== '[' && begins !== '"') {
    let j = start;
    while (j < s.length && !/[,}\]\s]/.test(s[j])) j++;
    return j;
  }
  if (begins === '"') {
    for (let j = start + 1; j < s.length; j++) {
      if (escape) escape = false;
      else if (s[j] === '\\') escape = true;
      else if (s[j] === '"') return j + 1;
    }
    throw new Error('Unterminated JSON string');
  }
  for (let j = start; j < s.length; j++) {
    const c = s[j];
    if (quoted) {
      if (escape) escape = false;
      else if (c === '\\') escape = true;
      else if (c === '"') quoted = false;
      continue;
    }
    if (c === '"') quoted = true;
    else if (c === '{' || c === '[') depth++;
    else if (c === '}' || c === ']') {
      depth--;
      if (depth === 0) return j + 1;
    }
  }
  throw new Error('Unterminated JSON structure');
}
function member(s, open, key) {
  if (s[open] !== '{') throw new Error('Expected object');
  const close = valueEnd(s, open) - 1;
  let i = open + 1;
  while (i < close) {
    i = skipSpace(s, i);
    if (i >= close) break;
    if (s[i] === ',') { i++; continue; }
    if (s[i] !== '"') throw new Error('Unexpected JSON object member');
    const keyEnd = valueEnd(s, i);
    const name = JSON.parse(s.slice(i, keyEnd));
    i = skipSpace(s, keyEnd);
    if (s[i] !== ':') throw new Error('Expected colon');
    const start = skipSpace(s, i + 1);
    const end = valueEnd(s, start);
    if (name === key) return { start, end, close };
    i = end;
  }
  return { close };
}
function insertMember(original, open, key, value) {
  const s = cleanJsonc(original);
  const m = member(s, open, key);
  if (m.start !== undefined) return original.slice(0, m.start) + value + original.slice(m.end);
  const prefix = skipSpace(s, open + 1) === m.close ? '' : (original.slice(open + 1, m.close).trimEnd().endsWith(',') ? '' : ',');
  const nl = original.includes('\r\n') ? '\r\n' : '\n';
  const newline = original.slice(0, m.close).includes('\n');
  const addition = prefix + (newline ? nl + '    ' : ' ') + JSON.stringify(key) + ': ' + value + (newline ? nl : '');
  return original.slice(0, m.close) + addition + original.slice(m.close);
}
function ensureNestedProperty(raw, parents, key, value) {
  for (let depth = parents.length; depth >= 0; depth--) {
    const prefix = parents.slice(0, depth);
    const s = cleanJsonc(raw);
    let open = skipSpace(s, 0);
    let found = true;
    for (const p of prefix) {
      const m = member(s, open, p);
      if (m.start === undefined) { found = false; break; }
      if (s[m.start] !== '{') throw new Error('Expected object: ' + p);
      open = m.start;
    }
    if (!found) continue;
    let v = value;
    if (depth < parents.length) {
      v = '{ ' + JSON.stringify(key) + ': ' + v + ' }';
      for (const p of parents.slice(depth + 1).reverse()) v = '{ ' + JSON.stringify(p) + ': ' + v + ' }';
    }
    const k = depth === parents.length ? key : parents[depth];
    return insertMember(raw, open, k, v);
  }
  throw new Error('Invalid Terminal settings');
}
function patchTheme(original) {
  const scheme = JSON.stringify(palette);
  let raw = original;
  const parsed = JSON.parse(cleanJsonc(raw));
  if (parsed === null || typeof parsed !== 'object' || Array.isArray(parsed)) throw new Error('Invalid settings object');
  if (parsed.schemes !== undefined && !Array.isArray(parsed.schemes)) throw new Error('schemes must be an array');
  if (!parsed.schemes) {
    raw = insertMember(raw, skipSpace(cleanJsonc(raw), 0), 'schemes', '[ ' + scheme + ' ]');
  } else {
    const sameNames = parsed.schemes.filter(x => x && x.name === palette.name);
    if (sameNames.length > 1) throw new Error('Duplicate custom theme name');
    if (!sameNames.length) {
      const s = cleanJsonc(raw), m = member(s, skipSpace(s, 0), 'schemes');
      const close = valueEnd(s, m.start) - 1;
      const needsComma = parsed.schemes.length > 0 && !raw.slice(m.start + 1, close).trimEnd().endsWith(',');
      const addition = (needsComma ? ',' : '') + '\n        ' + scheme + '\n';
      raw = raw.slice(0, close) + addition + raw.slice(close);
    } else if (JSON.stringify(sameNames[0]) !== scheme) {
      const s = cleanJsonc(raw), m = member(s, skipSpace(s, 0), 'schemes');
      let i = m.start + 1, done = false;
      const close = valueEnd(s, m.start) - 1;
      while (i < close) {
        i = skipSpace(s, i);
        if (s[i] === ',') { i++; continue; }
        const end = valueEnd(s, i);
        const item = JSON.parse(s.slice(i, end));
        if (item && item.name === palette.name) {
          raw = raw.slice(0, i) + scheme + raw.slice(end);
          done = true; break;
        }
        i = end;
      }
      if (!done) throw new Error('Unable to find named scheme');
    }
  }
  const after = JSON.parse(cleanJsonc(raw));
  if (after.profiles?.defaults?.colorScheme !== palette.name) {
    raw = ensureNestedProperty(raw, ['profiles', 'defaults'], 'colorScheme', JSON.stringify(palette.name));
  }
  JSON.parse(cleanJsonc(raw));
  return raw;
}
function main() {
  const target = process.argv[2];
  if (!target || !fs.existsSync(target)) throw new Error('Existing settings.json path is required');
  const before = fs.readFileSync(target, 'utf8');
  const after = patchTheme(before);
  if (after === before) return console.log('Windows Terminal color scheme already configured.');
  const backup = target + '.bak-' + new Date().toISOString().replace(/[:.]/g, '-');
  fs.copyFileSync(target, backup, fs.constants.COPYFILE_EXCL);
  fs.writeFileSync(target, after, 'utf8');
  console.log('Windows Terminal theme updated. Backup: ' + backup);
}
if (require.main === module) {
  try { main(); } catch (e) { console.error(e.message); process.exitCode = 1; }
}
module.exports = { patchTheme };
