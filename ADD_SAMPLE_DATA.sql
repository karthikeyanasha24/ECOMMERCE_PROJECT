-- ============================================================================
-- ADD SAMPLE DATA TO DATABASE
-- ============================================================================
-- Run this AFTER applying APPLY_MIGRATIONS_NOW.sql to populate with test data
-- This gives you departments, categories, and products to test with
-- ============================================================================

-- Insert sample departments
INSERT INTO departments (id, slug, name, description, image) VALUES
  ('550e8400-e29b-41d4-a716-446655440001', 'building-hardware', 'Building & Hardware', 'Essential building materials and hardware supplies', 'https://images.pexels.com/photos/162553/keys-workshop-mechanic-tools-162553.jpeg'),
  ('550e8400-e29b-41d4-a716-446655440002', 'tools-equipment', 'Tools & Equipment', 'Professional tools for every job', 'https://images.pexels.com/photos/1249611/pexels-photo-1249611.jpeg'),
  ('550e8400-e29b-41d4-a716-446655440003', 'garden-outdoor', 'Garden & Outdoor', 'Everything for your outdoor spaces', 'https://images.pexels.com/photos/296230/pexels-photo-296230.jpeg')
ON CONFLICT (slug) DO NOTHING;

-- Insert sample categories
INSERT INTO categories (id, slug, name, description, department_id, product_count) VALUES
  ('550e8400-e29b-41d4-a716-446655440011', 'fasteners', 'Fasteners & Fixings', 'Screws, nails, bolts and more', '550e8400-e29b-41d4-a716-446655440001', 245),
  ('550e8400-e29b-41d4-a716-446655440012', 'timber', 'Timber & Lumber', 'Quality timber for all projects', '550e8400-e29b-41d4-a716-446655440001', 189),
  ('550e8400-e29b-41d4-a716-446655440013', 'power-tools', 'Power Tools', 'Professional grade power tools', '550e8400-e29b-41d4-a716-446655440002', 156),
  ('550e8400-e29b-41d4-a716-446655440014', 'hand-tools', 'Hand Tools', 'Essential hand tools', '550e8400-e29b-41d4-a716-446655440002', 298),
  ('550e8400-e29b-41d4-a716-446655440015', 'gardening', 'Gardening', 'Tools and supplies for gardening', '550e8400-e29b-41d4-a716-446655440003', 167),
  ('550e8400-e29b-41d4-a716-446655440016', 'outdoor-furniture', 'Outdoor Furniture', 'Furniture for outdoor living', '550e8400-e29b-41d4-a716-446655440003', 89)
ON CONFLICT (slug) DO NOTHING;

