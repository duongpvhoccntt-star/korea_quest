-- Expose the published revision's WGS84 representative center in public
-- location summaries. Draft coordinate changes remain private until publish.

create or replace function public.list_published_locations_vi()
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(jsonb_agg(
    jsonb_build_object(
      'id', location.id,
      'slug', location.slug,
      'name', revision.name,
      'korean_name', revision.korean_name,
      'english_name', revision.english_name,
      'city', revision.city,
      'region', revision.region,
      'country', revision.country,
      'short_description', revision.short_description,
      'thumbnail_url', coalesce(nullif(revision.thumbnail_url, ''), revision.cover_image_url),
      'thumbnail_alt', coalesce(nullif(revision.thumbnail_alt, ''), revision.cover_image_alt),
      'release_status', revision.release_status,
      'estimated_duration_minutes', revision.estimated_duration_minutes,
      'categories', revision.categories,
      'latitude', revision.latitude,
      'longitude', revision.longitude
    ) order by revision.display_order, revision.name
  ), '[]'::jsonb)
  from public.locations location
  join public.location_revisions revision on revision.location_id = location.id
  where location.archived_at is null
    and revision.status = 'published';
$$;

revoke all on function public.list_published_locations_vi() from public;
