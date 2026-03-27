import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { useQuery } from "@tanstack/react-query";
import { Search, Tv, Settings } from "lucide-react";
import { Input } from "@/components/ui/input";
import CategoryFilter from "@/components/CategoryFilter";
import ChannelCard from "@/components/ChannelCard";

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

  const { data, isLoading, error } = useQuery({
    queryKey: ["channels"],
    queryFn: fetchChannels,
  });

  const filtered = data?.channels.filter((ch) => {
    const matchCat = activeCategory === 0 || ch.categories.includes(activeCategory);
    const matchSearch = ch.name.toLowerCase().includes(search.toLowerCase());
    return matchCat && matchSearch;
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
          <button
            onClick={() => navigate("/settings")}
            className="p-2 rounded-lg hover:bg-secondary transition-colors text-muted-foreground hover:text-foreground"
          >
            <Settings className="w-5 h-5" />
          </button>
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
          {filtered.length} Canais
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
              />
            ))}
          </div>
        )}
      </main>
    </div>
  );
};

export default Index;
