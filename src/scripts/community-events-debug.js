// Debug helper for community events
// Use in browser console to test the functionality

async function testCommunityEventsAPI() {
  console.log('🔍 Testing Community Events API...');
  
  if (!window.supabaseClient) {
    console.error('❌ Supabase client not available');
    return;
  }
  
  const client = window.supabaseClient;
  
  // Test 1: Quick stats
  console.log('📊 Testing get_quick_stats...');
  try {
    const { data: stats, error: statsError } = await client.rpc('get_quick_stats');
    if (statsError) {
      console.error('❌ get_quick_stats error:', statsError);
    } else {
      console.log('✅ Quick stats:', stats);
    }
  } catch (e) {
    console.error('❌ get_quick_stats exception:', e);
  }
  
  // Test 2: Featured events
  console.log('🎯 Testing list_featured_events...');
  try {
    const { data: events, error: eventsError } = await client.rpc('list_featured_events', { in_limit: 6 });
    if (eventsError) {
      console.error('❌ list_featured_events error:', eventsError);
    } else {
      console.log('✅ Featured events:', events);
    }
  } catch (e) {
    console.error('❌ list_featured_events exception:', e);
  }
  
  // Test 3: Individual challenges
  console.log('⚔️ Testing list_individual_challenges...');
  try {
    const { data: challenges, error: challengesError } = await client.rpc('list_individual_challenges');
    if (challengesError) {
      console.error('❌ list_individual_challenges error:', challengesError);
    } else {
      console.log('✅ Individual challenges:', challenges);
    }
  } catch (e) {
    console.error('❌ list_individual_challenges exception:', e);
  }
  
  // Test 4: House challenges
  console.log('🏰 Testing list_house_challenges...');
  try {
    const { data: houseChallenges, error: houseError } = await client.rpc('list_house_challenges');
    if (houseError) {
      console.error('❌ list_house_challenges error:', houseError);
    } else {
      console.log('✅ House challenges:', houseChallenges);
    }
  } catch (e) {
    console.error('❌ list_house_challenges exception:', e);
  }
  
  // Test 5: Active polls
  console.log('🗳️ Testing get_polls_active...');
  try {
    const { data: polls, error: pollsError } = await client.rpc('get_polls_active');
    if (pollsError) {
      console.error('❌ get_polls_active error:', pollsError);
    } else {
      console.log('✅ Active polls:', polls);
      
      // If we have a poll, test getting options
      if (polls && polls.length > 0) {
        const pollId = polls[0].poll_id;
        const { data: options, error: optionsError } = await client.rpc('get_poll_options_with_counts', { in_poll_id: pollId });
        if (optionsError) {
          console.error('❌ get_poll_options_with_counts error:', optionsError);
        } else {
          console.log('✅ Poll options:', options);
        }
      }
    }
  } catch (e) {
    console.error('❌ get_polls_active exception:', e);
  }
  
  // Test 6: Database direct queries
  console.log('🔍 Testing direct table queries...');
  try {
    const { data: events, error: eventsError } = await client
      .from('events')
      .select('id, slug, title, status, featured')
      .limit(5);
    if (eventsError) {
      console.error('❌ Direct events query error:', eventsError);
    } else {
      console.log('✅ Direct events query:', events);
    }
  } catch (e) {
    console.error('❌ Direct events query exception:', e);
  }
  
  console.log('🏁 Testing complete!');
}

// Auto-run when script loads
document.addEventListener('DOMContentLoaded', () => {
  setTimeout(() => {
    testCommunityEventsAPI();
  }, 2000);
});

// Export for manual testing
window.testCommunityEventsAPI = testCommunityEventsAPI;