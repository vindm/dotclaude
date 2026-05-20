import { existsSync } from 'node:fs';
import { resolve } from 'node:path';
import { renderProfile } from '../orchestrate.js';
import type { ProfileDefaults } from '../types.js';

export interface InitArgs {
  profileName: string;
  projectName: string;
  targetRepo: string;
  dotclaudeRoot: string;
  force?: boolean;
  overrideDefaults?: Partial<ProfileDefaults>;
}

export async function runInit(args: InitArgs): Promise<void> {
  const { profileName, projectName, targetRepo, dotclaudeRoot, force, overrideDefaults } = args;

  const claudeDir = resolve(targetRepo, '.claude');
  if (existsSync(claudeDir) && !force) {
    throw new Error(
      `.claude/ already exists at ${claudeDir}. Pass --force to overwrite, or run \`dotclaude update\` to merge.`,
    );
  }

  await renderProfile({
    profileName,
    targetRepo,
    dotclaudeRoot,
    projectName,
    overrideDefaults,
  });

  console.log(`✓ Initialized profile "${profileName}" in ${targetRepo}`);
  console.log(`✓ Wrote .claude/ and dotclaude.yml`);
  console.log(`\nNext: review .claude/CLAUDE.md, customize as needed, commit.`);
}
