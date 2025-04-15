grant create on schema public to authenticated;

create or replace function get_cols (tablename text) returns table (name text, type text) language sql as $$
select column_name, data_type 
from information_schema.columns
where table_name = tablename and table_schema = 'public';
$$;

create or replace function create_table (name text) returns void language plpgsql as $$
begin
execute format('create table %s (id uuid primary key default uuid_generate_v4());', name);
execute format('alter table %s enable row level security;', name);
execute format('create policy "enable insert for authenticated users only" on %s to authenticated with check ( true );', name);
end;
$$;

create or replace function create_column (tablename text, name text, datatype text) returns void language plpgsql as $$
begin
execute format('alter table %s add %2$s %3$s;', tablename, name, datatype);
end;
$$;

create or replace function list_tables () returns table (schemaname text, tablename text) as $$
  select schemaname, tablename from pg_catalog.pg_tables
  where schemaname='public';
$$ language sql;
