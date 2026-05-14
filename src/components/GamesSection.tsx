import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { Trophy, Clock, Bell, BellOff } from "lucide-react";
import { useGameFavorites, FavoriteGame } from "@/hooks/useGameFavorites";
import { toast } from "sonner";

interface GameTeam {
  name: string;
  image: string;
}

interface GameData {
  league: string;
  timer: { start: number; end: number };
  teams: { home: GameTeam; away: GameTeam };
}

interface Game {
  title: string;
  image: string;
  data: GameData;
  players: string[];
}

const STREAM_DOMAIN = import.meta.env.VITE_STREAM_DOMAIN ?? "https://maxsaidapp.embedtv.lat";

const rewriteStreamUrl = (url: string): string => {
  try {
    const parsed = new URL(url);
    return `${STREAM_DOMAIN}${parsed.pathname}${parsed.search}`;
  } catch {
    return url;
  }
};

const formatTime = (timestamp: number): string => {
  const date = new Date(timestamp * 1000);
  return date.toLocaleTimeString("pt-BR", { hour: "2-digit", minute: "2-digit" });
};

const getGameStatus = (start: number, end: number): "upcoming" | "live" | "ended" => {
  const now = Date.now() / 1000;
  if (now < start) return "upcoming";
  if (now > end) return "ended";
  return "live";
};

const makeGameId = (game: Game): string =>
  `${game.data.teams.home.name}-${game.data.teams.away.name}-${game.data.timer.start}`;

const GamesSection = () => {
  const navigate = useNavigate();
  const [games, setGames] = useState<Game[]>([]);
  const [loading, setLoading] = useState(true);
  const { isFavorite, toggleFavorite } = useGameFavorites();

  useEffect(() => {
    fetch(import.meta.env.VITE_GAMES_API_URL ?? "https://embedtv.lat/jogos.php")
      .then((res) => res.json())
      .then((data) => {
        setGames(Array.isArray(data) ? data : []);
      })
      .catch((err) => {
        console.error("Erro ao carregar jogos:", err);
      })
      .finally(() => setLoading(false));
  }, []);

  const handlePlay = (game: Game) => {
    if (!game.players?.length) return;
    const streamUrl = rewriteStreamUrl(game.players[0]);
    navigate(`/player?stream=${encodeURIComponent(streamUrl)}&title=${encodeURIComponent(game.title)}`);
  };

  const handleToggleFavorite = async (e: React.MouseEvent, game: Game) => {
    e.stopPropagation();
    const id = makeGameId(game);
    const fav: FavoriteGame = {
      id,
      title: game.title,
      start: game.data.timer.start,
    };
    const wasAlready = isFavorite(id);
    await toggleFavorite(fav);

    if (wasAlready) {
      toast.info(`Notificação removida para "${game.title}"`);
    } else {
      const status = getGameStatus(game.data.timer.start, game.data.timer.end);
      if (status === "upcoming") {
        toast.success(
          `Você será notificado 5 min antes de "${game.title}" começar`,
          { duration: 4000 }
        );
      } else {
        toast.info(`"${game.title}" adicionado aos favoritos`);
      }
    }
  };

  if (loading) {
    return (
      <div className="space-y-3">
        <h2 className="text-lg font-bold text-foreground flex items-center gap-2">
          <Trophy className="w-5 h-5 text-primary" />
          Jogos do Dia
        </h2>
        <div className="flex gap-3 overflow-x-auto pb-2">
          {Array.from({ length: 3 }).map((_, i) => (
            <div key={i} className="min-w-[280px] h-24 rounded-xl bg-card border border-border animate-pulse" />
          ))}
        </div>
      </div>
    );
  }

  if (games.length === 0) return null;

  return (
    <div className="space-y-3">
      <h2 className="text-lg font-bold text-foreground flex items-center gap-2">
        <Trophy className="w-5 h-5 text-primary" />
        Jogos do Dia
      </h2>
      <div className="flex gap-3 overflow-x-auto pb-2 scrollbar-hide">
        {games.map((game, i) => {
          const status = getGameStatus(game.data.timer.start, game.data.timer.end);
          const gameId = makeGameId(game);
          const favored = isFavorite(gameId);

          return (
            <button
              key={i}
              onClick={() => handlePlay(game)}
              disabled={!game.players?.length}
              className="min-w-[300px] flex-shrink-0 bg-card border border-border rounded-xl p-3 hover:border-primary/50 hover:bg-card/80 transition-all text-left disabled:opacity-50 disabled:cursor-not-allowed group relative"
            >
              {/* Favorite/notification bell */}
              <span
                role="button"
                onClick={(e) => handleToggleFavorite(e, game)}
                className={`absolute top-2 right-2 p-1 rounded-full transition-colors z-10 pointer-events-auto ${
                  favored
                    ? "text-yellow-400 bg-yellow-400/10"
                    : "text-muted-foreground opacity-0 group-hover:opacity-100 hover:bg-black/10"
                }`}
                title={favored ? "Remover notificação" : "Receber notificação"}
              >
                {favored ? (
                  <Bell className="w-4 h-4 fill-yellow-400" />
                ) : (
                  <BellOff className="w-4 h-4" />
                )}
              </span>

              {/* League + Status */}
              <div className="flex items-center justify-between mb-2 pr-6">
                <span className="text-[11px] text-muted-foreground font-medium uppercase tracking-wider">
                  {game.data.league}
                </span>
                {status === "live" ? (
                  <span className="px-2 py-0.5 rounded bg-red-500/20 text-red-400 text-[10px] font-bold flex items-center gap-1">
                    <span className="w-1.5 h-1.5 rounded-full bg-red-400 animate-pulse" />
                    AO VIVO
                  </span>
                ) : status === "upcoming" ? (
                  <span className="text-[11px] text-muted-foreground flex items-center gap-1">
                    <Clock className="w-3 h-3" />
                    {formatTime(game.data.timer.start)}
                  </span>
                ) : (
                  <span className="text-[11px] text-muted-foreground">Encerrado</span>
                )}
              </div>

              {/* Teams */}
              <div className="flex items-center gap-3">
                <div className="flex items-center gap-2 flex-1 min-w-0">
                  <img
                    src={game.data.teams.home.image}
                    alt=""
                    className="w-7 h-7 object-contain rounded"
                    onError={(e) => { (e.target as HTMLImageElement).style.display = "none"; }}
                  />
                  <span className="text-sm font-semibold text-foreground truncate">
                    {game.data.teams.home.name}
                  </span>
                </div>

                <span className="text-xs font-bold text-muted-foreground px-1">×</span>

                <div className="flex items-center gap-2 flex-1 min-w-0 justify-end">
                  <span className="text-sm font-semibold text-foreground truncate text-right">
                    {game.data.teams.away.name}
                  </span>
                  <img
                    src={game.data.teams.away.image}
                    alt=""
                    className="w-7 h-7 object-contain rounded"
                    onError={(e) => { (e.target as HTMLImageElement).style.display = "none"; }}
                  />
                </div>
              </div>
            </button>
          );
        })}
      </div>
    </div>
  );
};

export default GamesSection;
