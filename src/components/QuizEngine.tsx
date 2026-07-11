import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import {
  AppMode,
  OPTION_LETTERS,
  Question,
  QuestionOption,
  QuizOutcome,
  SUBJECT_BADGE_CLASS,
  SUBJECT_LABEL,
} from '../types';
import { BubbleSheet } from './BubbleSheet';
import { LShape } from './LShape';
import { MarkdownText } from './MarkdownText';
import { Timer } from './Timer';

function OptionContent({ option }: { option: QuestionOption }) {
  if (typeof option === 'string') return <span className="flex-1">{option}</span>;
  return (
    <span className="flex-1">
      <LShape rotation={option.rotation} mirrored={option.mirrored} />
    </span>
  );
}

function QuestionVisualBlock({ question }: { question: Question }) {
  const visual = question.visual;
  if (!visual) return null;
  if (visual.kind === 'pattern') {
    return (
      <div className="my-4 bg-indigo-50 rounded-xl p-4 text-center text-3xl leading-relaxed tracking-[0.3em] text-indigo-700 whitespace-pre-wrap">
        {visual.lines.join('\n')}
      </div>
    );
  }
  return (
    <div className="my-4 bg-indigo-50 rounded-xl p-4 flex items-center justify-center gap-5 flex-wrap">
      {visual.rotations.map((rotation, index) => (
        <span key={index} className="flex items-center gap-5">
          {index > 0 && <span className="text-slate-400 font-black">→</span>}
          <LShape rotation={rotation} />
        </span>
      ))}
      <span className="text-slate-400 font-black">→</span>
      <span className="text-amber-500 text-3xl font-black">?</span>
    </div>
  );
}

interface QuizEngineProps {
  mode: AppMode;
  questions: Question[];
  /** Countdown length in seconds; null in Study Mode (untimed). */
  timeLimitSeconds: number | null;
  onComplete: (outcome: QuizOutcome) => void;
  onAbort: () => void;
}

