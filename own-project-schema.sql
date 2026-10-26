-- Follow Up: схема за собствения Supabase проект (акаунти само за Follow Up, без връзка с AKTIV90).
-- Същите колони като общите контакти в AKTIV90, за да работи приложението еднакво и в двата случая.
create table if not exists public.contacts (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null default auth.uid() references auth.users(id) on delete cascade,
  name        text not null,
  info        text not null default '',
  note        text not null default '',
  created_day date not null default current_date,
  created_at  timestamptz not null default now(),
  fu_stage    text check (fu_stage in ('prospect','interested','close','client','later','lost')),
  fu_back     text check (fu_back in ('prospect','interested','close')),
  fu_network  text check (fu_network in ('instagram','tiktok','facebook','viber','live')),
  fu_source   text,
  fu_phase    smallint not null default 0 check (fu_phase between 0 and 4),
  fu_next     date,
  fu_last     date,
  fu_msgs     smallint not null default 0 check (fu_msgs between 0 and 99),
  fu_log      jsonb not null default '[]'::jsonb,
  fu_updated  timestamptz
);
alter table public.contacts enable row level security;
create policy contacts_own on public.contacts for all to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create index if not exists contacts_user_idx on public.contacts (user_id, fu_stage);
