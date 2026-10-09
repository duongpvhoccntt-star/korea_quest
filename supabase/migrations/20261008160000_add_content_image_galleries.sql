-- Ordered image galleries for History, Highlights, Experiences and Foods.
-- Existing singular media columns remain as a compatibility projection of
-- the first image (or the single YouTube item for supported content types).

create or replace function private.is_valid_image_gallery(value jsonb)
returns boolean
language sql
immutable
set search_path = ''
as $$
  select case
    when jsonb_typeof(value) is distinct from 'array' then false
    else jsonb_array_length(value) <= 10
      and not exists (
        select 1
        from jsonb_array_elements(value) image
        where jsonb_typeof(image) is distinct from 'object'
          or jsonb_typeof(image -> 'url') is distinct from 'string'
          or jsonb_typeof(image -> 'credit') is distinct from 'string'
          or jsonb_typeof(image -> 'source_url') is distinct from 'string'
          or jsonb_typeof(image -> 'alt') is distinct from 'string'
      )
  end;
$$;

alter table public.location_history
  add column image_gallery jsonb not null default '[]'::jsonb;
alter table public.location_highlights
  add column image_gallery jsonb not null default '[]'::jsonb;
alter table public.location_experiences
  add column image_gallery jsonb not null default '[]'::jsonb;
alter table public.location_foods
  add column image_gallery jsonb not null default '[]'::jsonb;

update public.location_history
set image_gallery = jsonb_build_array(jsonb_build_object(
  'url', media_url,
  'credit', media_credit,
  'source_url', media_source_url,
  'alt', media_alt
))
where media_kind = 'image' and not private.is_blank(media_url);

update public.location_highlights
set image_gallery = jsonb_build_array(jsonb_build_object(
  'url', media_url,
  'credit', media_credit,
  'source_url', media_source_url,
  'alt', media_alt
))
where media_kind = 'image' and not private.is_blank(media_url);

update public.location_experiences
set image_gallery = jsonb_build_array(jsonb_build_object(
  'url', media_url,
  'credit', media_credit,
  'source_url', media_source_url,
  'alt', media_alt
))
where media_kind = 'image' and not private.is_blank(media_url);

update public.location_foods
set image_gallery = jsonb_build_array(jsonb_build_object(
  'url', image_url,
  'credit', image_credit,
  'source_url', image_source_url,
  'alt', image_alt
))
where not private.is_blank(image_url);

alter table public.location_history
  add constraint location_history_image_gallery_check
  check (private.is_valid_image_gallery(image_gallery));
alter table public.location_highlights
  add constraint location_highlights_image_gallery_check
  check (private.is_valid_image_gallery(image_gallery));
alter table public.location_experiences
  add constraint location_experiences_image_gallery_check
  check (private.is_valid_image_gallery(image_gallery));
alter table public.location_foods
  add constraint location_foods_image_gallery_check
  check (private.is_valid_image_gallery(image_gallery));

create or replace function private.normalized_image_gallery(
  item jsonb,
  legacy_prefix text
)
returns jsonb
language sql
immutable
set search_path = ''
as $$
  select case
    when item ? 'image_gallery' then coalesce(item -> 'image_gallery', '[]'::jsonb)
    when coalesce(item ->> (legacy_prefix || '_url'), '') <> '' then
      jsonb_build_array(jsonb_build_object(
        'url', coalesce(item ->> (legacy_prefix || '_url'), ''),
        'credit', coalesce(item ->> (legacy_prefix || '_credit'), ''),
        'source_url', coalesce(item ->> (legacy_prefix || '_source_url'), ''),
        'alt', coalesce(item ->> (legacy_prefix || '_alt'), '')
      ))
    else '[]'::jsonb
  end;
$$;

create or replace function private.public_content_media(
  media_kind text,
  legacy_url text,
  legacy_credit text,
  legacy_source_url text,
  legacy_alt text,
  gallery jsonb
)
returns jsonb
language plpgsql
immutable
set search_path = ''
as $$
declare
  active_gallery jsonb := '[]'::jsonb;
  primary_image jsonb := '{}'::jsonb;
