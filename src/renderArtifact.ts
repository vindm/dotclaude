import {
  mkdirSync,
  readFileSync,
  writeFileSync,
  chmodSync,
  existsSync,
  statSync,
  readdirSync,
} from 'node:fs';
import { resolve } from 'node:path';
import { renderTemplate } from './render.js';
import type { ArtifactType } from './types.js';

export interface RenderArtifactArgs {
  type: ArtifactType;
  name: string;
  targetRepo: string;
  dotclaudeRoot: string;
  ctx: Record<string, unknown>;
}

interface TypeConfig {
  srcDir: string;
  targetSubdir: string;
  ext: string;
  executable: boolean;
  isDirectory: boolean;
}

const TYPE_CONFIG: Record<ArtifactType, TypeConfig> = {
  hook: { srcDir: 'templates/hooks', targetSubdir: '.claude/hooks', ext: '.sh', executable: true, isDirectory: false },
  rule: { srcDir: 'templates/rules', targetSubdir: '.claude/rules', ext: '.md', executable: false, isDirectory: false },
  agent: { srcDir: 'templates/agents', targetSubdir: '.claude/agents', ext: '.md', executable: false, isDirectory: false },
  skill: { srcDir: 'templates/skills', targetSubdir: '.claude/skills', ext: '', executable: false, isDirectory: true },
};

export async function renderArtifact(args: RenderArtifactArgs): Promise<void> {
  const { type, name, targetRepo, dotclaudeRoot, ctx } = args;
  const cfg = TYPE_CONFIG[type];

  const srcPath = resolve(dotclaudeRoot, cfg.srcDir, name + cfg.ext);
  if (!existsSync(srcPath)) {
    throw new Error(`Artifact "${name}" (type=${type}) not found at ${srcPath}`);
  }

  const targetDir = resolve(targetRepo, cfg.targetSubdir);
  mkdirSync(targetDir, { recursive: true });

  if (cfg.isDirectory) {
    const targetSkillDir = resolve(targetDir, name);
    mkdirSync(targetSkillDir, { recursive: true });
    copyDirRendered(srcPath, targetSkillDir, ctx);
  } else {
    const tpl = readFileSync(srcPath, 'utf8');
    const rendered = renderTemplate(tpl, ctx);
    const outPath = resolve(targetDir, name + cfg.ext);
    writeFileSync(outPath, rendered, 'utf8');
    if (cfg.executable) chmodSync(outPath, 0o755);
  }
}

function copyDirRendered(srcDir: string, destDir: string, ctx: Record<string, unknown>): void {
  for (const entry of readdirSync(srcDir)) {
    const srcEntry = resolve(srcDir, entry);
    const destEntry = resolve(destDir, entry);
    if (statSync(srcEntry).isDirectory()) {
      mkdirSync(destEntry, { recursive: true });
      copyDirRendered(srcEntry, destEntry, ctx);
    } else {
      const tpl = readFileSync(srcEntry, 'utf8');
      const rendered = renderTemplate(tpl, ctx);
      writeFileSync(destEntry, rendered, 'utf8');
    }
  }
}