-- Insert sample products
INSERT INTO products (id, slug, name, description, price, original_price, images, category_id, department_id, brand, rating, review_count, stock, specifications, weight_kg, shipping_class) VALUES
  (
    '550e8400-e29b-41d4-a716-446655440021',
    'concrete-mix-50kg',
    'Premium Concrete Mix 50kg',
    'High-strength concrete mix suitable for foundations, driveways, and general construction projects. Professional grade quality.',
    12.95,
    15.95,
    ARRAY['https://images.pexels.com/photos/585419/pexels-photo-585419.jpeg'],
    '550e8400-e29b-41d4-a716-446655440011',
    '550e8400-e29b-41d4-a716-446655440001',
    'BuildPro',
    4.5,
    127,
    45,
    '{"Weight": "50kg", "Coverage": "25L when mixed", "Setting Time": "2-4 hours", "Compressive Strength": "25MPa"}'::jsonb,
    50.0,
    'standard'
  ),
  (
    '550e8400-e29b-41d4-a716-446655440022',
    'cordless-drill-18v',
    '18V Cordless Drill with Battery',
    'Professional cordless drill with lithium-ion battery and 13mm keyless chuck. Includes 2 batteries, charger, and carrying case.',
    149.99,
    NULL,
    ARRAY['https://images.pexels.com/photos/1249611/pexels-photo-1249611.jpeg'],
    '550e8400-e29b-41d4-a716-446655440013',
    '550e8400-e29b-41d4-a716-446655440002',
    'PowerMax',
    4.8,
    89,
    23,
    '{"Voltage": "18V", "Chuck Size": "13mm", "Battery Type": "Lithium-ion", "Torque Settings": "21", "Weight": "1.6kg"}'::jsonb,
    2.5,
    'standard'
  ),
  (
    '550e8400-e29b-41d4-a716-446655440023',
    'garden-hose-30m',
    '30m Heavy Duty Garden Hose',
    'Durable garden hose with brass fittings and kink-resistant design. UV resistant and weather proof.',
    89.99,
    109.99,
    ARRAY['https://images.pexels.com/photos/1301856/pexels-photo-1301856.jpeg'],
    '550e8400-e29b-41d4-a716-446655440015',
    '550e8400-e29b-41d4-a716-446655440003',
    'FlowPro',
    4.3,
    56,
    18,
    '{"Length": "30m", "Diameter": "12mm", "Material": "Reinforced PVC", "Fittings": "Brass", "Warranty": "5 years"}'::jsonb,
    3.2,
    'standard'
  ),
  (
    '550e8400-e29b-41d4-a716-446655440024',
    'hammer-claw-16oz',
    '16oz Claw Hammer',
    'Professional claw hammer with fibreglass handle. Perfectly balanced for all-day use.',
    29.95,
    NULL,
    ARRAY['https://images.pexels.com/photos/209235/pexels-photo-209235.jpeg'],
    '550e8400-e29b-41d4-a716-446655440014',
    '550e8400-e29b-41d4-a716-446655440002',
    'StrikeRight',
    4.6,
    234,
    67,
    '{"Weight": "16oz", "Handle": "Fibreglass", "Head": "Forged Steel", "Length": "33cm"}'::jsonb,
    0.8,
    'standard'
  ),
  (
    '550e8400-e29b-41d4-a716-446655440025',
    'pine-timber-90x45',
    'Pine Timber 90x45mm 2.4m',
    'Treated pine timber suitable for structural and general building purposes.',
    18.50,
    NULL,
    ARRAY['https://images.pexels.com/photos/1907785/pexels-photo-1907785.jpeg'],
    '550e8400-e29b-41d4-a716-446655440012',
    '550e8400-e29b-41d4-a716-446655440001',
    'TimberPro',
    4.4,
    78,
    156,
    '{"Dimensions": "90x45mm", "Length": "2.4m", "Treatment": "H3", "Species": "Pine"}'::jsonb,
    8.5,
    'standard'
  ),
  (
    '550e8400-e29b-41d4-a716-446655440026',
    'outdoor-table-setting',
    '5-Piece Outdoor Table Setting',
    'Modern outdoor dining set with weather-resistant finish. Includes table and 4 chairs.',
    599.00,
    799.00,
    ARRAY['https://images.pexels.com/photos/1571460/pexels-photo-1571460.jpeg'],
    '550e8400-e29b-41d4-a716-446655440016',
    '550e8400-e29b-41d4-a716-446655440003',
    'OutdoorLiving',
    4.7,
    45,
    12,
    '{"Pieces": "5", "Material": "Powder-coated steel", "Table Size": "120x80cm", "Weight Capacity": "150kg per chair"}'::jsonb,
    45.0,
    'standard'
  )
ON CONFLICT (slug) DO NOTHING;

-- Insert sample services
INSERT INTO services (id, slug, name, description, image, price, duration, category) VALUES
  (
    '550e8400-e29b-41d4-a716-446655440031',
    'kitchen-installation',
    'Kitchen Installation Service',
    'Professional kitchen installation by certified tradespeople. Full installation including plumbing and electrical.',
    'https://images.pexels.com/photos/1080721/pexels-photo-1080721.jpeg',
    299.00,
    '1-2 days',
    'Installation'
  ),
  (
    '550e8400-e29b-41d4-a716-446655440032',
    'garden-design',
    'Garden Design Consultation',
    'Expert garden design and landscaping advice from qualified designers. Includes 3D mockups.',
    'https://images.pexels.com/photos/1002703/pexels-photo-1002703.jpeg',
    150.00,
    '2-3 hours',
    'Consultation'
  ),
  (
    '550e8400-e29b-41d4-a716-446655440033',
    'deck-building',
    'Deck Building Service',
    'Complete deck construction service including design, materials, and installation.',
    'https://images.pexels.com/photos/1105325/pexels-photo-1105325.jpeg',
    2500.00,
    '3-5 days',
    'Construction'
  )
ON CONFLICT (slug) DO NOTHING;

