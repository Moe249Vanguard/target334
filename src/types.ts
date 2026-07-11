/** Core domain types for Target 334 — strict, no `any`. */

export enum QuestionType {
  MATHS = 'MATHS',
  VERBAL = 'VERBAL',
  NON_VERBAL = 'NON_VERBAL',
}

export enum AppMode {
  STUDY = 'STUDY',
  TEST = 'TEST',
}

/** What the user picked on the dashboard: a single discipline or the full mock. */
export type SubjectFocus = QuestionType | 'ALL';

export type Screen = 'dashboard' | 'quiz' | 'review';

/** An answer option that is rendered as an SVG L-shape (NVR rotation questions). */
export interface LShapeOption {
  kind: 'lshape';
  rotation: number;
  mirrored?: boolean;
}

/** Most options are plain text; NVR rotation questions use SVG shape options. */
export type QuestionOption = string | LShapeOption;

/** Optional visual stimulus rendered between the prompt and the options. */
export type QuestionVisual =
  | { kind: 'pattern'; lines: string[] } // Unicode shape rows (series, matrices)
  | { kind: 'lshape-sequence'; rotations: number[] }; // SVG rotation series ending in "?"

export interface Question {
  id: string;
  type: QuestionType;
  topic: string;
  prompt: string;
  visual?: QuestionVisual;
  options: QuestionOption[];
  /** Index into `options` of the correct answer. */
  answerIndex: number;
  /** Markdown-formatted step-by-step pedagogical explanation. */
  explanation: string;
}

/** One recorded answer inside a completed session. */
export interface UserAnswer {
  questionId: string;
  selectedIndex: number | null;
  flagged: boolean;
  correct: boolean;
}

export interface SubjectBreakdown {
  type: QuestionType;
  total: number;
  correct: number;
}

/** A completed session, persisted to localStorage as score history. */
export interface TestResult {
  id: string;
  completedAt: string; // ISO timestamp
  mode: AppMode;
  focus: SubjectFocus;
  totalQuestions: number;
  attempted: number;
  correct: number;
  percentage: number;
  timeTakenSeconds: number;
  timedOut: boolean;
  breakdown: SubjectBreakdown[];
  answers: UserAnswer[];
}

/** What QuizEngine hands back to the container when a session ends. */
export interface QuizOutcome {
  selections: (number | null)[];
  flagged: boolean[];
  timeTakenSeconds: number;
  timedOut: boolean;
}

export const SUBJECT_LABEL: Record<QuestionType, string> = {
  [QuestionType.MATHS]: 'Mathematics',
  [QuestionType.VERBAL]: 'Verbal Reasoning',
  [QuestionType.NON_VERBAL]: 'Non-Verbal Reasoning',
};

export const SUBJECT_BADGE_CLASS: Record<QuestionType, string> = {
  [QuestionType.MATHS]: 'bg-sky-100 text-sky-700',
  [QuestionType.VERBAL]: 'bg-violet-100 text-violet-700',
  [QuestionType.NON_VERBAL]: 'bg-teal-100 text-teal-700',
};

/** Test-mode time limits in minutes. The full mock is the real 60-minute block. */
export const TEST_MINUTES: Record<SubjectFocus, number> = {
  ALL: 60,
  [QuestionType.MATHS]: 35,
  [QuestionType.VERBAL]: 12,
  [QuestionType.NON_VERBAL]: 9,
};

export const OPTION_LETTERS = ['A', 'B', 'C', 'D', 'E'] as const;
