-- ============================================================================
-- COMPLETE DATABASE SETUP - COPY AND PASTE INTO SUPABASE SQL EDITOR
-- ============================================================================
--
-- This script creates ALL tables for your e-commerce platform and fixes
-- the infinite recursion error in RLS policies.
--
-- HOW TO APPLY:
-- 1. Go to https://app.supabase.com
-- 2. Select your project: gfyuyriucgzxjizatwsw
-- 3. Click "SQL Editor" in the left sidebar
-- 4. Click "New query"
-- 5. Copy and paste this ENTIRE file
-- 6. Click "Run" (or press Cmd/Ctrl + Enter)
-- 7. Wait for completion (should take 10-20 seconds)
-- 8. Refresh your app - all errors should be gone!
--
-- ============================================================================

-- STEP 1: Create Helper Function (Prevents Infinite Recursion)
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.user_profiles
    WHERE id = auth.uid() AND role = 'admin'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- STEP 2: Create Core Tables
CREATE TABLE IF NOT EXISTS public.user_profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  first_name text DEFAULT '',
  last_name text DEFAULT '',
  role text DEFAULT 'customer' CHECK (role IN ('customer', 'admin', 'seller')),
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.addresses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  type text NOT NULL CHECK (type IN ('billing', 'shipping')),
  first_name text NOT NULL,
  last_name text NOT NULL,
  company text,
  address1 text NOT NULL,
  address2 text,
  city text NOT NULL,
  state text NOT NULL,
  postcode text NOT NULL,
  country text NOT NULL DEFAULT 'Australia',
  phone text,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.departments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  slug text UNIQUE NOT NULL,
  name text NOT NULL,
  description text DEFAULT '',
  image text DEFAULT '',
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  slug text UNIQUE NOT NULL,
  name text NOT NULL,
  description text DEFAULT '',
  image text DEFAULT '',
  product_count integer DEFAULT 0,
  department_id uuid REFERENCES public.departments(id) ON DELETE CASCADE,
  seller_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.products (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  slug text UNIQUE NOT NULL,
  name text NOT NULL,
  description text DEFAULT '',
  price numeric(10,2) NOT NULL,
  original_price numeric(10,2),
  images text[] DEFAULT '{}',
  category_id uuid REFERENCES public.categories(id) ON DELETE SET NULL,
  department_id uuid REFERENCES public.departments(id) ON DELETE SET NULL,
  brand text DEFAULT '',
  rating numeric(3,2) DEFAULT 0 CHECK (rating >= 0 AND rating <= 5),
  review_count integer DEFAULT 0,
  stock integer DEFAULT 0,
  specifications jsonb DEFAULT '{}',
  seller_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  discount_type text,
  discount_value numeric,
  is_taxable boolean DEFAULT true,
  is_shipping_exempt boolean DEFAULT false,
  weight_kg numeric DEFAULT 0,
  dimensions_cm jsonb DEFAULT '{"width": 0, "height": 0, "length": 0}'::jsonb,
  shipping_class text DEFAULT 'standard',
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.product_variants (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id uuid REFERENCES public.products(id) ON DELETE CASCADE,
  name text NOT NULL,
  price numeric(10,2) NOT NULL,
  stock integer DEFAULT 0,
  attributes jsonb DEFAULT '{}',
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.cart_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  product_id uuid REFERENCES public.products(id) ON DELETE CASCADE,
  variant_id uuid REFERENCES public.product_variants(id) ON DELETE CASCADE,
  quantity integer NOT NULL DEFAULT 1 CHECK (quantity > 0),
  created_at timestamptz DEFAULT now(),
  UNIQUE(user_id, product_id, variant_id)
);

CREATE TABLE IF NOT EXISTS public.wishlist (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  product_id uuid REFERENCES public.products(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  UNIQUE(user_id, product_id)
);

CREATE TABLE IF NOT EXISTS public.shipping_carriers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  code text UNIQUE NOT NULL,
  api_endpoint text,
  tracking_url_template text,
  is_active boolean DEFAULT true,
  supported_countries text[] DEFAULT ARRAY['Australia'],
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.orders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  order_number text UNIQUE NOT NULL,
  status text DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled')),
  total numeric(10,2) NOT NULL,
  shipping_address_id uuid REFERENCES public.addresses(id),
  billing_address_id uuid REFERENCES public.addresses(id),
  delivery_method text DEFAULT 'shipping' CHECK (delivery_method IN ('shipping', 'click-collect')),
  fulfillment_method text DEFAULT 'platform' CHECK (fulfillment_method IN ('platform', 'seller')),
  carrier_id uuid REFERENCES public.shipping_carriers(id),
  tracking_number text,
  estimated_delivery_date timestamptz,
  actual_delivery_date timestamptz,
  delivery_instructions text,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.order_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id uuid REFERENCES public.orders(id) ON DELETE CASCADE,
  product_id uuid REFERENCES public.products(id) ON DELETE CASCADE,
  variant_id uuid REFERENCES public.product_variants(id) ON DELETE CASCADE,
  quantity integer NOT NULL DEFAULT 1 CHECK (quantity > 0),
  price numeric(10,2) NOT NULL,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.services (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  slug text UNIQUE NOT NULL,
  name text NOT NULL,
  description text DEFAULT '',
  image text DEFAULT '',
  price numeric(10,2) NOT NULL,
  duration text DEFAULT '',
  category text DEFAULT '',
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.diy_articles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  slug text UNIQUE NOT NULL,
  title text NOT NULL,
  excerpt text DEFAULT '',
  content text DEFAULT '',
  featured_image text DEFAULT '',
  author text DEFAULT '',
  published_at timestamptz DEFAULT now(),
  category text DEFAULT '',
  tags text[] DEFAULT '{}',
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.global_settings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  default_tax_rate numeric(5,2) DEFAULT 0.00,
  tax_type text DEFAULT 'GST' CHECK (tax_type IN ('GST', 'VAT', 'Sales_Tax')),
  allow_seller_tax_override boolean DEFAULT false,
  free_shipping_threshold numeric(10,2) DEFAULT 0.00,
  default_shipping_carriers jsonb DEFAULT '[]'::jsonb,
  platform_fulfillment_enabled boolean DEFAULT true,
  standard_delivery_days text DEFAULT '2-5',
  express_delivery_days text DEFAULT '1-2',
  delivery_tracking_enabled boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.seller_settings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  seller_id uuid UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  tax_registration_number text,
  tax_rate_override numeric(5,2),
  prices_include_tax boolean DEFAULT false,
  fulfillment_method text DEFAULT 'platform' CHECK (fulfillment_method IN ('platform', 'self')),
  shipping_rules jsonb DEFAULT '{}'::jsonb,
  free_shipping_threshold numeric(10,2),
  self_delivery_enabled boolean DEFAULT false,
  pickup_address_id uuid REFERENCES public.addresses(id),
  delivery_sla_days integer DEFAULT 5,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.shipping_rules (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  seller_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  rule_name text NOT NULL,
  rule_type text NOT NULL CHECK (rule_type IN ('free', 'flat_rate', 'weight_based', 'price_based')),
  conditions jsonb DEFAULT '{}'::jsonb,
  shipping_cost numeric(10,2) DEFAULT 0.00,
  carrier_id uuid REFERENCES public.shipping_carriers(id),
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.order_tracking (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id uuid REFERENCES public.orders(id) ON DELETE CASCADE,
  status text NOT NULL,
  location text,
  notes text,
  updated_by uuid REFERENCES auth.users(id),
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.order_taxes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id uuid REFERENCES public.orders(id) ON DELETE CASCADE,
  tax_type text NOT NULL,
  tax_rate numeric(5,2) NOT NULL,
  tax_amount numeric(10,2) NOT NULL,
  applied_by text NOT NULL CHECK (applied_by IN ('global', 'seller')),
  created_at timestamptz DEFAULT now()
);

-- STEP 3: Enable RLS on All Tables
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.departments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_variants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cart_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wishlist ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.services ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.diy_articles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shipping_carriers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.global_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.seller_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shipping_rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_tracking ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_taxes ENABLE ROW LEVEL SECURITY;

-- STEP 4: Drop Old Problematic Policies
DROP POLICY IF EXISTS "Users can read own profile" ON public.user_profiles;
DROP POLICY IF EXISTS "Users can read own profile or admins can read all profiles" ON public.user_profiles;
DROP POLICY IF EXISTS "Admins can manage global settings" ON public.global_settings;

-- STEP 5: Create Fixed RLS Policies
CREATE POLICY "Anyone can read user profiles"
  ON public.user_profiles FOR SELECT
  USING (true);

CREATE POLICY "Users can insert own profile"
  ON public.user_profiles FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON public.user_profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Admins can delete any profile"
  ON public.user_profiles FOR DELETE
  TO authenticated
  USING (is_admin());

CREATE POLICY "Users can manage own addresses"
  ON public.addresses FOR ALL
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Anyone can read departments"
  ON public.departments FOR SELECT
  USING (true);

CREATE POLICY "Admins can manage departments"
  ON public.departments FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

CREATE POLICY "Anyone can read categories"
  ON public.categories FOR SELECT
  USING (true);

CREATE POLICY "Sellers can manage own categories"
  ON public.categories FOR ALL
  TO authenticated
  USING (auth.uid() = seller_id OR is_admin())
  WITH CHECK (auth.uid() = seller_id OR is_admin());

CREATE POLICY "Anyone can read products"
  ON public.products FOR SELECT
  USING (true);

CREATE POLICY "Sellers can manage own products"
  ON public.products FOR ALL
  TO authenticated
  USING (auth.uid() = seller_id OR is_admin())
  WITH CHECK (auth.uid() = seller_id OR is_admin());

CREATE POLICY "Anyone can read product variants"
  ON public.product_variants FOR SELECT
  USING (true);

CREATE POLICY "Sellers can manage own product variants"
  ON public.product_variants FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.products
      WHERE products.id = product_variants.product_id
      AND (products.seller_id = auth.uid() OR is_admin())
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.products
      WHERE products.id = product_variants.product_id
      AND (products.seller_id = auth.uid() OR is_admin())
    )
  );

CREATE POLICY "Users can manage own cart items"
  ON public.cart_items FOR ALL
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can manage own wishlist"
  ON public.wishlist FOR ALL
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can read own orders"
  ON public.orders FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id OR is_admin());

CREATE POLICY "Users can create own orders"
  ON public.orders FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Admins can update orders"
  ON public.orders FOR UPDATE
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

CREATE POLICY "Users can read own order items"
  ON public.order_items FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.orders
      WHERE orders.id = order_items.order_id
      AND (orders.user_id = auth.uid() OR is_admin())
    )
  );

