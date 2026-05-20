export interface Profile {
  name: string;
  description: string;
  hooks: string[];
  rules: string[];
  skills: string[];
  agents: string[];
  defaults: ProfileDefaults;
}

export interface ProfileDefaults {
  fileSize: { ceiling: number; warn: number };
  forbiddenPhrases?: { phrases: string[]; scopes: string[] };
  visualVerification?: { tool: 'simctl' | 'playwright' | 'none' };
  designTokens?: { sourcePath: string };
  database?: 'supabase' | 'postgres' | 'mysql' | 'none';
}

export interface DotclaudeConfig {
  profile: string;
  projectName: string;
  defaults: ProfileDefaults;
  customHooks?: string[];
  customRules?: string[];
  customSkills?: string[];
  customAgents?: string[];
}

export type ArtifactType = 'hook' | 'rule' | 'skill' | 'agent';

export interface ArtifactRef {
  type: ArtifactType;
  name: string;
}
