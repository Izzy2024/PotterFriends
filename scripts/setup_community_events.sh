#!/bin/bash

# Community Events - Complete Setup Script
# This script runs all necessary migrations for the community events system

echo "🚀 Starting Community Events Setup..."

# Check if we're in the right directory
if [[ ! -f "supabase/migrations/20250811_community_events_backend.sql" ]]; then
    echo "❌ Please run this script from the project root directory"
    exit 1
fi

# Check if supabase CLI is installed
if ! command -v supabase &> /dev/null; then
    echo "❌ Supabase CLI not found. Please install it first:"
    echo "   npm install -g supabase"
    exit 1
fi

echo "📊 Step 1: Creating backend tables and policies..."
supabase db push --file supabase/migrations/20250811_community_events_backend.sql

echo "⚡ Step 2: Creating RPC functions and triggers..."
supabase db push --file supabase/migrations/20250811_community_events_rpcs.sql

echo "🌱 Step 3: Seeding initial data..."
supabase db push --file supabase/migrations/20250811_seed_community_events.sql

echo "🔧 Step 4: Adding sample data for testing..."
supabase db push --file supabase/migrations/sample_community_events_data.sql

echo "✨ Step 5: Fixing materialized views..."
supabase db push --file supabase/migrations/fix_materialized_views.sql

echo "✅ Community Events setup complete!"
echo ""
echo "🎯 Next steps:"
echo "1. Start your local server: python3 -m http.server 8080"
echo "2. Open: http://localhost:8080/pages/community_events_challenges_center.html"
echo "3. Open browser console to see API test results"
echo ""
echo "🐛 Debugging:"
echo "- Check browser console for errors"
echo "- Use testCommunityEventsAPI() in console to test API calls"
echo "- Verify Supabase connection in Network tab"