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

  it('loads web-saas profile', () => {
    const profile = loadProfile('web-saas', profilesDir);
    expect(profile.name).toBe('web-saas');
    expect(profile.hooks.length).toBeGreaterThanOrEqual(9);
    expect(profile.defaults.fileSize.ceiling).toBe(800);
    expect(profile.defaults.database).toBe('postgres');
  });

  it('loads mobile-rn profile', () => {
    const profile = loadProfile('mobile-rn', profilesDir);
    expect(profile.name).toBe('mobile-rn');
    expect(profile.hooks).toContain('check-prebuild-required');
    expect(profile.defaults.visualVerification?.tool).toBe('simctl');
    expect(profile.defaults.fileSize.ceiling).toBe(1000);
  });

  it('loads api-only profile', () => {
    const profile = loadProfile('api-only', profilesDir);
    expect(profile.name).toBe('api-only');
    expect(profile.hooks).not.toContain('check-design-tokens');
    expect(profile.defaults.fileSize.ceiling).toBe(1200);
    expect(profile.defaults.database).toBe('postgres');
  });

  it('loads full-stack profile', () => {
    const profile = loadProfile('full-stack', profilesDir);
    expect(profile.name).toBe('full-stack');
    expect(profile.hooks.length).toBeGreaterThanOrEqual(11);
    expect(profile.rules.length).toBeGreaterThanOrEqual(4);
  });
});
