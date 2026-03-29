import { supabase } from "@/integrations/supabase/client";

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
  const { data: categories, error: catErr } = await supabase
    .from("categories")
    .select("id, name")
    .order("id");

  const { data: channels, error: chErr } = await supabase
    .from("channels")
    .select("id, name, image, url, archived");

  const { data: channelCats, error: ccErr } = await supabase
    .from("channel_categories")
    .select("channel_id, category_id");

  if (catErr || chErr || ccErr) {
    console.error("Error loading from database:", catErr, chErr, ccErr);
    // Fallback to channels.json
    const res = await fetch("/channels.json");
    if (!res.ok) throw new Error("Falha ao carregar canais");
    return res.json();
  }

  // If database is empty, seed from channels.json
  if (!channels || channels.length === 0) {
    const res = await fetch("/channels.json");
    if (!res.ok) throw new Error("Falha ao carregar canais");
    const seedData: ChannelData = await res.json();
    await seedDatabase(seedData);
    return seedData;
  }

  // Map categories to channels
  const catMap = new Map<string, number[]>();
  channelCats?.forEach((cc) => {
    if (!catMap.has(cc.channel_id)) catMap.set(cc.channel_id, []);
    catMap.get(cc.channel_id)!.push(cc.category_id);
  });

  const mappedChannels: Channel[] = channels.map((ch) => ({
    id: ch.id,
    name: ch.name,
    image: ch.image,
    url: ch.url,
    archived: ch.archived,
    categories: catMap.get(ch.id) ?? [],
  }));

  return {
    categories: categories ?? [],
    channels: mappedChannels,
  };
}

async function seedDatabase(data: ChannelData) {
  // Insert categories
  const { error: catErr } = await supabase
    .from("categories")
    .upsert(data.categories.map((c) => ({ id: c.id, name: c.name })));
  if (catErr) console.error("Seed categories error:", catErr);

  // Insert channels
  const { error: chErr } = await supabase
    .from("channels")
    .upsert(data.channels.map((ch) => ({
      id: ch.id,
      name: ch.name,
      image: ch.image,
      url: ch.url,
      archived: ch.archived ?? false,
    })));
  if (chErr) console.error("Seed channels error:", chErr);

  // Insert channel_categories
  const ccRows: { channel_id: string; category_id: number }[] = [];
  data.channels.forEach((ch) => {
    ch.categories.forEach((catId) => {
      ccRows.push({ channel_id: ch.id, category_id: catId });
    });
  });
  if (ccRows.length > 0) {
    // Insert in batches of 500
    for (let i = 0; i < ccRows.length; i += 500) {
      const batch = ccRows.slice(i, i + 500);
      const { error } = await supabase.from("channel_categories").upsert(batch);
      if (error) console.error("Seed channel_categories error:", error);
    }
  }
}

// === Channel CRUD ===
export async function saveChannel(channel: Channel, isNew: boolean) {
  const { id, name, image, url, archived, categories } = channel;

  if (isNew) {
    const { error } = await supabase.from("channels").insert({ id, name, image, url, archived: archived ?? false });
    if (error) throw error;
  } else {
    const { error } = await supabase.from("channels").update({ name, image, url, archived: archived ?? false }).eq("id", id);
    if (error) throw error;
  }

  // Sync categories: delete old, insert new
  await supabase.from("channel_categories").delete().eq("channel_id", id);
  if (categories.length > 0) {
    const { error } = await supabase.from("channel_categories").insert(
      categories.map((catId) => ({ channel_id: id, category_id: catId }))
    );
    if (error) throw error;
  }
}

export async function deleteChannel(id: string) {
  const { error } = await supabase.from("channels").delete().eq("id", id);
  if (error) throw error;
}

export async function toggleArchiveChannel(id: string, currentArchived: boolean) {
  const { error } = await supabase.from("channels").update({ archived: !currentArchived }).eq("id", id);
  if (error) throw error;
}

// === Category CRUD ===
export async function saveCategory(category: Category, isNew: boolean) {
  if (isNew) {
    const { error } = await supabase.from("categories").insert({ id: category.id, name: category.name });
    if (error) throw error;
  } else {
    const { error } = await supabase.from("categories").update({ name: category.name }).eq("id", category.id);
    if (error) throw error;
  }
}

export async function deleteCategory(id: number) {
  // channel_categories will cascade delete
  const { error } = await supabase.from("categories").delete().eq("id", id);
  if (error) throw error;
}

// === Admin auth (kept as session-based) ===
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
