import { existsSync, readFileSync, writeFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { load as yamlLoad, dump as yamlDump } from 'js-yaml';
import type { DotclaudeConfig } from './types.js';

const CONFIG_FILENAME = 'dotclaude.yml';
const HEADER = `# Managed by dotclaude — edit with care.
# Re-run \`npx dotclaude update\` to apply template upgrades.
`;

export function readConfig(repoRoot: string): DotclaudeConfig | null {
  const path = resolve(repoRoot, CONFIG_FILENAME);
  if (!existsSync(path)) return null;
  return yamlLoad(readFileSync(path, 'utf8')) as DotclaudeConfig;
}

export function writeConfig(repoRoot: string, cfg: DotclaudeConfig): void {
  const path = resolve(repoRoot, CONFIG_FILENAME);
  const body = yamlDump(cfg, { lineWidth: 100, noRefs: true });
  writeFileSync(path, HEADER + body, 'utf8');
}
