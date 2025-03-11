-- Drop existing objects if they exist
DROP TABLE IF EXISTS reports;

-- Create reports table
CREATE TABLE reports (
    id UUID PRIMARY KEY,
    title TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('finance', 'employee', 'stock', 'crop')),
    start_date TIMESTAMPTZ NOT NULL,
    end_date TIMESTAMPTZ NOT NULL,
    filters JSONB DEFAULT '{}'::jsonb,
    chart_type TEXT NOT NULL CHECK (chart_type IN ('bar', 'line', 'pie', 'scatter')),
    data JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    exported_at TIMESTAMPTZ,
    export_format TEXT CHECK (export_format IN ('pdf', 'excel')),
    farmer_id UUID REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Set up Row Level Security (RLS)
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;

-- Create reports policies
CREATE POLICY "Users can view their own reports"
    ON reports FOR SELECT
    USING (auth.uid() = farmer_id);

CREATE POLICY "Users can insert their own reports"
    ON reports FOR INSERT
    WITH CHECK (auth.uid() = farmer_id);

CREATE POLICY "Users can update their own reports"
    ON reports FOR UPDATE
    USING (auth.uid() = farmer_id);

CREATE POLICY "Users can delete their own reports"
    ON reports FOR DELETE
    USING (auth.uid() = farmer_id);

-- Create updated_at trigger
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON reports
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at(); 