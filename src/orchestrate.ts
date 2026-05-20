import { resolve } from 'node:path';
import { loadProfile } from './profiles.js';
import { renderArtifact } from './renderArtifact.js';
import { writeConfig } from './config.js';
import type { ProfileDefaults, ArtifactType } from './types.js';

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
  const ctx = defaults as unknown as Record<string, unknown>;

  const groups: Array<{ type: ArtifactType; names: string[] }> = [
    { type: 'hook', names: profile.hooks },
    { type: 'rule', names: profile.rules },
    { type: 'skill', names: profile.skills },
    { type: 'agent', names: profile.agents },
  ];

  for (const group of groups) {
    for (const name of group.names) {
      try {
        await renderArtifact({ type: group.type, name, targetRepo, dotclaudeRoot, ctx });
      } catch (err) {
        console.warn(`⚠️  Skipped ${group.type} "${name}": ${(err as Error).message}`);
      }
    }
  }

  writeConfig(targetRepo, { profile: profileName, projectName, defaults });
}
