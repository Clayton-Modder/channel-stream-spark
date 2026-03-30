import { useState, useEffect, useRef, useCallback } from "react";
import { useSearchParams, useNavigate } from "react-router-dom";
import { useQuery } from "@tanstack/react-query";
import {
  ArrowLeft,
  Maximize,
  Minimize,
  ChevronUp,
  ChevronDown,
  List,
  Settings,
  X,
} from "lucide-react";
import ChannelDrawer from "@/components/ChannelDrawer";
import PresenceModal, { usePresenceCheck } from "@/components/PresenceModal";

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

const Player = () => {
  const [params] = useSearchParams();
  const navigate = useNavigate();
  const channelId = params.get("id") || "";
  const containerRef = useRef<HTMLDivElement>(null);
  const [isFullscreen, setIsFullscreen] = useState(false);
  const [showControls, setShowControls] = useState(true);
  const [showDrawer, setShowDrawer] = useState(false);
  const hideTimer = useRef<ReturnType<typeof setTimeout>>();

  const { data } = useQuery({
    queryKey: ["channels"],
    queryFn: fetchChannels,
  });

  const channels = data?.channels ?? [];
  const categories = data?.categories ?? [];
  const currentIndex = channels.findIndex((c) => c.id === channelId);
  const current = channels[currentIndex];

  const goTo = useCallback(
    (ch: Channel) => {
      navigate(`/player?id=${ch.id}`, { replace: true });
      setShowDrawer(false);
    },
    [navigate]
  );

  const prev = () => {
    if (currentIndex > 0) goTo(channels[currentIndex - 1]);
  };
  const next = () => {
    if (currentIndex < channels.length - 1) goTo(channels[currentIndex + 1]);
  };

  // Auto-hide controls
  const resetHide = useCallback(() => {
    setShowControls(true);
    clearTimeout(hideTimer.current);
    hideTimer.current = setTimeout(() => setShowControls(false), 4000);
  }, []);

  useEffect(() => {
    resetHide();
    return () => clearTimeout(hideTimer.current);
  }, [resetHide]);

  // Fullscreen
  const toggleFullscreen = async () => {
    if (!containerRef.current) return;
    if (!document.fullscreenElement) {
      await containerRef.current.requestFullscreen();
      setIsFullscreen(true);
    } else {
      await document.exitFullscreen();
      setIsFullscreen(false);
    }
  };

  useEffect(() => {
    const handler = () => setIsFullscreen(!!document.fullscreenElement);
    document.addEventListener("fullscreenchange", handler);
    return () => document.removeEventListener("fullscreenchange", handler);
  }, []);

  // Keyboard
  useEffect(() => {
    const handler = (e: KeyboardEvent) => {
      if (e.key === "ArrowUp") prev();
      else if (e.key === "ArrowDown") next();
      else if (e.key === "f") toggleFullscreen();
      else if (e.key === "Escape" && showDrawer) setShowDrawer(false);
      resetHide();
    };
    window.addEventListener("keydown", handler);
    return () => window.removeEventListener("keydown", handler);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [currentIndex, channels, showDrawer]);

  if (!current) {
    return (
      <div className="min-h-screen bg-background flex items-center justify-center text-foreground">
        <p>Canal não encontrado.</p>
      </div>
    );
  }

  return (
    <div
      ref={containerRef}
      className="relative w-full h-screen bg-black overflow-hidden select-none"
      onMouseMove={resetHide}
      onTouchStart={resetHide}
      onClick={() => {
        if (showDrawer) return;
        resetHide();
      }}
    >
      {/* Video iframe */}
      <iframe
        src={current.url}
        title={current.name}
        className="absolute inset-0 w-full h-full border-0"
        allowFullScreen
        allow="autoplay; encrypted-media; fullscreen"
      />

      {/* Controls overlay */}
      <div
        className={`absolute inset-0 z-10 pointer-events-none transition-opacity duration-300 ${
          showControls ? "opacity-100" : "opacity-0"
        }`}
      >
        {/* Top bar */}
        <div className="pointer-events-auto absolute top-0 left-0 right-0 flex items-center justify-between px-3 py-2 sm:px-5 sm:py-3 bg-gradient-to-b from-black/80 to-transparent">
          <button
            onClick={() => navigate("/")}
            className="flex items-center gap-2 text-white/90 hover:text-white transition-colors"
          >
            <ArrowLeft className="w-5 h-5" />
            <span className="text-sm hidden sm:inline">Voltar</span>
          </button>

          <div className="flex items-center gap-2 text-center flex-1 justify-center">
            <img
              src={current.image}
              alt=""
              className="w-6 h-6 object-contain rounded hidden sm:block"
              onError={(e) => {
                (e.target as HTMLImageElement).style.display = "none";
              }}
            />
            <span className="text-white font-semibold text-sm sm:text-base truncate max-w-[200px] sm:max-w-xs">
              {current.name}
            </span>
            <span className="ml-2 px-2 py-0.5 rounded bg-[hsl(var(--live))] text-[10px] text-white font-bold flex items-center gap-1">
              <span className="w-1.5 h-1.5 rounded-full bg-white animate-pulse" />
              AO VIVO
            </span>
          </div>

          <div className="flex items-center gap-1">
            <button
              onClick={() => navigate("/settings")}
              className="p-2 text-white/70 hover:text-white transition-colors"
            >
              <Settings className="w-5 h-5" />
            </button>
            <button
              onClick={toggleFullscreen}
              className="p-2 text-white/70 hover:text-white transition-colors"
            >
              {isFullscreen ? (
                <Minimize className="w-5 h-5" />
              ) : (
                <Maximize className="w-5 h-5" />
              )}
            </button>
          </div>
        </div>

        {/* Right side: channel nav */}
        <div className="pointer-events-auto absolute right-2 sm:right-4 top-1/2 -translate-y-1/2 flex flex-col items-center gap-2">
          <button
            onClick={prev}
            disabled={currentIndex <= 0}
            className="p-2 rounded-full bg-black/50 text-white/80 hover:bg-black/70 hover:text-white disabled:opacity-30 transition-all"
          >
            <ChevronUp className="w-6 h-6" />
          </button>
          <span className="text-white/60 text-xs font-mono">
            {currentIndex + 1}/{channels.length}
          </span>
          <button
            onClick={next}
            disabled={currentIndex >= channels.length - 1}
            className="p-2 rounded-full bg-black/50 text-white/80 hover:bg-black/70 hover:text-white disabled:opacity-30 transition-all"
          >
            <ChevronDown className="w-6 h-6" />
          </button>
        </div>

        {/* Bottom: channel list button */}
        <div className="pointer-events-auto absolute bottom-4 left-1/2 -translate-x-1/2">
          <button
            onClick={() => setShowDrawer(true)}
            className="flex items-center gap-2 px-4 py-2 rounded-full bg-black/60 backdrop-blur text-white/90 hover:bg-black/80 transition-all text-sm"
          >
            <List className="w-4 h-4" />
            Canais
          </button>
        </div>
      </div>

      {/* Channel drawer */}
      {showDrawer && (
        <ChannelDrawer
          channels={channels}
          categories={categories}
          currentId={channelId}
          onSelect={goTo}
          onClose={() => setShowDrawer(false)}
        />
      )}
    </div>
  );
};

export default Player;
