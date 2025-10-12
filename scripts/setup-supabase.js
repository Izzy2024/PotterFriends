// Script to set up Supabase tables for Hogwarts Community Hub
const { createClient } = require('@supabase/supabase-js');

// Supabase configuration
const supabaseUrl = 'https://vdcclritlgnwwdxloayt.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZkY2Nscml0bGdud3dkeGxvYXl0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTMwOTQxMDQsImV4cCI6MjA2ODY3MDEwNH0.BaBIrCS9fgkLEkC_KLZg9gR_jNgFIPC7bMvuwfCnb6E';

// Initialize Supabase client
const supabase = createClient(supabaseUrl, supabaseKey);

async function setupDatabase() {
  console.log('Setting up Supabase database for Hogwarts Community Hub...');

  try {
    // Check if profiles table exists
    const { data: tables, error: tablesError } = await supabase
      .from('information_schema.tables')
      .select('table_name')
      .eq('table_schema', 'public');

    if (tablesError) {
      console.error('Error checking tables:', tablesError);
      return;
    }

    const profilesExists = tables.some(table => table.table_name === 'profiles');

    if (!profilesExists) {
      console.log('Creating profiles table...');
      
      // Create profiles table using SQL
      const { error: createError } = await supabase.rpc('exec_sql', {
        sql: `
          CREATE TABLE profiles (
            id UUID PRIMARY KEY REFERENCES auth.users(id),
            first_name TEXT,
            last_name TEXT,
            wizard_name TEXT NOT NULL,
            email TEXT UNIQUE NOT NULL,
            house TEXT,
            avatar_url TEXT,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
          );
          
          -- Set up Row Level Security
          ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
          
          -- Create policies
          CREATE POLICY "Users can view their own profile" 
            ON profiles FOR SELECT 
            USING (auth.uid() = id);
            
          CREATE POLICY "Users can update their own profile" 
            ON profiles FOR UPDATE 
            USING (auth.uid() = id);
            
          -- Create public profiles view for limited data
          CREATE VIEW public_profiles AS
            SELECT id, wizard_name, house, avatar_url
            FROM profiles;
            
          -- Allow public read access to public_profiles
          CREATE POLICY "Anyone can view public profiles" 
            ON public_profiles FOR SELECT 
            USING (true);
        `
      });

      if (createError) {
        console.error('Error creating profiles table:', createError);
      } else {
        console.log('Profiles table created successfully!');
      }
    } else {
      console.log('Profiles table already exists.');
    }

    // Check if houses table exists
    const housesExists = tables.some(table => table.table_name === 'houses');

    if (!housesExists) {
      console.log('Creating houses table...');
      
      // Create houses table using SQL
      const { error: createHousesError } = await supabase.rpc('exec_sql', {
        sql: `
          CREATE TABLE houses (
            id SERIAL PRIMARY KEY,
            name TEXT UNIQUE NOT NULL,
            description TEXT,
            color TEXT,
            emblem_url TEXT,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
          );
          
          -- Insert house data
          INSERT INTO houses (name, description, color, emblem_url) VALUES
            ('gryffindor', 'Casa de los valientes y osados', '#740001', '/images/gryffindor.png'),
            ('hufflepuff', 'Casa de los leales y trabajadores', '#FFD800', '/images/hufflepuff.png'),
            ('ravenclaw', 'Casa de los sabios e inteligentes', '#0E1A40', '/images/ravenclaw.png'),
            ('slytherin', 'Casa de los astutos y ambiciosos', '#1A472A', '/images/slytherin.png');
            
          -- Allow public read access to houses
          ALTER TABLE houses ENABLE ROW LEVEL SECURITY;
          CREATE POLICY "Anyone can view houses" ON houses FOR SELECT USING (true);
        `
      });

      if (createHousesError) {
        console.error('Error creating houses table:', createHousesError);
      } else {
        console.log('Houses table created successfully!');
      }
    } else {
      console.log('Houses table already exists.');
    }

    console.log('Database setup complete!');
  } catch (error) {
    console.error('Error setting up database:', error);
  }
}

// Run the setup
setupDatabase();