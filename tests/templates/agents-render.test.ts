import { describe, it, expect } from 'vitest';
import { readFileSync } from 'node:fs';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { renderTemplate } from '../../src/render.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

describe('pre-flight.md agent', () => {
  const tpl = readFileSync(resolve(__dirname, '../../templates/agents/pre-flight.md'), 'utf8');
  it('renders without raw placeholders', () => {
    const out = renderTemplate(tpl, {});
    expect(out).not.toContain('{{');
  });
});

describe('code-reviewer.md agent', () => {
  const tpl = readFileSync(resolve(__dirname, '../../templates/agents/code-reviewer.md'), 'utf8');
  it('renders without raw placeholders', () => {
    const out = renderTemplate(tpl, {});
    expect(out).not.toContain('{{');
  });
});

describe('interaction-audit.md agent', () => {
  const tpl = readFileSync(
    resolve(__dirname, '../../templates/agents/interaction-audit.md'),
    'utf8',
  );
  it('renders without raw placeholders', () => {
    const out = renderTemplate(tpl, {});
    expect(out).not.toContain('{{');
  });
});
