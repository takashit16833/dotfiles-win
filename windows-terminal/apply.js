'use strict';
const fs = require('node:fs');

const bindings = [
  { command: { action: 'prevTab', tabSwitcherMode: 'inOrder' }, keys: 'ctrl+pgup' },
  { command: { action: 'nextTab', tabSwitcherMode: 'inOrder' }, keys: 'ctrl+pgdn' },
  { command: 'closeTab', keys: 'ctrl+w' },
];

// Mask JSONC comments while preserving offsets; then mask trailing commas.
function cleanJsonc(input) {
  const chars = input.split('');
  let quoted = false, escape = false;
  for (let i = 0; i < chars.length; i++) {
    const c = chars[i], next = chars[i + 1];
    if (quoted) {
      if (escape) escape = false;
      else if (c === '\\') escape = true;
      else if (c === '"') quoted = false;
    } else if (c === '"') quoted = true;
    else if (c === '/' && next === '/') {
      for (let j = i; j < chars.length && chars[j] !== '\n'; j++) chars[j] = ' ';
    } else if (c === '/' && next === '*') {
      let j = i;
      while (j < chars.length && !(chars[j] === '*' && chars[j + 1] === '/')) {
        if (chars[j] !== '\r' && chars[j] !== '\n') chars[j] = ' ';
        j++;
      }
      if (j === chars.length) throw new Error('Unterminated JSONC comment');
      chars[j] = chars[j + 1] = ' ';
      i = j + 1;
    }
  }
  quoted = false; escape = false;
  for (let i = 0; i < chars.length; i++) {
    if (quoted) {
      if (escape) escape = false;
      else if (chars[i] === '\\') escape = true;
      else if (chars[i] === '"') quoted = false;
    } else if (chars[i] === '"') quoted = true;
    else if (chars[i] === ',') {
      let j = i + 1;
      while (j < chars.length && /\s/.test(chars[j])) j++;
      if (chars[j] === ']' || chars[j] === '}') chars[i] = ' ';
    }
  }
  return chars.join('');
}

function locateActions(cleaned) {
  let depth = 0;
  for (let i = 0; i < cleaned.length; i++) {
    const c = cleaned[i];
    if (c === '"') {
      const start = i++;
      while (i < cleaned.length) {
        if (cleaned[i] === '\\') i += 2;
        else if (cleaned[i++] === '"') break;
      }
      if (depth !== 1) continue;
      const key = JSON.parse(cleaned.slice(start, i));
      let j = i;
      while (/\s/.test(cleaned[j] || '')) j++;
      if (key !== 'actions' || cleaned[j] !== ':') continue;
      j++;
      while (/\s/.test(cleaned[j] || '')) j++;
      if (cleaned[j] !== '[') throw new Error('Top-level actions must be an array');
      let bracketDepth = 0;
      for (let k = j; k < cleaned.length; k++) {
        if (cleaned[k] === '"') {
          k++;
          while (k < cleaned.length) {
            if (cleaned[k] === '\\') k += 2;
            else if (cleaned[k++] === '"') break;
          }
          k--;
        } else if (cleaned[k] === '[') bracketDepth++;
        else if (cleaned[k] === ']' && --bracketDepth === 0) return { open: j, close: k };
      }
      throw new Error('Unterminated actions array');
    }
    if (c === '{' || c === '[') depth++;
    else if (c === '}' || c === ']') depth--;
  }
  return null;
}

function trailingCommaAt(clean, original, open, close) {
  for (let k = close - 1; k > open; k--) {
    if (!/\s/.test(clean[k])) break;
    if (original[k] === ',' && clean[k] === ' ') return true;
  }
  return false;
}

function patch(original) {
  const clean = cleanJsonc(original);
  const settings = JSON.parse(clean);
  if (!settings || typeof settings !== 'object' || Array.isArray(settings)) throw new Error('Expected settings object');
  if (settings.actions !== undefined && !Array.isArray(settings.actions)) throw new Error('Invalid actions');
  const actions = settings.actions || [];
  const missing = [];
  for (const binding of bindings) {
    const existing = actions.filter(x => x && typeof x.keys === 'string' && x.keys.toLowerCase() === binding.keys);
    if (existing.length) {
      if (existing.length !== 1 || JSON.stringify(existing[0].command) !== JSON.stringify(binding.command)) {
        throw new Error('Existing shortcut conflict: ' + binding.keys + '. No settings changed.');
      }
    } else missing.push(binding);
  }
  if (!missing.length) return original;
  const newline = original.includes('\r\n') ? '\r\n' : '\n';
  const entries = missing.map(x => '        ' + JSON.stringify(x)).join(',' + newline);
  const location = locateActions(clean);
  let patched;
  if (location) {
    const trailingComma = trailingCommaAt(clean, original, location.open, location.close);
    const prefix = actions.length && !trailingComma ? ',' : '';
    patched = original.slice(0, location.close) + prefix + newline + entries + newline + '    ' + original.slice(location.close);
  } else {
    const close = clean.lastIndexOf('}');
    const separator = Object.keys(settings).length && !trailingCommaAt(clean, original, 0, close) ? ',' : '';
    patched = original.slice(0, close) + separator + newline + '    "actions": [' + newline + entries + newline + '    ]' + newline + original.slice(close);
  }
  const verified = JSON.parse(cleanJsonc(patched));
  if (!Array.isArray(verified.actions) || verified.actions.length !== actions.length + missing.length) throw new Error('Validation failed');
  return patched;
}

function main() {
  const target = process.argv[2];
  if (!target || !fs.existsSync(target)) throw new Error('Existing Windows Terminal settings.json path required');
  const original = fs.readFileSync(target, 'utf8');
  const updated = patch(original);
  if (updated === original) return console.log('Windows Terminal shortcuts already configured.');
  const backup = target + '.bak-' + new Date().toISOString().replace(/[:.]/g, '-');
  fs.copyFileSync(target, backup, fs.constants.COPYFILE_EXCL);
  fs.writeFileSync(target, updated, 'utf8');
  console.log('Windows Terminal shortcuts updated. Backup: ' + backup);
}

if (require.main === module) {
  try { main(); } catch (error) { console.error(error.message); process.exitCode = 1; }
}
module.exports = { patch, cleanJsonc };
