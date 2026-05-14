import { useState, useEffect, useCallback, useRef } from "react";
import { useNavigate } from "react-router-dom";
import { ArrowLeft, Search, Film, Tv2, Sparkles, Play, Loader2 } from "lucide-react";
import { Input } from "@/components/ui/input";

interface Episode {
  id_link: number;
  season: number;
  episode: number;
  language: string;
  quality: string;
  image: string;
  stream_url: string;
}

export interface CatalogItem {
  id: number;
  tmdb_id: number;
  title: string;
  type: string;
  poster: string;
  backdrop: string;
  year: string;
  genres: string;
  synopsis: string;
  episodes_count: number;
  stream_url: string;
  episodes?: Episode[];
}

type TabType = "movies" | "series" | "animes";

const API_BASE = import.meta.env.VITE_CATALOG_API_URL ?? "https://cinetvembed.bond/api/catalog.php?username=TVOnlineHD-vods&password=js7vHAsc&type=";

const TABS: { key: TabType; label: string; icon: React.ReactNode }[] = [
  { key: "movies", label: "Filmes", icon: <Film className="w-4 h-4" /> },
  { key: "series", label: "Séries", icon: <Tv2 className="w-4 h-4" /> },
  { key: "animes", label: "Animes", icon: <Sparkles className="w-4 h-4" /> },
];

