import { useCallback, useState } from 'react';

/**
 * useState that transparently persists to window.localStorage.
 * Storage failures (private browsing, quota) degrade gracefully to in-memory state.
 */
export function useLocalStorage<T>(
  key: string,
  initialValue: T,
): [T, (value: T | ((previous: T) => T)) => void] {
  const [stored, setStored] = useState<T>(() => {
    try {
      const raw = window.localStorage.getItem(key);
      return raw !== null ? (JSON.parse(raw) as T) : initialValue;
    } catch {
      return initialValue;
    }
  });

  const setValue = useCallback(
    (value: T | ((previous: T) => T)) => {
      setStored((previous) => {
        const next = value instanceof Function ? value(previous) : value;
        try {
          window.localStorage.setItem(key, JSON.stringify(next));
        } catch {
          // Storage unavailable — keep state in memory only.
        }
        return next;
      });
    },
    [key],
  );

  return [stored, setValue];
}
