import { describe, it, expect } from 'vitest';
import { readFileSync } from 'node:fs';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { renderTemplate } from '../../src/render.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

describe('check-file-size.sh template', () => {
  const tpl = readFileSync(
    resolve(__dirname, '../../templates/hooks/check-file-size.sh'),
    'utf8',
  );

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
