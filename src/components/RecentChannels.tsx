import { useNavigate } from "react-router-dom";
import { Clock, X } from "lucide-react";
import { RecentChannel, useRecentChannels } from "@/hooks/useRecentChannels";

const formatRelativeTime = (ts: number): string => {
  const diff = Date.now() - ts;
  const m = Math.floor(diff / 60000);
  if (m < 1) return "Agora";
  if (m < 60) return `${m}min atrás`;
  const h = Math.floor(m / 60);
  if (h < 24) return `${h}h atrás`;
  return `${Math.floor(h / 24)}d atrás`;
};

interface RecentChannelsProps {
  channels: RecentChannel[];
  onClear: () => void;
}

const RecentChannels = ({ channels, onClear }: RecentChannelsProps) => {
  const navigate = useNavigate();

  if (channels.length === 0) return null;

  const handleSelect = (ch: RecentChannel) => {
    navigate(`/player?id=${ch.id}`);
  };

  return (
    <div className="space-y-3">
      <div className="flex items-center justify-between">
        <h2 className="text-lg font-bold text-foreground flex items-center gap-2">
          <Clock className="w-5 h-5 text-primary" />
          Continuar Assistindo
        </h2>
        <button
          onClick={onClear}
          className="text-xs text-muted-foreground hover:text-foreground transition-colors flex items-center gap-1"
        >
          <X className="w-3 h-3" />
          Limpar
        </button>
      </div>

      <div className="flex gap-3 overflow-x-auto pb-2 scrollbar-hide">
        {channels.map((ch) => (
          <button
            key={ch.id}
            onClick={() => handleSelect(ch)}
            className="min-w-[140px] flex-shrink-0 bg-card border border-border rounded-xl p-3 hover:border-primary/50 hover:bg-card/80 transition-all text-left group"
          >
            <div className="flex items-center justify-center h-14 mb-2">
              <img
                src={ch.image}
                alt={ch.name}
                className="max-h-12 max-w-full object-contain opacity-80 group-hover:opacity-100 transition-opacity"
                onError={(e) => {
                  (e.target as HTMLImageElement).style.display = "none";
                }}
              />
            </div>
            <p className="text-xs font-semibold text-foreground truncate text-center">
              {ch.name}
            </p>
            <p className="text-[10px] text-muted-foreground text-center mt-0.5">
              {formatRelativeTime(ch.watchedAt)}
            </p>
          </button>
        ))}
      </div>
    </div>
  );
};

export default RecentChannels;
