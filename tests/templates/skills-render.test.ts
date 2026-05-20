import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { mkdtempSync, rmSync, existsSync, readFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { renderArtifact } from '../../src/renderArtifact.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const dotclaudeRoot = resolve(__dirname, '../..');

let tmpRepo: string;

beforeEach(() => {
  tmpRepo = mkdtempSync(resolve(tmpdir(), 'dotclaude-skill-'));
});

afterEach(() => {
  rmSync(tmpRepo, { recursive: true, force: true });
});

describe('skill artifact', () => {
  it('copies decompose-file directory to .claude/skills/decompose-file/SKILL.md with substitution', async () => {
    await renderArtifact({
      type: 'skill',
      name: 'decompose-file',
      targetRepo: tmpRepo,
      dotclaudeRoot,
      ctx: { fileSize: { ceiling: 1000 } },
    });
    const skillFile = resolve(tmpRepo, '.claude/skills/decompose-file/SKILL.md');
    expect(existsSync(skillFile)).toBe(true);
    const content = readFileSync(skillFile, 'utf8');
    expect(content).toContain('1000');
    expect(content).not.toContain('{{');
  });

  it('copies journey-audit skill', async () => {
    await renderArtifact({
      type: 'skill',
      name: 'journey-audit',
      targetRepo: tmpRepo,
      dotclaudeRoot,
      ctx: {},
    });
    expect(existsSync(resolve(tmpRepo, '.claude/skills/journey-audit/SKILL.md'))).toBe(true);
  });
});
