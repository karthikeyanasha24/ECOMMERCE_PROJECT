# Database Setup Instructions

## Problem Summary

Your Supabase database is currently empty (no tables created) and the application is showing infinite recursion errors. This is because:

1. The migration files exist locally but have never been applied to the remote Supabase database
2. Some of the existing migration files contain RLS policies that create infinite recursion loops
3. Several required tables for the multi-vendor features are missing

## Solution

I've created a comprehensive SQL script that:
- Creates ALL 18 required database tables
- Fixes the infinite recursion errors in RLS policies
- Sets up proper security with Row Level Security
- Includes support for admin, seller, and customer roles
- Adds sample data (shipping carriers, global settings)

## How to Apply (5 Minutes)

### Step 1: Open Supabase Dashboard
1. Go to https://app.supabase.com
2. Log in to your account
3. Select your project: **gfyuyriucgzxjizatwsw**

### Step 2: Open SQL Editor
1. Click **"SQL Editor"** in the left sidebar
2. Click **"New query"** button (top right)

### Step 3: Copy and Paste the SQL
1. Open the file: `APPLY_MIGRATIONS_NOW.sql` (in your project root)
2. Select ALL the contents (Cmd/Ctrl + A)
3. Copy it (Cmd/Ctrl + C)
4. Paste it into the Supabase SQL Editor (Cmd/Ctrl + V)

### Step 4: Run the Script
1. Click the **"Run"** button (or press Cmd/Ctrl + Enter)
2. Wait 10-20 seconds for completion
3. You should see "SUCCESS: All tables created!" message
4. You should see a list of all 18 tables that were created

### Step 5: Verify and Refresh
1. Click **"Table Editor"** in the left sidebar
2. You should now see 18 tables listed
3. Go back to your application and refresh the page
4. All the 500 errors should be gone!

## What Gets Created

### Tables Created (18 Total)
1. **user_profiles** - User information and roles (customer/seller/admin)
2. **addresses** - Billing and shipping addresses
3. **departments** - Product departments (Building & Hardware, etc.)
4. **categories** - Product categories within departments
5. **products** - Product catalog with pricing and inventory
6. **product_variants** - Product variations (size, color, etc.)
7. **cart_items** - Shopping cart contents
8. **wishlist** - User wishlists
9. **orders** - Customer orders
10. **order_items** - Items within orders
11. **services** - Service offerings
12. **diy_articles** - DIY guides and articles
13. **shipping_carriers** - Shipping providers (Australia Post, FedEx, DHL)
14. **global_settings** - Platform-wide settings (tax rates, shipping)
15. **seller_settings** - Seller-specific configurations
16. **shipping_rules** - Custom shipping rules per seller
17. **order_tracking** - Delivery status tracking
18. **order_taxes** - Tax calculation audit trail

### Security (Row Level Security)
- All tables have RLS enabled
- Users can only access their own data
- Sellers can manage their own products and settings
- Admins have full access to all data
- Public read access for product catalogs

### Default Data Inserted
- Global settings with 10% GST tax rate
- Three shipping carriers: Australia Post, FedEx, DHL
- Free shipping threshold set to $99

## Key Fix: Infinite Recursion Solution

**The Problem:**
Old RLS policies tried to check if a user is an admin by querying the `user_profiles` table, but to query that table, Supabase needs to check the RLS policy again, creating an infinite loop.

**The Solution:**
Created a helper function `is_admin()` that uses `SECURITY DEFINER` to bypass RLS and safely check user roles. All admin checks now use this function instead of directly querying `user_profiles`.

## After Setup

Once the database is set up, you'll be able to:

1. **Register Users** - Users can sign up with customer, seller, or admin roles
2. **Browse Products** - Public product catalog with categories and departments
3. **Manage Cart** - Authenticated users can add/remove cart items
4. **Place Orders** - Complete checkout with shipping and billing addresses
5. **Seller Dashboard** - Sellers can manage their products and settings
6. **Admin Panel** - Admins can manage all users, products, and platform settings

## Troubleshooting

### If You Still See Errors After Running:

1. **Check the SQL Editor output**
   - Look for any red error messages
   - Common issue: Already existing policies (this is safe to ignore)

2. **Verify tables were created**
   - Go to Table Editor in Supabase dashboard
   - You should see 18 tables listed

3. **Clear browser cache**
   - Hard refresh your app: Cmd+Shift+R (Mac) or Ctrl+Shift+R (Windows)
   - Or open in incognito/private window

4. **Check the browser console**
   - Open DevTools (F12)
   - Look for any remaining errors
   - The infinite recursion errors should be completely gone

### If Tables Already Exist:

The script uses `CREATE TABLE IF NOT EXISTS`, so it's safe to run multiple times. It will:
- Skip creating tables that already exist
- Drop and recreate problematic RLS policies
- Update default data if it exists

## Need to Start Fresh?

If you want to completely reset the database:

1. Go to Supabase Dashboard → SQL Editor
2. Run this command first:
```sql
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO public;
```
3. Then run the `APPLY_MIGRATIONS_NOW.sql` script

## Support Files Created

I've created these files for you:
- `APPLY_MIGRATIONS_NOW.sql` - The main script to run (copy & paste into Supabase)
- `DATABASE_SETUP_INSTRUCTIONS.md` - This instruction file
- `supabase/migrations/20251010120000_comprehensive_database_setup.sql` - Migration file for version control

## What's Next?

After the database is set up successfully:

1. **Test user registration** - Create a test account
2. **Check the admin panel** - You'll need to manually set a user to admin role in the database
3. **Add sample products** - Use the admin panel to add products
4. **Test the shopping flow** - Add products to cart and complete checkout

## Making a User Admin

To make yourself an admin:

1. Register a new account in your app
2. Go to Supabase Dashboard → Table Editor → user_profiles
3. Find your user record
4. Change the `role` column from `customer` to `admin`
5. Refresh your app

Now you'll have full admin access!