-- Insert sample DIY articles
INSERT INTO diy_articles (id, slug, title, excerpt, content, featured_image, author, category, tags) VALUES
  (
    '550e8400-e29b-41d4-a716-446655440041',
    'build-garden-deck',
    'How to Build a Garden Deck',
    'Step-by-step guide to building your own garden deck. Perfect weekend project for experienced DIYers.',
    'Building a garden deck is a rewarding project that can transform your outdoor space. In this comprehensive guide, we''ll walk you through every step of the process, from planning and materials to construction techniques.

## Planning Your Deck

Start by measuring your space and sketching out your design. Consider factors like:
- Sun exposure throughout the day
- Proximity to the house
- Access points and traffic flow
- Local building codes and permits

## Materials You''ll Need

- Treated pine posts (90x90mm)
- Decking boards (90x19mm)
- Galvanized screws and nails
- Concrete for footings
- Spirit level and measuring tape

## Step-by-Step Construction

1. Mark out your deck area
2. Dig holes for footings
3. Pour concrete and set posts
4. Build the frame
5. Install joists
6. Lay decking boards
7. Add finishing touches

With proper planning and the right tools, you can complete a basic deck in a weekend!',
    'https://images.pexels.com/photos/1105325/pexels-photo-1105325.jpeg',
    'BuildMart Team',
    'Outdoor Projects',
    ARRAY['deck', 'garden', 'diy', 'outdoor', 'woodworking']
  ),
  (
    '550e8400-e29b-41d4-a716-446655440042',
    'organize-garage-storage',
    'Garage Storage Solutions',
    'Maximize your garage space with smart storage ideas. Transform cluttered chaos into organized efficiency.',
    'A well-organized garage can save you time and reduce stress. Here are professional tips for maximizing your garage storage space.

## Assessment and Planning

Start by clearing everything out and sorting items into categories:
- Keep and use regularly
- Keep but use occasionally
- Donate or sell
- Discard

## Storage Solutions

### Wall-Mounted Systems
Install pegboards and slatwalls for frequently used tools. This keeps them visible and easily accessible.

### Overhead Storage
Use ceiling-mounted racks for seasonal items and things you don''t need often.

### Shelving Units
Heavy-duty metal shelving works great for bins and boxes. Label everything clearly.

## Maintenance Tips

- Review your organization quarterly
- Keep a donation box handy
- Return items to their designated spots
- Clean spills immediately

A little organization goes a long way in making your garage functional!',
    'https://images.pexels.com/photos/1080721/pexels-photo-1080721.jpeg',
    'BuildMart Team',
    'Storage',
    ARRAY['garage', 'storage', 'organization', 'diy', 'home improvement']
  ),
  (
    '550e8400-e29b-41d4-a716-446655440043',
    'power-tool-safety-guide',
    'Essential Power Tool Safety Guide',
    'Master power tool safety with our comprehensive guide. Protect yourself and work confidently.',
    'Power tools are essential for many projects, but they require respect and proper safety practices.

## General Safety Rules

1. Always wear appropriate PPE (Personal Protective Equipment)
2. Read the manual before using any new tool
3. Inspect tools before each use
4. Keep work area clean and well-lit
5. Never bypass safety features

## PPE Requirements

### Eye Protection
Safety glasses or goggles are essential for any power tool use.

### Hearing Protection
Many power tools exceed safe noise levels. Use earplugs or earmuffs.

### Dust Masks
Protect your lungs from sawdust and particles.

## Tool-Specific Safety

### Circular Saws
- Always use blade guards
- Support material properly
- Keep both hands on the tool

### Drills
- Secure workpiece before drilling
- Remove chuck key before starting
- Use sharp bits

## Emergency Preparedness

- Know where your first aid kit is
- Have emergency numbers posted
- Keep fire extinguisher nearby
- Never work alone on major projects

Stay safe and enjoy your projects!',
    'https://images.pexels.com/photos/1249611/pexels-photo-1249611.jpeg',
    'BuildMart Team',
    'Safety',
    ARRAY['safety', 'power tools', 'diy', 'tutorial', 'workshop']
  )
ON CONFLICT (slug) DO NOTHING;

-- Success message
SELECT
  'Sample data added successfully!' as status,
  (SELECT COUNT(*) FROM departments) as departments,
  (SELECT COUNT(*) FROM categories) as categories,
  (SELECT COUNT(*) FROM products) as products,
  (SELECT COUNT(*) FROM services) as services,
  (SELECT COUNT(*) FROM diy_articles) as diy_articles;