CREATE POLICY "Users can create order items for own orders"
  ON public.order_items FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.orders
      WHERE orders.id = order_items.order_id
      AND orders.user_id = auth.uid()
    )
  );

CREATE POLICY "Anyone can read services"
  ON public.services FOR SELECT
  USING (true);

CREATE POLICY "Admins can manage services"
  ON public.services FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

CREATE POLICY "Anyone can read DIY articles"
  ON public.diy_articles FOR SELECT
  USING (true);

CREATE POLICY "Admins can manage DIY articles"
  ON public.diy_articles FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

CREATE POLICY "Anyone can read shipping carriers"
  ON public.shipping_carriers FOR SELECT
  USING (true);

CREATE POLICY "Admins can manage shipping carriers"
  ON public.shipping_carriers FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

CREATE POLICY "Anyone can read global settings"
  ON public.global_settings FOR SELECT
  USING (true);

CREATE POLICY "Admins can manage global settings"
  ON public.global_settings FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

CREATE POLICY "Sellers can read own settings"
  ON public.seller_settings FOR SELECT
  TO authenticated
  USING (auth.uid() = seller_id OR is_admin());

CREATE POLICY "Sellers can manage own settings"
  ON public.seller_settings FOR ALL
  TO authenticated
  USING (auth.uid() = seller_id OR is_admin())
  WITH CHECK (auth.uid() = seller_id OR is_admin());

