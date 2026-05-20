import { readdirSync, existsSync } from 'node:fs';
import { resolve } from 'node:path';
import type { ArtifactType } from '../types.js';

interface ArtifactSourceDir {
  dir: string;
  ext: string;
  isDirectory: boolean;
}

const TYPE_DIRS: Record<ArtifactType, ArtifactSourceDir> = {
  hook: { dir: 'templates/hooks', ext: '.sh', isDirectory: false },
  rule: { dir: 'templates/rules', ext: '.md', isDirectory: false },
  skill: { dir: 'templates/skills', ext: '', isDirectory: true },
  agent: { dir: 'templates/agents', ext: '.md', isDirectory: false },
};

export async function runList(dotclaudeRoot: string): Promise<void> {
  console.log('Available profiles:');
  const profilesDir = resolve(dotclaudeRoot, 'profiles');
  if (existsSync(profilesDir)) {
    for (const file of readdirSync(profilesDir)) {
      if (file.endsWith('.yml')) {
        console.log(`  - ${file.replace(/\.yml$/, '')}`);
      }
    }
  } else {
    console.log('  (no profiles directory found)');
  }
  console.log('');

  const entries = Object.entries(TYPE_DIRS) as Array<[ArtifactType, ArtifactSourceDir]>;
  for (const [type, cfg] of entries) {
    console.log(`Available ${type} templates:`);
    const tdir = resolve(dotclaudeRoot, cfg.dir);
    if (existsSync(tdir)) {
      const names = readdirSync(tdir);
      if (names.length === 0) {
        console.log(`  (none)`);
      } else {
        for (const file of names) {
          if (cfg.isDirectory) {
            console.log(`  - ${file}`);
          } else if (file.endsWith(cfg.ext)) {
            console.log(`  - ${file.replace(new RegExp(`\\${cfg.ext}$`), '')}`);
          }
        }
      }
    } else {
      console.log(`  (no ${type} templates directory yet)`);
    }
    console.log('');
  }
}
