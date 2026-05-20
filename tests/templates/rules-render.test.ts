import { describe, it, expect } from 'vitest';
import { readFileSync } from 'node:fs';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { renderTemplate } from '../../src/render.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

describe('file-discipline.md rule template', () => {
  const tpl = readFileSync(resolve(__dirname, '../../templates/rules/file-discipline.md'), 'utf8');
  it('renders with {{fileSize.ceiling}}', () => {
    const out = renderTemplate(tpl, { fileSize: { ceiling: 1000 } });
    expect(out).toContain('1000');
    expect(out).not.toContain('{{');
  });
});

describe('audit-routing.md rule template', () => {
  const tpl = readFileSync(resolve(__dirname, '../../templates/rules/audit-routing.md'), 'utf8');
  it('renders without unsubstituted placeholders', () => {
    const out = renderTemplate(tpl, {});
    expect(out).not.toContain('{{');
  });
});

describe('visual-verification.md rule template', () => {
  const tpl = readFileSync(
    resolve(__dirname, '../../templates/rules/visual-verification.md'),
    'utf8',
  );
  it('renders without unsubstituted placeholders', () => {
    const out = renderTemplate(tpl, {});
    expect(out).not.toContain('{{');
  });
});

describe('database-query-discipline.md rule template', () => {
  const tpl = readFileSync(
    resolve(__dirname, '../../templates/rules/database-query-discipline.md'),
    'utf8',
  );
  it('renders without unsubstituted placeholders', () => {
    const out = renderTemplate(tpl, {});
    expect(out).not.toContain('{{');
  });
});
