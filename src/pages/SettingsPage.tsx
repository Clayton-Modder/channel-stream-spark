import { useState } from "react";
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

const SettingsPage = () => {
  const navigate = useNavigate();

  const clearCache = () => {
    if ("caches" in window) {
      caches.keys().then((names) => names.forEach((n) => caches.delete(n)));
    }
    localStorage.clear();
    sessionStorage.clear();
    toast.success("Cache limpo com sucesso!");
  };

  const handleNotifications = () => {
    if ("Notification" in window) {
      Notification.requestPermission().then((perm) => {
        if (perm === "granted") toast.success("Notificações ativadas!");
        else toast.info("Notificações bloqueadas pelo navegador");
      });
    } else {
      toast.error("Notificações não suportadas neste dispositivo");
    }
  };

  const handleShare = async () => {
    const shareData = {
      title: "TV Online HD",
      text: "Assista canais ao vivo grátis!",
      url: "https://play.google.com/store/apps/details?id=com.maxcanaisonline.cm&hl=pt",
    };
    if (navigator.share) {
      try { await navigator.share(shareData); } catch {}
    } else {
      await navigator.clipboard.writeText(shareData.url);
      toast.success("Link copiado para a área de transferência!");
    }
  };

  const items = [
    {
      icon: Bell,
      label: "Notificações",
      desc: "Gerenciar suas notificações",
      color: "text-yellow-400",
      action: handleNotifications,
    },
    {
      icon: Share2,
      label: "Compartilhar",
      desc: "Compartilhe o app com seus amigos",
      color: "text-green-400",
      action: handleShare,
    },
    {
      icon: MessageCircle,
      label: "Chat",
      desc: "Converse com outros usuários",
      color: "text-purple-400",
      action: () => navigate("/chat"),
    },
    {
      icon: Trash2,
      label: "Limpar Cache",
      desc: "Remove dados temporários e recarrega",
      color: "text-orange-400",
      action: clearCache,
    },
    {
      icon: RefreshCw,
      label: "Atualizar App",
      desc: "Baixar a versão mais recente do app",
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
      <header className="sticky top-0 z-10 bg-background/80 backdrop-blur-md border-b border-border">
        <div className="container mx-auto px-4 py-4 flex items-center gap-3">
          <button
            onClick={() => navigate(-1)}
            className="p-1.5 rounded-lg hover:bg-secondary transition-colors"
          >
            <ArrowLeft className="w-5 h-5" />
          </button>
          <h1 className="text-lg font-bold">Configurações</h1>
        </div>
      </header>

      <main className="container mx-auto px-4 py-6 max-w-lg space-y-6">

        {/* Settings list */}
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
                <p className="text-xs text-muted-foreground">{item.desc}</p>
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
