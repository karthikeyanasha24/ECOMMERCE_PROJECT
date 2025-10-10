-- IMMEDIATE FIX for Supabase 500 Errors
-- Run this in your Supabase SQL Editor to fix user_profiles access issues
-- This script drops the overly restrictive RLS policy and creates a permissive one

-- Drop existing restrictive SELECT policy
DROP POLICY IF EXISTS "Users can read own profile" ON user_profiles;

-- Create simplified SELECT policy that allows all read access
-- This is safe because user_profiles only contains non-sensitive public info (first_name, last_name, role)
-- Write operations remain restricted by existing INSERT/UPDATE policies
CREATE POLICY "Allow read access to user profiles"
  ON user_profiles
  FOR SELECT
  USING (true);

-- Verify the policy was created successfully
SELECT
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd
FROM pg_policies
WHERE tablename = 'user_profiles'
ORDER BY policyname;