CREATE POLICY "Anyone can read active shipping rules"
  ON public.shipping_rules FOR SELECT
  USING (is_active = true OR auth.uid() = seller_id OR is_admin());

CREATE POLICY "Sellers can manage own shipping rules"
  ON public.shipping_rules FOR ALL
  TO authenticated
  USING (auth.uid() = seller_id OR is_admin())
  WITH CHECK (auth.uid() = seller_id OR is_admin());

CREATE POLICY "Users can read own order tracking"
  ON public.order_tracking FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.orders
      WHERE orders.id = order_tracking.order_id
      AND (orders.user_id = auth.uid() OR is_admin())
    )
  );

CREATE POLICY "Admins and sellers can create tracking updates"
  ON public.order_tracking FOR INSERT
  TO authenticated
  WITH CHECK (is_admin() OR auth.uid() = updated_by);

CREATE POLICY "Users can read own order taxes"
  ON public.order_taxes FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.orders
      WHERE orders.id = order_taxes.order_id
      AND (orders.user_id = auth.uid() OR is_admin())
    )
  );

-- STEP 6: Insert Default Data
INSERT INTO public.global_settings (
  id,
  default_tax_rate,
  tax_type,
  free_shipping_threshold,
  platform_fulfillment_enabled,
  delivery_tracking_enabled
)
VALUES (
  '00000000-0000-0000-0000-000000000001',
  10.00,
  'GST',
  99.00,
  true,
  true
)
ON CONFLICT (id) DO UPDATE SET
  default_tax_rate = EXCLUDED.default_tax_rate,
  tax_type = EXCLUDED.tax_type,
  updated_at = now();

INSERT INTO public.shipping_carriers (name, code, tracking_url_template, is_active) VALUES
  ('Australia Post', 'auspost', 'https://auspost.com.au/mypost/track/#/details/{tracking_number}', true),
  ('FedEx', 'fedex', 'https://www.fedex.com/fedextrack/?tracknumbers={tracking_number}', true),
  ('DHL', 'dhl', 'https://www.dhl.com/au-en/home/tracking/tracking-express.html?submit=1&tracking-id={tracking_number}', true)
ON CONFLICT (code) DO NOTHING;

-- STEP 7: Create Trigger for Auto User Profile Creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.user_profiles (id, first_name, last_name, role)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'first_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'last_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'role', 'customer')
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- STEP 8: Verify Setup
SELECT 'SUCCESS: All tables created!' as status;

SELECT
  table_name,
  'Created' as status
FROM information_schema.tables
WHERE table_schema = 'public'
AND table_name IN (
  'user_profiles', 'addresses', 'departments', 'categories',
  'products', 'product_variants', 'cart_items', 'wishlist',
  'orders', 'order_items', 'services', 'diy_articles',
  'shipping_carriers', 'global_settings', 'seller_settings',
  'shipping_rules', 'order_tracking', 'order_taxes'
)
ORDER BY table_name;
