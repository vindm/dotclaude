import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { mkdtempSync, rmSync, existsSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { execSync } from 'node:child_process';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const dotclaudeRoot = resolve(__dirname, '..');
const cliBin = resolve(dotclaudeRoot, 'src/bin/dotclaude.ts');

let tmpRepo: string;

beforeEach(() => {
  tmpRepo = mkdtempSync(resolve(tmpdir(), 'dotclaude-cli-'));
});

afterEach(() => {
  rmSync(tmpRepo, { recursive: true, force: true });
});

function run(args: string, opts: { cwd: string } = { cwd: tmpRepo }) {
  return execSync(`npx tsx ${cliBin} ${args}`, {
    cwd: opts.cwd,
    stdio: 'pipe',
    encoding: 'utf8',
  });
}

describe('CLI init (non-interactive)', () => {
  it('initializes minimal profile in target repo', () => {
    run('init --profile=minimal --project=acme --no-interactive');
    expect(existsSync(resolve(tmpRepo, '.claude/hooks/check-file-size.sh'))).toBe(true);
    expect(existsSync(resolve(tmpRepo, '.claude/hooks/check-forbidden-phrases.sh'))).toBe(true);
    expect(existsSync(resolve(tmpRepo, 'dotclaude.yml'))).toBe(true);
  });

  it('refuses to overwrite existing .claude/', () => {
    run('init --profile=minimal --project=acme --no-interactive');
    expect(() => run('init --profile=minimal --project=acme --no-interactive')).toThrow();
  });

  it('allows --force overwrite', () => {
    run('init --profile=minimal --project=acme --no-interactive');
    // Second run with --force must succeed
    expect(() =>
      run('init --profile=minimal --project=acme --no-interactive --force'),
    ).not.toThrow();
    expect(existsSync(resolve(tmpRepo, 'dotclaude.yml'))).toBe(true);
  });
});
