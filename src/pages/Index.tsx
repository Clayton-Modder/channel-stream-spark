import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { useQuery } from "@tanstack/react-query";
import { Search, Tv, Settings, Star } from "lucide-react";
import { Input } from "@/components/ui/input";
import CategoryFilter from "@/components/CategoryFilter";
import ChannelCard from "@/components/ChannelCard";
import { useFavorites } from "@/hooks/useFavorites";

interface Channel {
  id: string;
  image: string;
  name: string;
  categories: number[];
  url: string;
}

interface ApiData {
  categories: { id: number; name: string }[];
  channels: Channel[];
}

const fetchChannels = async (): Promise<ApiData> => {
  const res = await fetch("/channels.json");
  if (!res.ok) throw new Error("Falha ao carregar canais");
  return res.json();
};

const Index = () => {
  const navigate = useNavigate();
  const [activeCategory, setActiveCategory] = useState(0);
  const [search, setSearch] = useState("");
  const [showFavoritesOnly, setShowFavoritesOnly] = useState(false);
  const { isFavorite, toggleFavorite, favorites } = useFavorites();

  const { data, isLoading, error } = useQuery({
    queryKey: ["channels"],
    queryFn: fetchChannels,
  });

  const filtered = data?.channels.filter((ch) => {
    const matchCat = activeCategory === 0 || ch.categories.includes(activeCategory);
    const matchSearch = ch.name.toLowerCase().includes(search.toLowerCase());
    const matchFav = !showFavoritesOnly || isFavorite(ch.id);
    return matchCat && matchSearch && matchFav;
  }) ?? [];

  return (
    <div className="min-h-screen bg-background text-foreground">
      {/* Header */}
      <header className="sticky top-0 z-10 bg-background/80 backdrop-blur-md border-b border-border">
        <div className="container mx-auto px-4 py-4 flex items-center justify-between gap-4">
          <div className="flex items-center gap-2">
            <Tv className="w-6 h-6 text-primary" />
            <h1 className="text-xl font-bold tracking-tight">TV ONLINE</h1>
          </div>
          <div className="relative w-full max-w-xs">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
            <Input
              placeholder="Buscar canal ou nº..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="pl-9 bg-secondary border-border"
            />
          </div>
          <div className="flex items-center gap-1">
            <button
              onClick={() => setShowFavoritesOnly(!showFavoritesOnly)}
              className={`p-2 rounded-lg transition-colors ${
                showFavoritesOnly
                  ? "bg-yellow-500/20 text-yellow-400"
                  : "text-muted-foreground hover:text-foreground hover:bg-secondary"
              }`}
              title="Favoritos"
            >
              <Star className={`w-5 h-5 ${showFavoritesOnly ? "fill-yellow-400" : ""}`} />
            </button>
            <button
              onClick={() => navigate("/settings")}
              className="p-2 rounded-lg hover:bg-secondary transition-colors text-muted-foreground hover:text-foreground"
            >
              <Settings className="w-5 h-5" />
            </button>
          </div>
        </div>
      </header>

      <main className="container mx-auto px-4 py-6 space-y-6">
        {/* Categories */}
        {data?.categories && (
          <CategoryFilter
            categories={data.categories}
            activeCategory={activeCategory}
            onSelect={setActiveCategory}
          />
        )}

        {/* Count */}
        <p className="text-sm font-semibold text-muted-foreground uppercase tracking-wider">
          {showFavoritesOnly && <Star className="w-3.5 h-3.5 inline fill-yellow-400 text-yellow-400 mr-1 -mt-0.5" />}
          {filtered.length} {showFavoritesOnly ? "Favoritos" : "Canais"}
        </p>

        {/* Loading / Error */}
        {isLoading && (
          <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-6 gap-4">
            {Array.from({ length: 12 }).map((_, i) => (
              <div key={i} className="rounded-lg bg-card border border-border h-40 animate-pulse" />
            ))}
          </div>
        )}
        {error && <p className="text-destructive">Erro ao carregar canais.</p>}

        {/* Grid */}
        {!isLoading && (
          <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-6 gap-4">
            {filtered.map((ch, i) => (
              <ChannelCard
                key={ch.id}
                id={ch.id}
                index={i + 1}
                name={ch.name}
                image={ch.image}
                isFavorite={isFavorite(ch.id)}
                onToggleFavorite={toggleFavorite}
              />
            ))}
          </div>
        )}

        {/* Empty favorites */}
        {!isLoading && showFavoritesOnly && filtered.length === 0 && (
          <div className="text-center py-12 text-muted-foreground">
            <Star className="w-10 h-10 mx-auto mb-3 opacity-30" />
            <p className="text-sm">Nenhum canal favorito ainda.</p>
            <p className="text-xs mt-1">Toque na ★ para adicionar favoritos.</p>
          </div>
        )}
      </main>
    </div>
  );
};

export default Index;
