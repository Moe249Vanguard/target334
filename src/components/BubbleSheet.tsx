import { useEffect, useRef } from 'react';
import { OPTION_LETTERS, Question } from '../types';

interface BubbleSheetProps {
  questions: Question[];
  selections: (number | null)[];
  flagged: boolean[];
  currentIndex: number;
  onNavigate: (index: number) => void;
}

/**
 * OMR-style digital answer sheet — mimics the GL optical mark reader grid to
 * build bubble-filling muscle memory. Rows navigate to their question.
 */
export function BubbleSheet({ questions, selections, flagged, currentIndex, onNavigate }: BubbleSheetProps) {
  const activeRowRef = useRef<HTMLButtonElement | null>(null);

  useEffect(() => {
    activeRowRef.current?.scrollIntoView({ block: 'nearest' });
  }, [currentIndex]);

  return (
    <aside className="bg-white rounded-2xl shadow-soft p-4 lg:sticky lg:top-24">
      <div className="flex items-center justify-between mb-3">
        <h4 className="font-black text-slate-700 text-sm uppercase tracking-wide">Answer Sheet</h4>
        <span className="text-[10px] font-extrabold text-slate-400 bg-slate-100 px-2 py-0.5 rounded-full">
          OMR
        </span>
      </div>
      <p className="text-[11px] text-slate-400 font-semibold mb-3 leading-snug">
        Fill one bubble per question — just like the real exam sheet. Tap a row to jump to that question.
      </p>
      <div className="space-y-1 max-h-[52vh] overflow-y-auto pr-1">
        {questions.map((question, rowIndex) => {
          const isCurrent = rowIndex === currentIndex;
          return (
            <button
              key={question.id}
              ref={isCurrent ? activeRowRef : undefined}
              onClick={() => onNavigate(rowIndex)}
              aria-label={`Go to question ${rowIndex + 1}`}
              aria-current={isCurrent ? 'true' : undefined}
              className={[
                'w-full flex items-center gap-1.5 px-2 py-1 rounded-lg transition',
                isCurrent ? 'bg-indigo-50 ring-2 ring-indigo-300' : 'hover:bg-slate-50',
              ].join(' ')}
            >
              <span
                className={[
                  'w-7 text-right text-[11px] font-black',
                  isCurrent ? 'text-indigo-700' : 'text-slate-400',
                ].join(' ')}
              >
                {rowIndex + 1}
              </span>
              {question.options.map((_, optionIndex) => {
                const filled = selections[rowIndex] === optionIndex;
                return (
                  <span
                    key={optionIndex}
                    className={[
                      'w-5 h-5 rounded-full border-2 flex items-center justify-center text-[8px] font-black transition',
                      filled
                        ? 'bg-slate-800 border-slate-800 text-white'
                        : 'border-slate-300 text-slate-400',
                    ].join(' ')}
                  >
                    {OPTION_LETTERS[optionIndex]}
                  </span>
                );
              })}
              <span className="w-4 text-xs">{flagged[rowIndex] ? '🚩' : ''}</span>
            </button>
          );
        })}
      </div>
    </aside>
  );
}