export function QuizEngine({ mode, questions, timeLimitSeconds, onComplete, onAbort }: QuizEngineProps) {
  const total = questions.length;
  const [current, setCurrent] = useState(0);
  const [selections, setSelections] = useState<(number | null)[]>(() => Array(total).fill(null));
  const [revealed, setRevealed] = useState<boolean[]>(() => Array(total).fill(false));
  const [flagged, setFlagged] = useState<boolean[]>(() => Array(total).fill(false));
  const [showSubmitModal, setShowSubmitModal] = useState(false);
  const [finished, setFinished] = useState(false);

  const startedAtRef = useRef(Date.now());
  const remainingRef = useRef(timeLimitSeconds ?? 0);
  const selectionsRef = useRef(selections);
  const flaggedRef = useRef(flagged);
  selectionsRef.current = selections;
  flaggedRef.current = flagged;

  const question = questions[current];
  const isLast = current === total - 1;
  const answeredCount = selections.filter((selection) => selection !== null).length;
  const flaggedCount = flagged.filter(Boolean).length;
  const isStudy = mode === AppMode.STUDY;
  const isRevealed = isStudy && (revealed[current] ?? false);

  const finish = useCallback(
    (timedOut: boolean) => {
      setFinished(true);
      const timeTakenSeconds =
        timeLimitSeconds !== null
          ? timeLimitSeconds - Math.max(0, remainingRef.current)
          : Math.round((Date.now() - startedAtRef.current) / 1000);
      onComplete({
        selections: selectionsRef.current,
        flagged: flaggedRef.current,
        timeTakenSeconds,
        timedOut,
      });
    },
    [onComplete, timeLimitSeconds],
  );

  const selectOption = useCallback(
    (optionIndex: number) => {
      if (finished || question === undefined) return;
      if (isStudy) {
        if (revealed[current]) return; // locked after feedback
        setSelections((previous) => previous.map((value, i) => (i === current ? optionIndex : value)));
        setRevealed((previous) => previous.map((value, i) => (i === current ? true : value)));
      } else {
        // Test mode: answers can be changed or unfilled until the paper is submitted.
        setSelections((previous) =>
          previous.map((value, i) =>
            i === current ? (value === optionIndex ? null : optionIndex) : value,
          ),
        );
      }
    },
    [current, finished, isStudy, question, revealed],
  );

  const go = useCallback(
    (delta: number) => {
      setCurrent((previous) => Math.min(total - 1, Math.max(0, previous + delta)));
    },
    [total],
  );

  const toggleFlag = useCallback(() => {
    setFlagged((previous) => previous.map((value, i) => (i === current ? !value : value)));
  }, [current]);

  // Keyboard shortcuts: A–E / 1–5 answer, arrows navigate, F flags.
  useEffect(() => {
    const handler = (event: KeyboardEvent) => {
      if (finished || showSubmitModal || question === undefined) return;
      const key = event.key.toLowerCase();
      const letterIndex = ['a', 'b', 'c', 'd', 'e'].indexOf(key);
      const numberIndex = ['1', '2', '3', '4', '5'].indexOf(key);
      const optionIndex = letterIndex >= 0 ? letterIndex : numberIndex;
      if (optionIndex >= 0 && optionIndex < question.options.length) selectOption(optionIndex);
      else if (event.key === 'ArrowRight') go(1);
      else if (event.key === 'ArrowLeft') go(-1);
      else if (key === 'f') toggleFlag();
    };
    window.addEventListener('keydown', handler);
    return () => window.removeEventListener('keydown', handler);
  }, [finished, go, question, selectOption, showSubmitModal, toggleFlag]);

  // Warn before closing the tab mid-test.
  useEffect(() => {
    if (mode !== AppMode.TEST) return;
    const handler = (event: BeforeUnloadEvent) => {
      if (!finished) event.preventDefault();
    };
    window.addEventListener('beforeunload', handler);
    return () => window.removeEventListener('beforeunload', handler);
  }, [finished, mode]);

  const unanswered = total - answeredCount;
  const selectedIndex = selections[current] ?? null;

  const optionClasses = useMemo(() => {
    if (question === undefined) return [];
    return question.options.map((_, optionIndex) => {
      const isSelected = selectedIndex === optionIndex;
      const isCorrect = optionIndex === question.answerIndex;
      if (isRevealed) {
        if (isCorrect) return 'border-emerald-500 bg-emerald-50 text-emerald-800';
        if (isSelected) return 'border-rose-400 bg-rose-50 text-rose-700';
        return 'border-slate-200 bg-white text-slate-400';
      }
      if (isSelected) return 'border-indigo-500 bg-indigo-50 text-indigo-900';
      return 'border-slate-200 bg-white text-slate-700 hover:border-indigo-300 hover:bg-indigo-50/50';
    });
  }, [isRevealed, question, selectedIndex]);

  if (question === undefined) return null;
  const answeredCorrectly = selectedIndex === question.answerIndex;

  return (
    <section className="animate-fade-in">
      <div className="flex items-center justify-end mb-4 gap-3">
        {mode === AppMode.TEST && timeLimitSeconds !== null ? (
          <Timer
            initialSeconds={timeLimitSeconds}
            paused={finished}
            onExpire={() => finish(true)}
            onTick={(remaining) => {
              remainingRef.current = remaining;
            }}
          />
        ) : (
          <span className="font-black text-sm px-4 py-2 rounded-xl bg-emerald-100 text-emerald-700">
            📖 STUDY MODE · untimed
          </span>
        )}
        <button
          onClick={onAbort}
          className="text-xs font-extrabold text-slate-400 hover:text-slate-600 transition"
        >
          ✕ Quit
        </button>
      </div>

      <div className="bg-white rounded-2xl shadow-soft p-4 mb-4">
        <div className="flex items-center justify-between text-sm font-extrabold text-slate-600 mb-2">
          <span>
            Question {current + 1} of {total} · {answeredCount} answered
          </span>
          <span className="text-amber-600">{flaggedCount > 0 ? `🚩 ${flaggedCount} flagged` : ''}</span>
        </div>
        <div className="w-full h-3 bg-slate-100 rounded-full overflow-hidden">
          <div
            className="h-full bg-gradient-to-r from-indigo-500 to-cyan-500 rounded-full transition-all duration-300"
            style={{ width: `${(answeredCount / total) * 100}%` }}
          />
        </div>
      </div>

      <div className="grid lg:grid-cols-[1fr_300px] gap-4 items-start">
        <div className="bg-white rounded-2xl shadow-soft p-6">
          <div className="flex flex-wrap items-center gap-2 mb-4">
            <span className={`text-xs font-black px-3 py-1 rounded-full ${SUBJECT_BADGE_CLASS[question.type]}`}>
              {SUBJECT_LABEL[question.type]}
            </span>
            <span className="text-xs font-black px-3 py-1 rounded-full bg-slate-100 text-slate-500">
              {question.topic}
            </span>
            {flagged[current] && (
              <span className="text-xs font-black px-3 py-1 rounded-full bg-amber-100 text-amber-700">
                🚩 Flagged
              </span>
            )}
          </div>

          <h2 className="text-lg md:text-xl font-bold text-slate-800 leading-relaxed">
            Q{current + 1}. {question.prompt}
          </h2>
          <QuestionVisualBlock question={question} />

          <div className="mt-5 space-y-3">
            {question.options.map((option, optionIndex) => {
              const isSelected = selectedIndex === optionIndex;
              const isCorrect = optionIndex === question.answerIndex;
              const badgeClass = isRevealed
                ? isCorrect
                  ? 'bg-emerald-500 text-white'
                  : isSelected
                    ? 'bg-rose-500 text-white'
                    : 'bg-slate-100 text-slate-500'
                : isSelected
                  ? 'bg-indigo-500 text-white'
                  : 'bg-slate-100 text-slate-500';
              return (
                <button
                  key={optionIndex}
                  disabled={isRevealed}
                  onClick={() => selectOption(optionIndex)}
                  className={`w-full text-left flex items-center gap-4 px-4 py-3.5 rounded-xl border-2 font-bold text-base transition ${optionClasses[optionIndex] ?? ''}`}
                >
                  <span
                    className={`w-8 h-8 shrink-0 rounded-lg flex items-center justify-center font-black text-sm ${badgeClass}`}
                  >
                    {OPTION_LETTERS[optionIndex]}
                  </span>
                  <OptionContent option={option} />
                  {isRevealed && isCorrect && <span className="text-emerald-600 font-black">✓</span>}
                  {isRevealed && isSelected && !isCorrect && (
                    <span className="text-rose-500 font-black">✗</span>
                  )}
                </button>
              );
            })}
          </div>

          {isRevealed && (
            <div
              className={`animate-fade-in mt-5 rounded-xl border-2 p-5 ${
                answeredCorrectly ? 'border-emerald-200 bg-emerald-50' : 'border-rose-200 bg-rose-50'
              }`}
            >
              <div
                className={`font-black text-lg mb-2 ${answeredCorrectly ? 'text-emerald-700' : 'text-rose-700'}`}
              >
                {answeredCorrectly
                  ? '🎉 Correct! Well done.'
                  : `❌ Not quite — the answer is ${OPTION_LETTERS[question.answerIndex]}.`}
              </div>
              <MarkdownText
                text={question.explanation}
                className="text-slate-700 font-semibold text-[15px] leading-relaxed"
              />
            </div>
          )}

          <div className="flex flex-wrap items-center gap-3 mt-6 pt-5 border-t border-slate-100">
            <button
              disabled={current === 0}
              onClick={() => go(-1)}
              className="px-5 py-2.5 rounded-xl font-extrabold bg-slate-100 text-slate-600 hover:bg-slate-200 transition disabled:opacity-40"
            >
              ◂ Back
            </button>
            <button
              onClick={toggleFlag}
              className={`px-5 py-2.5 rounded-xl font-extrabold border border-amber-200 transition ${
                flagged[current] ? 'bg-amber-200 text-amber-800' : 'bg-amber-50 text-amber-700 hover:bg-amber-100'
              }`}
            >
              🚩 {flagged[current] ? 'Unflag' : 'Flag'}
            </button>
            {!isLast && (
              <button
                onClick={() => go(1)}
                className="px-5 py-2.5 rounded-xl font-extrabold bg-slate-100 text-slate-600 hover:bg-slate-200 transition"
              >
                Skip ▸
              </button>
            )}
            <div className="ml-auto flex gap-3">
              {!isLast ? (
                <button
                  onClick={() => go(1)}
                  className="px-7 py-2.5 rounded-xl font-extrabold bg-indigo-600 text-white hover:bg-indigo-700 transition"
                >
                  Next ▸
                </button>
              ) : (
                <button
                  onClick={() => (mode === AppMode.TEST ? setShowSubmitModal(true) : finish(false))}
                  className="px-7 py-2.5 rounded-xl font-extrabold bg-emerald-600 text-white hover:bg-emerald-700 transition"
                >
                  Finish ✓
                </button>
              )}
            </div>
          </div>
        </div>

        <div>
          <BubbleSheet
            questions={questions}
            selections={selections}
            flagged={flagged}
            currentIndex={current}
            onNavigate={setCurrent}
          />
          {mode === AppMode.TEST && (
            <button
              onClick={() => setShowSubmitModal(true)}
              className="w-full mt-4 bg-rose-600 hover:bg-rose-700 text-white font-black py-3 rounded-xl transition"
            >
              Submit Paper ✓
            </button>
          )}
        </div>
      </div>

      {showSubmitModal && (
        <div className="fixed inset-0 bg-slate-900/50 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl shadow-lift p-6 max-w-md w-full animate-fade-in">
            <h3 className="text-xl font-black text-slate-800 mb-2">Submit your paper?</h3>
            <p className="text-slate-500 font-semibold mb-5">
              {unanswered > 0
                ? `You still have ${unanswered} unanswered question${unanswered > 1 ? 's' : ''}${
                    flaggedCount > 0 ? ` and ${flaggedCount} flagged for review` : ''
                  }. Once submitted, the paper locks and gets scored.`
                : 'All questions answered. Once submitted, the paper locks and gets scored.'}
            </p>
            <div className="flex gap-3 justify-end">
              <button
                onClick={() => setShowSubmitModal(false)}
                className="px-5 py-2.5 rounded-xl font-extrabold bg-slate-100 text-slate-600 hover:bg-slate-200"
              >
                Keep going
              </button>
              <button
                onClick={() => {
                  setShowSubmitModal(false);
                  finish(false);
                }}
                className="px-5 py-2.5 rounded-xl font-extrabold bg-rose-600 text-white hover:bg-rose-700"
              >
                Submit now
              </button>
            </div>
          </div>
        </div>
      )}
    </section>
  );
}
