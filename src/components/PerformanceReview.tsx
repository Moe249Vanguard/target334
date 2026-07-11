import { useMemo, useState } from 'react';
import {
  AppMode,
  OPTION_LETTERS,
  Question,
  QuestionOption,
  SUBJECT_BADGE_CLASS,
  SUBJECT_LABEL,
  TestResult,
} from '../types';
import { formatSeconds } from './Timer';
import { LShape } from './LShape';
import { MarkdownText } from './MarkdownText';

type ReviewFilter = 'all' | 'wrong' | 'flagged' | 'skipped';

const FILTERS: { key: ReviewFilter; label: string }[] = [
  { key: 'all', label: 'All' },
  { key: 'wrong', label: '❌ Wrong' },
  { key: 'flagged', label: '🚩 Flagged' },
  { key: 'skipped', label: '⬜ Skipped' },
];

function OptionText({ option }: { option: QuestionOption }) {
  if (typeof option === 'string') return <>{option}</>;
  return <LShape rotation={option.rotation} mirrored={option.mirrored} sizeClass="w-8 h-8" />;
}

function StatTile({ value, label }: { value: string; label: string }) {
  return (
    <div className="bg-slate-50 rounded-xl p-4">
      <div className="text-2xl font-black text-indigo-700 tabular-nums">{value}</div>
      <div className="text-xs font-extrabold text-slate-400 uppercase tracking-wide mt-0.5">{label}</div>
    </div>
  );
}

interface PerformanceReviewProps {
  result: TestResult;
  /** Question lookup so each recorded answer can render its full card. */
  questionsById: Map<string, Question>;
  history: TestResult[];
  onHome: () => void;
}

