begin;

create extension if not exists pgtap with schema extensions;

select plan(7);

select has_table(
  'public',
  'location_speech_rate_limits',
  'speech cache miss rate-limit table exists'
);
select has_column(
  'public',
  'location_speech_rate_limits',
  'client_hash',
  'rate limit stores only a hash of the client IP'
);
select has_function(
  'public',
  'consume_location_speech_cache_miss',
  array['text', 'timestamp with time zone', 'smallint'],
  'atomic cache miss limiter RPC exists'
);
select ok(
  not has_table_privilege(
    'anon',
    'public.location_speech_rate_limits',
    'select'
  ),
  'anon cannot read rate-limit records'
);
select ok(
  not has_table_privilege(
    'authenticated',
    'public.location_speech_rate_limits',
    'insert'
  ),
  'authenticated users cannot write rate-limit records'
);
select ok(
  exists (
    select 1
    from storage.buckets
    where id = 'location-speech'
      and public
      and 'audio/mpeg' = any(allowed_mime_types)
  ),
  'location speech bucket is public read-only MP3 storage'
);
select ok(
  exists (
    select 1
    from pg_policies
    where schemaname = 'storage'
      and tablename = 'objects'
      and policyname = 'location_speech_public_read'
      and cmd = 'SELECT'
  ),
  'location speech bucket has a public read policy'
);

select * from finish();

rollback;
