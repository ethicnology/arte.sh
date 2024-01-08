# Prepare

## dotenv

**.env** has to be in the same folder as the arte executable (.exe/.sh)
```sh
cp .env.example .env
```

## database

Make postgres **superuser** during migration and then put it back **nosuperuser** in supabase SQL editor
```sql
ALTER ROLE postgres SUPERUSER
-- After migrations make postgres NOSUPERUSER
ALTER ROLE postgres NOSUPERUSER
```

**restore dump** schema and basic data
```sh
psql -h localhost -U postgres -d postgres < migrations/001_schema.sql
psql -h localhost -U postgres -d postgres < migrations/002_data.sql
```

**dump** database `schema only`
```sh
pg_dump -h localhost -U postgres -d postgres -t link --schema-only > migrations/003_table_link.sql
```

**dump** database `data only`
```sh
pg_dump -h localhost -U postgres -n public --data-only > data.sql
```

# Usage
```sh
arte.sh
arte.sh --force
arte.sh --arte 083874-000-A
```

