const { createClient } = require('@supabase/supabase-js');

// Simple MCP server for Supabase
const supabaseUrl = process.env.SUPABASE_URL || 'https://vdcclritlgnwwdxloayt.supabase.co';
const supabaseKey = process.env.SUPABASE_TOKEN || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZkY2Nscml0bGdud3dkeGxvYXl0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTMwOTQxMDQsImV4cCI6MjA2ODY3MDEwNH0.BaBIrCS9fgkLEkC_KLZg9gR_jNgFIPC7bMvuwfCnb6E';

// Initialize Supabase client
let supabase = null;

// Handle messages from stdin
process.stdin.on('data', async (data) => {
  try {
    const message = JSON.parse(data.toString());
    const { id, method, params } = message;
    
    let result = null;
    let error = null;
    
    console.error(`Received method: ${method}`);
    
    switch (method) {
      case 'createClient':
        try {
          // Initialize Supabase client if not already done
          if (!supabase) {
            supabase = createClient(params.supabaseUrl || supabaseUrl, params.supabaseKey || supabaseKey);
          }
          result = { message: 'Supabase client created successfully' };
        } catch (err) {
          error = { message: `Error creating Supabase client: ${err.message}` };
        }
        break;
        
      case 'signUp':
        try {
          const { email, password, options } = params;
          const { data, error: signUpError } = await supabase.auth.signUp({
            email,
            password,
            options
          });
          
          if (signUpError) {
            error = { message: signUpError.message };
          } else {
            result = data;
          }
        } catch (err) {
          error = { message: `Error signing up: ${err.message}` };
        }
        break;
        
      case 'signIn':
        try {
          const { email, password } = params;
          const { data, error: signInError } = await supabase.auth.signInWithPassword({
            email,
            password
          });
          
          if (signInError) {
            error = { message: signInError.message };
          } else {
            result = data;
          }
        } catch (err) {
          error = { message: `Error signing in: ${err.message}` };
        }
        break;
        
      case 'signOut':
        try {
          const { error: signOutError } = await supabase.auth.signOut();
          
          if (signOutError) {
            error = { message: signOutError.message };
          } else {
            result = { message: 'Signed out successfully' };
          }
        } catch (err) {
          error = { message: `Error signing out: ${err.message}` };
        }
        break;
        
      case 'resetPasswordForEmail':
        try {
          const { email, options } = params;
          const { error: resetError } = await supabase.auth.resetPasswordForEmail(email, options);
          
          if (resetError) {
            error = { message: resetError.message };
          } else {
            result = { message: 'Password reset email sent successfully' };
          }
        } catch (err) {
          error = { message: `Error resetting password: ${err.message}` };
        }
        break;
        
      default:
        error = { message: `Unknown method: ${method}` };
    }
    
    // Send response
    const response = {
      id,
      result,
      error
    };
    
    process.stdout.write(JSON.stringify(response) + '\n');
  } catch (err) {
    console.error('Error processing message:', err);
    process.stdout.write(JSON.stringify({
      id: 'error',
      error: { message: `Error processing message: ${err.message}` }
    }) + '\n');
  }
});

// Handle process exit
process.on('SIGINT', () => {
  console.error('MCP server shutting down');
  process.exit(0);
});

console.error('Supabase MCP server started');