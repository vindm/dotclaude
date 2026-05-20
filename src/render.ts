import Mustache from 'mustache';

// Mustache HTML-escapes by default. We're rendering shell scripts and config
// files — never HTML — so disable escape globally.
Mustache.escape = (text) => text;

export function renderTemplate(template: string, vars: Record<string, unknown>): string {
  return Mustache.render(template, vars);
}
