-- Public cached audio is derived only from published location content.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('location-speech', 'location-speech', true, 10485760, array['audio/mpeg'])
on conflict (id) do update set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists location_speech_public_read on storage.objects;
create policy location_speech_public_read on storage.objects for select
using (bucket_id = 'location-speech');

create table if not exists public.location_speech_rate_limits (
  client_hash text not null,
  window_started_at timestamptz not null,
  cache_misses smallint not null default 0,
  primary key (client_hash, window_started_at),
  constraint location_speech_rate_limits_nonnegative
    check (cache_misses >= 0 and cache_misses <= 12)
);
alter table public.location_speech_rate_limits enable row level security;
revoke all on table public.location_speech_rate_limits from anon, authenticated;

create or replace function public.consume_location_speech_cache_miss(
  p_client_hash text,
  p_window_started_at timestamptz,
  p_limit smallint default 12
)
returns boolean
language plpgsql
security definer
set search_path = ''
as $$
declare
  affected_rows integer;
begin
  insert into public.location_speech_rate_limits (
    client_hash, window_started_at, cache_misses
  ) values (p_client_hash, p_window_started_at, 1)
  on conflict (client_hash, window_started_at) do update
    set cache_misses = public.location_speech_rate_limits.cache_misses + 1
    where public.location_speech_rate_limits.cache_misses < p_limit;
  get diagnostics affected_rows = row_count;
  return affected_rows > 0;
end;
$$;
revoke all on function public.consume_location_speech_cache_miss(
  text, timestamptz, smallint
) from public;
grant execute on function public.consume_location_speech_cache_miss(
  text, timestamptz, smallint
) to service_role;
