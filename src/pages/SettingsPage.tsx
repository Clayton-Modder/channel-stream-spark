import { useNavigate } from "react-router-dom";
import {
  ArrowLeft,
  Trash2,
  RefreshCw,
  HeadphonesIcon,
  Crown,
  ExternalLink,
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

  const items = [
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
      desc: "Recarregar para buscar atualizações",
      color: "text-blue-400",
      action: () => window.location.reload(),
    },
    {
      icon: HeadphonesIcon,
      label: "Suporte",
      desc: "Entrar em contato com a equipe",
      color: "text-green-400",
      action: () =>
        window.open(
          "https://wa.me/5500000000000?text=Olá, preciso de suporte!",
          "_blank"
        ),
    },
  ];

  return (
    <div className="min-h-screen bg-background text-foreground">
      {/* Header */}
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
        {/* VIP Card */}
        <div className="rounded-xl bg-gradient-to-br from-yellow-500/20 via-amber-500/10 to-orange-500/20 border border-yellow-500/30 p-5">
          <div className="flex items-center gap-3 mb-3">
            <div className="w-10 h-10 rounded-full bg-yellow-500/20 flex items-center justify-center">
              <Crown className="w-5 h-5 text-yellow-400" />
            </div>
            <div>
              <h2 className="font-bold text-base">Atualizar Meu VIP</h2>
              <p className="text-xs text-muted-foreground">
                Acesso completo a todos os canais
              </p>
            </div>
          </div>
          <div className="flex items-end justify-between">
            <div>
              <span className="text-3xl font-extrabold text-yellow-400">
                R$ 3,00
              </span>
              <span className="text-xs text-muted-foreground ml-1">/mês</span>
            </div>
            <button
              onClick={() =>
                toast.info("Redirecionando para pagamento...")
              }
              className="px-5 py-2 rounded-lg bg-yellow-500 text-black font-bold text-sm hover:bg-yellow-400 transition-colors flex items-center gap-1.5"
            >
              Assinar
              <ExternalLink className="w-3.5 h-3.5" />
            </button>
          </div>
        </div>

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

        {/* Footer */}
        <p className="text-center text-xs text-muted-foreground pt-4">
          TV Online HD v1.0 • Todos os direitos reservados
        </p>
      </main>
    </div>
  );
};

export default SettingsPage;
