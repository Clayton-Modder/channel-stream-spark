import { useState, useEffect } from "react";

const PRESENCE_INTERVAL_MS = 40 * 60 * 1000;
const STORAGE_KEY = "presence_validated_at";

export function usePresenceCheck() {
  const [blocked, setBlocked] = useState(() => {
    const saved = localStorage.getItem(STORAGE_KEY);
    if (!saved) return true;
    return Date.now() - Number(saved) >= PRESENCE_INTERVAL_MS;
  });

  useEffect(() => {
    if (blocked) return;
    const remaining = PRESENCE_INTERVAL_MS - (Date.now() - Number(localStorage.getItem(STORAGE_KEY) || 0));
    const timer = setTimeout(() => setBlocked(true), Math.max(remaining, 0));
    return () => clearTimeout(timer);
  }, [blocked]);

  const validate = () => {
    window.open("https://omg10.com/4/10981674", "_blank");
    localStorage.setItem(STORAGE_KEY, String(Date.now()));
    setBlocked(false);
  };

  return { blocked, validate };
}

interface PresenceModalProps {
  onValidate: () => void;
}

const PresenceModal = ({ onValidate }: PresenceModalProps) => {
  const [countdown, setCountdown] = useState(5);
  const [verifying, setVerifying] = useState(false);

  useEffect(() => {
    const interval = setInterval(() => {
      setCountdown((prev) => {
        if (prev <= 1) {
          clearInterval(interval);
          return 0;
        }
        return prev - 1;
      });
    }, 1000);
    return () => clearInterval(interval);
  }, []);

  const handleClick = () => {
    setVerifying(true);
    onValidate();
    // Simulate verification delay
    setTimeout(() => setVerifying(false), 3000);
  };

  return (
    <div className="absolute inset-0 z-50 flex items-center justify-center bg-black/90 backdrop-blur-sm animate-in fade-in duration-300">
      <div className="mx-4 w-full max-w-sm rounded-2xl border border-border bg-card p-6 text-center shadow-2xl animate-in zoom-in-95 duration-300">
        <div className="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-primary/20">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            className="h-8 w-8 text-primary animate-pulse"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
            strokeWidth={2}
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              d="M12 9v2m0 4h.01M12 3a9 9 0 100 18 9 9 0 000-18z"
            />
          </svg>
        </div>

        <h2 className="mb-2 text-lg font-bold text-foreground">
          Verificação de Presença
        </h2>
        <p className="mb-6 text-sm text-muted-foreground leading-relaxed">
          Para continuar assistindo, clique abaixo para validar sua presença.
        </p>

        {verifying ? (
          <div className="flex flex-col items-center gap-3 py-3">
            <div className="h-8 w-8 rounded-full border-3 border-primary border-t-transparent animate-spin" />
            <span className="text-sm text-muted-foreground animate-pulse">Verificando...</span>
          </div>
        ) : (
          <button
            onClick={handleClick}
            disabled={countdown > 0}
            className="w-full rounded-xl bg-primary py-3 text-sm font-bold uppercase tracking-wider text-primary-foreground transition-all hover:bg-primary/90 hover:scale-[1.02] active:scale-95 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {countdown > 0 ? `Aguarde ${countdown}s...` : "LIBERAR ACESSO"}
          </button>
        )}

        <p className="mt-4 text-xs text-muted-foreground/60">
          Sessões são verificadas a cada 40 minutos
        </p>
      </div>
    </div>
  );
};

export default PresenceModal;