export function PerformanceReview({ result, questionsById, history, onHome }: PerformanceReviewProps) {
  const [filter, setFilter] = useState<ReviewFilter>('all');

  const grade =
    result.percentage >= 85
      ? { text: 'Outstanding! 🏆', className: 'text-emerald-600' }
      : result.percentage >= 70
        ? { text: 'Great work! 🌟', className: 'text-emerald-600' }
        : result.percentage >= 50
          ? { text: 'Good effort — keep practising! 💪', className: 'text-amber-600' }
          : { text: 'Every expert started here — review and retry! 🌱', className: 'text-rose-500' };

  const weakestTopics = useMemo(() => {
    const byTopic = new Map<string, { correct: number; total: number; subjectBadge: string }>();
    for (const answer of result.answers) {
      const question = questionsById.get(answer.questionId);
      if (!question) continue;
      const entry = byTopic.get(question.topic) ?? {
        correct: 0,
        total: 0,
        subjectBadge: SUBJECT_BADGE_CLASS[question.type],
      };
      entry.total += 1;
      if (answer.correct) entry.correct += 1;
      byTopic.set(question.topic, entry);
    }
    return [...byTopic.entries()]
      .map(([topic, entry]) => ({
        topic,
        percentage: Math.round((entry.correct / entry.total) * 100),
        subjectBadge: entry.subjectBadge,
      }))
      .filter((entry) => entry.percentage < 100)
      .sort((a, b) => a.percentage - b.percentage)
      .slice(0, 3);
  }, [questionsById, result.answers]);

  const previousBest = useMemo(() => {
    const others = history.filter((entry) => entry.id !== result.id && entry.mode === AppMode.TEST);
    return others.reduce<number | null>(
      (best, entry) => (best === null ? entry.percentage : Math.max(best, entry.percentage)),
      null,
    );
  }, [history, result.id]);

  const visibleAnswers = result.answers.filter((answer) => {
    if (filter === 'wrong') return answer.selectedIndex !== null && !answer.correct;
    if (filter === 'flagged') return answer.flagged;
    if (filter === 'skipped') return answer.selectedIndex === null;
    return true;
  });

  return (
    <section className="animate-fade-in">
      {result.timedOut && (
        <div className="bg-rose-100 border-2 border-rose-200 text-rose-700 font-extrabold rounded-2xl p-4 text-center mb-5">
          ⏰ Time is up! Your paper was submitted automatically.
        </div>
      )}

      <div className="bg-white rounded-2xl shadow-soft p-8 text-center mb-5">
        <h2 className={`text-3xl font-black mb-1 ${grade.className}`}>{grade.text}</h2>
        <p className="text-slate-400 font-bold mb-2">
          {result.mode === AppMode.TEST ? 'Test Mode' : 'Study Mode'} ·{' '}
          {result.focus === 'ALL' ? 'All Combined' : SUBJECT_LABEL[result.focus]}
        </p>
        {previousBest !== null && result.mode === AppMode.TEST && result.percentage > previousBest && (
          <p className="text-sm font-black text-emerald-600 mb-4">
            🎉 New personal best — previous best was {previousBest}%!
          </p>
        )}
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mt-4">
          <StatTile value={`${result.correct} / ${result.totalQuestions}`} label="Raw score" />
          <StatTile value={`${result.percentage}%`} label="Percentage" />
          <StatTile value={formatSeconds(result.timeTakenSeconds)} label="Time spent" />
          <StatTile value={`${result.attempted} / ${result.totalQuestions}`} label="Attempted" />
        </div>
      </div>

      <div className="grid md:grid-cols-2 gap-5 mb-5">
        <div className="bg-white rounded-2xl shadow-soft p-6">
          <h3 className="font-black text-slate-700 mb-4">📊 Breakdown by subject</h3>
          {result.breakdown.map((entry) => {
            const percentage = Math.round((entry.correct / entry.total) * 100);
            const barColor =
              percentage >= 70 ? 'bg-emerald-500' : percentage >= 50 ? 'bg-amber-500' : 'bg-rose-500';
            return (
              <div key={entry.type} className="mb-4 last:mb-0">
                <div className="flex justify-between text-sm font-extrabold mb-1">
                  <span className="text-slate-700">{SUBJECT_LABEL[entry.type]}</span>
                  <span className="text-slate-500">
                    {entry.correct} / {entry.total} · {percentage}%
                  </span>
                </div>
                <div className="w-full h-3.5 bg-slate-100 rounded-full overflow-hidden">
                  <div
                    className={`h-full rounded-full transition-all duration-700 ${barColor}`}
                    style={{ width: `${percentage}%` }}
                  />
                </div>
              </div>
            );
          })}
        </div>
        <div className="bg-white rounded-2xl shadow-soft p-6">
          <h3 className="font-black text-slate-700 mb-4">🎯 Focus areas for next time</h3>
          {weakestTopics.length > 0 ? (
            weakestTopics.map((entry) => (
              <div
                key={entry.topic}
                className="flex items-center justify-between py-2.5 border-b border-slate-100 last:border-0"
              >
                <div>
                  <span className="font-extrabold text-slate-700">{entry.topic}</span>
                </div>
                <span
                  className={`font-black ${entry.percentage >= 50 ? 'text-amber-600' : 'text-rose-500'}`}
                >
                  {entry.percentage}%
                </span>
              </div>
            ))
          ) : (
            <p className="font-bold text-emerald-600">Perfect paper — nothing to fix! 🎉</p>
          )}
        </div>
      </div>

      <div className="flex flex-wrap items-center gap-3 mb-4">
        <h3 className="text-xl font-black text-slate-800 mr-auto">📝 Question-by-question review</h3>
        <div className="flex gap-2">
          {FILTERS.map((entry) => (
            <button
              key={entry.key}
              onClick={() => setFilter(entry.key)}
              className={[
                'px-4 py-2 rounded-xl text-sm font-extrabold shadow-soft transition',
                filter === entry.key ? 'bg-indigo-600 text-white' : 'bg-white text-slate-600 hover:bg-indigo-50',
              ].join(' ')}
            >
              {entry.label}
            </button>
          ))}
        </div>
      </div>

      <div className="space-y-4 mb-8">
        {visibleAnswers.length === 0 && (
          <p className="text-center font-bold text-slate-400 py-8">Nothing in this category. 🎉</p>
        )}
        {visibleAnswers.map((answer) => {
          const question = questionsById.get(answer.questionId);
          if (!question) return null;
          const questionNumber = result.answers.findIndex((a) => a.questionId === answer.questionId) + 1;
          const status =
            answer.selectedIndex === null
              ? { label: 'UNANSWERED', className: 'bg-slate-200 text-slate-600' }
              : answer.correct
                ? { label: 'CORRECT ✓', className: 'bg-emerald-100 text-emerald-700' }
                : { label: 'INCORRECT ✗', className: 'bg-rose-100 text-rose-700' };
          const chosen = answer.selectedIndex !== null ? question.options[answer.selectedIndex] : null;
          const correctOption = question.options[question.answerIndex];
          return (
            <div key={answer.questionId} className="bg-white rounded-2xl shadow-soft p-5">
              <div className="flex flex-wrap items-center gap-2 mb-3">
                <span className="font-black text-slate-400">Q{questionNumber}</span>
                <span className={`text-xs font-black px-2.5 py-0.5 rounded-full ${status.className}`}>
                  {status.label}
                </span>
                <span
                  className={`text-xs font-black px-2.5 py-0.5 rounded-full ${SUBJECT_BADGE_CLASS[question.type]}`}
                >
                  {SUBJECT_LABEL[question.type]}
                </span>
                <span className="text-xs font-black px-2.5 py-0.5 rounded-full bg-slate-100 text-slate-500">
                  {question.topic}
                </span>
                {answer.flagged && <span className="text-xs">🚩</span>}
              </div>
              <p className="font-bold text-slate-800 mb-2">{question.prompt}</p>
              <div className="text-sm font-semibold text-slate-600 mt-3 space-y-1">
                <div>
                  Your answer:{' '}
                  {answer.selectedIndex !== null && chosen !== undefined && chosen !== null ? (
                    <>
                      <strong>{OPTION_LETTERS[answer.selectedIndex]}</strong> —{' '}
                      <OptionText option={chosen} />
                    </>
                  ) : (
                    <em className="text-slate-400">no answer given</em>
                  )}
                </div>
                <div>
                  Correct answer:{' '}
                  <span className="text-emerald-700">
                    <strong>{OPTION_LETTERS[question.answerIndex]}</strong> —{' '}
                    {correctOption !== undefined && <OptionText option={correctOption} />}
                  </span>
                </div>
              </div>
              <details className="mt-3" open={answer.selectedIndex !== null && !answer.correct}>
                <summary className="cursor-pointer font-extrabold text-indigo-600 text-sm select-none">
                  💡 Show explanation
                </summary>
                <MarkdownText
                  text={question.explanation}
                  className="mt-2 text-[15px] font-semibold text-slate-700 leading-relaxed bg-indigo-50/60 rounded-xl p-4"
                />
              </details>
            </div>
          );
        })}
      </div>

      <div className="text-center pb-10">
        <button
          onClick={onHome}
          className="bg-gradient-to-r from-indigo-600 to-cyan-600 text-white text-lg font-black px-10 py-4 rounded-2xl shadow-lift hover:opacity-95 active:scale-95 transition"
        >
          🏠 Back to Dashboard
        </button>
      </div>
    </section>
  );
}
