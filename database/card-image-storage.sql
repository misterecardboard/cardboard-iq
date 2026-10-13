-- Run this in Supabase SQL Editor for Cardboard IQ.
-- Adds private image references to each card and creates a private storage bucket.
alter table public.cards
  add column if not exists image_front_path text,
  add column if not exists image_back_path text;

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('card-images', 'card-images', false, 10485760, array['image/jpeg','image/png','image/webp','image/heic','image/heif'])
on conflict (id) do update set public = false;

drop policy if exists "Users can read their own card images" on storage.objects;
create policy "Users can read their own card images"
on storage.objects for select to authenticated
using (bucket_id = 'card-images' and (storage.foldername(name))[1] = auth.uid()::text);

drop policy if exists "Users can upload their own card images" on storage.objects;
create policy "Users can upload their own card images"
on storage.objects for insert to authenticated
with check (bucket_id = 'card-images' and (storage.foldername(name))[1] = auth.uid()::text);

drop policy if exists "Users can update their own card images" on storage.objects;
create policy "Users can update their own card images"
on storage.objects for update to authenticated
using (bucket_id = 'card-images' and (storage.foldername(name))[1] = auth.uid()::text)
with check (bucket_id = 'card-images' and (storage.foldername(name))[1] = auth.uid()::text);

drop policy if exists "Users can delete their own card images" on storage.objects;
create policy "Users can delete their own card images"
on storage.objects for delete to authenticated
using (bucket_id = 'card-images' and (storage.foldername(name))[1] = auth.uid()::text);
