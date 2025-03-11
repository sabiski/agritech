-- Drop tables if they exist (in reverse order of dependencies)
DROP TABLE IF EXISTS public.stock_movements;
DROP TABLE IF EXISTS public.stock_items;
DROP TABLE IF EXISTS public.reports;
DROP TABLE IF EXISTS public.salary_transactions;
DROP TABLE IF EXISTS public.employee_performances;

-- Create tables
CREATE TABLE public.salary_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    employee_id UUID NOT NULL REFERENCES auth.users(id),
    amount DECIMAL(10, 2) NOT NULL,
    bonus DECIMAL(10, 2),
    bonus_reason TEXT,
    payment_date DATE NOT NULL,
    period VARCHAR(7) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    farmer_id UUID NOT NULL REFERENCES auth.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    CONSTRAINT fk_employee
        FOREIGN KEY (employee_id)
        REFERENCES auth.users(id)
        ON DELETE CASCADE
);

CREATE TABLE public.employee_performances (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    employee_id UUID NOT NULL,
    score DECIMAL(3, 1) NOT NULL,
    tasks_completed INTEGER NOT NULL DEFAULT 0,
    tasks_assigned INTEGER NOT NULL DEFAULT 0,
    notes TEXT,
    date DATE NOT NULL,
    farmer_id UUID NOT NULL REFERENCES auth.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    CONSTRAINT fk_employee
        FOREIGN KEY (employee_id)
        REFERENCES auth.users(id)
        ON DELETE CASCADE
);

-- Create stock_items table
CREATE TABLE public.stock_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    quantity INTEGER NOT NULL DEFAULT 0,
    min_quantity INTEGER NOT NULL DEFAULT 0,
    unit VARCHAR(50) NOT NULL,
    category VARCHAR(100),
    farmer_id UUID NOT NULL REFERENCES auth.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Create stock_movements table
CREATE TABLE public.stock_movements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    stock_item_id UUID NOT NULL REFERENCES public.stock_items(id),
    quantity INTEGER NOT NULL,
    type VARCHAR(50) NOT NULL CHECK (type IN ('in', 'out')),
    date TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    notes TEXT,
    farmer_id UUID NOT NULL REFERENCES auth.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    CONSTRAINT fk_stock_item
        FOREIGN KEY (stock_item_id)
        REFERENCES public.stock_items(id)
        ON DELETE CASCADE
);

-- Create reports table
CREATE TABLE public.reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    type VARCHAR(50) NOT NULL,
    start_date TIMESTAMP WITH TIME ZONE NOT NULL,
    end_date TIMESTAMP WITH TIME ZONE NOT NULL,
    filters JSONB DEFAULT '{}'::jsonb,
    chart_type VARCHAR(50) NOT NULL,
    data JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    exported_at TIMESTAMP WITH TIME ZONE,
    export_format VARCHAR(50),
    farmer_id UUID NOT NULL REFERENCES auth.users(id)
);

-- Create indexes for better performance
CREATE INDEX idx_stock_items_farmer_id ON public.stock_items(farmer_id);
CREATE INDEX idx_stock_movements_farmer_id ON public.stock_movements(farmer_id);
CREATE INDEX idx_stock_movements_stock_item_id ON public.stock_movements(stock_item_id);
CREATE INDEX idx_reports_farmer_id ON public.reports(farmer_id);
CREATE INDEX idx_reports_type ON public.reports(type);
CREATE INDEX idx_reports_created_at ON public.reports(created_at DESC);
CREATE INDEX idx_salary_transactions_employee_id ON public.salary_transactions(employee_id);
CREATE INDEX idx_salary_transactions_farmer_id ON public.salary_transactions(farmer_id);
CREATE INDEX idx_employee_performances_employee_id ON public.employee_performances(employee_id);
CREATE INDEX idx_employee_performances_farmer_id ON public.employee_performances(farmer_id);

-- Enable Row Level Security
ALTER TABLE public.stock_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stock_movements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.salary_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.employee_performances ENABLE ROW LEVEL SECURITY;

-- Create policies for stock_items
CREATE POLICY "Users can view their own stock items"
    ON public.stock_items
    FOR SELECT
    USING (auth.uid() = farmer_id);

CREATE POLICY "Users can insert their own stock items"
    ON public.stock_items
    FOR INSERT
    WITH CHECK (auth.uid() = farmer_id);

CREATE POLICY "Users can update their own stock items"
    ON public.stock_items
    FOR UPDATE
    USING (auth.uid() = farmer_id)
    WITH CHECK (auth.uid() = farmer_id);

CREATE POLICY "Users can delete their own stock items"
    ON public.stock_items
    FOR DELETE
    USING (auth.uid() = farmer_id);

-- Create policies for stock_movements
CREATE POLICY "Users can view their own stock movements"
    ON public.stock_movements
    FOR SELECT
    USING (auth.uid() = farmer_id);

CREATE POLICY "Users can insert their own stock movements"
    ON public.stock_movements
    FOR INSERT
    WITH CHECK (auth.uid() = farmer_id);

CREATE POLICY "Users can update their own stock movements"
    ON public.stock_movements
    FOR UPDATE
    USING (auth.uid() = farmer_id)
    WITH CHECK (auth.uid() = farmer_id);

CREATE POLICY "Users can delete their own stock movements"
    ON public.stock_movements
    FOR DELETE
    USING (auth.uid() = farmer_id);

-- Create policies for reports
CREATE POLICY "Users can view their own reports"
    ON public.reports
    FOR SELECT
    USING (auth.uid() = farmer_id);

CREATE POLICY "Users can insert their own reports"
    ON public.reports
    FOR INSERT
    WITH CHECK (auth.uid() = farmer_id);

CREATE POLICY "Users can update their own reports"
    ON public.reports
    FOR UPDATE
    USING (auth.uid() = farmer_id)
    WITH CHECK (auth.uid() = farmer_id);

CREATE POLICY "Users can delete their own reports"
    ON public.reports
    FOR DELETE
    USING (auth.uid() = farmer_id);

-- Create policies for salary_transactions
CREATE POLICY "Users can view their own salary transactions"
    ON public.salary_transactions
    FOR SELECT
    USING (auth.uid() = farmer_id);

CREATE POLICY "Users can insert their own salary transactions"
    ON public.salary_transactions
    FOR INSERT
    WITH CHECK (auth.uid() = farmer_id);

CREATE POLICY "Users can update their own salary transactions"
    ON public.salary_transactions
    FOR UPDATE
    USING (auth.uid() = farmer_id)
    WITH CHECK (auth.uid() = farmer_id);

CREATE POLICY "Users can delete their own salary transactions"
    ON public.salary_transactions
    FOR DELETE
    USING (auth.uid() = farmer_id);

-- Create policies for employee_performances
CREATE POLICY "Users can view their own employee performances"
    ON public.employee_performances
    FOR SELECT
    USING (auth.uid() = farmer_id);

CREATE POLICY "Users can insert their own employee performances"
    ON public.employee_performances
    FOR INSERT
    WITH CHECK (auth.uid() = farmer_id);

CREATE POLICY "Users can update their own employee performances"
    ON public.employee_performances
    FOR UPDATE
    USING (auth.uid() = farmer_id)
    WITH CHECK (auth.uid() = farmer_id);

CREATE POLICY "Users can delete their own employee performances"
    ON public.employee_performances
    FOR DELETE
    USING (auth.uid() = farmer_id); 