import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { mkdtempSync, rmSync, existsSync, readFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { renderProfile } from '../src/orchestrate.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const dotclaudeRoot = resolve(__dirname, '..');

let tmpRepo: string;

beforeEach(() => {
  tmpRepo = mkdtempSync(resolve(tmpdir(), 'dotclaude-orch-'));
});

afterEach(() => {
  rmSync(tmpRepo, { recursive: true, force: true });
});

describe('renderProfile (minimal)', () => {
  it('writes .claude/hooks/check-file-size.sh', async () => {
    await renderProfile({
      profileName: 'minimal',
      targetRepo: tmpRepo,
      dotclaudeRoot,
      projectName: 'acme',
    });
    const hookPath = resolve(tmpRepo, '.claude/hooks/check-file-size.sh');
    expect(existsSync(hookPath)).toBe(true);
    const content = readFileSync(hookPath, 'utf8');
    expect(content).toContain('CEILING=1000');
    expect(content).toContain('WARN=950');
  });

  it('writes dotclaude.yml', async () => {
    await renderProfile({
      profileName: 'minimal',
      targetRepo: tmpRepo,
      dotclaudeRoot,
      projectName: 'acme',
    });
    const cfgPath = resolve(tmpRepo, 'dotclaude.yml');
    expect(existsSync(cfgPath)).toBe(true);
    const content = readFileSync(cfgPath, 'utf8');
    expect(content).toContain('profile: minimal');
    expect(content).toContain('projectName: acme');
  });

  it('honors override defaults', async () => {
    await renderProfile({
      profileName: 'minimal',
      targetRepo: tmpRepo,
      dotclaudeRoot,
      projectName: 'acme',
      overrideDefaults: { fileSize: { ceiling: 1500, warn: 1400 } },
    });
    const hookPath = resolve(tmpRepo, '.claude/hooks/check-file-size.sh');
    const content = readFileSync(hookPath, 'utf8');
    expect(content).toContain('CEILING=1500');
    expect(content).toContain('WARN=1400');
  });

  it('renders both hooks from minimal profile', async () => {
    await renderProfile({
      profileName: 'minimal',
      targetRepo: tmpRepo,
      dotclaudeRoot,
      projectName: 'acme',
    });
    expect(existsSync(resolve(tmpRepo, '.claude/hooks/check-file-size.sh'))).toBe(true);
    expect(existsSync(resolve(tmpRepo, '.claude/hooks/check-forbidden-phrases.sh'))).toBe(true);
  });

  it('rendered hook is executable', async () => {
    await renderProfile({
      profileName: 'minimal',
      targetRepo: tmpRepo,
      dotclaudeRoot,
      projectName: 'acme',
    });
    const { statSync } = await import('node:fs');
    const hookPath = resolve(tmpRepo, '.claude/hooks/check-file-size.sh');
    const stat = statSync(hookPath);
    // Owner execute bit set (0o100 in mode)
    expect(stat.mode & 0o100).toBeTruthy();
  });

  it('does not crash when profile has empty rules/skills/agents', async () => {
    // minimal profile has hooks but empty rules/skills/agents arrays.
    // The grouped loop should iterate zero times for those types without error.
    await expect(
      renderProfile({
        profileName: 'minimal',
        targetRepo: tmpRepo,
        dotclaudeRoot,
        projectName: 'acme',
      }),
    ).resolves.toBeUndefined();
    // And NO non-hook directories should be created (renderArtifact only mkdirs when it actually renders).
    expect(existsSync(resolve(tmpRepo, '.claude/rules'))).toBe(false);
    expect(existsSync(resolve(tmpRepo, '.claude/skills'))).toBe(false);
    expect(existsSync(resolve(tmpRepo, '.claude/agents'))).toBe(false);
  });
});
