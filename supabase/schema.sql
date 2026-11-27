-- Run in Supabase SQL Editor. This migration keeps access owner-scoped and requires the email allowlist.
create table if not exists public.tokyo_itinerary (
  owner_id uuid primary key references auth.users(id) on delete cascade,
  itinerary jsonb not null default '[]'::jsonb,
  updated_at timestamptz not null default now()
);

create table if not exists public.tokyo_allowed_emails (
  email text primary key check (email = lower(btrim(email)))
);

alter table public.tokyo_itinerary enable row level security;
revoke all on table public.tokyo_itinerary from anon, authenticated;
grant select, insert, update, delete on table public.tokyo_itinerary to authenticated;

alter table public.tokyo_allowed_emails enable row level security;
revoke all on table public.tokyo_allowed_emails from anon, authenticated;
grant select on table public.tokyo_allowed_emails to authenticated;

drop policy if exists "Owners manage their Tokyo itinerary" on public.tokyo_itinerary;
drop policy if exists "Allowlisted owners manage their Tokyo itinerary" on public.tokyo_itinerary;
drop policy if exists "Users manage own Tokyo itinerary" on public.tokyo_itinerary;
drop policy if exists "Require allowlisted email for Tokyo itinerary" on public.tokyo_itinerary;

create policy "Users manage own Tokyo itinerary"
  on public.tokyo_itinerary
  as permissive
  for all
  to authenticated
  using ((select auth.uid()) = owner_id)
  with check ((select auth.uid()) = owner_id);

create policy "Require allowlisted email for Tokyo itinerary"
  on public.tokyo_itinerary
  as restrictive
  for all
  to authenticated
  using (
    exists (
      select 1 from public.tokyo_allowed_emails allowed
      where allowed.email = lower((select auth.jwt() ->> 'email'))
    )
  )
  with check (
    exists (
      select 1 from public.tokyo_allowed_emails allowed
      where allowed.email = lower((select auth.jwt() ->> 'email'))
    )
  );

drop policy if exists "Users can read their allowlist entry" on public.tokyo_allowed_emails;
create policy "Users can read their allowlist entry"
  on public.tokyo_allowed_emails
  for select
  to authenticated
  using (email = lower((select auth.jwt() ->> 'email')));

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

-- Add approved emails privately in SQL Editor, for example:
-- insert into public.tokyo_allowed_emails(email) values ('owner@example.com') on conflict do nothing;