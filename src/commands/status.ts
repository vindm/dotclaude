import { readConfig } from '../config.js';

export async function runStatus(targetRepo: string): Promise<void> {
  const cfg = readConfig(targetRepo);
  if (!cfg) {
    console.log(`No dotclaude.yml found at ${targetRepo}. Run \`npx dotclaude init\` first.`);
    process.exit(1);
  }
  console.log(`Profile: ${cfg.profile}`);
  console.log(`Project: ${cfg.projectName}`);
  console.log(`File-size ceiling: ${cfg.defaults.fileSize.ceiling}`);
  if (cfg.defaults.forbiddenPhrases) {
    console.log(`Forbidden phrases: ${cfg.defaults.forbiddenPhrases.phrases.length}`);
  }
}
