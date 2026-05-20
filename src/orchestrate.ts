import { mkdirSync, readFileSync, writeFileSync, chmodSync } from 'node:fs';
import { resolve } from 'node:path';
import { loadProfile } from './profiles.js';
import { renderTemplate } from './render.js';
import { writeConfig } from './config.js';
import type { ProfileDefaults } from './types.js';

export interface RenderProfileArgs {
  profileName: string;
  targetRepo: string;
  dotclaudeRoot: string;
  projectName: string;
  overrideDefaults?: Partial<ProfileDefaults>;
}

export async function renderProfile(args: RenderProfileArgs): Promise<void> {
  const { profileName, targetRepo, dotclaudeRoot, projectName, overrideDefaults } = args;

  const profile = loadProfile(profileName, resolve(dotclaudeRoot, 'profiles'));
  const defaults: ProfileDefaults = { ...profile.defaults, ...overrideDefaults };

  // Render hooks
  const hooksDir = resolve(targetRepo, '.claude/hooks');
  mkdirSync(hooksDir, { recursive: true });
  for (const hook of profile.hooks) {
    try {
      const srcPath = resolve(dotclaudeRoot, 'templates/hooks', `${hook}.sh`);
      const tpl = readFileSync(srcPath, 'utf8');
      const rendered = renderTemplate(tpl, defaults as unknown as Record<string, unknown>);
      const outPath = resolve(hooksDir, `${hook}.sh`);
      writeFileSync(outPath, rendered, 'utf8');
      chmodSync(outPath, 0o755);
    } catch (err) {
      console.warn(`⚠️  Skipped hook "${hook}": ${(err as Error).message}`);
      continue;
    }
  }

  // Write dotclaude.yml
  writeConfig(targetRepo, {
    profile: profileName,
    projectName,
    defaults,
  });
}
