-- Drop existing objects if they exist
DROP TABLE IF EXISTS employees;

-- Create employees table
CREATE TABLE employees (
    id UUID PRIMARY KEY,
    full_name TEXT NOT NULL,
    position TEXT NOT NULL,
    salary DECIMAL(10, 2) NOT NULL,
    phone_number TEXT NOT NULL,
    email TEXT NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('active', 'inactive')),
    start_date TIMESTAMPTZ NOT NULL,
    end_date TIMESTAMPTZ,
    address TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    farmer_id UUID REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Set up Row Level Security (RLS)
ALTER TABLE employees ENABLE ROW LEVEL SECURITY;

-- Create employees policies
CREATE POLICY "Users can view their own employees"
    ON employees FOR SELECT
    USING (auth.uid() = farmer_id);

CREATE POLICY "Users can insert their own employees"
    ON employees FOR INSERT
    WITH CHECK (auth.uid() = farmer_id);

CREATE POLICY "Users can update their own employees"
    ON employees FOR UPDATE
    USING (auth.uid() = farmer_id);

CREATE POLICY "Users can delete their own employees"
    ON employees FOR DELETE
    USING (auth.uid() = farmer_id);

-- Create updated_at trigger
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON employees
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at(); 