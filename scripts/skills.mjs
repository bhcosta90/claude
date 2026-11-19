#!/usr/bin/env node
// Lê o skills.lock.json (cópia versionada do ~/.agents/.skill-lock.json).
//
//   node scripts/skills.mjs list       -> "<source> <skill>" por linha, para instalar
//   node scripts/skills.mjs gitignore  -> reescreve o bloco gerenciado do .gitignore

import { readFileSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const lockPath = join(root, 'skills.lock.json');
const gitignorePath = join(root, '.gitignore');

const BEGIN = '# >>> skills externas (gerado por `make skills-sync`, não editar)';
const END = '# <<< skills externas';

const lock = JSON.parse(readFileSync(lockPath, 'utf8'));
const skills = Object.entries(lock.skills ?? {}).sort(([a], [b]) => a.localeCompare(b));

const command = process.argv[2];

if (command === 'list') {
  for (const [name, info] of skills) console.log(`${info.source} ${name}`);
} else if (command === 'gitignore') {
  const block = [BEGIN, ...skills.map(([name]) => `skills/${name}/`), END].join('\n');
  const current = readFileSync(gitignorePath, 'utf8');
  const pattern = new RegExp(`${escape(BEGIN)}[\\s\\S]*?${escape(END)}`);
  const next = pattern.test(current)
    ? current.replace(pattern, block)
    : `${current.trimEnd()}\n\n${block}\n`;
  writeFileSync(gitignorePath, next);
} else {
  console.error('Uso: node scripts/skills.mjs <list|gitignore>');
  process.exit(1);
}

function escape(text) {
  return text.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}
