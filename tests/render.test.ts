import { describe, it, expect } from 'vitest';
import { renderTemplate } from '../src/render.js';

describe('renderTemplate', () => {
  it('substitutes mustache variables', () => {
    const tpl = 'Hello {{name}}!';
    const out = renderTemplate(tpl, { name: 'World' });
    expect(out).toBe('Hello World!');
  });

  it('handles missing variables as empty string', () => {
    const tpl = 'Hello {{name}}!';
    const out = renderTemplate(tpl, {});
    expect(out).toBe('Hello !');
  });

  it('preserves shell heredoc and dollar-vars', () => {
    const tpl = 'cat <<EOF\nPATH=$HOME/{{project}}\nEOF';
    const out = renderTemplate(tpl, { project: 'foo' });
    expect(out).toBe('cat <<EOF\nPATH=$HOME/foo\nEOF');
  });

  it('handles nested object values', () => {
    const tpl = 'ceiling: {{fileSize.ceiling}}';
    const out = renderTemplate(tpl, { fileSize: { ceiling: 1000 } });
    expect(out).toBe('ceiling: 1000');
  });

  it('does NOT escape HTML/quotes in output', () => {
    const tpl = '{{cmd}}';
    const out = renderTemplate(tpl, { cmd: 'grep "<file>"' });
    expect(out).toBe('grep "<file>"');
  });
});
