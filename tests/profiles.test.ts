import { describe, it, expect } from 'vitest';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { loadProfile } from '../src/profiles.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const profilesDir = resolve(__dirname, '../profiles');

describe('loadProfile', () => {
  it('loads minimal profile', () => {
    const profile = loadProfile('minimal', profilesDir);
    expect(profile.name).toBe('minimal');
    expect(profile.hooks).toContain('check-file-size');
    expect(profile.hooks).toContain('check-forbidden-phrases');
    expect(profile.defaults.fileSize.ceiling).toBe(1000);
    expect(profile.defaults.fileSize.warn).toBe(950);
  });

  it('throws for unknown profile', () => {
    expect(() => loadProfile('nonexistent', profilesDir)).toThrow(/not found/i);
  });

  it('parses forbiddenPhrases defaults', () => {
    const profile = loadProfile('minimal', profilesDir);
    expect(profile.defaults.forbiddenPhrases).toBeDefined();
    expect(profile.defaults.forbiddenPhrases?.phrases).toBeInstanceOf(Array);
    expect(profile.defaults.forbiddenPhrases?.phrases.length).toBeGreaterThan(0);
  });
});