begin
  if media_kind = 'image' then
    active_gallery := case
      when jsonb_typeof(gallery) = 'array' and jsonb_array_length(gallery) > 0
        then gallery
      when coalesce(legacy_url, '') <> ''
        then jsonb_build_array(jsonb_build_object(
          'url', coalesce(legacy_url, ''),
          'credit', coalesce(legacy_credit, ''),
          'source_url', coalesce(legacy_source_url, ''),
          'alt', coalesce(legacy_alt, '')
        ))
      else '[]'::jsonb
    end;
    primary_image := coalesce(active_gallery -> 0, '{}'::jsonb);
    return jsonb_build_object(
      'kind', 'image',
      'url', coalesce(primary_image ->> 'url', ''),
      'credit', coalesce(primary_image ->> 'credit', ''),
      'source_url', coalesce(primary_image ->> 'source_url', ''),
      'alt', coalesce(primary_image ->> 'alt', ''),
      'images', active_gallery
    );
  end if;

  return jsonb_build_object(
    'kind', media_kind,
    'url', coalesce(legacy_url, ''),
    'credit', coalesce(legacy_credit, ''),
    'source_url', coalesce(legacy_source_url, ''),
    'alt', coalesce(legacy_alt, ''),
    'images', '[]'::jsonb
  );
end;
$$;

