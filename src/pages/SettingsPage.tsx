import { useNavigate } from "react-router-dom";
import {
  ArrowLeft,
  Trash2,
  RefreshCw,
  Bell,
  Share2,
  MessageCircle,
} from "lucide-react";
import { toast } from "sonner";

/**
 * Detecta se está rodando dentro do AppCreator24
 */
const isAppCreator = () => {
  try {
    return (
      typeof (window as any).AppCreator !== "undefined" ||
      navigator.userAgent.includes("AppCreator") ||
      typeof (window as any).webkit?.messageHandlers?.AppCreator !== "undefined"
    );
  } catch {
    return false;
  }
};

/**
 * Executa ações do AppCreator com fallback seguro
 */
const safeGoAction = (goUrl: string, fallbackFn?: () => void) => {
  if (isAppCreator()) {
    window.location.href = goUrl;
  } else {
    if (fallbackFn) {
      fallbackFn();
    } else {
      toast.error("Esta função só funciona dentro do aplicativo.");
    }
  }
};

const SettingsPage = () => {
  const navigate = useNavigate();

  /**
   * Limpar cache
   */
  const clearCache = () => {
    if ("caches" in window) {
      caches.keys().then((names) => {
        names.forEach((name) => caches.delete(name));
      });
    }

    localStorage.clear();
    sessionStorage.clear();

    toast.success("Cache limpo com sucesso!");
  };

  const items = [
    {
      icon: Bell,
      label: "Notificações",
      desc: "Gerenciar suas notificações",
      color: "text-yellow-400",
      action: () =>
        safeGoAction("go:action_notifications", () => {
          toast.info("Abra o app para acessar notificações.");
        }),
    },
    {
      icon: Share2,
      label: "Compartilhar",
      desc: "Compartilhe o app com seus amigos",
      color: "text-green-400",
      action: () =>
        safeGoAction("go:action_share", () => {
          if (navigator.share) {
            navigator.share({
              title: "TV Online HD",
              url: window.location.origin,
            });
          } else {
            toast.info("Compartilhamento não disponível neste navegador.");
          }
        }),
    },
    {
      icon: MessageCircle,
      label: "Chat",
      desc: "Converse com outros usuários",
      color: "text-purple-400",
      action: () =>
        safeGoAction("go:action_chat", () => {
          toast.info("Chat disponível apenas no aplicativo.");
        }),
    },
    {
      icon: Trash2,
      label: "Limpar Cache",
      desc: "Remove dados temporários",
      color: "text-orange-400",
      action: clearCache,
    },
    {
      icon: RefreshCw,
      label: "Atualizar App",
      desc: "Baixar versão mais recente",
      color: "text-blue-400",
      action: () =>
        window.open(
          "https://play.google.com/store/apps/details?id=com.maxcanaisonline.cm&hl=pt",
          "_blank"
        ),
    },
  ];

  return (
    <div className="min-h-screen bg-background text-foreground">
      {/* HEADER */}
      <header className="sticky top-0 z-10 bg-background/80 backdrop-blur-md border-b border-border">
        <div className="container mx-auto px-4 py-4 flex items-center gap-3">
          <button
            onClick={() => navigate(-1)}
            className="p-1.5 rounded-lg hover:bg-secondary transition"
          >
            <ArrowLeft className="w-5 h-5" />
          </button>
          <h1 className="text-lg font-bold">Configurações</h1>
        </div>
      </header>

      {/* CONTEÚDO */}
      <main className="container mx-auto px-4 py-6 max-w-lg space-y-6">
        <div className="space-y-2">
          {items.map((item) => (
            <button
              key={item.label}
              onClick={item.action}
              className="w-full flex items-center gap-4 p-4 rounded-xl bg-card border border-border hover:border-primary/30 transition-all text-left"
            >
              <div
                className={`w-10 h-10 rounded-lg bg-secondary flex items-center justify-center ${item.color}`}
              >
                <item.icon className="w-5 h-5" />
              </div>

              <div className="flex-1">
                <p className="text-sm font-semibold">{item.label}</p>
                <p className="text-xs text-muted-foreground">
                  {item.desc}
                </p>
              </div>
            </button>
          ))}
        </div>

        <p className="text-center text-xs text-muted-foreground pt-4">
          TV Online HD v1.0 • Todos os direitos reservados
        </p>
      </main>
    </div>
  );
};

export default SettingsPage;
