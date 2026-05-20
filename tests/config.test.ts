import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { mkdtempSync, rmSync, readFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { resolve } from 'node:path';
import { readConfig, writeConfig } from '../src/config.js';

let tmpDir: string;

beforeEach(() => {
  tmpDir = mkdtempSync(resolve(tmpdir(), 'dotclaude-test-'));
});

afterEach(() => {
  rmSync(tmpDir, { recursive: true, force: true });
});

describe('config', () => {
  it('returns null when dotclaude.yml absent', () => {
    expect(readConfig(tmpDir)).toBeNull();
  });

  it('roundtrips a config', () => {
    const cfg = {
      profile: 'minimal',
      projectName: 'test-project',
      defaults: { fileSize: { ceiling: 800, warn: 700 } },
    };
    writeConfig(tmpDir, cfg);
    const loaded = readConfig(tmpDir);
    expect(loaded).toEqual(cfg);
  });

  it('preserves managed header in output', () => {
    const cfg = {
      profile: 'minimal',
      projectName: 'test-project',
      defaults: { fileSize: { ceiling: 1000, warn: 950 } },
    };
    writeConfig(tmpDir, cfg);
    const raw = readFileSync(resolve(tmpDir, 'dotclaude.yml'), 'utf8');
    expect(raw).toContain('# Managed by dotclaude');
  });
});
