import { useState, useEffect, useCallback, useRef } from "react";

const STORAGE_KEY = "tv-game-favorites";
const NOTIFY_BEFORE_MS = 5 * 60 * 1000; // 5 min before kickoff

export interface FavoriteGame {
  id: string;
  title: string;
  start: number; // unix seconds
}

function load(): FavoriteGame[] {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    return raw ? JSON.parse(raw) : [];
  } catch {
    return [];
  }
}

function save(favs: FavoriteGame[]) {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(favs));
}

async function askPermission(): Promise<boolean> {
  if (!("Notification" in window)) return false;
  if (Notification.permission === "granted") return true;
  if (Notification.permission === "denied") return false;
  const result = await Notification.requestPermission();
  return result === "granted";
}

function scheduleNotif(game: FavoriteGame): ReturnType<typeof setTimeout> | null {
  if (typeof window === "undefined" || !("Notification" in window)) return null;
  if (Notification.permission !== "granted") return null;

  const fireAt = game.start * 1000 - NOTIFY_BEFORE_MS;
  const delay = fireAt - Date.now();
  if (delay < 0) return null;

  return setTimeout(() => {
    try {
      new Notification("Jogo começando em breve!", {
        body: game.title,
        icon: "/favicon.ico",
        tag: game.id,
      });
    } catch {}
  }, delay);
}

export function useGameFavorites() {
  const [favorites, setFavorites] = useState<FavoriteGame[]>(load);
  const timers = useRef<Map<string, ReturnType<typeof setTimeout>>>(new Map());

  // Re-schedule notifications on mount
  useEffect(() => {
    if (Notification.permission === "granted") {
      favorites.forEach((game) => {
        const t = scheduleNotif(game);
        if (t) timers.current.set(game.id, t);
      });
    }
    return () => {
      timers.current.forEach(clearTimeout);
    };
    // run once on mount
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const isFavorite = useCallback(
    (id: string) => favorites.some((f) => f.id === id),
    [favorites]
  );

  const toggleFavorite = useCallback(
    async (game: FavoriteGame) => {
      const alreadyFav = favorites.some((f) => f.id === game.id);

      if (alreadyFav) {
        const existing = timers.current.get(game.id);
        if (existing !== undefined) clearTimeout(existing);
        timers.current.delete(game.id);
        const next = favorites.filter((f) => f.id !== game.id);
        setFavorites(next);
        save(next);
      } else {
        const granted = await askPermission();
        const next = [...favorites, game];
        setFavorites(next);
        save(next);
        if (granted) {
          const t = scheduleNotif(game);
          if (t) timers.current.set(game.id, t);
        }
      }
    },
    [favorites]
  );

  return { favorites, isFavorite, toggleFavorite };
}
