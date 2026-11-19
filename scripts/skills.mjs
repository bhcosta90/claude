#!/usr/bin/env node
// Skills externas: o skills.lock.json do repo guarda só nome e origem de cada
// skill instalada com `npx skills` (lidas de ~/.agents/.skill-lock.json).
// Datas e hashes ficam de fora para não gerar commits a cada reinstalação.
//
//   node scripts/skills.mjs           -> "<source> <skill>" por linha, para instalar
//   node scripts/skills.mjs snapshot  -> imprime o skills.lock.json a partir do lock local

import { readFileSync } from 'node:fs';
import { homedir } from 'node:os';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const repoLock = join(root, 'skills.lock.json');
const agentsLock = join(homedir(), '.agents', '.skill-lock.json');

const KEEP = ['source', 'sourceType', 'sourceUrl', 'skillPath'];

if (process.argv[2] === 'snapshot') {
  const lock = JSON.parse(readFileSync(agentsLock, 'utf8'));
  const skills = Object.fromEntries(
    Object.entries(lock.skills ?? {})
      .sort(([a], [b]) => a.localeCompare(b))
      .map(([name, info]) => [name, Object.fromEntries(KEEP.map((key) => [key, info[key]]))]),
  );
  process.stdout.write(`${JSON.stringify({ skills }, null, 2)}\n`);
} else {
  const lock = JSON.parse(readFileSync(repoLock, 'utf8'));
  Object.entries(lock.skills ?? {})
    .sort(([a], [b]) => a.localeCompare(b))
    .forEach(([name, info]) => console.log(`${info.source} ${name}`));
}
