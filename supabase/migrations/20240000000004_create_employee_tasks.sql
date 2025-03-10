-- Drop existing objects if they exist
DROP TABLE IF EXISTS employee_tasks;

-- Create employee_tasks table
CREATE TABLE employee_tasks (
    id UUID PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    due_date TIMESTAMPTZ NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('pending', 'inProgress', 'completed', 'overdue')),
    priority TEXT NOT NULL CHECK (priority IN ('low', 'medium', 'high')),
    employee_id UUID REFERENCES employees(id) ON DELETE CASCADE,
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Set up Row Level Security (RLS)
ALTER TABLE employee_tasks ENABLE ROW LEVEL SECURITY;

-- Create employee_tasks policies
CREATE POLICY "Users can view their employees' tasks"
    ON employee_tasks FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM employees
            WHERE employees.id = employee_tasks.employee_id
            AND employees.farmer_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert tasks for their employees"
    ON employee_tasks FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM employees
            WHERE employees.id = employee_tasks.employee_id
            AND employees.farmer_id = auth.uid()
        )
    );

CREATE POLICY "Users can update their employees' tasks"
    ON employee_tasks FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM employees
            WHERE employees.id = employee_tasks.employee_id
            AND employees.farmer_id = auth.uid()
        )
    );

CREATE POLICY "Users can delete their employees' tasks"
    ON employee_tasks FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM employees
            WHERE employees.id = employee_tasks.employee_id
            AND employees.farmer_id = auth.uid()
        )
    );

-- Create updated_at trigger
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON employee_tasks
    FOR EACH ROW
    EXECUTE FUNCTION handle_updated_at(); 