const CatalogPage = () => {
  const navigate = useNavigate();
  const [activeTab, setActiveTab] = useState<TabType>("movies");
  const [search, setSearch] = useState("");
  const [items, setItems] = useState<CatalogItem[]>([]);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [loading, setLoading] = useState(false);
  const [initialLoad, setInitialLoad] = useState(true);
  const loaderRef = useRef<HTMLDivElement>(null);
  const abortRef = useRef<AbortController | null>(null);

  const fetchPage = useCallback(async (type: TabType, p: number, reset: boolean) => {
    abortRef.current?.abort();
    const ctrl = new AbortController();
    abortRef.current = ctrl;
    
    if (reset) setInitialLoad(true);
    setLoading(true);

    try {
      const res = await fetch(`${API_BASE}${type}&page=${p}`, { signal: ctrl.signal });
      if (!res.ok) throw new Error("Erro");
      const json = await res.json();
      const data: CatalogItem[] = json?.data ?? [];
      const total = json?.pagination?.total_pages ?? 1;

      setTotalPages(total);
      setItems(prev => reset ? data : [...prev, ...data]);
    } catch (e: any) {
      if (e.name !== "AbortError") console.error(e);
    } finally {
      setLoading(false);
      setInitialLoad(false);
    }
  }, []);

  // Reset on tab change
  useEffect(() => {
    setItems([]);
    setPage(1);
    setSearch("");
    fetchPage(activeTab, 1, true);
  }, [activeTab, fetchPage]);

  // Infinite scroll
  useEffect(() => {
    const el = loaderRef.current;
    if (!el) return;
    const obs = new IntersectionObserver(
      (entries) => {
        if (entries[0].isIntersecting && !loading && page < totalPages) {
          const next = page + 1;
          setPage(next);
          fetchPage(activeTab, next, false);
        }
      },
      { threshold: 0.1 }
    );
    obs.observe(el);
    return () => obs.disconnect();
  }, [page, totalPages, loading, activeTab, fetchPage]);

  const filtered = search
    ? items.filter((item) => item.title.toLowerCase().includes(search.toLowerCase()))
    : items;

  const handleClick = (item: CatalogItem) => {
    if (item.type === "serie" || (item.episodes && item.episodes.length > 1)) {
      navigate(`/catalog/${item.id}?type=${activeTab}`);
    } else {
      navigate(`/watch?url=${encodeURIComponent(item.stream_url)}&title=${encodeURIComponent(item.title)}`);
    }
  };

  return (
    <div className="min-h-screen bg-background text-foreground">
      <header className="sticky top-0 z-10 bg-background/80 backdrop-blur-md border-b border-border">
        <div className="container mx-auto px-4 py-3 flex items-center gap-3">
          <button onClick={() => navigate("/")} className="p-2 hover:bg-secondary rounded-lg transition-colors">
            <ArrowLeft className="w-5 h-5" />
          </button>
          <h1 className="text-lg font-bold">Catálogo</h1>
          <div className="relative flex-1 max-w-xs ml-auto">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
            <Input
              placeholder="Buscar..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="pl-9 bg-secondary border-border h-9"
            />
          </div>
        </div>
        <div className="container mx-auto px-4 pb-2 flex gap-2">
          {TABS.map((tab) => (
            <button
              key={tab.key}
              onClick={() => setActiveTab(tab.key)}
              className={`flex items-center gap-1.5 px-4 py-1.5 rounded-full text-sm font-medium transition-all ${
                activeTab === tab.key
                  ? "bg-primary text-primary-foreground"
                  : "bg-secondary text-muted-foreground hover:text-foreground"
              }`}
            >
              {tab.icon}
              {tab.label}
            </button>
          ))}
        </div>
      </header>

      <main className="container mx-auto px-4 py-4">
        <p className="text-sm text-muted-foreground mb-4">
          {filtered.length} {activeTab === "movies" ? "filmes" : activeTab === "series" ? "séries" : "animes"}
          {!search && ` (pág. ${page}/${totalPages})`}
        </p>

        {initialLoad && (
          <div className="grid grid-cols-3 sm:grid-cols-4 md:grid-cols-5 lg:grid-cols-6 gap-3">
            {Array.from({ length: 18 }).map((_, i) => (
              <div key={i} className="aspect-[2/3] rounded-lg bg-card border border-border animate-pulse" />
            ))}
          </div>
        )}

        {!initialLoad && (
          <div className="grid grid-cols-3 sm:grid-cols-4 md:grid-cols-5 lg:grid-cols-6 gap-3">
            {filtered.map((item, idx) => (
              <button
                key={`${item.id}-${idx}`}
                onClick={() => handleClick(item)}
                className="group relative aspect-[2/3] rounded-lg overflow-hidden bg-card border border-border hover:border-primary/50 transition-all"
              >
                <img
                  src={item.poster}
                  alt={item.title}
                  className="absolute inset-0 w-full h-full object-cover"
                  loading="lazy"
                  onError={(e) => { (e.target as HTMLImageElement).src = "/placeholder.svg"; }}
                />
                <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity flex items-end p-2">
                  <div className="w-full">
                    <p className="text-white text-xs font-semibold truncate">{item.title}</p>
                    <p className="text-white/60 text-[10px]">{item.year} · {item.genres?.split(",")[0]}</p>
                  </div>
                </div>
                <div className="absolute inset-0 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity">
                  <div className="w-10 h-10 rounded-full bg-primary/80 flex items-center justify-center">
                    <Play className="w-5 h-5 text-primary-foreground fill-primary-foreground" />
                  </div>
                </div>
                <span className="absolute top-1.5 right-1.5 bg-black/60 text-white text-[10px] px-1.5 py-0.5 rounded">
                  {item.year}
                </span>
                {item.episodes_count > 1 && (
                  <span className="absolute top-1.5 left-1.5 bg-primary/80 text-primary-foreground text-[10px] px-1.5 py-0.5 rounded">
                    {item.episodes_count} ep.
                  </span>
                )}
              </button>
            ))}
          </div>
        )}

        {/* Infinite scroll trigger */}
        {!search && (
          <div ref={loaderRef} className="flex justify-center py-8">
            {loading && !initialLoad && (
              <Loader2 className="w-6 h-6 animate-spin text-muted-foreground" />
            )}
            {page >= totalPages && !loading && items.length > 0 && (
              <p className="text-xs text-muted-foreground">Fim do catálogo</p>
            )}
          </div>
        )}

        {!initialLoad && filtered.length === 0 && (
          <div className="text-center py-12 text-muted-foreground">
            <Film className="w-10 h-10 mx-auto mb-3 opacity-30" />
            <p className="text-sm">Nenhum resultado encontrado.</p>
          </div>
        )}
      </main>
    </div>
  );
};

export default CatalogPage;
