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

describe('auto-lint-posttool.sh template', () => {
  const tpl = readFileSync(
    resolve(__dirname, '../../templates/hooks/auto-lint-posttool.sh'),
    'utf8',
  );
  it('uses default lint command when none configured', () => {
    const out = renderTemplate(tpl, {});
    expect(out).toContain('npx eslint --fix');
    expect(out).not.toContain('{{');
  });
  it('substitutes configured lint command', () => {
    const out = renderTemplate(tpl, { lint: { command: 'yarn lint --fix' } });
    expect(out).toContain('yarn lint --fix');
    expect(out).not.toContain('{{');
  });
});

describe('check-import-boundary.sh template', () => {
  const tpl = readFileSync(
    resolve(__dirname, '../../templates/hooks/check-import-boundary.sh'),
    'utf8',
  );
  it('substitutes boundary rules', () => {
    const out = renderTemplate(tpl, {
      importBoundary: {
        rules: [
          { from: 'features/auth', to: 'features/billing', message: 'auth cannot reach billing' },
        ],
      },
    });
    expect(out).toContain('features/auth');
    expect(out).toContain('features/billing');
    expect(out).toContain('auth cannot reach billing');
  });
});

describe('check-design-tokens.sh template', () => {
  const tpl = readFileSync(
    resolve(__dirname, '../../templates/hooks/check-design-tokens.sh'),
    'utf8',
  );
  it('uses default theme path when none configured', () => {
    const out = renderTemplate(tpl, {});
    expect(out).toContain('src/theme/');
    expect(out).not.toContain('{{');
  });
  it('substitutes configured theme path', () => {
    const out = renderTemplate(tpl, { designTokens: { theme: 'lib/theme/' } });
    expect(out).toContain('lib/theme/');
    expect(out).not.toContain('{{');
  });
});

describe('regen-generated-artifacts.sh template', () => {
  const tpl = readFileSync(
    resolve(__dirname, '../../templates/hooks/regen-generated-artifacts.sh'),
    'utf8',
  );
  it('substitutes configured regen command', () => {
    const out = renderTemplate(tpl, { regenCommand: 'yarn db:types' });
    expect(out).toContain('yarn db:types');
    expect(out).not.toContain('{{');
  });
  it('renders to empty COMMAND when none configured (graceful no-op)', () => {
    const out = renderTemplate(tpl, {});
    expect(out).toContain('COMMAND=""');
    expect(out).not.toContain('{{');
  });
});

describe('check-bash-safety.sh template', () => {
  const tpl = readFileSync(
    resolve(__dirname, '../../templates/hooks/check-bash-safety.sh'),
    'utf8',
  );
  it('renders without unsubstituted placeholders', () => {
    const out = renderTemplate(tpl, {});
    expect(out).not.toContain('{{');
    expect(out).not.toContain('}}');
  });
});

describe('check-no-todo-comments.sh template', () => {
  const tpl = readFileSync(
    resolve(__dirname, '../../templates/hooks/check-no-todo-comments.sh'),
    'utf8',
  );
  it('warns (exit 0) by default', () => {
    const out = renderTemplate(tpl, {});
    expect(out).toContain('exit 0');
    expect(out).not.toContain('{{');
  });
  it('blocks (exit 2) when todoBlock is true', () => {
    const out = renderTemplate(tpl, { todoBlock: true });
    expect(out).toContain('exit 2');
    expect(out).not.toContain('{{');
  });
});

describe('check-secret-leak.sh template', () => {
  const tpl = readFileSync(
    resolve(__dirname, '../../templates/hooks/check-secret-leak.sh'),
    'utf8',
  );
  it('renders without unsubstituted placeholders', () => {
    const out = renderTemplate(tpl, {});
    expect(out).not.toContain('{{');
    expect(out).not.toContain('}}');
  });
});
