-- Client Leads table (shared across all EpicLead clients)
-- Run this in Supabase SQL Editor — does NOT touch existing tables

CREATE TABLE IF NOT EXISTS client_leads (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  client_id text NOT NULL DEFAULT 'mike',
  session_id text NOT NULL,
  name text,
  email text,
  phone text,
  service_type text,
  property_type text,
  roof_material text,
  roof_age text,
  timeline text,
  zip_code text,
  status text DEFAULT 'partial',
  source text DEFAULT 'website',
  steps_completed int DEFAULT 0,
  notes text,
  retell_call_id text,
  calendly_event_uri text,
  call_scheduled_at timestamptz,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(client_id, session_id)
);

-- Index for fast lookups
CREATE INDEX IF NOT EXISTS idx_client_leads_client ON client_leads(client_id);
CREATE INDEX IF NOT EXISTS idx_client_leads_session ON client_leads(session_id);
CREATE INDEX IF NOT EXISTS idx_client_leads_status ON client_leads(client_id, status);

-- RLS policies
ALTER TABLE client_leads ENABLE ROW LEVEL SECURITY;

-- Anon can insert and update (for frontend upserts)
CREATE POLICY "anon_insert_client_leads" ON client_leads
  FOR INSERT TO anon WITH CHECK (true);

CREATE POLICY "anon_update_client_leads" ON client_leads
  FOR UPDATE TO anon USING (true) WITH CHECK (true);

-- Service role has full access (for edge functions)
CREATE POLICY "service_role_all_client_leads" ON client_leads
  FOR ALL TO service_role USING (true) WITH CHECK (true);

-- Authenticated users can read (for admin)
CREATE POLICY "authenticated_read_client_leads" ON client_leads
  FOR SELECT TO authenticated USING (true);

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION update_client_leads_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER client_leads_updated_at
  BEFORE UPDATE ON client_leads
  FOR EACH ROW
  EXECUTE FUNCTION update_client_leads_updated_at();
