import { useState } from "react";
import { useNavigate } from "react-router-dom";
import {
  ArrowLeft,
  Trash2,
  RefreshCw,
  HeadphonesIcon,
  Crown,
  ExternalLink,
  KeyRound,
  Loader2,
  CheckCircle2,
  XCircle,
} from "lucide-react";
import { toast } from "sonner";

interface VipAccount {
  username: string;
  password: string;
  label: string;
  expiry: string;
  active: boolean;
  created_at: string;
  updated_at: string;
  last_login: string | null;
  login_count: number;
  last_ip: string | null;
  codigo: string;
  usuario: string;
}

const VIP_STORAGE_KEY = "tv-vip-account";

function loadSavedAccount(): VipAccount | null {
  try {
    const raw = localStorage.getItem(VIP_STORAGE_KEY);
    return raw ? JSON.parse(raw) : null;
  } catch {
    return null;
  }
}

const SettingsPage = () => {
  const navigate = useNavigate();
  const [codigo, setCodigo] = useState("");
  const [loading, setLoading] = useState(false);
  const [account, setAccount] = useState<VipAccount | null>(loadSavedAccount);

  const activateCode = async () => {
    const trimmed = codigo.trim();
    if (!trimmed) {
      toast.error("Digite um código válido");
      return;
    }

    setLoading(true);
    try {
      let accounts: VipAccount[] = [];
      try {
        const res = await fetch("https://tvonlinehd.com.br/Vip/contas.json");
        if (res.ok) {
          accounts = await res.json();
        }
      } catch {
        // CORS fallback: try via proxy
        const proxyRes = await fetch(
          "https://api.allorigins.win/raw?url=" +
            encodeURIComponent("https://tvonlinehd.com.br/Vip/contas.json")
        );
        if (!proxyRes.ok) throw new Error("Erro ao buscar dados");
        accounts = await proxyRes.json();
      }
      if (!accounts.length) throw new Error("Nenhuma conta encontrada");

      const found = accounts.find(
        (a) => a.codigo?.toLowerCase() === trimmed.toLowerCase()
      );

      if (!found) {
        toast.error("Código não encontrado!");
        setAccount(null);
        localStorage.removeItem(VIP_STORAGE_KEY);
        return;
      }

      if (!found.active) {
        toast.error("Este código está inativo!");
        setAccount(null);
        localStorage.removeItem(VIP_STORAGE_KEY);
        return;
      }

      localStorage.setItem(VIP_STORAGE_KEY, JSON.stringify(found));
      setAccount(found);
      toast.success(`VIP ativado! Bem-vindo, ${found.usuario || found.label}`);
    } catch {
      toast.error("Erro de conexão. Tente novamente.");
    } finally {
      setLoading(false);
    }
  };

  const removeAccount = () => {
    localStorage.removeItem(VIP_STORAGE_KEY);
    setAccount(null);
    setCodigo("");
    toast.success("Conta VIP removida");
  };

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
      desc: "Baixar a versão mais recente do app",
      color: "text-blue-400",
      action: () =>
        window.open(
          "http://tvonlinehd.com.br/Vip/update-tvonlinehd.apk",
          "_blank"
        ),
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
        {/* Activate Code Section */}
        <div className="rounded-xl bg-card border border-border p-5 space-y-4">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-full bg-primary/10 flex items-center justify-center">
              <KeyRound className="w-5 h-5 text-primary" />
            </div>
            <div>
              <h2 className="font-bold text-base">Ativar Código VIP</h2>
              <p className="text-xs text-muted-foreground">
                Insira seu código para liberar o acesso
              </p>
            </div>
          </div>

          <div className="flex gap-2">
            <input
              type="text"
              value={codigo}
              onChange={(e) => setCodigo(e.target.value)}
              onKeyDown={(e) => e.key === "Enter" && activateCode()}
              placeholder="Digite seu código..."
              className="flex-1 h-11 rounded-lg border border-border bg-secondary px-4 text-sm text-foreground placeholder:text-muted-foreground focus:outline-none focus:ring-2 focus:ring-primary/50"
            />
            <button
              onClick={activateCode}
              disabled={loading}
              className="h-11 px-5 rounded-lg bg-primary text-primary-foreground font-bold text-sm hover:bg-primary/90 transition-colors disabled:opacity-50 flex items-center gap-2"
            >
              {loading ? (
                <Loader2 className="w-4 h-4 animate-spin" />
              ) : (
                "Aplicar"
              )}
            </button>
          </div>

          {/* Account Info */}
          {account && (
            <div className="rounded-lg bg-green-500/10 border border-green-500/30 p-4 space-y-2">
              <div className="flex items-center gap-2 text-green-400">
                <CheckCircle2 className="w-4 h-4" />
                <span className="text-sm font-bold">VIP Ativo</span>
              </div>
              <div className="grid grid-cols-2 gap-2 text-xs">
                <div>
                  <span className="text-muted-foreground">Usuário:</span>
                  <p className="font-medium">{account.usuario || account.username}</p>
                </div>
                <div>
                  <span className="text-muted-foreground">Label:</span>
                  <p className="font-medium">{account.label}</p>
                </div>
                <div>
                  <span className="text-muted-foreground">Expira em:</span>
                  <p className="font-medium">{account.expiry || "—"}</p>
                </div>
                <div>
                  <span className="text-muted-foreground">Status:</span>
                  <p className="font-medium">
                    {account.active ? (
                      <span className="text-green-400">Ativo</span>
                    ) : (
                      <span className="text-red-400">Inativo</span>
                    )}
                  </p>
                </div>
              </div>
              <button
                onClick={removeAccount}
                className="mt-2 text-xs text-red-400 hover:text-red-300 flex items-center gap-1 transition-colors"
              >
                <XCircle className="w-3.5 h-3.5" />
                Remover conta
              </button>
            </div>
          )}
        </div>

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
              onClick={() => toast.info("Redirecionando para pagamento...")}
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
