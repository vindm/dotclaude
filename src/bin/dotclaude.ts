#!/usr/bin/env node
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { runInit } from '../commands/init.js';

// Locate dotclaude package root. In dev (tsx): parent of src/. In published (built): parent of dist/.
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const DOTCLAUDE_ROOT = resolve(__dirname, '../..');

interface ParsedArgs {
  command: string;
  flags: Record<string, string | boolean>;
}

function parseArgs(argv: string[]): ParsedArgs {
  const [, , command = 'help', ...rest] = argv;
  const flags: Record<string, string | boolean> = {};
  for (const arg of rest) {
    if (arg.startsWith('--')) {
      const [key, value] = arg.slice(2).split('=');
      flags[key] = value ?? true;
    }
  }
  return { command, flags };
}

async function main() {
  const { command, flags } = parseArgs(process.argv);

  if (command === 'init') {
    const profileName = (flags.profile as string) || 'minimal';
    const projectName = (flags.project as string) || 'untitled';
    const targetRepo = process.cwd();
    const force = flags.force === true;
    const noInteractive = flags['no-interactive'] === true;

    if (!noInteractive) {
      throw new Error('Interactive mode not implemented yet (Task 9). Pass --no-interactive.');
    }

    await runInit({ profileName, projectName, targetRepo, dotclaudeRoot: DOTCLAUDE_ROOT, force });
  } else if (command === 'help' || command === '--help' || command === '-h') {
    console.log('dotclaude — Claude Code workflow pack generator');
    console.log('');
    console.log('Usage:');
    console.log('  npx dotclaude init [--profile=X] [--project=Y] [--no-interactive] [--force]');
    console.log('');
    console.log('Commands:');
    console.log('  init    Initialize .claude/ in the current directory');
    process.exit(0);
  } else {
    console.error(`Unknown command: ${command}`);
    process.exit(1);
  }
}

main().catch((err) => {
  console.error(err.message);
  process.exit(1);
});