create or replace function public.save_location_section_with_galleries(
  revision_id uuid,
  expected_lock_version integer,
  section_name text,
  items jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  result jsonb;
  item jsonb;
  item_order integer := 0;
  gallery jsonb;
begin
  result := public.save_location_section(
    revision_id,
    expected_lock_version,
    section_name,
    items
  );

  if section_name = 'history' then
    for item in select value from jsonb_array_elements(coalesce(items, '[]'::jsonb))
    loop
      gallery := private.normalized_image_gallery(item, 'media');
      update public.location_history
      set image_gallery = gallery,
          media_url = case when media_kind = 'image' then coalesce(gallery -> 0 ->> 'url', '') else media_url end,
          media_credit = case when media_kind = 'image' then coalesce(gallery -> 0 ->> 'credit', '') else media_credit end,
          media_source_url = case when media_kind = 'image' then coalesce(gallery -> 0 ->> 'source_url', '') else media_source_url end,
          media_alt = case when media_kind = 'image' then coalesce(gallery -> 0 ->> 'alt', '') else media_alt end
      where location_history.revision_id = save_location_section_with_galleries.revision_id
        and display_order = item_order;
      item_order := item_order + 1;
    end loop;
  elsif section_name = 'highlights' then
    for item in select value from jsonb_array_elements(coalesce(items, '[]'::jsonb))
    loop
      gallery := private.normalized_image_gallery(item, 'media');
      update public.location_highlights
      set image_gallery = gallery,
          media_url = case when media_kind = 'image' then coalesce(gallery -> 0 ->> 'url', '') else media_url end,
          media_credit = case when media_kind = 'image' then coalesce(gallery -> 0 ->> 'credit', '') else media_credit end,
          media_source_url = case when media_kind = 'image' then coalesce(gallery -> 0 ->> 'source_url', '') else media_source_url end,
          media_alt = case when media_kind = 'image' then coalesce(gallery -> 0 ->> 'alt', '') else media_alt end
      where location_highlights.revision_id = save_location_section_with_galleries.revision_id
        and display_order = item_order;
      item_order := item_order + 1;
    end loop;
  elsif section_name = 'experiences' then
    for item in select value from jsonb_array_elements(coalesce(items, '[]'::jsonb))
    loop
      gallery := private.normalized_image_gallery(item, 'media');
      update public.location_experiences
      set image_gallery = gallery,
          media_url = case when media_kind = 'image' then coalesce(gallery -> 0 ->> 'url', '') else media_url end,
          media_credit = case when media_kind = 'image' then coalesce(gallery -> 0 ->> 'credit', '') else media_credit end,
          media_source_url = case when media_kind = 'image' then coalesce(gallery -> 0 ->> 'source_url', '') else media_source_url end,
          media_alt = case when media_kind = 'image' then coalesce(gallery -> 0 ->> 'alt', '') else media_alt end
      where location_experiences.revision_id = save_location_section_with_galleries.revision_id
        and display_order = item_order;
      item_order := item_order + 1;
    end loop;
  elsif section_name = 'foods' then
    for item in select value from jsonb_array_elements(coalesce(items, '[]'::jsonb))
    loop
      gallery := private.normalized_image_gallery(item, 'image');
      update public.location_foods
      set image_gallery = gallery,
          image_url = coalesce(gallery -> 0 ->> 'url', ''),
          image_credit = coalesce(gallery -> 0 ->> 'credit', ''),
          image_source_url = coalesce(gallery -> 0 ->> 'source_url', ''),
          image_alt = coalesce(gallery -> 0 ->> 'alt', '')
      where location_foods.revision_id = save_location_section_with_galleries.revision_id
        and display_order = item_order;
      item_order := item_order + 1;
    end loop;
  end if;

  return result;
end;
$$;

revoke all on function public.save_location_section_with_galleries(uuid, integer, text, jsonb) from public;
grant execute on function public.save_location_section_with_galleries(uuid, integer, text, jsonb) to authenticated;

create or replace function private.copy_content_image_galleries()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.base_revision_id is null then
    return null;
  end if;

  update public.location_history target
  set image_gallery = source.image_gallery
  from public.location_history source
  where target.revision_id = new.id
    and source.revision_id = new.base_revision_id
    and target.display_order = source.display_order;

  update public.location_highlights target
  set image_gallery = source.image_gallery
  from public.location_highlights source
  where target.revision_id = new.id
    and source.revision_id = new.base_revision_id
    and target.display_order = source.display_order;

  update public.location_experiences target
  set image_gallery = source.image_gallery
  from public.location_experiences source
  where target.revision_id = new.id
    and source.revision_id = new.base_revision_id
    and target.display_order = source.display_order;

  update public.location_foods target
  set image_gallery = source.image_gallery
  from public.location_foods source
  where target.revision_id = new.id
    and source.revision_id = new.base_revision_id
    and target.display_order = source.display_order;

  return null;
end;
$$;

create constraint trigger copy_content_image_galleries
after insert on public.location_revisions
deferrable initially deferred
for each row
execute function private.copy_content_image_galleries();

create or replace function private.content_image_gallery_errors(target_revision_id uuid)
returns text[]
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  errors text[] := '{}';
begin
  if exists (
    select 1
    from public.location_history item
    cross join lateral jsonb_array_elements(item.image_gallery) image
    where item.revision_id = target_revision_id
      and item.is_visible
      and not private.is_http_url(image ->> 'url')
  ) then
    errors := array_append(errors, 'Thư viện ảnh Lịch sử có URL ảnh không hợp lệ.');
  end if;

  if exists (
    select 1
    from public.location_highlights item
    cross join lateral jsonb_array_elements(item.image_gallery) image
    where item.revision_id = target_revision_id
      and item.is_visible
      and not private.is_http_url(image ->> 'url')
  ) then
    errors := array_append(errors, 'Thư viện ảnh Điểm đến có URL ảnh không hợp lệ.');
  end if;

  if exists (
    select 1
    from public.location_experiences item
    cross join lateral jsonb_array_elements(item.image_gallery) image
    where item.revision_id = target_revision_id
      and item.is_visible
      and not private.is_http_url(image ->> 'url')
  ) then
    errors := array_append(errors, 'Thư viện ảnh Trải nghiệm có URL ảnh không hợp lệ.');
  end if;

  if exists (
    select 1
    from public.location_foods item
    cross join lateral jsonb_array_elements(item.image_gallery) image
    where item.revision_id = target_revision_id
      and item.is_visible
      and not private.is_http_url(image ->> 'url')
  ) then
    errors := array_append(errors, 'Thư viện ảnh Ẩm thực có URL ảnh không hợp lệ.');
  end if;

  return errors;
end;
$$;

create or replace function public.validate_location_revision_with_galleries(revision_id uuid)
returns text[]
language plpgsql
security definer
set search_path = ''
as $$
begin
  perform private.assert_admin();
  return public.validate_location_revision(revision_id)
    || private.content_image_gallery_errors(revision_id);
end;
$$;

revoke all on function public.validate_location_revision_with_galleries(uuid) from public;
grant execute on function public.validate_location_revision_with_galleries(uuid) to authenticated;

create or replace function public.publish_location_revision(
  revision_id uuid,
  expected_lock_version integer
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  validation_errors text[];
  target_location_id uuid;
begin
  perform private.lock_draft(revision_id, expected_lock_version);
  validation_errors := public.validate_location_revision_with_galleries(revision_id);

  if cardinality(validation_errors) > 0 then
    raise exception '%', array_to_string(validation_errors, ' | ')
      using errcode = '22023';
  end if;

  select location_id into target_location_id
  from public.location_revisions
  where id = revision_id;

  update public.location_revisions
  set status = 'archived', updated_at = now(), updated_by = auth.uid()
  where location_id = target_location_id and status = 'published';

  update public.location_revisions
  set status = 'published', updated_at = now(), updated_by = auth.uid()
  where id = revision_id;

  update public.locations set archived_at = null where id = target_location_id;

  return jsonb_build_object(
    'location_id', target_location_id,
    'revision_id', revision_id,
    'status', 'published'
  );
end;
$$;

create or replace function private.with_content_image_galleries(base jsonb)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  result jsonb := base;
begin
  if base is null then
    return null;
  end if;

  result := jsonb_set(result, '{history}', coalesce((
    select jsonb_agg(entry.value || jsonb_build_object(
      'media', private.public_content_media(
        item.media_kind::text, item.media_url, item.media_credit,
        item.media_source_url, item.media_alt, item.image_gallery
      )
    ) order by entry.ordinality)
    from jsonb_array_elements(result -> 'history') with ordinality entry(value, ordinality)
    join public.location_history item on item.id = (entry.value ->> 'id')::uuid
  ), '[]'::jsonb));

  result := jsonb_set(result, '{highlights}', coalesce((
    select jsonb_agg(entry.value || jsonb_build_object(
      'media', private.public_content_media(
        item.media_kind::text, item.media_url, item.media_credit,
        item.media_source_url, item.media_alt, item.image_gallery
      )
    ) order by entry.ordinality)
    from jsonb_array_elements(result -> 'highlights') with ordinality entry(value, ordinality)
    join public.location_highlights item on item.id = (entry.value ->> 'id')::uuid
  ), '[]'::jsonb));

  result := jsonb_set(result, '{experiences}', coalesce((
    select jsonb_agg(entry.value || jsonb_build_object(
      'media', private.public_content_media(
        item.media_kind::text, item.media_url, item.media_credit,
        item.media_source_url, item.media_alt, item.image_gallery
      )
    ) order by entry.ordinality)
    from jsonb_array_elements(result -> 'experiences') with ordinality entry(value, ordinality)
    join public.location_experiences item on item.id = (entry.value ->> 'id')::uuid
  ), '[]'::jsonb));

  result := jsonb_set(result, '{foods}', coalesce((
    select jsonb_agg(entry.value || jsonb_build_object(
      'media', private.public_content_media(
        'image', item.image_url, item.image_credit,
        item.image_source_url, item.image_alt, item.image_gallery
      )
    ) order by entry.ordinality)
    from jsonb_array_elements(result -> 'foods') with ordinality entry(value, ordinality)
    join public.location_foods item on item.id = (entry.value ->> 'id')::uuid
  ), '[]'::jsonb));

  return result;
end;
$$;

create or replace function public.get_published_location(
  target_slug text,
  requested_locale text default 'vi'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  normalized_locale text := case when requested_locale in ('vi', 'en', 'ko')
    then requested_locale else 'vi' end;
  base jsonb;
  localized jsonb;
begin
  base := private.with_content_image_galleries(
    public.get_published_location_vi(target_slug)
  );
  if base is null then return null; end if;

  if normalized_locale <> 'vi' then
    select translation.content -> 'detail' into localized
    from public.location_revision_translations translation
    where translation.revision_id = (base ->> 'revision_id')::uuid
      and translation.locale::text = normalized_locale
      and translation.status = 'approved';
  end if;

  return private.jsonb_deep_merge(base, coalesce(localized, '{}'::jsonb))
    || jsonb_build_object(
      'requested_locale', normalized_locale,
      'resolved_locale', case when localized is null then 'vi' else normalized_locale end,
      'is_fallback', normalized_locale <> 'vi' and localized is null
    );
end;
$$;
