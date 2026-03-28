import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { Tv, Plus, Pencil, Trash2, Archive, ArchiveRestore, LogOut, Search, Save, Tag } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { isAdminLoggedIn, adminLogout, loadChannelData, saveChannelData, type Channel, type Category, type ChannelData } from "@/lib/channelStorage";
import { toast } from "sonner";

const AdminPanel = () => {
  const navigate = useNavigate();
  const [data, setData] = useState<ChannelData | null>(null);
  const [search, setSearch] = useState("");
  const [showArchived, setShowArchived] = useState(false);
  const [editChannel, setEditChannel] = useState<Channel | null>(null);
  const [isNew, setIsNew] = useState(false);
  const [dialogOpen, setDialogOpen] = useState(false);

  // Category state
  const [catDialogOpen, setCatDialogOpen] = useState(false);
  const [editCategory, setEditCategory] = useState<Category | null>(null);
  const [isCatNew, setIsCatNew] = useState(false);

  useEffect(() => {
    if (!isAdminLoggedIn()) {
      navigate("/admin/login");
      return;
    }
    loadChannelData().then(setData);
  }, [navigate]);

  if (!data) return <div className="min-h-screen bg-background flex items-center justify-center text-foreground">Carregando...</div>;

  const channels = data.channels.filter((ch) => {
    const matchArchive = showArchived ? ch.archived : !ch.archived;
    const matchSearch = ch.name.toLowerCase().includes(search.toLowerCase()) || ch.id.toLowerCase().includes(search.toLowerCase());
    return matchArchive && matchSearch;
  });

  const persist = (updated: ChannelData) => {
    setData(updated);
    saveChannelData(updated);
  };

  // === Channel handlers ===
  const handleDelete = (id: string) => {
    if (!confirm("Excluir este canal permanentemente?")) return;
    persist({ ...data, channels: data.channels.filter((c) => c.id !== id) });
    toast.success("Canal excluído");
  };

  const handleArchive = (id: string) => {
    persist({
      ...data,
      channels: data.channels.map((c) => c.id === id ? { ...c, archived: !c.archived } : c),
    });
    toast.success("Canal atualizado");
  };

  const openNew = () => {
    setEditChannel({ id: "", name: "", image: "", url: "", categories: [0] });
    setIsNew(true);
    setDialogOpen(true);
  };

  const openEdit = (ch: Channel) => {
    setEditChannel({ ...ch });
    setIsNew(false);
    setDialogOpen(true);
  };

  const handleSave = () => {
    if (!editChannel || !editChannel.id.trim() || !editChannel.name.trim()) {
      toast.error("ID e Nome são obrigatórios");
      return;
    }
    if (isNew && data.channels.some((c) => c.id === editChannel.id)) {
      toast.error("ID já existe");
      return;
    }
    const updated = isNew
      ? { ...data, channels: [...data.channels, editChannel] }
      : { ...data, channels: data.channels.map((c) => c.id === editChannel.id ? editChannel : c) };
    persist(updated);
    setDialogOpen(false);
    toast.success(isNew ? "Canal adicionado" : "Canal atualizado");
  };

  // === Category handlers ===
  const openNewCategory = () => {
    const maxId = data.categories.reduce((max, c) => Math.max(max, c.id), 0);
    setEditCategory({ id: maxId + 1, name: "" });
    setIsCatNew(true);
    setCatDialogOpen(true);
  };

  const openEditCategory = (cat: Category) => {
    setEditCategory({ ...cat });
    setIsCatNew(false);
    setCatDialogOpen(true);
  };

  const handleSaveCategory = () => {
    if (!editCategory || !editCategory.name.trim()) {
      toast.error("Nome da categoria é obrigatório");
      return;
    }
    if (isCatNew && data.categories.some((c) => c.id === editCategory.id)) {
      toast.error("ID já existe");
      return;
    }
    const updated = isCatNew
      ? { ...data, categories: [...data.categories, editCategory] }
      : { ...data, categories: data.categories.map((c) => c.id === editCategory.id ? editCategory : c) };
    persist(updated);
    setCatDialogOpen(false);
    toast.success(isCatNew ? "Categoria adicionada" : "Categoria atualizada");
  };

  const handleDeleteCategory = (id: number) => {
    if (id === 0) {
      toast.error("A categoria 'Todos' não pode ser excluída");
      return;
    }
    const usedBy = data.channels.filter((ch) => ch.categories.includes(id)).length;
    if (usedBy > 0 && !confirm(`Esta categoria é usada por ${usedBy} canal(is). Excluir mesmo assim?`)) return;
    
    // Remove category and clean from channels
    persist({
      ...data,
      categories: data.categories.filter((c) => c.id !== id),
      channels: data.channels.map((ch) => ({
        ...ch,
        categories: ch.categories.filter((cid) => cid !== id),
      })),
    });
    toast.success("Categoria excluída");
  };

  const handleLogout = () => {
    adminLogout();
    navigate("/admin/login");
  };

  const getCategoryName = (id: number) => data.categories.find((c) => c.id === id)?.name ?? `#${id}`;

  return (
    <div className="min-h-screen bg-background text-foreground">
      <header className="sticky top-0 z-10 bg-background/80 backdrop-blur-md border-b border-border">
        <div className="container mx-auto px-4 py-3 flex items-center justify-between gap-3">
          <div className="flex items-center gap-2">
            <Tv className="w-5 h-5 text-primary" />
            <h1 className="text-lg font-bold">Admin</h1>
          </div>
          <div className="flex items-center gap-2">
            <Button size="sm" variant="ghost" onClick={handleLogout}><LogOut className="w-4 h-4" /></Button>
          </div>
        </div>
      </header>

      <main className="container mx-auto px-4 py-4">
        <Tabs defaultValue="channels" className="space-y-4">
          <TabsList className="grid w-full max-w-xs grid-cols-2">
            <TabsTrigger value="channels">Canais</TabsTrigger>
            <TabsTrigger value="categories">Categorias</TabsTrigger>
          </TabsList>

          {/* === CHANNELS TAB === */}
          <TabsContent value="channels" className="space-y-4">
            <div className="flex items-center gap-3 flex-wrap">
              <div className="relative flex-1 min-w-[200px]">
                <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
                <Input placeholder="Buscar canal..." value={search} onChange={(e) => setSearch(e.target.value)} className="pl-9 bg-secondary" />
              </div>
              <Button size="sm" variant={showArchived ? "default" : "outline"} onClick={() => setShowArchived(!showArchived)}>
                <Archive className="w-4 h-4 mr-1" />{showArchived ? "Arquivados" : "Ativos"}
              </Button>
              <Button size="sm" onClick={openNew}><Plus className="w-4 h-4 mr-1" />Novo Canal</Button>
              <span className="text-sm text-muted-foreground">{channels.length} canais</span>
            </div>

            <div className="border border-border rounded-lg overflow-hidden">
              <div className="overflow-x-auto">
                <table className="w-full text-sm">
                  <thead>
                    <tr className="border-b border-border bg-muted/50">
                      <th className="text-left p-3 font-medium text-muted-foreground">Logo</th>
                      <th className="text-left p-3 font-medium text-muted-foreground">ID</th>
                      <th className="text-left p-3 font-medium text-muted-foreground">Nome</th>
                      <th className="text-left p-3 font-medium text-muted-foreground hidden md:table-cell">Categorias</th>
                      <th className="text-right p-3 font-medium text-muted-foreground">Ações</th>
                    </tr>
                  </thead>
                  <tbody>
                    {channels.map((ch) => (
                      <tr key={ch.id} className="border-b border-border last:border-0 hover:bg-muted/30 transition-colors">
                        <td className="p-3"><img src={ch.image} alt="" className="w-8 h-8 object-contain" onError={(e) => { (e.target as HTMLImageElement).style.display = "none"; }} /></td>
                        <td className="p-3 font-mono text-xs text-muted-foreground">{ch.id}</td>
                        <td className="p-3 font-medium">{ch.name}</td>
                        <td className="p-3 hidden md:table-cell">
                          <div className="flex gap-1 flex-wrap">
                            {ch.categories.filter(c => c !== 0).slice(0, 3).map((c) => (
                              <span key={c} className="text-xs bg-primary/10 text-primary rounded px-1.5 py-0.5">{getCategoryName(c)}</span>
                            ))}
                          </div>
                        </td>
                        <td className="p-3">
                          <div className="flex justify-end gap-1">
                            <Button size="icon" variant="ghost" className="h-8 w-8" onClick={() => openEdit(ch)} title="Editar">
                              <Pencil className="w-3.5 h-3.5" />
                            </Button>
                            <Button size="icon" variant="ghost" className="h-8 w-8" onClick={() => handleArchive(ch.id)} title={ch.archived ? "Desarquivar" : "Arquivar"}>
                              {ch.archived ? <ArchiveRestore className="w-3.5 h-3.5" /> : <Archive className="w-3.5 h-3.5" />}
                            </Button>
                            <Button size="icon" variant="ghost" className="h-8 w-8 text-destructive hover:text-destructive" onClick={() => handleDelete(ch.id)} title="Excluir">
                              <Trash2 className="w-3.5 h-3.5" />
                            </Button>
                          </div>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          </TabsContent>

          {/* === CATEGORIES TAB === */}
          <TabsContent value="categories" className="space-y-4">
            <div className="flex items-center gap-3 flex-wrap">
              <h2 className="text-base font-semibold flex items-center gap-2"><Tag className="w-4 h-4 text-primary" />Gerenciar Categorias</h2>
              <div className="ml-auto">
                <Button size="sm" onClick={openNewCategory}><Plus className="w-4 h-4 mr-1" />Nova Categoria</Button>
              </div>
            </div>

            <div className="border border-border rounded-lg overflow-hidden">
              <table className="w-full text-sm">
                <thead>
                  <tr className="border-b border-border bg-muted/50">
                    <th className="text-left p-3 font-medium text-muted-foreground w-20">ID</th>
                    <th className="text-left p-3 font-medium text-muted-foreground">Nome</th>
                    <th className="text-left p-3 font-medium text-muted-foreground hidden sm:table-cell">Canais</th>
                    <th className="text-right p-3 font-medium text-muted-foreground">Ações</th>
                  </tr>
                </thead>
                <tbody>
                  {data.categories.map((cat) => {
                    const count = data.channels.filter((ch) => ch.categories.includes(cat.id)).length;
                    return (
                      <tr key={cat.id} className="border-b border-border last:border-0 hover:bg-muted/30 transition-colors">
                        <td className="p-3 font-mono text-xs text-muted-foreground">{cat.id}</td>
                        <td className="p-3 font-medium">{cat.name}</td>
                        <td className="p-3 hidden sm:table-cell">
                          <span className="text-xs bg-secondary text-muted-foreground rounded px-2 py-0.5">{count} canais</span>
                        </td>
                        <td className="p-3">
                          <div className="flex justify-end gap-1">
                            <Button size="icon" variant="ghost" className="h-8 w-8" onClick={() => openEditCategory(cat)} title="Editar">
                              <Pencil className="w-3.5 h-3.5" />
                            </Button>
                            {cat.id !== 0 && (
                              <Button size="icon" variant="ghost" className="h-8 w-8 text-destructive hover:text-destructive" onClick={() => handleDeleteCategory(cat.id)} title="Excluir">
                                <Trash2 className="w-3.5 h-3.5" />
                              </Button>
                            )}
                          </div>
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>
          </TabsContent>
        </Tabs>
      </main>

      {/* Channel Dialog */}
      <Dialog open={dialogOpen} onOpenChange={setDialogOpen}>
        <DialogContent className="max-w-md">
          <DialogHeader>
            <DialogTitle>{isNew ? "Novo Canal" : "Editar Canal"}</DialogTitle>
          </DialogHeader>
          {editChannel && (
            <div className="space-y-3">
              <div>
                <label className="text-sm font-medium text-foreground">ID</label>
                <Input value={editChannel.id} onChange={(e) => setEditChannel({ ...editChannel, id: e.target.value })} disabled={!isNew} className="bg-secondary mt-1" placeholder="ex: globosp" />
              </div>
              <div>
                <label className="text-sm font-medium text-foreground">Nome</label>
                <Input value={editChannel.name} onChange={(e) => setEditChannel({ ...editChannel, name: e.target.value })} className="bg-secondary mt-1" placeholder="Globo SP" />
              </div>
              <div>
                <label className="text-sm font-medium text-foreground">URL da Imagem</label>
                <Input value={editChannel.image} onChange={(e) => setEditChannel({ ...editChannel, image: e.target.value })} className="bg-secondary mt-1" placeholder="https://..." />
              </div>
              <div>
                <label className="text-sm font-medium text-foreground">URL do Stream</label>
                <Input value={editChannel.url} onChange={(e) => setEditChannel({ ...editChannel, url: e.target.value })} className="bg-secondary mt-1" placeholder="https://..." />
              </div>
              <div>
                <label className="text-sm font-medium text-foreground">Categorias (IDs separados por vírgula)</label>
                <Input
                  value={editChannel.categories.join(",")}
                  onChange={(e) => setEditChannel({ ...editChannel, categories: e.target.value.split(",").map(Number).filter((n) => !isNaN(n)) })}
                  className="bg-secondary mt-1"
                  placeholder="0,1,6"
                />
                <p className="text-xs text-muted-foreground mt-1">
                  {data.categories.map((c) => `${c.id}=${c.name}`).join(" | ")}
                </p>
              </div>
            </div>
          )}
          <DialogFooter>
            <Button variant="outline" onClick={() => setDialogOpen(false)}>Cancelar</Button>
            <Button onClick={handleSave}><Save className="w-4 h-4 mr-1" />Salvar</Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Category Dialog */}
      <Dialog open={catDialogOpen} onOpenChange={setCatDialogOpen}>
        <DialogContent className="max-w-sm">
          <DialogHeader>
            <DialogTitle>{isCatNew ? "Nova Categoria" : "Editar Categoria"}</DialogTitle>
          </DialogHeader>
          {editCategory && (
            <div className="space-y-3">
              <div>
                <label className="text-sm font-medium text-foreground">ID</label>
                <Input value={editCategory.id} disabled className="bg-secondary mt-1" />
              </div>
              <div>
                <label className="text-sm font-medium text-foreground">Nome</label>
                <Input value={editCategory.name} onChange={(e) => setEditCategory({ ...editCategory, name: e.target.value })} className="bg-secondary mt-1" placeholder="Nome da categoria" autoFocus />
              </div>
            </div>
          )}
          <DialogFooter>
            <Button variant="outline" onClick={() => setCatDialogOpen(false)}>Cancelar</Button>
            <Button onClick={handleSaveCategory}><Save className="w-4 h-4 mr-1" />Salvar</Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
};

export default AdminPanel;
