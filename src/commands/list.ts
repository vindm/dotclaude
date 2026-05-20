import { readdirSync, existsSync } from 'node:fs';
import { resolve } from 'node:path';

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
  console.log('Available hook templates:');
  const hooksDir = resolve(dotclaudeRoot, 'templates/hooks');
  if (existsSync(hooksDir)) {
    for (const file of readdirSync(hooksDir)) {
      if (file.endsWith('.sh')) {
        console.log(`  - ${file.replace(/\.sh$/, '')}`);
      }
    }
  } else {
    console.log('  (no hook templates directory found)');
  }
}
