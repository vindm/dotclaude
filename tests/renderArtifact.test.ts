import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { mkdtempSync, rmSync, existsSync, readFileSync, statSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { renderArtifact } from '../src/renderArtifact.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const dotclaudeRoot = resolve(__dirname, '..');

let tmpRepo: string;

beforeEach(() => {
  tmpRepo = mkdtempSync(resolve(tmpdir(), 'dotclaude-ra-'));
});

afterEach(() => {
  rmSync(tmpRepo, { recursive: true, force: true });
});

describe('renderArtifact', () => {
  it('hook: renders to .claude/hooks/<name>.sh and is executable', async () => {
    await renderArtifact({
      type: 'hook',
      name: 'check-file-size',
      targetRepo: tmpRepo,
      dotclaudeRoot,
      ctx: { fileSize: { ceiling: 1500, warn: 1400 } },
    });
    const outPath = resolve(tmpRepo, '.claude/hooks/check-file-size.sh');
    expect(existsSync(outPath)).toBe(true);
    expect(readFileSync(outPath, 'utf8')).toContain('CEILING=1500');
    expect(statSync(outPath).mode & 0o100).toBeTruthy();
  });

  it('throws clearly when artifact name not found', async () => {
    await expect(
      renderArtifact({
        type: 'hook',
        name: 'nonexistent-hook',
        targetRepo: tmpRepo,
        dotclaudeRoot,
        ctx: {},
      }),
    ).rejects.toThrow(/nonexistent-hook/);
  });
});
