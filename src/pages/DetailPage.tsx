import { useState, useEffect } from "react";
import { useParams, useSearchParams, useNavigate } from "react-router-dom";
import { ArrowLeft, Play, Calendar, Tag, Film, Loader2 } from "lucide-react";
import type { CatalogItem } from "./CatalogPage";

interface Episode {
  id_link: number;
  season: number;
  episode: number;
  language: string;
  quality: string;
  image: string;
  stream_url: string;
}

const API_BASE = "https://cinetvembed.bond/api/catalog.php?username=TVOnlineHD-vods&password=js7vHAsc&type=";

const DetailPage = () => {
  const { id } = useParams();
  const [params] = useSearchParams();
  const navigate = useNavigate();
  const type = params.get("type") || "series";

  const [item, setItem] = useState<CatalogItem | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const findItem = async () => {
      setLoading(true);
      let page = 1;
      let found: CatalogItem | null = null;

      while (!found) {
        try {
          const res = await fetch(`${API_BASE}${type}&page=${page}`);
          const json = await res.json();
          const data: CatalogItem[] = json?.data ?? [];
          found = data.find((d) => String(d.id) === id) || null;
          if (found || page >= (json?.pagination?.total_pages ?? 1)) break;
          page++;
        } catch {
          break;
        }
      }
      setItem(found);
      setLoading(false);
    };
    findItem();
  }, [id, type]);

  const episodes: Episode[] = (item as any)?.episodes ?? [];

  // Group episodes by season
  const seasons = episodes.reduce<Record<number, Episode[]>>((acc, ep) => {
    if (!acc[ep.season]) acc[ep.season] = [];
    acc[ep.season].push(ep);
    return acc;
  }, {});

  const seasonNumbers = Object.keys(seasons).map(Number).sort((a, b) => a - b);
  const [activeSeason, setActiveSeason] = useState(1);

  useEffect(() => {
    if (seasonNumbers.length > 0 && !seasonNumbers.includes(activeSeason)) {
      setActiveSeason(seasonNumbers[0]);
    }
  }, [seasonNumbers, activeSeason]);

  // Deduplicate episodes (prefer Dublado)
  const currentEpisodes = (seasons[activeSeason] ?? [])
    .sort((a, b) => a.episode - b.episode)
    .reduce<Episode[]>((acc, ep) => {
      const existing = acc.find((e) => e.episode === ep.episode);
      if (!existing) acc.push(ep);
      else if (ep.language === "Dublado" && existing.language !== "Dublado") {
        acc[acc.indexOf(existing)] = ep;
      }
      return acc;
    }, []);

  const handlePlay = (url: string, title: string) => {
    navigate(`/watch?url=${encodeURIComponent(url)}&title=${encodeURIComponent(title)}`);
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-background flex items-center justify-center">
        <Loader2 className="w-8 h-8 animate-spin text-primary" />
      </div>
    );
  }

  if (!item) {
    return (
      <div className="min-h-screen bg-background flex flex-col items-center justify-center text-foreground gap-4">
        <Film className="w-12 h-12 opacity-30" />
        <p>Conteúdo não encontrado.</p>
        <button onClick={() => navigate("/catalog")} className="text-primary underline text-sm">Voltar ao catálogo</button>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background text-foreground">
      {/* Backdrop */}
      <div className="relative h-56 sm:h-72 md:h-80 overflow-hidden">
        <img
          src={item.backdrop || item.poster}
          alt=""
          className="absolute inset-0 w-full h-full object-cover"
        />
        <div className="absolute inset-0 bg-gradient-to-t from-background via-background/60 to-transparent" />
        <button
          onClick={() => navigate("/catalog")}
          className="absolute top-4 left-4 z-10 p-2 rounded-full bg-black/50 text-white hover:bg-black/70 transition-colors"
        >
          <ArrowLeft className="w-5 h-5" />
        </button>
      </div>

      <div className="container mx-auto px-4 -mt-20 relative z-10">
        <div className="flex gap-4">
          {/* Poster */}
          <img
            src={item.poster}
            alt={item.title}
            className="w-28 sm:w-36 rounded-lg shadow-lg border-2 border-border flex-shrink-0"
            onError={(e) => { (e.target as HTMLImageElement).src = "/placeholder.svg"; }}
          />
          <div className="flex flex-col justify-end pb-2">
            <h1 className="text-xl sm:text-2xl font-bold">{item.title}</h1>
            <div className="flex items-center gap-3 mt-1 text-sm text-muted-foreground">
              <span className="flex items-center gap-1"><Calendar className="w-3.5 h-3.5" />{item.year}</span>
              <span className="flex items-center gap-1"><Tag className="w-3.5 h-3.5" />{item.genres?.split(",")[0]}</span>
              {item.episodes_count > 1 && <span>{item.episodes_count} episódios</span>}
            </div>
            {/* Play button for movies */}
            {item.stream_url && episodes.length === 0 && (
              <button
                onClick={() => handlePlay(item.stream_url, item.title)}
                className="mt-3 flex items-center gap-2 px-4 py-2 rounded-lg bg-primary text-primary-foreground font-semibold text-sm hover:bg-primary/90 transition-colors w-fit"
              >
                <Play className="w-4 h-4 fill-primary-foreground" /> Assistir
              </button>
            )}
          </div>
        </div>

        {/* Synopsis */}
        <div className="mt-5">
          <h2 className="text-sm font-semibold uppercase tracking-wider text-muted-foreground mb-2">Sinopse</h2>
          <p className="text-sm leading-relaxed">{item.synopsis || "Sinopse não disponível."}</p>
        </div>

        {/* Genres */}
        {item.genres && (
          <div className="mt-4 flex flex-wrap gap-2">
            {item.genres.split(",").map((g) => (
              <span key={g.trim()} className="px-2.5 py-1 rounded-full bg-secondary text-xs font-medium text-foreground">
                {g.trim()}
              </span>
            ))}
          </div>
        )}

        {/* Episodes */}
        {seasonNumbers.length > 0 && (
          <div className="mt-6 pb-8">
            <h2 className="text-sm font-semibold uppercase tracking-wider text-muted-foreground mb-3">Episódios</h2>

            {/* Season tabs */}
            {seasonNumbers.length > 1 && (
              <div className="flex gap-2 overflow-x-auto pb-3 scrollbar-hide">
                {seasonNumbers.map((s) => (
                  <button
                    key={s}
                    onClick={() => setActiveSeason(s)}
                    className={`px-3 py-1.5 rounded-full text-xs font-medium transition-all whitespace-nowrap ${
                      activeSeason === s
                        ? "bg-primary text-primary-foreground"
                        : "bg-secondary text-muted-foreground hover:text-foreground"
                    }`}
                  >
                    Temporada {s}
                  </button>
                ))}
              </div>
            )}

            {/* Episode list */}
            <div className="space-y-2">
              {currentEpisodes.map((ep) => (
                <button
                  key={ep.id_link}
                  onClick={() => handlePlay(ep.stream_url, `${item.title} T${ep.season}E${ep.episode}`)}
                  className="w-full flex items-center gap-3 p-3 rounded-lg bg-card border border-border hover:border-primary/50 hover:bg-card/80 transition-all text-left"
                >
                  <div className="w-10 h-10 rounded-lg bg-primary/10 flex items-center justify-center flex-shrink-0">
                    <Play className="w-4 h-4 text-primary fill-primary" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-medium">Episódio {ep.episode}</p>
                    <p className="text-xs text-muted-foreground">{ep.language} · {ep.quality}</p>
                  </div>
                </button>
              ))}
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default DetailPage;
