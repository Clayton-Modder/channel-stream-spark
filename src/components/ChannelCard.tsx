import { useNavigate } from "react-router-dom";
import { Star } from "lucide-react";
import { Badge } from "@/components/ui/badge";

interface ChannelCardProps {
  id: string;
  index: number;
  name: string;
  image: string;
  isFavorite: boolean;
  onToggleFavorite: (id: string) => void;
}

const ChannelCard = ({ id, index, name, image, isFavorite, onToggleFavorite }: ChannelCardProps) => {
  const navigate = useNavigate();

  return (
    <button
      onClick={() => navigate(`/player?id=${id}`)}
      className="group relative block w-full text-left rounded-lg bg-card border border-border overflow-hidden transition-all hover:border-primary/50 hover:shadow-lg hover:shadow-primary/5 hover:scale-[1.02]"
    >
      {/* Favorite star */}
      <span
        role="button"
        onClick={(e) => {
          e.stopPropagation();
          onToggleFavorite(id);
        }}
        className="absolute top-2 right-2 z-[2] p-1 rounded-full hover:bg-black/20 transition-colors"
      >
        <Star
          className={`w-4 h-4 transition-colors ${
            isFavorite
              ? "fill-yellow-400 text-yellow-400"
              : "text-muted-foreground opacity-0 group-hover:opacity-100"
          }`}
        />
      </span>

      <div className="relative p-4">
        <span className="absolute top-2 left-2 text-xs font-bold text-primary bg-primary/10 rounded px-1.5 py-0.5">
          {index}
        </span>
        <Badge className="absolute bottom-2 right-2 bg-[hsl(var(--live))] text-[hsl(var(--live-foreground))] border-none text-[10px] gap-1">
          <span className="w-1.5 h-1.5 rounded-full bg-current animate-pulse" />
          AO VIVO
        </Badge>
        <div className="flex items-center justify-center h-24 mt-2">
          <img
            src={image}
            alt={name}
            className="max-h-20 max-w-full object-contain opacity-80 group-hover:opacity-100 transition-opacity"
            loading="lazy"
            onError={(e) => {
              (e.target as HTMLImageElement).style.display = "none";
            }}
          />
        </div>
      </div>
      <div className="px-4 pb-3">
        <p className="text-sm font-medium text-card-foreground truncate">{name}</p>
      </div>
    </button>
  );
};

export default ChannelCard;
