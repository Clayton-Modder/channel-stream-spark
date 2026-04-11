import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { useQuery } from "@tanstack/react-query";
import { ArrowLeft, Search, Film, Tv2, Sparkles, Play } from "lucide-react";
import { Input } from "@/components/ui/input";

interface CatalogItem {
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
}

type TabType = "movies" | "series" | "animes";

const API_BASE = "https://cinetvembed.bond/api/catalog.php?username=TVOnlineHD-vods&password=js7vHAsc&type=";

const TABS: { key: TabType; label: string; icon: React.ReactNode }[] = [
  { key: "movies", label: "Filmes", icon: <Film className="w-4 h-4" /> },
  { key: "series", label: "Séries", icon: <Tv2 className="w-4 h-4" /> },
  { key: "animes", label: "Animes", icon: <Sparkles className="w-4 h-4" /> },
];

const fetchCatalog = async (type: TabType): Promise<CatalogItem[]> => {
  const res = await fetch(`${API_BASE}${type}`);
  if (!res.ok) throw new Error("Falha ao carregar catálogo");
  const data = await res.json();
  return Array.isArray(data) ? data : [];
};

const CatalogPage = () => {
  const navigate = useNavigate();
  const [activeTab, setActiveTab] = useState<TabType>("movies");
  const [search, setSearch] = useState("");

  const { data: items, isLoading } = useQuery({
    queryKey: ["catalog", activeTab],
    queryFn: () => fetchCatalog(activeTab),
  });

  const filtered = items?.filter((item) =>
    item.title.toLowerCase().includes(search.toLowerCase())
  ) ?? [];

  const handlePlay = (item: CatalogItem) => {
    navigate(
      `/player?stream=${encodeURIComponent(item.stream_url)}&title=${encodeURIComponent(item.title)}`
    );
  };

  return (
    <div className="min-h-screen bg-background text-foreground">
      {/* Header */}
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

        {/* Tabs */}
        <div className="container mx-auto px-4 pb-2 flex gap-2">
          {TABS.map((tab) => (
            <button
              key={tab.key}
              onClick={() => { setActiveTab(tab.key); setSearch(""); }}
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
        {/* Count */}
        <p className="text-sm text-muted-foreground mb-4">
          {filtered.length} {activeTab === "movies" ? "filmes" : activeTab === "series" ? "séries" : "animes"}
        </p>

        {/* Loading */}
        {isLoading && (
          <div className="grid grid-cols-3 sm:grid-cols-4 md:grid-cols-5 lg:grid-cols-6 gap-3">
            {Array.from({ length: 18 }).map((_, i) => (
              <div key={i} className="aspect-[2/3] rounded-lg bg-card border border-border animate-pulse" />
            ))}
          </div>
        )}

        {/* Grid */}
        {!isLoading && (
          <div className="grid grid-cols-3 sm:grid-cols-4 md:grid-cols-5 lg:grid-cols-6 gap-3">
            {filtered.map((item) => (
              <button
                key={item.id}
                onClick={() => handlePlay(item)}
                className="group relative aspect-[2/3] rounded-lg overflow-hidden bg-card border border-border hover:border-primary/50 transition-all"
              >
                <img
                  src={item.poster}
                  alt={item.title}
                  className="absolute inset-0 w-full h-full object-cover"
                  loading="lazy"
                  onError={(e) => {
                    (e.target as HTMLImageElement).src = "/placeholder.svg";
                  }}
                />
                {/* Overlay */}
                <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity flex items-end p-2">
                  <div className="w-full">
                    <p className="text-white text-xs font-semibold truncate">{item.title}</p>
                    <p className="text-white/60 text-[10px]">{item.year}</p>
                  </div>
                </div>
                {/* Play icon on hover */}
                <div className="absolute inset-0 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity">
                  <div className="w-10 h-10 rounded-full bg-primary/80 flex items-center justify-center">
                    <Play className="w-5 h-5 text-primary-foreground fill-primary-foreground" />
                  </div>
                </div>
                {/* Year badge */}
                <span className="absolute top-1.5 right-1.5 bg-black/60 text-white text-[10px] px-1.5 py-0.5 rounded">
                  {item.year}
                </span>
              </button>
            ))}
          </div>
        )}

        {/* Empty */}
        {!isLoading && filtered.length === 0 && (
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
