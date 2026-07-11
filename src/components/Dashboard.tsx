import { useState } from 'react';
import {
  AppMode,
  QuestionType,
  SUBJECT_LABEL,
  SubjectFocus,
  TEST_MINUTES,
  TestResult,
} from '../types';

interface SubjectCardMeta {
  focus: SubjectFocus;
  label: string;
  icon: string;
  description: string;
}

const SUBJECT_CARDS: SubjectCardMeta[] = [
  { focus: 'ALL', label: 'All Combined', icon: '🎯', description: 'Full GL-style mock' },
  { focus: QuestionType.MATHS, label: 'Maths Only', icon: '🔢', description: '~60 sec per question' },
  { focus: QuestionType.VERBAL, label: 'VR Only', icon: '🔤', description: '~45 sec per question' },
  { focus: QuestionType.NON_VERBAL, label: 'NVR Only', icon: '🧩', description: 'Patterns & shapes' },
];

interface DashboardProps {
  questionCount: (focus: SubjectFocus) => number;
  history: TestResult[];
  onStart: (mode: AppMode, focus: SubjectFocus) => void;
  onClearHistory: () => void;
}

function focusLabel(focus: SubjectFocus): string {
  return focus === 'ALL' ? 'All Combined' : SUBJECT_LABEL[focus];
}

