-- ============================================================================
-- DATABASE VERIFICATION SCRIPT
-- ============================================================================
-- Run this AFTER applying APPLY_MIGRATIONS_NOW.sql to verify everything works
-- ============================================================================

-- Check 1: Verify all tables exist
SELECT
  '✓ Table Check' as test,
  CASE
    WHEN COUNT(*) = 18 THEN 'PASS - All 18 tables created'
    ELSE 'FAIL - Only ' || COUNT(*) || ' tables found'
  END as result
FROM information_schema.tables
WHERE table_schema = 'public'
AND table_name IN (
  'user_profiles', 'addresses', 'departments', 'categories',
  'products', 'product_variants', 'cart_items', 'wishlist',
  'orders', 'order_items', 'services', 'diy_articles',
  'shipping_carriers', 'global_settings', 'seller_settings',
  'shipping_rules', 'order_tracking', 'order_taxes'
);

-- Check 2: Verify RLS is enabled on all tables
SELECT
  '✓ RLS Check' as test,
  CASE
    WHEN COUNT(*) = 18 THEN 'PASS - RLS enabled on all tables'
    ELSE 'FAIL - RLS missing on ' || (18 - COUNT(*)) || ' tables'
  END as result
FROM pg_tables
WHERE schemaname = 'public'
AND rowsecurity = true
AND tablename IN (
  'user_profiles', 'addresses', 'departments', 'categories',
  'products', 'product_variants', 'cart_items', 'wishlist',
  'orders', 'order_items', 'services', 'diy_articles',
  'shipping_carriers', 'global_settings', 'seller_settings',
  'shipping_rules', 'order_tracking', 'order_taxes'
);

-- Check 3: Verify helper function exists
SELECT
  '✓ Helper Function Check' as test,
  CASE
    WHEN COUNT(*) > 0 THEN 'PASS - is_admin() function exists'
    ELSE 'FAIL - is_admin() function not found'
  END as result
FROM pg_proc
WHERE proname = 'is_admin';

-- Check 4: Verify trigger exists
SELECT
  '✓ Trigger Check' as test,
  CASE
    WHEN COUNT(*) > 0 THEN 'PASS - Auto user profile trigger exists'
    ELSE 'FAIL - Trigger not found'
  END as result
FROM pg_trigger
WHERE tgname = 'on_auth_user_created';

-- Check 5: Verify default data exists
SELECT
  '✓ Default Data Check' as test,
  CASE
    WHEN COUNT(*) >= 3 THEN 'PASS - Shipping carriers added'
    ELSE 'FAIL - Shipping carriers missing'
  END as result
FROM shipping_carriers;

-- Check 6: Verify global settings exists
SELECT
  '✓ Global Settings Check' as test,
  CASE
    WHEN COUNT(*) > 0 THEN 'PASS - Global settings configured'
    ELSE 'FAIL - Global settings missing'
  END as result
FROM global_settings;

-- Check 7: List all RLS policies (should be ~25+)
SELECT
  '✓ RLS Policies Count' as test,
  'INFO - ' || COUNT(*) || ' RLS policies created' as result
FROM pg_policies
WHERE schemaname = 'public';

-- Check 8: Test that user_profiles can be queried without recursion
SELECT
  '✓ Recursion Test' as test,
  CASE
    WHEN COUNT(*) >= 0 THEN 'PASS - No infinite recursion detected'
    ELSE 'FAIL - Query failed'
  END as result
FROM user_profiles;

-- ============================================================================
-- DETAILED TABLE LIST
-- ============================================================================
SELECT
  table_name,
  (SELECT COUNT(*) FROM pg_policies WHERE tablename = t.table_name) as policies_count,
  (SELECT reltuples::bigint FROM pg_class WHERE relname = t.table_name) as row_count
FROM information_schema.tables t
WHERE table_schema = 'public'
AND table_name IN (
  'user_profiles', 'addresses', 'departments', 'categories',
  'products', 'product_variants', 'cart_items', 'wishlist',
  'orders', 'order_items', 'services', 'diy_articles',
  'shipping_carriers', 'global_settings', 'seller_settings',
  'shipping_rules', 'order_tracking', 'order_taxes'
)
ORDER BY table_name;

-- ============================================================================
-- ALL TESTS COMPLETE
-- ============================================================================
SELECT '✅ Verification Complete!' as status;
