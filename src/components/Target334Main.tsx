import { useCallback, useMemo, useState } from 'react';
import { mockQuestions } from '../data/questions';
import { useLocalStorage } from '../hooks/useLocalStorage';
import {
  AppMode,
  Question,
  QuestionType,
  QuizOutcome,
  Screen,
  SubjectBreakdown,
  SubjectFocus,
  TEST_MINUTES,
  TestResult,
  UserAnswer,
} from '../types';
import { Dashboard } from './Dashboard';
import { PerformanceReview } from './PerformanceReview';
import { QuizEngine } from './QuizEngine';

const HISTORY_KEY = 'target334_history_v1';
const SUBJECT_ORDER: QuestionType[] = [QuestionType.MATHS, QuestionType.VERBAL, QuestionType.NON_VERBAL];

function shuffle<T>(items: T[]): T[] {
  const copy = [...items];
  for (let i = copy.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    const a = copy[i] as T;
    copy[i] = copy[j] as T;
    copy[j] = a;
  }
  return copy;
}

/** Shuffle within each subject but keep the exam's Maths → VR → NVR section order. */
function buildPaper(focus: SubjectFocus): Question[] {
  const pool = focus === 'ALL' ? mockQuestions : mockQuestions.filter((q) => q.type === focus);
  return SUBJECT_ORDER.flatMap((subject) => shuffle(pool.filter((q) => q.type === subject)));
}

interface ActiveSession {
  mode: AppMode;
  focus: SubjectFocus;
  questions: Question[];
}

function Logo() {
  return (
    <svg className="w-11 h-11" viewBox="0 0 64 64" xmlns="http://www.w3.org/2000/svg" aria-label="Target 334 logo">
      <defs>
        <linearGradient id="logo-gradient" x1="0" y1="0" x2="1" y2="1">
          <stop offset="0" stopColor="#6366f1" />
          <stop offset="1" stopColor="#06b6d4" />
        </linearGradient>
      </defs>
      <rect width="64" height="64" rx="14" fill="url(#logo-gradient)" />
      <circle cx="32" cy="32" r="20" fill="none" stroke="white" strokeWidth="4" />
      <circle cx="32" cy="32" r="11" fill="none" stroke="white" strokeWidth="4" />
      <circle cx="32" cy="32" r="4" fill="#fbbf24" />
    </svg>
  );
}

export function Target334Main() {
  const [screen, setScreen] = useState<Screen>('dashboard');
  const [session, setSession] = useState<ActiveSession | null>(null);
  const [lastResult, setLastResult] = useState<TestResult | null>(null);
  const [history, setHistory] = useLocalStorage<TestResult[]>(HISTORY_KEY, []);

  const questionsById = useMemo(() => new Map(mockQuestions.map((q) => [q.id, q])), []);

  const questionCount = useCallback(
    (focus: SubjectFocus) =>
      focus === 'ALL' ? mockQuestions.length : mockQuestions.filter((q) => q.type === focus).length,
    [],
  );

  const startSession = useCallback((mode: AppMode, focus: SubjectFocus) => {
    setSession({ mode, focus, questions: buildPaper(focus) });
    setScreen('quiz');
    window.scrollTo({ top: 0 });
  }, []);

  const completeSession = useCallback(
    (outcome: QuizOutcome) => {
      if (session === null) return;
      const answers: UserAnswer[] = session.questions.map((question, index) => {
        const selectedIndex = outcome.selections[index] ?? null;
        return {
          questionId: question.id,
          selectedIndex,
          flagged: outcome.flagged[index] ?? false,
          correct: selectedIndex === question.answerIndex,
        };
      });
      const breakdown: SubjectBreakdown[] = SUBJECT_ORDER.filter((subject) =>
        session.questions.some((q) => q.type === subject),
      ).map((subject) => ({
        type: subject,
        total: session.questions.filter((q) => q.type === subject).length,
        correct: answers.filter(
          (answer, index) => session.questions[index]?.type === subject && answer.correct,
        ).length,
      }));
      const correct = answers.filter((answer) => answer.correct).length;
      const result: TestResult = {
        id: `result-${Date.now()}-${Math.random().toString(36).slice(2, 8)}`,
        completedAt: new Date().toISOString(),
        mode: session.mode,
        focus: session.focus,
        totalQuestions: session.questions.length,
        attempted: answers.filter((answer) => answer.selectedIndex !== null).length,
        correct,
        percentage: Math.round((correct / session.questions.length) * 100),
        timeTakenSeconds: outcome.timeTakenSeconds,
        timedOut: outcome.timedOut,
        breakdown,
        answers,
      };
      setLastResult(result);
      setHistory((previous) => [...previous, result].slice(-50)); // keep the latest 50 sessions
      setScreen('review');
      window.scrollTo({ top: 0 });
    },
    [session, setHistory],
  );

  const goHome = useCallback(() => {
    setSession(null);
    setScreen('dashboard');
    window.scrollTo({ top: 0 });
  }, []);

  return (
    <div className="bg-slate-100 text-slate-800 min-h-screen">
      <header className="bg-white/90 backdrop-blur border-b border-slate-200 sticky top-0 z-40">
        <div className="max-w-6xl mx-auto px-4 py-3 flex items-center gap-3">
          <button onClick={goHome} className="flex items-center gap-3" aria-label="Back to dashboard">
            <Logo />
            <span className="text-left">
              <span className="block text-xl font-black text-indigo-950 leading-tight">
                Target <span className="text-amber-500">334</span>
              </span>
              <span className="block text-xs text-slate-500 font-semibold -mt-0.5">
                Trafford GL · 11 Plus Practice
              </span>
            </span>
          </button>
        </div>
      </header>

      <main className="max-w-6xl mx-auto px-4 py-6">
        {screen === 'dashboard' && (
          <Dashboard
            questionCount={questionCount}
            history={history}
            onStart={startSession}
            onClearHistory={() => setHistory([])}
          />
        )}
        {screen === 'quiz' && session !== null && (
          <QuizEngine
            key={`${session.mode}-${session.focus}-${session.questions[0]?.id ?? ''}`}
            mode={session.mode}
            questions={session.questions}
            timeLimitSeconds={session.mode === AppMode.TEST ? TEST_MINUTES[session.focus] * 60 : null}
            onComplete={completeSession}
            onAbort={goHome}
          />
        )}
        {screen === 'review' && lastResult !== null && (
          <PerformanceReview
            result={lastResult}
            questionsById={questionsById}
            history={history}
            onHome={goHome}
          />
        )}
      </main>
    </div>
  );
}
