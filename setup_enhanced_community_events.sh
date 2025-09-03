#!/bin/bash

# Community Events - Complete Setup Script (Updated)
# This script runs all necessary migrations for the enhanced community events system

echo "🚀 Starting Enhanced Community Events Setup..."

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

echo "🔧 Step 3: Adding additional RPC functions..."
supabase db push --file supabase/migrations/20250818_additional_event_rpcs.sql

echo "🌱 Step 4: Seeding initial data..."
supabase db push --file supabase/migrations/20250811_seed_community_events.sql

echo "🔧 Step 5: Adding sample data for testing..."
supabase db push --file supabase/migrations/sample_community_events_data.sql

echo "✨ Step 6: Fixing materialized views..."
supabase db push --file supabase/migrations/fix_materialized_views.sql

echo "✅ Enhanced Community Events setup complete!"
echo ""
echo "🎯 Available Pages:"
echo "1. Main Events Hub: http://localhost:8080/pages/community_events_challenges_center.html"
echo "2. Event Detail (dynamic): http://localhost:8080/pages/event-detail.html?event=SLUG"
echo "3. Event Administration: http://localhost:8080/pages/event-admin.html"
echo ""
echo "🔧 New Features:"
echo "✅ Individual event pages with full interaction"
echo "✅ Event creation and management admin panel"
echo "✅ Dynamic calendar with event markers"
echo "✅ Participation system with submissions"
echo "✅ User participations tracking"
echo "✅ Leaderboard system (users and houses)"
echo "✅ Interactive voting and challenges"
echo ""
echo "🚀 Next steps:"
echo "1. Start your local server: python3 -m http.server 8080"
echo "2. Navigate to the events center to see all features"
echo "3. Use the admin panel to create new events"
echo "4. Click on events to see individual detail pages"
echo ""
echo "🐛 Debugging:"
echo "- Check browser console for errors"
echo "- Use testCommunityEventsAPI() in console to test API calls"
echo "- Use communityEventsDebug.testConnection() to verify connection"
echo "- All pages include comprehensive error logging"