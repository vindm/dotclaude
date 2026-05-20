import prompts from 'prompts';
import { readdirSync } from 'node:fs';
import { resolve } from 'node:path';

export interface InteractiveAnswers {
  profileName: string;
  projectName: string;
  fileSizeCeiling: number;
  forbiddenPhrases: string[];
}

export async function runInteractivePrompts(dotclaudeRoot: string): Promise<InteractiveAnswers> {
  const profilesDir = resolve(dotclaudeRoot, 'profiles');
  const profileChoices = readdirSync(profilesDir)
    .filter((f) => f.endsWith('.yml'))
    .map((f) => ({ title: f.replace(/\.yml$/, ''), value: f.replace(/\.yml$/, '') }));

  const response = await prompts(
    [
      {
        type: 'select',
        name: 'profileName',
        message: 'Profile?',
        choices: profileChoices,
        initial: Math.max(0, profileChoices.findIndex((c) => c.value === 'minimal')),
      },
      {
        type: 'text',
        name: 'projectName',
        message: 'Project name?',
        validate: (v: string) => (v.length > 0 ? true : 'Required'),
      },
      {
        type: 'number',
        name: 'fileSizeCeiling',
        message: 'File-size ceiling (LOC)?',
        initial: 1000,
        validate: (v: number) => (v > 100 ? true : 'Must be > 100'),
      },
      {
        type: 'list',
        name: 'forbiddenPhrases',
        message: 'Forbidden phrases (comma-separated, optional)?',
        separator: ',',
        initial: '',
      },
    ],
    {
      onCancel: () => {
        throw new Error('Aborted by user.');
      },
    },
  );

  return {
    profileName: response.profileName,
    projectName: response.projectName,
    fileSizeCeiling: response.fileSizeCeiling,
    forbiddenPhrases: (response.forbiddenPhrases as string[]).filter((p) => p.trim().length > 0),
  };
}
