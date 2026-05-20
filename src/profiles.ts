import { readFileSync, existsSync } from 'node:fs';
import { resolve } from 'node:path';
import { load as yamlLoad } from 'js-yaml';
import type { Profile } from './types.js';

export function loadProfile(name: string, profilesDir: string): Profile {
  const path = resolve(profilesDir, `${name}.yml`);
  if (!existsSync(path)) {
    throw new Error(`Profile "${name}" not found at ${path}`);
  }
  const raw = readFileSync(path, 'utf8');
  const parsed = yamlLoad(raw) as Profile;
  return parsed;
}
