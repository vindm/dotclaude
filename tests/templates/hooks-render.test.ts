import { describe, it, expect } from 'vitest';
import { readFileSync } from 'node:fs';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { renderTemplate } from '../../src/render.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

describe('check-file-size.sh template', () => {
  const tpl = readFileSync(resolve(__dirname, '../../templates/hooks/check-file-size.sh'), 'utf8');

  it('substitutes ceiling and warn values', () => {
    const out = renderTemplate(tpl, { fileSize: { ceiling: 1500, warn: 1400 } });
    expect(out).toContain('CEILING=1500');
    expect(out).toContain('WARN=1400');
  });

  it('does not contain raw mustache placeholders after render', () => {
    const out = renderTemplate(tpl, { fileSize: { ceiling: 1000, warn: 950 } });
    expect(out).not.toContain('{{');
    expect(out).not.toContain('}}');
  });
});

describe('check-forbidden-phrases.sh template', () => {
  const tpl = readFileSync(
    resolve(__dirname, '../../templates/hooks/check-forbidden-phrases.sh'),
    'utf8',
  );

  it('substitutes forbidden phrases list', () => {
    const out = renderTemplate(tpl, {
      forbiddenPhrases: {
        phrases: ['As an AI', 'Let me help you'],
        scopes: ['lib/**/*.ts'],
      },
    });
    expect(out).toContain('As an AI');
    expect(out).toContain('Let me help you');
    expect(out).toContain('lib/**/*.ts');
  });

  it('handles empty phrases gracefully', () => {
    const out = renderTemplate(tpl, {
      forbiddenPhrases: { phrases: [], scopes: ['src/**/*.ts'] },
    });
    expect(out).not.toContain('{{');
    expect(out).not.toContain('}}');
    expect(out).toContain('src/**/*.ts');
  });

  it('handles empty scopes gracefully', () => {
    const out = renderTemplate(tpl, {
      forbiddenPhrases: { phrases: ['foo'], scopes: [] },
    });
    expect(out).not.toContain('{{');
    expect(out).not.toContain('}}');
  });
});

describe('git-context-sessionstart.sh template', () => {
  const tpl = readFileSync(
    resolve(__dirname, '../../templates/hooks/git-context-sessionstart.sh'),
    'utf8',
  );
  it('renders without unsubstituted placeholders', () => {
    const out = renderTemplate(tpl, {});
    expect(out).not.toContain('{{');
    expect(out).not.toContain('}}');
  });
});
