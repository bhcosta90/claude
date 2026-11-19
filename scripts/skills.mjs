#!/usr/bin/env node
// Lista as skills externas do skills.lock.json (cópia versionada do
// ~/.agents/.skill-lock.json), uma por linha: "<source> <skill>".

import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const lock = JSON.parse(readFileSync(join(root, 'skills.lock.json'), 'utf8'));

Object.entries(lock.skills ?? {})
  .sort(([a], [b]) => a.localeCompare(b))
  .forEach(([name, info]) => console.log(`${info.source} ${name}`));
