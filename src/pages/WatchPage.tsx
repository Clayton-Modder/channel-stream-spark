import { useEffect, useRef, useState } from "react";
import { useSearchParams, useNavigate } from "react-router-dom";
import { ArrowLeft, Maximize, Minimize, Loader2 } from "lucide-react";
import Hls from "hls.js";

const WatchPage = () => {
  const [params] = useSearchParams();
  const navigate = useNavigate();
  const url = params.get("url") || "";
  const title = params.get("title") || "Reproduzindo";

  const videoRef = useRef<HTMLVideoElement>(null);
  const containerRef = useRef<HTMLDivElement>(null);
  const hlsRef = useRef<Hls | null>(null);
  const [isFullscreen, setIsFullscreen] = useState(false);
  const [showControls, setShowControls] = useState(true);
  const [error, setError] = useState(false);
  const [loading, setLoading] = useState(true);
  const hideTimer = useRef<ReturnType<typeof setTimeout>>();

  const isHls = url.includes(".m3u8");

  useEffect(() => {
    const video = videoRef.current;
    if (!video || !url) return;

    setError(false);
    setLoading(true);

    if (isHls) {
      if (Hls.isSupported()) {
        const hls = new Hls({ enableWorker: true });
        hlsRef.current = hls;
        hls.loadSource(url);
        hls.attachMedia(video);
        hls.on(Hls.Events.MANIFEST_PARSED, () => {
          video.play().catch(() => {});
          setLoading(false);
        });
        hls.on(Hls.Events.ERROR, (_, data) => {
          if (data.fatal) setError(true);
          setLoading(false);
        });
      } else if (video.canPlayType("application/vnd.apple.mpegurl")) {
        video.src = url;
        video.addEventListener("loadedmetadata", () => {
          video.play().catch(() => {});
          setLoading(false);
        });
      } else {
        setError(true);
        setLoading(false);
      }
    } else {
      video.src = url;
      video.addEventListener("loadeddata", () => setLoading(false));
      video.addEventListener("error", () => { setError(true); setLoading(false); });
      video.play().catch(() => {});
    }

    return () => {
      hlsRef.current?.destroy();
      hlsRef.current = null;
    };
  }, [url, isHls]);

  // Auto-hide controls
  const resetHide = () => {
    setShowControls(true);
    clearTimeout(hideTimer.current);
    hideTimer.current = setTimeout(() => setShowControls(false), 4000);
  };

  useEffect(() => {
    resetHide();
    return () => clearTimeout(hideTimer.current);
  }, []);

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

  return (
    <div
      ref={containerRef}
      className="relative w-full h-screen bg-black overflow-hidden"
      onMouseMove={resetHide}
      onTouchStart={resetHide}
    >
      {/* Video */}
      <video
        ref={videoRef}
        className="absolute inset-0 w-full h-full"
        controls={false}
        playsInline
        autoPlay
      />

      {/* Loading spinner */}
      {loading && (
        <div className="absolute inset-0 flex items-center justify-center z-20">
          <Loader2 className="w-10 h-10 animate-spin text-white" />
        </div>
      )}

      {/* Error */}
      {error && (
        <div className="absolute inset-0 flex flex-col items-center justify-center z-20 text-white gap-3">
          <p className="text-sm">Erro ao reproduzir o vídeo.</p>
          <button
            onClick={() => navigate(-1)}
            className="px-4 py-2 rounded-lg bg-primary text-primary-foreground text-sm"
          >
            Voltar
          </button>
        </div>
      )}

      {/* Controls */}
      <div
        className={`absolute inset-0 z-10 pointer-events-none transition-opacity duration-300 ${
          showControls ? "opacity-100" : "opacity-0"
        }`}
      >
        {/* Top bar */}
        <div className="pointer-events-auto absolute top-0 left-0 right-0 flex items-center justify-between px-4 py-3 bg-gradient-to-b from-black/80 to-transparent">
          <button
            onClick={() => navigate(-1)}
            className="flex items-center gap-2 text-white/90 hover:text-white transition-colors"
          >
            <ArrowLeft className="w-5 h-5" />
            <span className="text-sm hidden sm:inline">Voltar</span>
          </button>

          <span className="text-white font-semibold text-sm truncate max-w-[250px] sm:max-w-md text-center flex-1">
            {title}
          </span>

          <button
            onClick={toggleFullscreen}
            className="p-2 text-white/70 hover:text-white transition-colors"
          >
            {isFullscreen ? <Minimize className="w-5 h-5" /> : <Maximize className="w-5 h-5" />}
          </button>
        </div>

        {/* Bottom: native controls area */}
        <div
          className="pointer-events-auto absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/80 to-transparent p-4"
          onClick={(e) => e.stopPropagation()}
        >
          <VideoControls videoRef={videoRef} />
        </div>
      </div>
    </div>
  );
};

// Simple video controls component
const VideoControls = ({ videoRef }: { videoRef: React.RefObject<HTMLVideoElement> }) => {
  const [playing, setPlaying] = useState(true);
  const [progress, setProgress] = useState(0);
  const [duration, setDuration] = useState(0);

  useEffect(() => {
    const video = videoRef.current;
    if (!video) return;

    const onTime = () => setProgress(video.currentTime);
    const onDur = () => setDuration(video.duration || 0);
    const onPlay = () => setPlaying(true);
    const onPause = () => setPlaying(false);

    video.addEventListener("timeupdate", onTime);
    video.addEventListener("loadedmetadata", onDur);
    video.addEventListener("play", onPlay);
    video.addEventListener("pause", onPause);
    return () => {
      video.removeEventListener("timeupdate", onTime);
      video.removeEventListener("loadedmetadata", onDur);
      video.removeEventListener("play", onPlay);
      video.removeEventListener("pause", onPause);
    };
  }, [videoRef]);

  const toggle = () => {
    const v = videoRef.current;
    if (!v) return;
    v.paused ? v.play() : v.pause();
  };

  const seek = (e: React.ChangeEvent<HTMLInputElement>) => {
    const v = videoRef.current;
    if (v) v.currentTime = Number(e.target.value);
  };

  const fmt = (s: number) => {
    if (!isFinite(s)) return "--:--";
    const m = Math.floor(s / 60);
    const sec = Math.floor(s % 60);
    return `${m}:${sec.toString().padStart(2, "0")}`;
  };

  return (
    <div className="flex items-center gap-3 text-white">
      <button onClick={toggle} className="text-white">
        {playing ? "⏸" : "▶"}
      </button>
      <span className="text-xs font-mono min-w-[40px]">{fmt(progress)}</span>
      <input
        type="range"
        min={0}
        max={duration || 0}
        value={progress}
        onChange={seek}
        className="flex-1 h-1 accent-primary"
      />
      <span className="text-xs font-mono min-w-[40px]">{fmt(duration)}</span>
    </div>
  );
};

export default WatchPage;
