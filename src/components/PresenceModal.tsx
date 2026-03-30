import { useState, useEffect } from "react";

const PRESENCE_INTERVAL_MS = 40 * 60 * 1000; // 40 minutes
const STORAGE_KEY = "presence_last_validated";

export function usePresenceCheck() {
  const [blocked, setBlocked] = useState(true); // blocked on first load

  useEffect(() => {
    if (blocked) return; // don't start timer while blocked
    const timer = setTimeout(() => setBlocked(true), PRESENCE_INTERVAL_MS);
    return () => clearTimeout(timer);
  }, [blocked]);

  const validate = () => {
    window.open("https://dfmnfkdkf.com", "_blank");
    localStorage.setItem(STORAGE_KEY, String(Date.now()));
    setBlocked(false);
  };

  return { blocked, validate };
}

interface PresenceModalProps {
  onValidate: () => void;
}

const PresenceModal = ({ onValidate }: PresenceModalProps) => {
  const [countdown, setCountdown] = useState(0);

  useEffect(() => {
    setCountdown(5);
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

  return (
    <div className="absolute inset-0 z-50 flex items-center justify-center bg-black/90 backdrop-blur-sm animate-in fade-in duration-300">
      <div className="mx-4 w-full max-w-sm rounded-2xl border border-border bg-card p-6 text-center shadow-2xl animate-in zoom-in-95 duration-300">
        <div className="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-primary/20">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            className="h-8 w-8 text-primary"
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

        <button
          onClick={onValidate}
          disabled={countdown > 0}
          className="w-full rounded-xl bg-primary py-3 text-sm font-bold uppercase tracking-wider text-primary-foreground transition-all hover:bg-primary/90 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {countdown > 0 ? `Aguarde ${countdown}s...` : "LIBERAR ACESSO"}
        </button>

        <p className="mt-4 text-xs text-muted-foreground/60">
          Sessões são verificadas a cada 40 minutos
        </p>
      </div>
    </div>
  );
};

export default PresenceModal;
