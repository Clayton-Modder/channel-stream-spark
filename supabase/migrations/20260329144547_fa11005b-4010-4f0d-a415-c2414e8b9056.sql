-- Create categories table
CREATE TABLE public.categories (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create channels table
CREATE TABLE public.channels (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  image TEXT NOT NULL DEFAULT '',
  url TEXT NOT NULL DEFAULT '',
  archived BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create channel_categories junction table
CREATE TABLE public.channel_categories (
  channel_id TEXT NOT NULL REFERENCES public.channels(id) ON DELETE CASCADE,
  category_id INTEGER NOT NULL REFERENCES public.categories(id) ON DELETE CASCADE,
  PRIMARY KEY (channel_id, category_id)
);

-- Enable RLS
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.channels ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.channel_categories ENABLE ROW LEVEL SECURITY;

-- Public read access
CREATE POLICY "Anyone can read categories" ON public.categories FOR SELECT USING (true);
CREATE POLICY "Anyone can read channels" ON public.channels FOR SELECT USING (true);
CREATE POLICY "Anyone can read channel_categories" ON public.channel_categories FOR SELECT USING (true);

-- Write access (admin is password-based, not auth-based)
CREATE POLICY "Anyone can insert categories" ON public.categories FOR INSERT WITH CHECK (true);
CREATE POLICY "Anyone can update categories" ON public.categories FOR UPDATE USING (true);
CREATE POLICY "Anyone can delete categories" ON public.categories FOR DELETE USING (true);

CREATE POLICY "Anyone can insert channels" ON public.channels FOR INSERT WITH CHECK (true);
CREATE POLICY "Anyone can update channels" ON public.channels FOR UPDATE USING (true);
CREATE POLICY "Anyone can delete channels" ON public.channels FOR DELETE USING (true);

CREATE POLICY "Anyone can insert channel_categories" ON public.channel_categories FOR INSERT WITH CHECK (true);
CREATE POLICY "Anyone can update channel_categories" ON public.channel_categories FOR UPDATE USING (true);
CREATE POLICY "Anyone can delete channel_categories" ON public.channel_categories FOR DELETE USING (true);

-- Trigger for updated_at
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SET search_path = public;

CREATE TRIGGER update_channels_updated_at
  BEFORE UPDATE ON public.channels
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();