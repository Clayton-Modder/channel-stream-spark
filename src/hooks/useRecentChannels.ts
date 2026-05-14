import { useState, useCallback } from "react";

const STORAGE_KEY = "tv-recent-channels";
const MAX_RECENT = 10;

export interface RecentChannel {
  id: string;
  name: string;
  image: string;
  url: string;
  watchedAt: number;
}

function load(): RecentChannel[] {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    return raw ? JSON.parse(raw) : [];
  } catch {
    return [];
  }
}

function save(channels: RecentChannel[]) {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(channels));
}

export function useRecentChannels() {
  const [recent, setRecent] = useState<RecentChannel[]>(load);

  const addRecent = useCallback((channel: Omit<RecentChannel, "watchedAt">) => {
    setRecent((prev) => {
      const filtered = prev.filter((c) => c.id !== channel.id);
      const next = [{ ...channel, watchedAt: Date.now() }, ...filtered].slice(
        0,
        MAX_RECENT
      );
      save(next);
      return next;
    });
  }, []);

  const clearRecent = useCallback(() => {
    setRecent([]);
    localStorage.removeItem(STORAGE_KEY);
  }, []);

  return { recent, addRecent, clearRecent };
}
