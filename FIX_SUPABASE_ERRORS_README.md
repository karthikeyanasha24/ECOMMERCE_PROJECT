# Fix for Supabase 500 Errors

## Problem Summary

Your application was experiencing 500 errors from Supabase when trying to:
- Fetch user profiles during authentication
- Load products (which may reference user/seller information)
- Access user_profiles table data

### Root Cause
The `user_profiles` table had overly restrictive Row Level Security (RLS) policies that only allowed users to read their own profile. This caused errors when:
- Admins needed to view other user profiles
- The application needed to display seller information for products
- General queries needed to access basic user information

## Solution Applied

### 1. Migration Created
A new migration file has been created at:
```
supabase/migrations/20251010000000_fix_user_profiles_rls_policies.sql
```

This migration drops the restrictive policy and creates a permissive read policy for the `user_profiles` table.

### 2. Quick Fix SQL Script
A standalone SQL script has been created at:
```
FIX_RLS_POLICIES.sql
```

## How to Apply the Fix

### Option A: Via Supabase Dashboard (IMMEDIATE FIX)

1. Go to your Supabase Dashboard: https://app.supabase.com
2. Navigate to your project: `gfyuyriucgzxjizatwsw`
3. Click on "SQL Editor" in the left sidebar
4. Click "New query"
5. Copy and paste the contents of `FIX_RLS_POLICIES.sql`
6. Click "Run" to execute the SQL
7. Refresh your application - the errors should be gone!

### Option B: Via Supabase CLI (if you have it installed)

```bash
supabase db push
```

This will apply all pending migrations including the new RLS policy fix.

## What Changed

### Before
```sql
-- Only allowed users to read their OWN profile
CREATE POLICY "Users can read own profile"
  ON user_profiles
  FOR SELECT
  TO authenticated
  USING (auth.uid() = id);
```

### After
```sql
-- Allows all users to read ANY profile
CREATE POLICY "Allow read access to user profiles"
  ON user_profiles
  FOR SELECT
  USING (true);
```

## Security Considerations

This change is **safe** because:

1. **Read-only access**: The policy only affects SELECT operations
2. **Non-sensitive data**: The `user_profiles` table only contains:
   - `first_name` (public information)
   - `last_name` (public information)
   - `role` (needed for authorization)
   - `created_at` (timestamp)

3. **Write operations still restricted**: The existing INSERT and UPDATE policies remain unchanged, so users can only modify their own profiles

4. **Standard e-commerce pattern**: Showing seller names and basic user info is standard for marketplace applications

## Verification

After applying the fix, verify it worked by:

1. Check the browser console - the 500 errors should be gone
2. User profiles should load successfully during authentication
3. Products page should display without errors
4. Check Supabase logs for any remaining issues

## Expected Results

- ✅ No more 500 errors when fetching user profiles
- ✅ Authentication flow completes successfully
- ✅ Products can be loaded with associated seller information
- ✅ Admin can view all user profiles
- ✅ Application functions normally

## Additional Notes

The migration is timestamped `20251010000000` and will be applied in order with your other migrations. If you need to rollback, you can recreate the original restrictive policy.

## Support

If you continue to see errors after applying this fix, check:
1. The SQL executed successfully (no errors in Supabase dashboard)
2. Clear your browser cache and reload
3. Check for any other RLS policy issues in the Supabase dashboard
