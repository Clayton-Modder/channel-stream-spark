import { defineConfig } from "vite";
import react from "@vitejs/plugin-react-swc";
import legacy from "@vitejs/plugin-legacy";
import path from "path";
import { componentTagger } from "lovable-tagger";

export default defineConfig(({ mode }) => ({
  plugins: [
    react(),

    // suporte básico a navegadores mais antigos (sem exagero)
    legacy({
      targets: ["defaults", "not IE 11"],
    }),

    // só roda em desenvolvimento (evita erro no Vercel)
    ...(mode === "development" ? [componentTagger()] : []),
  ],

  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
    },
    dedupe: ["react", "react-dom"],
  },

  build: {
    target: "esnext", // mais compatível com Vercel
    outDir: "dist",
  },
}));
