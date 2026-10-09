-- Remove progress-based access gates while preserving editorial release state,
-- explorer progress, and earned rewards.

-- Preserve historical Fun Fact activity as ordinary content views before the
-- unlock-specific table is removed. Existing view rows keep the earliest time.
insert into public.explorer_content_views (
  user_id,
  revision_id,
  kind,
  content_id,
  first_viewed_at
)
select
  unlock.user_id,
  fact.revision_id,
  'fun_fact'::public.content_view_kind,
  unlock.fun_fact_id,
  coalesce(unlock.read_at, unlock.unlocked_at)
from public.explorer_fun_fact_unlocks unlock
join public.location_fun_facts fact on fact.id = unlock.fun_fact_id
on conflict (user_id, kind, content_id) do update
set first_viewed_at = least(
  public.explorer_content_views.first_viewed_at,
  excluded.first_viewed_at
);

-- Unlock-based goals become view-based goals for the same Fun Fact content.
-- The criteria immutability trigger is disabled only for this one-time semantic
-- migration and is restored immediately afterwards.
alter table public.achievement_definitions
  disable trigger achievement_definitions_lock_awarded_criteria;

update public.achievement_definitions
set metric = 'content_views',
    criteria_filter = coalesce(criteria_filter, '{}'::jsonb)
      || jsonb_build_object('kind', 'fun_fact'),
    updated_at = now()
where metric = 'unlocked_fun_facts';

alter table public.achievement_definitions
  enable trigger achievement_definitions_lock_awarded_criteria;

update public.challenge_goals
set metric = 'content_views',
    criteria_filter = coalesce(criteria_filter, '{}'::jsonb)
      || jsonb_build_object('kind', 'fun_fact')
where metric = 'unlocked_fun_facts';

-- All stages are available from the start. Progress now records only whether a
-- stage has not started, is in progress, or is completed.
create type public.stage_progress_status_without_locks as enum (
  'not_started',
  'in_progress',
  'completed'
);

alter table public.explorer_stage_progress
  alter column status drop default;

alter table public.explorer_stage_progress
  alter column status type public.stage_progress_status_without_locks
  using (
    case status::text
      when 'in_progress' then 'in_progress'
      when 'completed' then 'completed'
      else 'not_started'
    end
  )::public.stage_progress_status_without_locks;

drop type public.stage_progress_status;
alter type public.stage_progress_status_without_locks
  rename to stage_progress_status;

alter table public.explorer_stage_progress
  alter column status set default 'not_started';

-- Raw public content policies use this helper. Coming-soon revisions remain
-- discoverable through the summary RPC but their detail rows are not readable.
create or replace function public.can_read_revision(target_revision_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.location_revisions revision
    join public.locations location on location.id = revision.location_id
    where revision.id = target_revision_id
      and revision.status = 'published'
      and revision.release_status = 'released'
      and location.archived_at is null
  );
$$;

-- The Vietnamese base read model is replaced before dropping Fun Fact gating
-- metadata. The locale-aware public wrapper continues to call this function.
create or replace function public.get_published_location_vi(target_slug text)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select jsonb_build_object(
    'id', location.id,
    'revision_id', revision.id,
    'slug', location.slug,
    'name', revision.name,
    'korean_name', revision.korean_name,
    'english_name', revision.english_name,
    'city', revision.city,
    'region', revision.region,
    'country', revision.country,
    'location_type', revision.location_type,
    'latitude', revision.latitude,
    'longitude', revision.longitude,
    'short_description', revision.short_description,
    'long_description', revision.long_description,
    'cover_media', jsonb_build_object(
      'kind', 'image', 'url', revision.cover_image_url,
      'credit', revision.cover_image_credit,
      'source_url', revision.cover_image_source_url,
      'alt', revision.cover_image_alt
    ),
    'hook_media', jsonb_build_object(
      'kind', revision.hook_media_kind, 'url', revision.hook_media_url,
      'credit', revision.hook_media_credit,
      'source_url', revision.hook_media_source_url,
      'alt', revision.hook_media_alt, 'title', revision.hook_title,
      'caption', revision.hook_caption
    ),
    'tags', revision.tags,
    'categories', revision.categories,
    'release_status', revision.release_status,
    'estimated_duration_minutes', revision.estimated_duration_minutes,
    'quick_facts', coalesce((select jsonb_agg(jsonb_build_object(
      'id', item.id, 'label', item.label, 'value', item.value,
      'display_order', item.display_order
    ) order by item.display_order) from public.location_quick_facts item
      where item.revision_id = revision.id and item.is_visible), '[]'::jsonb),
    'history', coalesce((select jsonb_agg(jsonb_build_object(
      'id', item.id, 'period_label', item.period_label, 'title', item.title,
      'short_description', item.short_description, 'long_description', item.long_description,
      'related_people', item.related_people, 'categories', item.categories,
      'fun_fact', item.fun_fact, 'media', jsonb_build_object(
        'kind', item.media_kind, 'url', item.media_url, 'credit', item.media_credit,
        'source_url', item.media_source_url, 'alt', item.media_alt
      ), 'display_order', item.display_order
    ) order by item.display_order) from public.location_history item
      where item.revision_id = revision.id and item.is_visible), '[]'::jsonb),
    'highlights', coalesce((select jsonb_agg(jsonb_build_object(
      'id', item.id, 'name', item.name, 'korean_name', item.korean_name,
      'tagline', item.tagline, 'short_description', item.short_description,
      'long_description', item.long_description, 'address', item.address,
      'activities', item.activities, 'categories', item.categories, 'fun_fact', item.fun_fact,
      'media', jsonb_build_object('kind', item.media_kind, 'url', item.media_url,
        'credit', item.media_credit, 'source_url', item.media_source_url, 'alt', item.media_alt),
      'display_order', item.display_order
    ) order by item.display_order) from public.location_highlights item
      where item.revision_id = revision.id and item.is_visible), '[]'::jsonb),
    'experiences', coalesce((select jsonb_agg(jsonb_build_object(
      'id', item.id, 'name', item.name, 'korean_name', item.korean_name,
      'short_description', item.short_description, 'long_description', item.long_description,
      'origin_meaning', item.origin_meaning, 'recognizable_features', item.recognizable_features,
      'dos', item.dos, 'donts', item.donts, 'related_experience', item.related_experience,
      'media', jsonb_build_object('kind', item.media_kind, 'url', item.media_url,
        'credit', item.media_credit, 'source_url', item.media_source_url, 'alt', item.media_alt),
      'display_order', item.display_order
    ) order by item.display_order) from public.location_experiences item
      where item.revision_id = revision.id and item.is_visible), '[]'::jsonb),
    'culture_guidelines', coalesce((select jsonb_agg(jsonb_build_object(
      'id', item.id, 'kind', item.kind, 'content', item.content, 'display_order', item.display_order
    ) order by item.kind, item.display_order) from public.location_culture_guidelines item
      where item.revision_id = revision.id and item.is_visible), '[]'::jsonb),
    'foods', coalesce((select jsonb_agg(jsonb_build_object(
      'id', item.id, 'name', item.name, 'korean_name', item.korean_name,
      'short_description', item.short_description, 'long_description', item.long_description,
      'ingredients', item.ingredients, 'flavors', item.flavors,
      'special_feature', item.special_feature, 'experience_places', item.experience_places,
      'media', jsonb_build_object('kind', 'image', 'url', item.image_url,
        'credit', item.image_credit, 'source_url', item.image_source_url, 'alt', item.image_alt),
      'display_order', item.display_order
    ) order by item.display_order) from public.location_foods item
      where item.revision_id = revision.id and item.is_visible), '[]'::jsonb),
    'fun_facts', coalesce((select jsonb_agg(jsonb_build_object(
      'id', item.id, 'title', item.title, 'fact', item.fact, 'category', item.category,
      'icon_name', item.icon_name,
      'media', jsonb_build_object('kind', item.media_kind, 'url', item.media_url,
        'credit', item.media_credit, 'source_url', item.media_source_url, 'alt', item.media_alt),
      'display_order', item.display_order
    ) order by item.display_order) from public.location_fun_facts item
      where item.revision_id = revision.id and item.is_visible), '[]'::jsonb),
    'travel', jsonb_build_object(
      'opening_hours', revision.opening_hours, 'ticket_price', revision.ticket_price,
      'recommended_duration', revision.recommended_duration,
      'best_time_to_visit', revision.best_time_to_visit,
      'accessibility_info', revision.accessibility_info,
      'official_source_url', revision.travel_official_source_url,
      'last_verified_at', revision.travel_last_verified_at,
      'transport_options', coalesce((select jsonb_agg(jsonb_build_object(
        'id', item.id, 'mode', item.mode, 'title', item.title,
        'instructions', item.instructions, 'tip', item.tip,
        'is_recommended', item.is_recommended, 'display_order', item.display_order
      ) order by item.display_order) from public.location_transport_options item
        where item.revision_id = revision.id and item.is_visible), '[]'::jsonb),
      'visitor_notes', coalesce((select jsonb_agg(jsonb_build_object(
        'id', item.id, 'content', item.content, 'display_order', item.display_order
      ) order by item.display_order) from public.location_visitor_notes item
        where item.revision_id = revision.id and item.is_visible), '[]'::jsonb)
    ),
    'quiz', coalesce((select jsonb_agg(jsonb_build_object(
      'id', question.id, 'kind', question.kind, 'prompt', question.prompt,
      'explanation', question.explanation, 'media', case when question.media_url is null then null else
        jsonb_build_object('kind', question.media_kind, 'url', question.media_url,
          'credit', question.media_credit, 'source_url', question.media_source_url, 'alt', question.media_alt) end,
      'options', coalesce((select jsonb_agg(jsonb_build_object('id', option.id, 'text', option.option_text)
        order by option.display_order) from public.quiz_options option where option.question_id = question.id), '[]'::jsonb),
      'matching_left', coalesce((select jsonb_agg(jsonb_build_object('id', pair.id, 'text', pair.left_text)
        order by pair.display_order) from public.quiz_matching_pairs pair where pair.question_id = question.id), '[]'::jsonb),
      'matching_right', coalesce((select jsonb_agg(jsonb_build_object('text', pair.right_text)
        order by md5(pair.id::text)) from public.quiz_matching_pairs pair where pair.question_id = question.id), '[]'::jsonb),
      'ordering_items', coalesce((select jsonb_agg(jsonb_build_object('id', item.id, 'text', item.item_text)
        order by md5(item.id::text)) from public.quiz_ordering_items item where item.question_id = question.id), '[]'::jsonb),
      'display_order', question.display_order
    ) order by question.display_order) from public.quiz_questions question
      where question.revision_id = revision.id and question.is_visible), '[]'::jsonb)
  )
  from public.locations location
  join public.location_revisions revision on revision.location_id = location.id
  where location.slug = target_slug
    and location.archived_at is null
    and revision.status = 'published'
    and revision.release_status = 'released';