export function Dashboard({ questionCount, history, onStart, onClearHistory }: DashboardProps) {
  const [mode, setMode] = useState<AppMode | null>(null);
  const [focus, setFocus] = useState<SubjectFocus | null>(null);

  const ready = mode !== null && focus !== null;
  const testResults = history.filter((result) => result.mode === AppMode.TEST);
  const best = testResults.reduce<number | null>(
    (currentBest, result) => (currentBest === null ? result.percentage : Math.max(currentBest, result.percentage)),
    null,
  );
  const average =
    testResults.length > 0
      ? Math.round(testResults.reduce((sum, result) => sum + result.percentage, 0) / testResults.length)
      : null;
  const recent = [...history].slice(-5).reverse();

  return (
    <section className="animate-fade-in">
      <div className="text-center mt-4 mb-8">
        <h2 className="text-3xl md:text-4xl font-black text-indigo-950">Ready to practise? 🌟</h2>
        <p className="text-slate-500 font-semibold mt-2">
          Aiming for 334 — pick a mode, choose your focus, and let&apos;s go!
        </p>
      </div>

      <h3 className="text-sm font-extrabold uppercase tracking-wider text-slate-400 mb-3">
        1 · Choose your mode
      </h3>
      <div className="grid md:grid-cols-2 gap-4 mb-8">
        <button
          onClick={() => setMode(AppMode.STUDY)}
          aria-pressed={mode === AppMode.STUDY}
          className={[
            'text-left bg-white rounded-2xl p-6 border-2 shadow-soft hover:shadow-lift transition',
            mode === AppMode.STUDY ? 'border-indigo-500' : 'border-transparent',
          ].join(' ')}
        >
          <div className="flex items-center gap-4">
            <div className="w-14 h-14 rounded-2xl bg-emerald-100 flex items-center justify-center text-3xl">
              📖
            </div>
            <div>
              <h4 className="text-lg font-black text-slate-800">Study Mode</h4>
              <p className="text-sm text-slate-500 font-semibold">
                No timer. Instant feedback with a full step-by-step explanation after every answer.
              </p>
            </div>
          </div>
        </button>
        <button
          onClick={() => setMode(AppMode.TEST)}
          aria-pressed={mode === AppMode.TEST}
          className={[
            'text-left bg-white rounded-2xl p-6 border-2 shadow-soft hover:shadow-lift transition',
            mode === AppMode.TEST ? 'border-indigo-500' : 'border-transparent',
          ].join(' ')}
        >
          <div className="flex items-center gap-4">
            <div className="w-14 h-14 rounded-2xl bg-rose-100 flex items-center justify-center text-3xl">
              ⏱️
            </div>
            <div>
              <h4 className="text-lg font-black text-slate-800">Test Mode</h4>
              <p className="text-sm text-slate-500 font-semibold">
                Real GL exam simulation. Strict countdown, flag &amp; skip, no feedback until the paper is
                scored.
              </p>
            </div>
          </div>
        </button>
      </div>

      <h3 className="text-sm font-extrabold uppercase tracking-wider text-slate-400 mb-3">
        2 · Choose your focus
      </h3>
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
        {SUBJECT_CARDS.map((card) => (
          <button
            key={card.focus}
            onClick={() => setFocus(card.focus)}
            aria-pressed={focus === card.focus}
            className={[
              'bg-white rounded-2xl p-4 border-2 shadow-soft hover:shadow-lift transition text-center',
              focus === card.focus ? 'border-indigo-500' : 'border-transparent',
            ].join(' ')}
          >
            <div className="text-3xl mb-1">{card.icon}</div>
            <div className="font-black text-slate-800">{card.label}</div>
            <div className="text-xs text-slate-400 font-bold">{card.description}</div>
            <div className="text-[11px] mt-1 font-extrabold text-indigo-500">
              {questionCount(card.focus)} questions
            </div>
          </button>
        ))}
      </div>

      <div className="text-center mb-10">
        <button
          disabled={!ready}
          onClick={() => {
            if (mode !== null && focus !== null) onStart(mode, focus);
          }}
          className="bg-gradient-to-r from-indigo-600 to-cyan-600 text-white text-lg font-black px-12 py-4 rounded-2xl shadow-lift hover:opacity-95 active:scale-95 transition disabled:opacity-40 disabled:cursor-not-allowed"
        >
          Start ▸
        </button>
        <p className="text-sm text-slate-400 font-semibold mt-3">
          {ready && mode !== null && focus !== null
            ? mode === AppMode.TEST
              ? `${questionCount(focus)} questions · ${TEST_MINUTES[focus]} minute countdown · no feedback until you submit`
              : `${questionCount(focus)} questions · untimed · instant feedback and explanations`
            : 'Select a mode and a subject to begin.'}
        </p>
      </div>

      {history.length > 0 && (
        <div className="bg-white rounded-2xl shadow-soft p-6 mb-10">
          <div className="flex flex-wrap items-center gap-3 mb-4">
            <h3 className="font-black text-slate-700 text-lg mr-auto">📈 Score history</h3>
            {best !== null && (
              <span className="text-xs font-black px-3 py-1 rounded-full bg-emerald-100 text-emerald-700">
                Best test: {best}%
              </span>
            )}
            {average !== null && (
              <span className="text-xs font-black px-3 py-1 rounded-full bg-indigo-100 text-indigo-700">
                Test average: {average}%
              </span>
            )}
            <button
              onClick={() => {
                if (window.confirm('Delete all saved scores? This cannot be undone.')) onClearHistory();
              }}
              className="text-xs font-extrabold text-rose-400 hover:text-rose-600 transition"
            >
              Clear
            </button>
          </div>
          <ul className="divide-y divide-slate-100">
            {recent.map((result) => (
              <li key={result.id} className="py-2.5 flex flex-wrap items-center gap-2 text-sm">
                <span className="font-extrabold text-slate-700">
                  {new Date(result.completedAt).toLocaleDateString('en-GB', {
                    day: 'numeric',
                    month: 'short',
                  })}
                </span>
                <span
                  className={[
                    'text-[11px] font-black px-2 py-0.5 rounded-full',
                    result.mode === AppMode.TEST
                      ? 'bg-rose-100 text-rose-700'
                      : 'bg-emerald-100 text-emerald-700',
                  ].join(' ')}
                >
                  {result.mode === AppMode.TEST ? 'Test' : 'Study'}
                </span>
                <span className="font-semibold text-slate-500">{focusLabel(result.focus)}</span>
                <span className="ml-auto font-black text-slate-700 tabular-nums">
                  {result.correct}/{result.totalQuestions}
                </span>
                <span
                  className={[
                    'font-black tabular-nums w-12 text-right',
                    result.percentage >= 70
                      ? 'text-emerald-600'
                      : result.percentage >= 50
                        ? 'text-amber-600'
                        : 'text-rose-500',
                  ].join(' ')}
                >
                  {result.percentage}%
                </span>
              </li>
            ))}
          </ul>
        </div>
      )}
    </section>
  );
}
