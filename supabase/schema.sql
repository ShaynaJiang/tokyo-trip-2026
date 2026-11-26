-- Run once in Supabase SQL Editor.
create table if not exists public.tokyo_itinerary (
  owner_id uuid primary key references auth.users(id) on delete cascade,
  itinerary jsonb not null default '[]'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.tokyo_itinerary enable row level security;
revoke all on table public.tokyo_itinerary from anon, authenticated;
grant select, insert, update, delete on table public.tokyo_itinerary to authenticated;

drop policy if exists "Owners manage their Tokyo itinerary" on public.tokyo_itinerary;
create policy "Owners manage their Tokyo itinerary"
  on public.tokyo_itinerary
  for all
  to authenticated
  using ((select auth.uid()) = owner_id)
  with check ((select auth.uid()) = owner_id);

do $$
begin
  if not exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    execute 'create publication supabase_realtime';
  end if;
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'tokyo_itinerary'
  ) then
    execute 'alter publication supabase_realtime add table public.tokyo_itinerary';
  end if;
end $$;