$$;

drop table public.explorer_fun_fact_unlocks;

alter table public.explorer_progress_summary
  drop column unlocked_fun_fact_count;

alter table public.location_fun_facts
  drop column unlock_after_stage;

alter table public.location_revisions
  drop column prerequisite_location_id;

-- Remove the obsolete achievement metric after all stored definitions have
-- been converted to the generic content_views metric.
drop function private.metric_value(
  uuid,
  public.achievement_metric,
  jsonb
);

create type public.achievement_metric_without_unlocks as enum (
  'completed_locations',
  'correct_answers',
  'streak_days',
  'completed_specific_location',
  'challenge_completion',
  'content_views'
);

alter table public.achievement_definitions
  alter column metric type public.achievement_metric_without_unlocks
  using metric::text::public.achievement_metric_without_unlocks;

alter table public.challenge_goals
  alter column metric type public.achievement_metric_without_unlocks
  using metric::text::public.achievement_metric_without_unlocks;

drop type public.achievement_metric;
alter type public.achievement_metric_without_unlocks
  rename to achievement_metric;
create or replace function private.apply_overview(
  target_revision_id uuid,
  target_slug text,
  payload jsonb
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  target_location_id uuid;
  item jsonb;
  item_order integer := 0;
begin
  select location_id into target_location_id
  from public.location_revisions
  where id = target_revision_id;

  if target_slug is null
    or target_slug !~ '^[a-z0-9]+(?:-[a-z0-9]+)*$' then
    raise exception 'Slug chỉ gồm chữ thường không dấu, số và dấu gạch ngang.'
      using errcode = '22023';
  end if;

  update public.locations set slug = target_slug where id = target_location_id;

  update public.location_revisions
  set name = coalesce(payload ->> 'name', ''),
      korean_name = coalesce(payload ->> 'korean_name', ''),
      english_name = coalesce(payload ->> 'english_name', ''),
      region = coalesce(payload ->> 'region', ''),
      address = coalesce(payload ->> 'address', ''),
      city = coalesce(payload ->> 'city', ''),
      country = coalesce(payload ->> 'country', ''),
      latitude = nullif(payload ->> 'latitude', '')::double precision,
      longitude = nullif(payload ->> 'longitude', '')::double precision,
      location_type = coalesce(payload ->> 'location_type', ''),
      short_description = coalesce(payload ->> 'short_description', ''),
      long_description = coalesce(payload ->> 'long_description', ''),
      cover_image_url = coalesce(payload ->> 'cover_image_url', ''),
      cover_image_credit = coalesce(payload ->> 'cover_image_credit', ''),
      cover_image_source_url = coalesce(payload ->> 'cover_image_source_url', ''),
      cover_image_alt = coalesce(payload ->> 'cover_image_alt', ''),
      thumbnail_url = coalesce(payload ->> 'thumbnail_url', ''),
      thumbnail_credit = coalesce(payload ->> 'thumbnail_credit', ''),
      thumbnail_source_url = coalesce(payload ->> 'thumbnail_source_url', ''),
      thumbnail_alt = coalesce(payload ->> 'thumbnail_alt', ''),
      hook_media_kind = coalesce(
        nullif(payload ->> 'hook_media_kind', '')::public.content_media_kind,
        'youtube'
      ),
      hook_media_url = coalesce(payload ->> 'hook_media_url', ''),
      hook_media_credit = coalesce(payload ->> 'hook_media_credit', ''),
      hook_media_source_url = coalesce(payload ->> 'hook_media_source_url', ''),
      hook_media_alt = coalesce(payload ->> 'hook_media_alt', ''),
      hook_title = coalesce(payload ->> 'hook_title', ''),
      hook_caption = coalesce(payload ->> 'hook_caption', ''),
      tags = array(
        select jsonb_array_elements_text(coalesce(payload -> 'tags', '[]'::jsonb))
      ),
      categories = array(
        select jsonb_array_elements_text(coalesce(payload -> 'categories', '[]'::jsonb))
      ),
      release_status = coalesce(
        nullif(payload ->> 'release_status', '')::public.location_release_status,
        'coming_soon'
      ),
      estimated_duration_minutes =
        nullif(payload ->> 'estimated_duration_minutes', '')::integer,
      display_order = coalesce(
        nullif(payload ->> 'display_order', '')::integer,
        0
      ),
      stamp_name = coalesce(payload ->> 'stamp_name', ''),
      stamp_description = coalesce(payload ->> 'stamp_description', ''),
      stamp_image_url = coalesce(payload ->> 'stamp_image_url', ''),
      stamp_image_credit = coalesce(payload ->> 'stamp_image_credit', ''),
      stamp_image_source_url = coalesce(payload ->> 'stamp_image_source_url', ''),
      stamp_image_alt = coalesce(payload ->> 'stamp_image_alt', '')
  where id = target_revision_id;

  delete from public.location_quick_facts
  where revision_id = target_revision_id;

  for item in
    select value
    from jsonb_array_elements(coalesce(payload -> 'quick_facts', '[]'::jsonb))
  loop
    insert into public.location_quick_facts (
      revision_id, label, value, is_visible, display_order
    ) values (
      target_revision_id,
      coalesce(item ->> 'label', ''),
      coalesce(item ->> 'value', ''),
      coalesce((item ->> 'is_visible')::boolean, true),
      item_order
    );
    item_order := item_order + 1;
  end loop;
end;
$$;
create or replace function public.save_location_section(
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
  item jsonb;
  nested_item jsonb;
  item_order integer := 0;
  nested_order integer;
  question_id uuid;
  next_lock_version integer;
begin
  perform private.lock_draft(revision_id, expected_lock_version);

  if jsonb_typeof(coalesce(items, '[]'::jsonb)) <> 'array' then
    raise exception 'Dữ liệu section phải là một danh sách.'
      using errcode = '22023';
  end if;

  if section_name = 'history' then
    delete from public.location_history
    where location_history.revision_id = save_location_section.revision_id;
    for item in
      select value from jsonb_array_elements(coalesce(items, '[]'::jsonb))
    loop
      insert into public.location_history (
        revision_id, period_label, title, short_description, long_description,
        related_people, categories, media_kind, media_url, media_credit,
        media_source_url, media_alt, fun_fact, is_visible, display_order
      ) values (
        revision_id,
        coalesce(item ->> 'period_label', ''),
        coalesce(item ->> 'title', ''),
        coalesce(item ->> 'short_description', ''),
        coalesce(item ->> 'long_description', ''),
        nullif(item ->> 'related_people', ''),
        array(
          select jsonb_array_elements_text(
            coalesce(item -> 'categories', '[]'::jsonb)
          )
        ),
        coalesce(
          nullif(item ->> 'media_kind', '')::public.content_media_kind,
          'image'
        ),
        coalesce(item ->> 'media_url', ''),
        coalesce(item ->> 'media_credit', ''),
        coalesce(item ->> 'media_source_url', ''),
        coalesce(item ->> 'media_alt', ''),
        coalesce(item ->> 'fun_fact', ''),
        coalesce((item ->> 'is_visible')::boolean, true),
        item_order
      );
      item_order := item_order + 1;
    end loop;

  elsif section_name = 'highlights' then
    delete from public.location_highlights
    where location_highlights.revision_id = save_location_section.revision_id;
    for item in
      select value from jsonb_array_elements(coalesce(items, '[]'::jsonb))
    loop
      insert into public.location_highlights (
        revision_id, name, korean_name, tagline, short_description,
        long_description, address, activities, categories, fun_fact,
        media_kind, media_url, media_credit, media_source_url, media_alt,
        is_visible, display_order
      ) values (
        revision_id,
        coalesce(item ->> 'name', ''),
        coalesce(item ->> 'korean_name', ''),
        coalesce(item ->> 'tagline', ''),
        coalesce(item ->> 'short_description', ''),
        coalesce(item ->> 'long_description', ''),
        coalesce(item ->> 'address', ''),
        array(
          select jsonb_array_elements_text(
            coalesce(item -> 'activities', '[]'::jsonb)
          )
        ),
        array(
          select jsonb_array_elements_text(
            coalesce(item -> 'categories', '[]'::jsonb)
          )
        ),
        coalesce(item ->> 'fun_fact', ''),
        coalesce(
          nullif(item ->> 'media_kind', '')::public.content_media_kind,
          'image'
        ),
        coalesce(item ->> 'media_url', ''),
        coalesce(item ->> 'media_credit', ''),
        coalesce(item ->> 'media_source_url', ''),
        coalesce(item ->> 'media_alt', ''),
        coalesce((item ->> 'is_visible')::boolean, true),
        item_order
      );
      item_order := item_order + 1;
    end loop;

  elsif section_name = 'experiences' then
    delete from public.location_experiences
    where location_experiences.revision_id = save_location_section.revision_id;
    for item in
      select value from jsonb_array_elements(coalesce(items, '[]'::jsonb))
    loop
      insert into public.location_experiences (
        revision_id, name, korean_name, short_description, long_description,
        origin_meaning, recognizable_features, related_experience,
        media_kind, media_url, media_credit, media_source_url, media_alt,
        is_visible, display_order
      ) values (
        revision_id,
        coalesce(item ->> 'name', ''),
        coalesce(item ->> 'korean_name', ''),
        coalesce(item ->> 'short_description', ''),
        coalesce(item ->> 'long_description', ''),
        coalesce(item ->> 'origin_meaning', ''),
        array(
          select jsonb_array_elements_text(
            coalesce(item -> 'recognizable_features', '[]'::jsonb)
          )
        ),
        coalesce(item ->> 'related_experience', ''),
        coalesce(
          nullif(item ->> 'media_kind', '')::public.content_media_kind,
          'image'
        ),
        coalesce(item ->> 'media_url', ''),
        coalesce(item ->> 'media_credit', ''),
        coalesce(item ->> 'media_source_url', ''),
        coalesce(item ->> 'media_alt', ''),
        coalesce((item ->> 'is_visible')::boolean, true),
        item_order
      );
      item_order := item_order + 1;
    end loop;

  elsif section_name = 'foods' then
    delete from public.location_foods
    where location_foods.revision_id = save_location_section.revision_id;
    for item in
      select value from jsonb_array_elements(coalesce(items, '[]'::jsonb))
    loop
      insert into public.location_foods (
        revision_id, name, korean_name, short_description, long_description,
        ingredients, flavors, special_feature, experience_places,
        image_url, image_credit, image_source_url, image_alt,
        is_visible, display_order
      ) values (
        revision_id,
        coalesce(item ->> 'name', ''),
        coalesce(item ->> 'korean_name', ''),
        coalesce(item ->> 'short_description', ''),
        coalesce(item ->> 'long_description', ''),
        array(
          select jsonb_array_elements_text(
            coalesce(item -> 'ingredients', '[]'::jsonb)
          )
        ),
        array(
          select jsonb_array_elements_text(
            coalesce(item -> 'flavors', '[]'::jsonb)
          )
        ),
        coalesce(item ->> 'special_feature', ''),
        array(
          select jsonb_array_elements_text(
            coalesce(item -> 'experience_places', '[]'::jsonb)
          )
        ),
        coalesce(item ->> 'image_url', ''),
        coalesce(item ->> 'image_credit', ''),
        coalesce(item ->> 'image_source_url', ''),
        coalesce(item ->> 'image_alt', ''),
        coalesce((item ->> 'is_visible')::boolean, true),
        item_order
      );
      item_order := item_order + 1;
    end loop;

  elsif section_name = 'fun_facts' then
    delete from public.location_fun_facts
    where location_fun_facts.revision_id = save_location_section.revision_id;
    for item in
      select value from jsonb_array_elements(coalesce(items, '[]'::jsonb))
    loop
      insert into public.location_fun_facts (
        revision_id, title, fact, category, icon_name, media_kind,
        media_url, media_credit, media_source_url, media_alt,
        is_visible, display_order
      ) values (
        revision_id,
        coalesce(item ->> 'title', ''),
        coalesce(item ->> 'fact', ''),
        coalesce(item ->> 'category', ''),
        coalesce(item ->> 'icon_name', ''),
        coalesce(
          nullif(item ->> 'media_kind', '')::public.content_media_kind,
          'image'
        ),
        coalesce(item ->> 'media_url', ''),
        coalesce(item ->> 'media_credit', ''),
        coalesce(item ->> 'media_source_url', ''),
        coalesce(item ->> 'media_alt', ''),
        coalesce((item ->> 'is_visible')::boolean, true),
        item_order
      );
      item_order := item_order + 1;
    end loop;

  elsif section_name = 'sources' then
    delete from public.location_sources
    where location_sources.revision_id = save_location_section.revision_id;
    for item in
      select value from jsonb_array_elements(coalesce(items, '[]'::jsonb))
    loop
      insert into public.location_sources (
        revision_id, title, publisher, url, accessed_at,
        verification_status, verified_at, is_official, is_visible,
        display_order
      ) values (
        revision_id,
        coalesce(item ->> 'title', ''),
        coalesce(item ->> 'publisher', ''),
        coalesce(item ->> 'url', ''),
        nullif(item ->> 'accessed_at', '')::date,
        coalesce(
          nullif(item ->> 'verification_status', '')::public.source_verification_status,
          'unverified'
        ),
        nullif(item ->> 'verified_at', '')::date,
        coalesce((item ->> 'is_official')::boolean, false),
        coalesce((item ->> 'is_visible')::boolean, true),
        item_order
      );
      item_order := item_order + 1;
    end loop;

  elsif section_name = 'quiz' then
    if jsonb_array_length(coalesce(items, '[]'::jsonb)) > 20 then
      raise exception 'Quiz tổng kết có tối đa 20 câu hỏi.'
        using errcode = '22023';
    end if;

    delete from public.quiz_questions
    where quiz_questions.revision_id = save_location_section.revision_id;
    for item in
      select value from jsonb_array_elements(coalesce(items, '[]'::jsonb))
    loop
      insert into public.quiz_questions (
        revision_id, kind, prompt, explanation, media_kind,
        media_url, media_credit, media_source_url, media_alt,
        is_visible, display_order
      ) values (
        revision_id,
        (item ->> 'kind')::public.quiz_question_kind,
        coalesce(item ->> 'prompt', ''),
        coalesce(item ->> 'explanation', ''),
        case
          when nullif(item ->> 'media_url', '') is null then null
          else nullif(item ->> 'media_kind', '')::public.content_media_kind
        end,
        nullif(item ->> 'media_url', ''),
        nullif(item ->> 'media_credit', ''),
        nullif(item ->> 'media_source_url', ''),
        coalesce(item ->> 'media_alt', ''),
        coalesce((item ->> 'is_visible')::boolean, true),
        item_order
      ) returning id into question_id;

      if item ->> 'kind' in ('single_choice', 'true_false') then
        nested_order := 0;
        for nested_item in
          select value
          from jsonb_array_elements(coalesce(item -> 'options', '[]'::jsonb))
        loop
          insert into public.quiz_options (
            question_id, option_text, is_correct, display_order
          ) values (
            question_id,
            coalesce(nested_item ->> 'text', ''),
            coalesce((nested_item ->> 'is_correct')::boolean, false),
            nested_order
          );
          nested_order := nested_order + 1;
        end loop;
      elsif item ->> 'kind' = 'matching' then
        nested_order := 0;
        for nested_item in
          select value
          from jsonb_array_elements(coalesce(item -> 'pairs', '[]'::jsonb))
        loop
          insert into public.quiz_matching_pairs (
            question_id, left_text, right_text, display_order
          ) values (
            question_id,
            coalesce(nested_item ->> 'left', ''),
            coalesce(nested_item ->> 'right', ''),
            nested_order
          );
          nested_order := nested_order + 1;
        end loop;
      elsif item ->> 'kind' = 'ordering' then
        nested_order := 0;
        for nested_item in
          select value
          from jsonb_array_elements(coalesce(item -> 'items', '[]'::jsonb))
        loop
          insert into public.quiz_ordering_items (
            question_id, item_text, correct_position
          ) values (
            question_id,
            coalesce(nested_item ->> 'text', ''),
            nested_order
          );
          nested_order := nested_order + 1;
        end loop;
      end if;
      item_order := item_order + 1;
    end loop;
  else
    raise exception 'Section không được hỗ trợ: %', section_name
      using errcode = '22023';
  end if;

  next_lock_version := private.finish_edit(revision_id);
  return jsonb_build_object('lock_version', next_lock_version);
end;
$$;
create or replace function public.validate_location_revision(revision_id uuid)
returns text[]
language plpgsql
security definer
set search_path = ''
as $$
declare
  revision public.location_revisions%rowtype;
  errors text[] := '{}';
  quiz_count integer;
begin
  perform private.assert_admin();

  select * into revision
  from public.location_revisions
  where id = revision_id;

  if not found then
    return array['Không tìm thấy Phiên bản nội dung.'];
  end if;

  if revision.status <> 'draft' then
    errors := array_append(errors, 'Chỉ Bản nháp mới có thể Xuất bản.');
  end if;

  if private.is_blank(revision.name)
    or private.is_blank(revision.korean_name)
    or private.is_blank(revision.english_name)
    or private.is_blank(revision.address)
    or private.is_blank(revision.city)
    or private.is_blank(revision.region)
    or private.is_blank(revision.country)
    or private.is_blank(revision.location_type) then
    errors := array_append(
      errors,
      'Tổng quan còn thiếu tên, tên Hàn/Anh, địa chỉ, vùng, quốc gia hoặc loại Địa điểm.'
    );
  end if;

  if revision.latitude is null or revision.longitude is null then
    errors := array_append(errors, 'Tọa độ latitude và longitude là bắt buộc.');
  end if;

  if revision.estimated_duration_minutes is null
    or cardinality(revision.categories) < 1
    or cardinality(revision.tags) < 1 then
    errors := array_append(
      errors,
      'Cần thời lượng dự kiến, ít nhất một danh mục bản đồ và một tag.'
    );
  end if;

  if private.word_count(revision.short_description) not between 20 and 40
    or private.word_count(revision.long_description) not between 80 and 120 then
    errors := array_append(
      errors,
      'Mô tả Tổng quan phải đúng khoảng 20–40 và 80–120 từ.'
    );
  end if;

  if not private.is_http_url(revision.cover_image_url)
    or private.is_blank(revision.cover_image_credit)
    or not private.is_http_url(revision.cover_image_source_url)
    or private.is_blank(revision.cover_image_alt) then
    errors := array_append(
      errors,
      'Ảnh bìa cần URL, credit, nguồn và mô tả thay thế hợp lệ.'
    );
  end if;

  if not private.is_blank(revision.thumbnail_url)
    and (
      not private.is_http_url(revision.thumbnail_url)
      or private.is_blank(revision.thumbnail_credit)
      or not private.is_http_url(revision.thumbnail_source_url)
      or private.is_blank(revision.thumbnail_alt)
    ) then
    errors := array_append(
      errors,
      'Thumbnail đã nhập phải có URL, credit, nguồn và mô tả thay thế.'
    );
  end if;

  if private.is_blank(revision.hook_media_url)
    or private.is_blank(revision.hook_media_credit)
    or not private.is_http_url(revision.hook_media_source_url)
    or private.is_blank(revision.hook_media_alt)
    or private.is_blank(revision.hook_title)
    or private.is_blank(revision.hook_caption)
    or (
      revision.hook_media_kind = 'image'
      and not private.is_http_url(revision.hook_media_url)
    )
    or (
      revision.hook_media_kind = 'youtube'
      and not private.is_youtube_url(revision.hook_media_url)
    ) then
    errors := array_append(
      errors,
      'Mở đầu cần ảnh/YouTube, credit, nguồn, alt, tagline và caption hợp lệ.'
    );
  end if;

  if private.is_blank(revision.stamp_name)
    or private.is_blank(revision.stamp_description)
    or not private.is_http_url(revision.stamp_image_url)
    or private.is_blank(revision.stamp_image_credit)
    or not private.is_http_url(revision.stamp_image_source_url)
    or private.is_blank(revision.stamp_image_alt) then
    errors := array_append(
      errors,
      'Dấu mộc cần tên, mô tả, ảnh, credit, nguồn và alt.'
    );
  end if;

  if (
    select count(*) from public.location_quick_facts fact
    where fact.revision_id = validate_location_revision.revision_id
      and fact.is_visible
  ) not between 3 and 5 then
    errors := array_append(errors, 'Cần 3–5 thông tin nhanh hiển thị.');
  elsif exists (
    select 1 from public.location_quick_facts fact
    where fact.revision_id = validate_location_revision.revision_id
      and fact.is_visible
      and (private.is_blank(fact.label) or private.is_blank(fact.value))
  ) then
    errors := array_append(errors, 'Thông tin nhanh còn thiếu nhãn hoặc giá trị.');
  end if;

  if not exists (
    select 1 from public.location_sources source
    where source.revision_id = validate_location_revision.revision_id
      and source.is_visible
      and source.verification_status = 'verified'
  ) then
    errors := array_append(
      errors,
      'Cần ít nhất một nguồn hiển thị đã được kiểm chứng.'
    );
  elsif exists (
    select 1 from public.location_sources source
    where source.revision_id = validate_location_revision.revision_id
      and source.is_visible
      and (
        private.is_blank(source.title)
        or private.is_blank(source.publisher)
        or not private.is_http_url(source.url)
        or source.accessed_at is null
        or (
          source.verification_status = 'verified'
          and source.verified_at is null
        )
      )
  ) then
    errors := array_append(errors, 'Nguồn tham khảo hiển thị còn thiếu dữ liệu.');
  end if;

  if (
    select count(*) from public.location_history item
    where item.revision_id = validate_location_revision.revision_id
      and item.is_visible
  ) not between 4 and 6 then
    errors := array_append(errors, 'Cần 4–6 mốc lịch sử hiển thị.');
  elsif exists (
    select 1 from public.location_history item
    where item.revision_id = validate_location_revision.revision_id
      and item.is_visible
      and (
        private.is_blank(item.period_label)
        or private.word_count(item.title) not between 4 and 10
        or private.word_count(item.short_description) not between 20 and 35
        or private.word_count(item.long_description) not between 70 and 120
        or private.is_blank(item.fun_fact)
        or private.is_blank(item.media_credit)
        or not private.is_http_url(item.media_source_url)
        or private.is_blank(item.media_alt)
        or (item.media_kind = 'image' and not private.is_http_url(item.media_url))
        or (item.media_kind = 'youtube' and not private.is_youtube_url(item.media_url))
      )
  ) then
    errors := array_append(errors, 'Một hoặc nhiều mốc lịch sử chưa hợp lệ.');
  end if;

  if (
    select count(*) from public.location_highlights item
    where item.revision_id = validate_location_revision.revision_id
      and item.is_visible
  ) not between 4 and 6 then
    errors := array_append(errors, 'Cần 4–6 Điểm đến hiển thị.');
  elsif exists (
    select 1 from public.location_highlights item
    where item.revision_id = validate_location_revision.revision_id
      and item.is_visible
      and (
        private.is_blank(item.name)
        or private.is_blank(item.korean_name)
        or private.is_blank(item.tagline)
        or private.word_count(item.short_description) not between 25 and 40
        or private.word_count(item.long_description) not between 70 and 110
        or private.is_blank(item.address)
        or cardinality(item.activities) < 1
        or private.is_blank(item.fun_fact)
        or private.is_blank(item.media_credit)
        or not private.is_http_url(item.media_source_url)
        or private.is_blank(item.media_alt)
        or (item.media_kind = 'image' and not private.is_http_url(item.media_url))
        or (item.media_kind = 'youtube' and not private.is_youtube_url(item.media_url))
      )
  ) then
    errors := array_append(errors, 'Một hoặc nhiều Điểm đến chưa hợp lệ.');
  end if;

  if (
    select count(*) from public.location_experiences item
    where item.revision_id = validate_location_revision.revision_id
      and item.is_visible
  ) not between 3 and 5 then
    errors := array_append(errors, 'Cần 3–5 Trải nghiệm hiển thị.');
  elsif exists (
    select 1 from public.location_experiences item
    where item.revision_id = validate_location_revision.revision_id
      and item.is_visible
      and (
        private.is_blank(item.name)
        or private.is_blank(item.korean_name)
        or private.word_count(item.short_description) not between 25 and 40
        or private.word_count(item.long_description) not between 70 and 120
        or private.is_blank(item.origin_meaning)
        or cardinality(item.recognizable_features) < 1
        or private.is_blank(item.related_experience)
        or private.is_blank(item.media_credit)
        or not private.is_http_url(item.media_source_url)
        or private.is_blank(item.media_alt)
        or (item.media_kind = 'image' and not private.is_http_url(item.media_url))
        or (item.media_kind = 'youtube' and not private.is_youtube_url(item.media_url))
      )
  ) then
    errors := array_append(errors, 'Một hoặc nhiều Trải nghiệm chưa hợp lệ.');
  end if;

  if (
    select count(*) from public.location_foods item
    where item.revision_id = validate_location_revision.revision_id
      and item.is_visible
  ) not between 3 and 6 then
    errors := array_append(errors, 'Cần 3–6 món ăn hiển thị.');
  elsif exists (
    select 1 from public.location_foods item
    where item.revision_id = validate_location_revision.revision_id
      and item.is_visible
      and (
        private.is_blank(item.name)
        or private.is_blank(item.korean_name)
        or private.word_count(item.short_description) not between 20 and 30
        or private.word_count(item.long_description) not between 50 and 80
        or cardinality(item.ingredients) < 1
        or cardinality(item.flavors) < 1
        or private.is_blank(item.special_feature)
        or cardinality(item.experience_places) < 1
        or not private.is_http_url(item.image_url)
        or private.is_blank(item.image_credit)
        or not private.is_http_url(item.image_source_url)
        or private.is_blank(item.image_alt)
      )
  ) then
    errors := array_append(errors, 'Một hoặc nhiều món ăn chưa hợp lệ.');
  end if;

  if (
    select count(*) from public.location_fun_facts item
    where item.revision_id = validate_location_revision.revision_id
      and item.is_visible
  ) not between 4 and 6 then
    errors := array_append(errors, 'Cần 4–6 Fun Facts hiển thị.');
  elsif exists (
    select 1 from public.location_fun_facts item
    where item.revision_id = validate_location_revision.revision_id
      and item.is_visible
      and (
        private.is_blank(item.title)
        or private.is_blank(item.category)
        or private.word_count(item.fact) not between 15 and 35
        or (
          private.is_blank(item.icon_name)
          and private.is_blank(item.media_url)
        )
        or (
          not private.is_blank(item.media_url)
          and (
            private.is_blank(item.media_credit)
            or not private.is_http_url(item.media_source_url)
            or private.is_blank(item.media_alt)
            or (
              item.media_kind = 'image'
              and not private.is_http_url(item.media_url)
            )
            or (
              item.media_kind = 'youtube'
              and not private.is_youtube_url(item.media_url)
            )
          )
        )
      )
  ) then
    errors := array_append(errors, 'Một hoặc nhiều Fun Fact chưa hợp lệ.');
  end if;

  if private.is_blank(revision.opening_hours)
    or private.is_blank(revision.ticket_price)
    or private.is_blank(revision.recommended_duration)
    or private.is_blank(revision.best_time_to_visit)
    or private.is_blank(revision.accessibility_info)
    or not private.is_http_url(revision.travel_official_source_url)
    or revision.travel_last_verified_at is null
    or not exists (
      select 1 from public.location_transport_options item
      where item.revision_id = validate_location_revision.revision_id
        and item.is_visible
        and not private.is_blank(item.title)
        and not private.is_blank(item.instructions)
    )
    or not exists (
      select 1 from public.location_visitor_notes item
      where item.revision_id = validate_location_revision.revision_id
        and item.is_visible
        and not private.is_blank(item.content)
    ) then
    errors := array_append(errors, 'Thông tin du lịch thực tế còn thiếu.');
  end if;

  select count(*) into quiz_count
  from public.quiz_questions question
  where question.revision_id = validate_location_revision.revision_id
    and question.is_visible;

  if quiz_count not between 10 and 20 then
    errors := array_append(
      errors,
      'Quiz tổng kết cần từ 10 đến 20 câu hỏi hiển thị.'
    );
  end if;

  if exists (
    select 1 from public.quiz_questions question
    where question.revision_id = validate_location_revision.revision_id
      and question.is_visible
      and (
        private.is_blank(question.prompt)
        or private.word_count(question.explanation) not between 25 and 50
        or (
          question.media_kind is not null
          and (
            private.is_blank(question.media_credit)
            or not private.is_http_url(question.media_source_url)
            or private.is_blank(question.media_alt)
            or (
              question.media_kind = 'image'
              and not private.is_http_url(question.media_url)
            )
            or (
              question.media_kind = 'youtube'
              and not private.is_youtube_url(question.media_url)
            )
          )
        )
      )
  ) then
    errors := array_append(errors, 'Một hoặc nhiều Câu hỏi chưa hợp lệ.');
  end if;

  if exists (
    select 1 from public.quiz_questions question
    where question.revision_id = validate_location_revision.revision_id
      and question.is_visible
      and question.kind = 'single_choice'
      and (
        (select count(*) from public.quiz_options answer where answer.question_id = question.id)
          not between 3 and 4
        or (select count(*) from public.quiz_options answer where answer.question_id = question.id and answer.is_correct) <> 1
        or exists (
          select 1 from public.quiz_options answer
          where answer.question_id = question.id
            and private.is_blank(answer.option_text)
        )
      )
  ) then
    errors := array_append(
      errors,
      'Câu một đáp án cần 3–4 lựa chọn và đúng chính xác một đáp án.'
    );
  end if;

  if exists (
    select 1 from public.quiz_questions question
    where question.revision_id = validate_location_revision.revision_id
      and question.is_visible
      and question.kind = 'true_false'
      and (
        (select count(*) from public.quiz_options answer where answer.question_id = question.id) <> 2
        or (select count(*) from public.quiz_options answer where answer.question_id = question.id and answer.is_correct) <> 1
      )
  ) then
    errors := array_append(errors, 'Câu Đúng/Sai phải có hai lựa chọn.');
  end if;

  if exists (
    select 1 from public.quiz_questions question
    where question.revision_id = validate_location_revision.revision_id
      and question.is_visible
      and question.kind = 'matching'
      and (
        (select count(*) from public.quiz_matching_pairs answer where answer.question_id = question.id)
          not between 3 and 6
        or exists (
          select 1 from public.quiz_matching_pairs answer
          where answer.question_id = question.id
            and (
              private.is_blank(answer.left_text)
              or private.is_blank(answer.right_text)
            )
        )
      )
  ) then
    errors := array_append(errors, 'Câu nối cặp cần 3–6 cặp hợp lệ.');
  end if;

  if exists (
    select 1 from public.quiz_questions question
    where question.revision_id = validate_location_revision.revision_id
      and question.is_visible
      and question.kind = 'ordering'
      and (
        (select count(*) from public.quiz_ordering_items answer where answer.question_id = question.id)
          not between 3 and 6
        or exists (
          select 1 from public.quiz_ordering_items answer
          where answer.question_id = question.id
            and private.is_blank(answer.item_text)
        )
      )
  ) then
    errors := array_append(errors, 'Câu sắp xếp cần 3–6 mục hợp lệ.');
  end if;

  return errors;
end;
$$;
create or replace function public.get_admin_location(location_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  target_revision_id uuid;
  result jsonb;
begin
  perform private.assert_admin();

  select revision.id into target_revision_id
  from public.location_revisions revision
  where revision.location_id = get_admin_location.location_id
  order by
    case revision.status
      when 'draft' then 0
      when 'published' then 1
      when 'archived' then 2
    end,
    revision.version_number desc
  limit 1;

  if target_revision_id is null then
    raise exception 'Không tìm thấy nội dung Địa điểm.'
      using errcode = 'P0002';
  end if;

  select jsonb_build_object(
    'location_id', location.id,
    'revision_id', revision.id,
    'slug', location.slug,
    'status', revision.status,
    'version_number', revision.version_number,
    'lock_version', revision.lock_version,
    'overview', jsonb_build_object(
      'name', revision.name,
      'korean_name', revision.korean_name,
      'english_name', revision.english_name,
      'region', revision.region,
      'address', revision.address,
      'city', revision.city,
      'country', revision.country,
      'latitude', revision.latitude,
      'longitude', revision.longitude,
      'location_type', revision.location_type,
      'short_description', revision.short_description,
      'long_description', revision.long_description,
      'cover_image_url', revision.cover_image_url,
      'cover_image_credit', revision.cover_image_credit,
      'cover_image_source_url', revision.cover_image_source_url,
      'cover_image_alt', revision.cover_image_alt,
      'thumbnail_url', revision.thumbnail_url,
      'thumbnail_credit', revision.thumbnail_credit,
      'thumbnail_source_url', revision.thumbnail_source_url,
      'thumbnail_alt', revision.thumbnail_alt,
      'hook_media_kind', revision.hook_media_kind,
      'hook_media_url', revision.hook_media_url,
      'hook_media_credit', revision.hook_media_credit,
      'hook_media_source_url', revision.hook_media_source_url,
      'hook_media_alt', revision.hook_media_alt,
      'hook_title', revision.hook_title,
      'hook_caption', revision.hook_caption,
      'tags', to_jsonb(revision.tags),
      'categories', to_jsonb(revision.categories),
      'release_status', revision.release_status,
      'estimated_duration_minutes', revision.estimated_duration_minutes,
      'display_order', revision.display_order,
      'stamp_name', revision.stamp_name,
      'stamp_description', revision.stamp_description,
      'stamp_image_url', revision.stamp_image_url,
      'stamp_image_credit', revision.stamp_image_credit,
      'stamp_image_source_url', revision.stamp_image_source_url,
      'stamp_image_alt', revision.stamp_image_alt,
      'quick_facts', coalesce((
        select jsonb_agg(
          to_jsonb(fact) - 'id' - 'revision_id' - 'display_order'
          order by fact.display_order
        )
        from public.location_quick_facts fact
        where fact.revision_id = revision.id
      ), '[]'::jsonb)
    ),
    'history', coalesce((
      select jsonb_agg(
        to_jsonb(item) - 'id' - 'revision_id' - 'display_order'
        order by item.display_order
      )
      from public.location_history item
      where item.revision_id = revision.id
    ), '[]'::jsonb),
    'highlights', coalesce((
      select jsonb_agg(
        to_jsonb(item) - 'id' - 'revision_id' - 'display_order'
        order by item.display_order
      )
      from public.location_highlights item
      where item.revision_id = revision.id
    ), '[]'::jsonb),
    'experiences', coalesce((
      select jsonb_agg(
        to_jsonb(item)
          - 'id' - 'revision_id' - 'display_order' - 'dos' - 'donts'
        order by item.display_order
      )
      from public.location_experiences item
      where item.revision_id = revision.id
    ), '[]'::jsonb),
    'experience_guide', jsonb_build_object(
      'featured_fact', revision.experience_featured_fact,
      'dos', coalesce((
        select jsonb_agg(item.content order by item.display_order)
        from public.location_culture_guidelines item
        where item.revision_id = revision.id
          and item.kind = 'do'
          and item.is_visible
      ), '[]'::jsonb),
      'donts', coalesce((
        select jsonb_agg(item.content order by item.display_order)
        from public.location_culture_guidelines item
        where item.revision_id = revision.id
          and item.kind = 'dont'
          and item.is_visible
      ), '[]'::jsonb)
    ),
    'foods', coalesce((
      select jsonb_agg(
        to_jsonb(item) - 'id' - 'revision_id' - 'display_order'
        order by item.display_order
      )
      from public.location_foods item
      where item.revision_id = revision.id
    ), '[]'::jsonb),
    'fun_facts', coalesce((
      select jsonb_agg(
        to_jsonb(item) - 'id' - 'revision_id' - 'display_order'
        order by item.display_order
      )
      from public.location_fun_facts item
      where item.revision_id = revision.id
    ), '[]'::jsonb),
    'quiz', coalesce((
      select jsonb_agg(
        (
          to_jsonb(question) - 'id' - 'revision_id' - 'display_order'
        ) || jsonb_build_object(
          'options', coalesce((
            select jsonb_agg(
              jsonb_build_object(
                'text', answer.option_text,
                'is_correct', answer.is_correct
              ) order by answer.display_order
            )
            from public.quiz_options answer
            where answer.question_id = question.id
          ), '[]'::jsonb),
          'pairs', coalesce((
            select jsonb_agg(
              jsonb_build_object(
                'left', answer.left_text,
                'right', answer.right_text
              ) order by answer.display_order
            )
            from public.quiz_matching_pairs answer
            where answer.question_id = question.id
          ), '[]'::jsonb),
          'items', coalesce((
            select jsonb_agg(
              jsonb_build_object('text', answer.item_text)
              order by answer.correct_position
            )
            from public.quiz_ordering_items answer
            where answer.question_id = question.id
          ), '[]'::jsonb)
        ) order by question.display_order
      )
      from public.quiz_questions question
      where question.revision_id = revision.id
    ), '[]'::jsonb),
    'travel', jsonb_build_object(
      'opening_hours', revision.opening_hours,
      'ticket_price', revision.ticket_price,
      'recommended_duration', revision.recommended_duration,
      'best_time_to_visit', revision.best_time_to_visit,
      'accessibility_info', revision.accessibility_info,
      'official_source_url', revision.travel_official_source_url,
      'last_verified_at', revision.travel_last_verified_at,
      'transport_options', coalesce((
        select jsonb_agg(
          to_jsonb(item) - 'id' - 'revision_id' - 'display_order'
          order by item.display_order
        )
        from public.location_transport_options item
        where item.revision_id = revision.id
      ), '[]'::jsonb),
      'visitor_notes', coalesce((
        select jsonb_agg(
          to_jsonb(item) - 'id' - 'revision_id' - 'display_order'
          order by item.display_order
        )
        from public.location_visitor_notes item
        where item.revision_id = revision.id
      ), '[]'::jsonb)
    ),
    'sources', coalesce((
      select jsonb_agg(
        to_jsonb(source) - 'id' - 'revision_id' - 'display_order'
        order by source.display_order
      )
      from public.location_sources source
      where source.revision_id = revision.id
    ), '[]'::jsonb)
  ) into result
  from public.location_revisions revision
  join public.locations location on location.id = revision.location_id
  where revision.id = target_revision_id;

  return result;
end;
$$;
create or replace function public.create_location_draft_from_current(
  location_id uuid
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  existing_draft public.location_revisions%rowtype;
  source_revision public.location_revisions%rowtype;
  new_revision_id uuid := gen_random_uuid();
  next_version_number integer;
  source_question record;
  new_question_id uuid;
begin
  perform private.assert_admin();

  perform 1 from public.locations
  where id = location_id
  for update;
  if not found then
    raise exception 'Không tìm thấy Địa điểm.' using errcode = 'P0002';
  end if;

  select * into existing_draft
  from public.location_revisions
  where location_revisions.location_id =
    create_location_draft_from_current.location_id
    and status = 'draft'
  limit 1;

  if found then
    return jsonb_build_object(
      'location_id', location_id,
      'revision_id', existing_draft.id,
      'lock_version', existing_draft.lock_version
    );
  end if;

  select * into source_revision
  from public.location_revisions
  where location_revisions.location_id =
    create_location_draft_from_current.location_id
    and status in ('published', 'archived')
  order by version_number desc
  limit 1;
  if not found then
    raise exception 'Không có Phiên bản nội dung để tạo Bản nháp.'
      using errcode = 'P0002';
  end if;

  select coalesce(max(version_number), 0) + 1 into next_version_number
  from public.location_revisions
  where location_revisions.location_id =
    create_location_draft_from_current.location_id;

  insert into public.location_revisions
  select (
    jsonb_populate_record(
      null::public.location_revisions,
      to_jsonb(source_revision) || jsonb_build_object(
        'id', new_revision_id,
        'version_number', next_version_number,
        'status', 'draft',
        'base_revision_id', source_revision.id,
        'lock_version', 1,
        'published_at', null,
        'created_at', now(),
        'created_by', auth.uid(),
        'updated_at', now(),
        'updated_by', auth.uid()
      )
    )
  ).*;

  insert into public.location_quick_facts (
    revision_id, label, value, is_visible, display_order
  )
  select new_revision_id, label, value, is_visible, display_order
  from public.location_quick_facts
  where revision_id = source_revision.id;

  insert into public.location_sources (
    revision_id, title, publisher, url, accessed_at, verification_status,
    verified_at, is_official, is_visible, display_order
  )
  select new_revision_id, title, publisher, url, accessed_at,
    verification_status, verified_at, is_official, is_visible, display_order
  from public.location_sources
  where revision_id = source_revision.id;

  insert into public.location_history (
    revision_id, period_label, title, short_description, long_description,
    related_people, categories, media_kind, media_url, media_credit,
    media_source_url, media_alt, fun_fact, is_visible, display_order
  )
  select new_revision_id, period_label, title, short_description,
    long_description, related_people, categories, media_kind, media_url,
    media_credit, media_source_url, media_alt, fun_fact, is_visible,
    display_order
  from public.location_history
  where revision_id = source_revision.id;

  insert into public.location_highlights (
    revision_id, name, korean_name, tagline, short_description,
    long_description, address, activities, categories, fun_fact, media_kind,
    media_url, media_credit, media_source_url, media_alt, is_visible,
    display_order
  )
  select new_revision_id, name, korean_name, tagline, short_description,
    long_description, address, activities, categories, fun_fact, media_kind,
    media_url, media_credit, media_source_url, media_alt, is_visible,
    display_order
  from public.location_highlights
  where revision_id = source_revision.id;

  insert into public.location_experiences (
    revision_id, name, korean_name, short_description, long_description,
    origin_meaning, recognizable_features, dos, donts, related_experience,
    media_kind, media_url, media_credit, media_source_url, media_alt,
    is_visible, display_order
  )
  select new_revision_id, name, korean_name, short_description,
    long_description, origin_meaning, recognizable_features, dos, donts,
    related_experience, media_kind, media_url, media_credit, media_source_url,
    media_alt, is_visible, display_order
  from public.location_experiences
  where revision_id = source_revision.id;

  insert into public.location_culture_guidelines (
    revision_id, kind, content, display_order, is_visible
  )
  select new_revision_id, kind, content, display_order, is_visible
  from public.location_culture_guidelines
  where revision_id = source_revision.id;

  insert into public.location_foods (
    revision_id, name, korean_name, short_description, long_description,
    ingredients, flavors, special_feature, experience_places, image_url,
    image_credit, image_source_url, image_alt, is_visible, display_order
  )
  select new_revision_id, name, korean_name, short_description,
    long_description, ingredients, flavors, special_feature,
    experience_places, image_url, image_credit, image_source_url, image_alt,
    is_visible, display_order
  from public.location_foods
  where revision_id = source_revision.id;

  insert into public.location_fun_facts (
    revision_id, title, fact, category, icon_name, media_kind, media_url,
    media_credit, media_source_url, media_alt, is_visible,
    display_order
  )
  select new_revision_id, title, fact, category, icon_name, media_kind,
    media_url, media_credit, media_source_url, media_alt,
    is_visible, display_order
  from public.location_fun_facts
  where revision_id = source_revision.id;

  insert into public.location_transport_options (
    revision_id, mode, title, instructions, tip, is_recommended, is_visible,
    display_order
  )
  select new_revision_id, mode, title, instructions, tip, is_recommended,
    is_visible, display_order
  from public.location_transport_options
  where revision_id = source_revision.id;

  insert into public.location_visitor_notes (
    revision_id, content, is_visible, display_order
  )
  select new_revision_id, content, is_visible, display_order
  from public.location_visitor_notes
  where revision_id = source_revision.id;

  for source_question in
    select * from public.quiz_questions
    where revision_id = source_revision.id
    order by display_order
  loop
    insert into public.quiz_questions (
      revision_id, kind, prompt, explanation, media_kind, media_url,
      media_credit, media_source_url, media_alt, is_visible, display_order
    ) values (
      new_revision_id, source_question.kind, source_question.prompt,
      source_question.explanation, source_question.media_kind,
      source_question.media_url, source_question.media_credit,
      source_question.media_source_url, source_question.media_alt,
      source_question.is_visible, source_question.display_order
    ) returning id into new_question_id;

    insert into public.quiz_options (
      question_id, option_text, is_correct, display_order
    )
    select new_question_id, option_text, is_correct, display_order
    from public.quiz_options
    where question_id = source_question.id;

    insert into public.quiz_matching_pairs (
      question_id, left_text, right_text, display_order
    )
    select new_question_id, left_text, right_text, display_order
    from public.quiz_matching_pairs
    where question_id = source_question.id;

    insert into public.quiz_ordering_items (
      question_id, item_text, correct_position
    )
    select new_question_id, item_text, correct_position
    from public.quiz_ordering_items
    where question_id = source_question.id;
  end loop;

  return jsonb_build_object(
    'location_id', location_id,
    'revision_id', new_revision_id,
    'lock_version', 1
  );
end;
$$;
create or replace function public.archive_location(location_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  perform private.assert_admin();

  perform 1
  from public.locations
  where id = location_id
  for update;

  if not found then
    raise exception 'Không tìm thấy Địa điểm.' using errcode = 'P0002';
  end if;

  if exists (
    select 1
    from public.location_revisions
    where location_revisions.location_id = archive_location.location_id
      and status = 'draft'
  ) then
    raise exception 'Hãy Xuất bản hoặc xử lý Bản nháp trước khi Lưu trữ.'
      using errcode = '22023';
  end if;

  update public.location_revisions
  set status = 'archived',
      updated_at = now(),
      updated_by = auth.uid()
  where location_revisions.location_id = archive_location.location_id
    and status = 'published';

  update public.locations
  set archived_at = now()
  where id = location_id;
end;
$$;
create or replace function private.metric_value(
  target_user uuid,
  target_metric public.achievement_metric,
  target_filter jsonb default '{}'::jsonb
)
returns integer
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  return case target_metric
    when 'completed_locations' then (
      select count(*)::integer from public.explorer_journeys
      where user_id = target_user and status = 'completed'
    )
    when 'completed_specific_location' then (
      select count(*)::integer from public.explorer_journeys
      where user_id = target_user and status = 'completed'
        and location_id = (target_filter ->> 'location_id')::uuid
    )
    when 'correct_answers' then (
      select count(distinct answer.question_id)::integer
      from public.explorer_quiz_answers answer
      join public.explorer_quiz_attempts attempt on attempt.id = answer.attempt_id
      join public.explorer_journeys journey on journey.id = attempt.journey_id
      where journey.user_id = target_user and answer.is_correct
    )
    when 'streak_days' then coalesce((
      select current_streak from public.explorer_progress_summary
      where user_id = target_user
    ), 0)
    when 'challenge_completion' then (
      select count(*)::integer from public.explorer_challenge_progress
      where user_id = target_user and status in ('completed', 'rewarded')
        and (
          not (target_filter ? 'challenge_id')
          or challenge_id = (target_filter ->> 'challenge_id')::uuid
        )
    )
    when 'content_views' then (
      select count(*)::integer from public.explorer_content_views
      where user_id = target_user
        and (
          not (target_filter ? 'kind')
          or kind = (target_filter ->> 'kind')::public.content_view_kind
        )
    )
  end;
end;
$$;
create or replace function private.refresh_progression(target_user uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  achievement_row record;
  challenge_row record;
  current_goal record;
  current_metric integer;
begin
  insert into public.explorer_progress_summary (
    user_id, correct_answer_count, completed_location_count,
    content_view_count, updated_at
  ) values (
    target_user,
    private.metric_value(target_user, 'correct_answers'),
    private.metric_value(target_user, 'completed_locations'),
    private.metric_value(target_user, 'content_views'),
    now()
  ) on conflict (user_id) do update set
    correct_answer_count = excluded.correct_answer_count,
    completed_location_count = excluded.completed_location_count,
    content_view_count = excluded.content_view_count,
    updated_at = now();

  for challenge_row in
    select challenge.*
    from public.challenge_definitions challenge
    join public.explorer_challenge_progress progress
      on progress.challenge_id = challenge.id and progress.user_id = target_user
    where progress.status = 'joined'
      and challenge.status in ('scheduled', 'active')
      and now() between challenge.starts_at and challenge.ends_at
  loop
    for current_goal in
      select * from public.challenge_goals
      where challenge_id = challenge_row.id
    loop
      current_metric := private.metric_value(
        target_user,
        current_goal.metric,
        current_goal.criteria_filter
      );
      insert into public.explorer_challenge_goal_progress (
        user_id, challenge_id, goal_id, current_value, updated_at
      ) values (
        target_user,
        challenge_row.id,
        current_goal.id,
        current_metric,
        now()
      ) on conflict (user_id, goal_id) do update set
        current_value = excluded.current_value,
        updated_at = now();
    end loop;

    if not exists (
      select 1
      from public.challenge_goals as challenge_goal
      left join public.explorer_challenge_goal_progress as goal_progress
        on goal_progress.goal_id = challenge_goal.id
        and goal_progress.user_id = target_user
      where challenge_goal.challenge_id = challenge_row.id
        and coalesce(goal_progress.current_value, 0) < challenge_goal.target
    ) and exists (
      select 1 from public.challenge_goals as required_goal
      where required_goal.challenge_id = challenge_row.id
    ) then
      update public.explorer_challenge_progress
      set status = 'completed', completed_at = now()
      where user_id = target_user
        and challenge_id = challenge_row.id
        and status = 'joined';
    end if;
  end loop;

  for achievement_row in
    select * from public.achievement_definitions
    where is_active
      and (available_from is null or available_from <= now())
      and (available_until is null or available_until >= now())
  loop
    current_metric := private.metric_value(
      target_user,
      achievement_row.metric,
      achievement_row.criteria_filter
    );
    insert into public.explorer_achievement_progress (
      user_id, achievement_id, current_value, target_value, updated_at
    ) values (
      target_user,
      achievement_row.id,
      current_metric,
      achievement_row.target,
      now()
    ) on conflict (user_id, achievement_id) do update set
      current_value = excluded.current_value,
      target_value = excluded.target_value,
      updated_at = now();

    if current_metric >= achievement_row.target then
      insert into public.explorer_badges (
        user_id,
        achievement_id,
        source_reference
      ) values (
        target_user,
        achievement_row.id,
        'achievement:' || achievement_row.id::text
      ) on conflict (user_id, achievement_id) do nothing;

      if found then
        update public.achievement_definitions
        set criteria_locked_at = coalesce(criteria_locked_at, now())
        where id = achievement_row.id;
      end if;
    end if;
  end loop;
end;
$$;
