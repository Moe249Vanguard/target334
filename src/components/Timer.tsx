import { useEffect, useRef, useState } from 'react';

export function formatSeconds(totalSeconds: number): string {
  const clamped = Math.max(0, totalSeconds);
  const minutes = Math.floor(clamped / 60);
  const seconds = clamped % 60;
  return `${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;
}

interface TimerProps {
  /** Full countdown length in seconds (e.g. 3600 for the 60-minute block). */
  initialSeconds: number;
  /** Pauses the countdown (used once the paper is submitted/locked). */
  paused: boolean;
  /** Fired exactly once when the countdown reaches zero. */
  onExpire: () => void;
  /** Reports the remaining seconds each tick so the parent can compute time used. */
  onTick: (remaining: number) => void;
}

/**
 * Robust countdown for Test Mode. Computes remaining time from a wall-clock
 * deadline rather than accumulating ticks, so it cannot drift and it survives
 * the tab being throttled in the background.
 * Alert states: amber warning at ≤5 minutes, pulsing red at ≤1 minute.
 */
export function Timer({ initialSeconds, paused, onExpire, onTick }: TimerProps) {
  const [remaining, setRemaining] = useState(initialSeconds);
  const deadlineRef = useRef<number>(Date.now() + initialSeconds * 1000);
  const pausedAtRef = useRef<number | null>(null);
  const expiredRef = useRef(false);
  const onExpireRef = useRef(onExpire);
  const onTickRef = useRef(onTick);
  onExpireRef.current = onExpire;
  onTickRef.current = onTick;

  useEffect(() => {
    if (paused) {
      if (pausedAtRef.current === null) pausedAtRef.current = Date.now();
      return;
    }
    // Resume: push the deadline forward by however long we were paused.
    if (pausedAtRef.current !== null) {
      deadlineRef.current += Date.now() - pausedAtRef.current;
      pausedAtRef.current = null;
    }
    const interval = window.setInterval(() => {
      const secondsLeft = Math.ceil((deadlineRef.current - Date.now()) / 1000);
      const next = Math.max(0, secondsLeft);
      setRemaining(next);
      onTickRef.current(next);
      if (next <= 0 && !expiredRef.current) {
        expiredRef.current = true;
        onExpireRef.current();
      }
    }, 250);
    return () => window.clearInterval(interval);
  }, [paused]);

  const warning = remaining <= 300;
  const critical = remaining <= 60;

  return (
    <div className="flex items-center gap-3">
      <span className="text-xs font-extrabold text-slate-400 hidden sm:inline">TIME LEFT</span>
      <span
        role="timer"
        aria-live="off"
        className={[
          'font-black text-2xl tabular-nums px-4 py-1.5 rounded-xl',
          critical
            ? 'animate-pulse-red bg-rose-100 text-rose-700'
            : warning
              ? 'bg-rose-100 text-rose-700'
              : 'bg-indigo-50 text-indigo-700',
        ].join(' ')}
      >
        {formatSeconds(remaining)}
      </span>
    </div>
  );
}
