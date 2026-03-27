import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { Lock, Tv } from "lucide-react";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { adminLogin } from "@/lib/channelStorage";

const AdminLogin = () => {
  const navigate = useNavigate();
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (adminLogin(password)) {
      navigate("/admin");
    } else {
      setError("Senha incorreta");
      setPassword("");
    }
  };

  return (
    <div className="min-h-screen bg-background flex items-center justify-center p-4">
      <div className="w-full max-w-sm space-y-6">
        <div className="text-center space-y-2">
          <div className="flex items-center justify-center gap-2">
            <Tv className="w-8 h-8 text-primary" />
            <h1 className="text-2xl font-bold text-foreground">TV ONLINE</h1>
          </div>
          <p className="text-muted-foreground text-sm">Painel Administrativo</p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4 bg-card border border-border rounded-lg p-6">
          <div className="space-y-2">
            <label className="text-sm font-medium text-foreground flex items-center gap-2">
              <Lock className="w-4 h-4" /> Senha
            </label>
            <Input
              type="password"
              value={password}
              onChange={(e) => { setPassword(e.target.value); setError(""); }}
              placeholder="Digite a senha..."
              className="bg-secondary"
              autoFocus
            />
            {error && <p className="text-sm text-destructive">{error}</p>}
          </div>
          <Button type="submit" className="w-full">Entrar</Button>
        </form>

        <button onClick={() => navigate("/")} className="block mx-auto text-sm text-muted-foreground hover:text-foreground transition-colors">
          ← Voltar ao site
        </button>
      </div>
    </div>
  );
};

export default AdminLogin;
