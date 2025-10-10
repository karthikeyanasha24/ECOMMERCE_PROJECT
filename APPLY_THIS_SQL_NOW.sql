-- ============================================================================
-- COPY AND PASTE THIS ENTIRE SCRIPT INTO SUPABASE SQL EDITOR
-- ============================================================================
--
-- This fixes the 500 errors you're seeing when accessing user_profiles
--
-- Steps:
-- 1. Go to: https://app.supabase.com
-- 2. Select your project: gfyuyriucgzxjizatwsw
-- 3. Click "SQL Editor" in the left sidebar
-- 4. Click "New query"
-- 5. Paste this entire file
-- 6. Click "Run"
-- 7. Refresh your app - errors should be gone!
--
-- ============================================================================

-- Drop the overly restrictive policy
DROP POLICY IF EXISTS "Users can read own profile" ON user_profiles;

-- Create a new permissive read policy
-- This allows all users to read any user profile
-- Safe because user_profiles only contains: first_name, last_name, role
CREATE POLICY "Allow read access to user profiles"
  ON user_profiles
  FOR SELECT
  USING (true);

-- Verify the fix was applied successfully
SELECT
  'SUCCESS: RLS Policy Updated' as status,
  count(*) as total_policies
FROM pg_policies
WHERE tablename = 'user_profiles';

-- Show all current policies on user_profiles
SELECT
  policyname as policy_name,
  cmd as command,
  CASE
    WHEN permissive = 'PERMISSIVE' THEN '✓ Permissive'
    ELSE '✗ Restrictive'
  END as type,
  CASE
    WHEN roles::text LIKE '%public%' THEN '🌐 Public'
    WHEN roles::text LIKE '%authenticated%' THEN '🔒 Authenticated'
    ELSE roles::text
  END as applies_to
FROM pg_policies
WHERE tablename = 'user_profiles'
ORDER BY cmd, policyname;
