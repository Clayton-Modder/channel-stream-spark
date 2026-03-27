const STORAGE_KEY = "tv_channels_data";

export interface Channel {
  id: string;
  image: string;
  name: string;
  categories: number[];
  url: string;
  archived?: boolean;
}

export interface Category {
  id: number;
  name: string;
}

export interface ChannelData {
  categories: Category[];
  channels: Channel[];
}

export async function loadChannelData(): Promise<ChannelData> {
  const stored = localStorage.getItem(STORAGE_KEY);
  if (stored) {
    try {
      return JSON.parse(stored);
    } catch {}
  }
  const res = await fetch("/channels.json");
  if (!res.ok) throw new Error("Falha ao carregar canais");
  const data = await res.json();
  return data;
}

export function saveChannelData(data: ChannelData) {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(data));
}

export function isAdminLoggedIn(): boolean {
  return sessionStorage.getItem("admin_auth") === "true";
}

export function adminLogin(password: string): boolean {
  if (password === "267432") {
    sessionStorage.setItem("admin_auth", "true");
    return true;
  }
  return false;
}

export function adminLogout() {
  sessionStorage.removeItem("admin_auth");
}
