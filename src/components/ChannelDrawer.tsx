import { useState } from "react";
import { Search, X } from "lucide-react";
import { Input } from "@/components/ui/input";
import { cn } from "@/lib/utils";
import { ScrollArea } from "@/components/ui/scroll-area";

interface Channel {
  id: string;
  image: string;
  name: string;
  categories: number[];
  url: string;
}

interface Props {
  channels: Channel[];
  categories: { id: number; name: string }[];
  currentId: string;
  onSelect: (ch: Channel) => void;
  onClose: () => void;
}

const ChannelDrawer = ({ channels, categories, currentId, onSelect, onClose }: Props) => {
  const [search, setSearch] = useState("");
  const [activeCat, setActiveCat] = useState(0);

  const filtered = channels.filter((ch) => {
    const matchCat = activeCat === 0 || ch.categories.includes(activeCat);
    const matchSearch = ch.name.toLowerCase().includes(search.toLowerCase());
    return matchCat && matchSearch;
  });

  return (
    <div className="absolute inset-0 z-30 flex" onClick={onClose}>
      {/* Backdrop */}
      <div className="flex-1" />

      {/* Panel */}
      <div
        className="w-full sm:w-96 h-full bg-background/95 backdrop-blur-xl border-l border-border flex flex-col animate-in slide-in-from-right duration-200"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div className="flex items-center justify-between px-4 py-3 border-b border-border">
          <h2 className="text-base font-bold text-foreground">Selecionar Canal</h2>
          <button onClick={onClose} className="p-1 text-muted-foreground hover:text-foreground">
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Search */}
        <div className="px-4 py-2">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
            <Input
              placeholder="Buscar canal..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="pl-9 bg-secondary border-border h-9 text-sm"
            />
          </div>
        </div>

        {/* Categories */}
        <div className="px-4 py-2 flex gap-1.5 overflow-x-auto no-scrollbar">
          {categories.map((cat) => (
            <button
              key={cat.id}
              onClick={() => setActiveCat(cat.id)}
              className={cn(
                "px-3 py-1 rounded-full text-xs font-medium whitespace-nowrap transition-colors border",
                activeCat === cat.id
                  ? "bg-primary text-primary-foreground border-primary"
                  : "bg-secondary text-secondary-foreground border-border hover:bg-accent"
              )}
            >
              {cat.name}
            </button>
          ))}
        </div>

        {/* Channel list */}
        <ScrollArea className="flex-1">
          <div className="px-2 py-1 space-y-0.5">
            {filtered.map((ch, i) => (
              <button
                key={ch.id}
                onClick={() => onSelect(ch)}
                className={cn(
                  "w-full flex items-center gap-3 px-3 py-2.5 rounded-lg text-left transition-colors",
                  ch.id === currentId
                    ? "bg-primary/15 border border-primary/30"
                    : "hover:bg-secondary border border-transparent"
                )}
              >
                <span className="text-xs font-mono text-muted-foreground w-6 text-right">
                  {i + 1}
                </span>
                <img
                  src={ch.image}
                  alt=""
                  className="w-8 h-8 object-contain rounded"
                  onError={(e) => {
                    (e.target as HTMLImageElement).style.display = "none";
                  }}
                />
                <span
                  className={cn(
                    "text-sm truncate",
                    ch.id === currentId
                      ? "text-primary font-semibold"
                      : "text-foreground"
                  )}
                >
                  {ch.name}
                </span>
                {ch.id === currentId && (
                  <span className="ml-auto px-1.5 py-0.5 rounded bg-[hsl(var(--live))] text-[8px] text-white font-bold flex items-center gap-1">
                    <span className="w-1 h-1 rounded-full bg-white animate-pulse" />
                    LIVE
                  </span>
                )}
              </button>
            ))}
          </div>
        </ScrollArea>
      </div>
    </div>
  );
};

export default ChannelDrawer;
