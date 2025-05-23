/*
  # Initial Schema Setup for Gospel Mission Website

  1. New Tables
    - events
      - id (uuid, primary key)
      - title (text)
      - description (text)
      - date (timestamptz)
      - location (text)
      - image_url (text, optional)
      - video_url (text, optional)
      - type (text: past, current, future)
      - created_at (timestamptz)
    
    - prayer_requests
      - id (uuid, primary key)
      - name (text)
      - email (text)
      - request (text)
      - created_at (timestamptz)
    
    - volunteers
      - id (uuid, primary key)
      - name (text)
      - email (text)
      - phone (text)
      - unit (text)
      - message (text)
      - created_at (timestamptz)
    
    - soul_count
      - id (uuid, primary key)
      - count (integer)
      - last_updated (timestamptz)

  2. Security
    - Enable RLS on all tables
    - Add policies for authenticated users
*/

-- Events Table
CREATE TABLE IF NOT EXISTS events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text NOT NULL,
  date timestamptz NOT NULL,
  location text NOT NULL,
  image_url text,
  video_url text,
  type text NOT NULL CHECK (type IN ('past', 'current', 'future')),
  created_at timestamptz DEFAULT now()
);

ALTER TABLE events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view events"
  ON events
  FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Only admins can modify events"
  ON events
  FOR ALL
  TO authenticated
  USING (auth.role() = 'admin');

-- Function to Insert Event
CREATE OR REPLACE FUNCTION insert_event(
  p_title text,
  p_description text,
  p_date timestamptz,
  p_location text,
  p_image_url text,
  p_video_url text,
  p_type text
) RETURNS void AS $$
BEGIN
  INSERT INTO events (title, description, date, location, image_url, video_url, type)
  VALUES (p_title, p_description, p_date, p_location, p_image_url, p_video_url, p_type);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Fetch Events Function
CREATE OR REPLACE FUNCTION get_events()
RETURNS TABLE (
  id uuid,
  title text,
  description text,
  date timestamptz,
  location text,
  image_url text,
  video_url text,
  type text,
  created_at timestamptz
) AS $$
BEGIN
  RETURN QUERY SELECT * FROM events;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Prayer Requests Table
CREATE TABLE IF NOT EXISTS prayer_requests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  email text NOT NULL,
  request text NOT NULL,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE prayer_requests ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can submit prayer requests"
  ON prayer_requests
  FOR INSERT
  TO public
  WITH CHECK (true);

CREATE POLICY "Only admins can view prayer requests"
  ON prayer_requests
  FOR SELECT
  TO authenticated
  USING (auth.role() = 'admin');

-- Volunteers Table
CREATE TABLE IF NOT EXISTS volunteers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  email text NOT NULL,
  phone text NOT NULL,
  unit text NOT NULL,
  message text,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE volunteers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can submit volunteer applications"
  ON volunteers
  FOR INSERT
  TO public
  WITH CHECK (true);

CREATE POLICY "Only admins can view volunteers"
  ON volunteers
  FOR SELECT
  TO authenticated
  USING (auth.role() = 'admin');

-- Soul Count Table
CREATE TABLE IF NOT EXISTS soul_count (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  count integer NOT NULL DEFAULT 0,
  last_updated timestamptz DEFAULT now()
);

ALTER TABLE soul_count ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view soul count"
  ON soul_count
  FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Only admins can update soul count"
  ON soul_count
  FOR ALL
  TO authenticated
  USING (auth.role() = 'admin');

-- Insert initial soul count
INSERT INTO soul_count (count) VALUES (0);
