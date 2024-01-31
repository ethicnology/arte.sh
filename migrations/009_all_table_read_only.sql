DO $$ 
DECLARE
    current_table text;
BEGIN
    FOR current_table IN (SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE') 
    LOOP
        -- Enable Row-Level Security
        EXECUTE 'ALTER TABLE public.' || current_table || ' ENABLE ROW LEVEL SECURITY';

        -- Force Row-Level Security
        EXECUTE 'ALTER TABLE public.' || current_table || ' FORCE ROW LEVEL SECURITY';

        -- Create Policy for Read Access
        EXECUTE 'CREATE POLICY enable_read_access_policy ON public.' || current_table || ' AS PERMISSIVE FOR SELECT TO anon USING (true)';
    END LOOP;
END $$;
