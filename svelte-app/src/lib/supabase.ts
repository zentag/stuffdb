import { createClient } from "@supabase/supabase-js";

// Create a single supabase client for interacting with your database
export const supabase = createClient(
  "https://ctawkrjjzlnczvmxniyh.supabase.co",
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN0YXdrcmpqemxuY3p2bXhuaXloIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzk0MDIxMzcsImV4cCI6MjA1NDk3ODEzN30.Ko-mWOkoWCt6Z-mKNdJQzc_2ayp4lI8e0vR5fbs-Xh8",
);

export const auth = supabase.auth;
