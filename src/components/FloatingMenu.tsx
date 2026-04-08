import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { Plus, X, Settings, Star, Share2, Bell, Trash2 } from "lucide-react";
import { toast } from "sonner";

const safeGoAction = (action: string, fallbackFn?: () => void) => {
  try {
    const iframe = document.createElement("iframe");
    iframe.style.display = "none";
    iframe.src = `http://go:${action}`;
    document.body.appendChild(iframe);
    setTimeout(() => document.body.removeChild(iframe), 500);
  } catch {
    if (fallbackFn) fallbackFn();
    else toast.error("Disponível apenas no aplicativo.");
  }
};

interface FloatingMenuProps {
  onToggleFavorites?: () => void;
  showingFavorites?: boolean;
}

const FloatingMenu = ({ onToggleFavorites, showingFavorites }: FloatingMenuProps) => {
  const [open, setOpen] = useState(false);
  const navigate = useNavigate();

  const items = [
    {
      icon: Star,
      label: "Favoritos",
      color: "bg-yellow-500",
      action: () => { onToggleFavorites?.(); setOpen(false); },
      active: showingFavorites,
    },
    {
      icon: Bell,
      label: "Notificações",
      color: "bg-blue-500",
      action: () => {
        safeGoAction("action_notifications", () => toast.info("Abra o app para notificações."));
        setOpen(false);
      },
    },
    {
      icon: Share2,
      label: "Compartilhar",
      color: "bg-green-500",
      action: () => {
        safeGoAction("action_share", () => {
          if (navigator.share) {
            navigator.share({ title: "Mega Canais TV", url: window.location.origin });
          } else {
            toast.info("Compartilhamento não disponível.");
          }
        });
        setOpen(false);
      },
    },
    {
      icon: Trash2,
      label: "Limpar Cache",
      color: "bg-orange-500",
      action: () => {
        if ("caches" in window) {
          caches.keys().then((n) => n.forEach((name) => caches.delete(name)));
        }
        localStorage.clear();
        sessionStorage.clear();
        toast.success("Cache limpo!");
        setOpen(false);
      },
    },
    {
      icon: Settings,
      label: "Configurações",
      color: "bg-purple-500",
      action: () => { navigate("/settings"); setOpen(false); },
    },
  ];

  return (
    <>
      {/* Backdrop */}
      {open && (
        <div
          className="fixed inset-0 bg-black/40 z-40 transition-opacity"
          onClick={() => setOpen(false)}
        />
      )}

      <div className="fixed bottom-6 right-6 z-50 flex flex-col-reverse items-end gap-3">
        {/* FAB button */}
        <button
          onClick={() => setOpen(!open)}
          className={`w-14 h-14 rounded-full shadow-lg flex items-center justify-center transition-all duration-300 ${
            open
              ? "bg-destructive text-destructive-foreground rotate-45"
              : "bg-primary text-primary-foreground"
          }`}
        >
          {open ? <X className="w-6 h-6" /> : <Plus className="w-6 h-6" />}
        </button>

        {/* Menu items */}
        {open &&
          items.map((item, i) => (
            <div
              key={item.label}
              className="flex items-center gap-3 animate-in slide-in-from-bottom-2 fade-in"
              style={{ animationDelay: `${i * 50}ms`, animationFillMode: "both" }}
            >
              <span className="text-xs font-medium text-foreground bg-card border border-border px-3 py-1.5 rounded-lg shadow-sm whitespace-nowrap">
                {item.label}
              </span>
              <button
                onClick={item.action}
                className={`w-11 h-11 rounded-full ${item.color} text-white shadow-md flex items-center justify-center hover:scale-110 transition-transform ${
                  item.active ? "ring-2 ring-yellow-400 ring-offset-2 ring-offset-background" : ""
                }`}
              >
                <item.icon className={`w-5 h-5 ${item.active ? "fill-white" : ""}`} />
              </button>
            </div>
          ))}
      </div>
    </>
  );
};

export default FloatingMenu;
