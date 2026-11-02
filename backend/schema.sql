begin;
create table public.tidalis_admins (user_id uuid primary key references auth.users(id) on delete cascade);
alter table public.tidalis_admins enable row level security;
grant select on public.tidalis_admins to authenticated;
create policy own_membership on public.tidalis_admins for select to authenticated using(user_id=(select auth.uid()));
create table public.tidalis_content (
 id uuid primary key default gen_random_uuid(),
 kind text not null check(kind in ('page','service','talent','work','news')),
 slug text not null unique check(length(slug) between 1 and 150),
 title_th text not null default '' check(length(title_th)<=300), title_en text not null default '' check(length(title_en)<=300),
 body_th text not null default '' check(length(body_th)<=20000), body_en text not null default '' check(length(body_en)<=20000),
 image_url text not null default '' check(image_url='' or image_url like 'https://%'), link_url text not null default '' check(link_url='' or link_url like 'https://%'),
 published boolean not null default false, sort_order integer not null default 0,
 updated_at timestamptz not null default now()
);
alter table public.tidalis_content enable row level security;
grant select on public.tidalis_content to anon,authenticated;
grant insert,update,delete on public.tidalis_content to authenticated;
create policy public_content on public.tidalis_content for select to anon,authenticated using(published);
create policy admin_content on public.tidalis_content for all to authenticated using(exists(select 1 from public.tidalis_admins where user_id=(select auth.uid()))) with check(exists(select 1 from public.tidalis_admins where user_id=(select auth.uid())));
create table public.tidalis_messages (
 id uuid primary key default gen_random_uuid(), name text not null check(length(name) between 1 and 150),
 email text not null check(length(email) between 3 and 254 and email like '%@%.%'), interest text not null check(interest in ('production','talent','collaboration')),
 details text not null check(length(details) between 1 and 5000), status text not null default 'new' check(status in ('new','read','closed')),
 created_at timestamptz not null default now()
);
alter table public.tidalis_messages enable row level security;
grant insert(name,email,interest,details) on public.tidalis_messages to anon,authenticated;
grant select,update,delete on public.tidalis_messages to authenticated;
create policy submit_message on public.tidalis_messages for insert to anon,authenticated with check(status='new');
create policy manage_messages on public.tidalis_messages for all to authenticated using(exists(select 1 from public.tidalis_admins where user_id=(select auth.uid()))) with check(exists(select 1 from public.tidalis_admins where user_id=(select auth.uid())));
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types) values('tidalis-media','tidalis-media',true,5242880,array['image/jpeg','image/png','image/webp']);
create policy admin_media on storage.objects for all to authenticated using(bucket_id='tidalis-media' and exists(select 1 from public.tidalis_admins where user_id=(select auth.uid()))) with check(bucket_id='tidalis-media' and exists(select 1 from public.tidalis_admins where user_id=(select auth.uid())));
commit;
revoke all on public.tidalis_admins, public.tidalis_content, public.tidalis_messages from anon, authenticated;
grant select on public.tidalis_admins to authenticated;
grant select on public.tidalis_content to anon, authenticated;
grant insert,update,delete on public.tidalis_content to authenticated;
grant insert(name,email,interest,details) on public.tidalis_messages to anon, authenticated;
grant select,update,delete on public.tidalis_messages to authenticated;
