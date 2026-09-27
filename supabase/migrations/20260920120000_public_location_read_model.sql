-- Public read model for the explorer app.  It deliberately exposes only a
-- published revision and omits editorial sources and quiz answer keys.

create or replace function public.list_published_locations()
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
      'categories', revision.categories
    ) order by revision.display_order, revision.name
  ), '[]'::jsonb)
  from public.locations location
  join public.location_revisions revision on revision.location_id = location.id
  where location.archived_at is null
    and revision.status = 'published';
$$;

create or replace function public.get_published_location(target_slug text)
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
      'icon_name', item.icon_name, 'unlock_after_stage', item.unlock_after_stage,
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
    and revision.status = 'published';
$$;

create or replace function public.submit_quiz_answer(question_id uuid, answer jsonb)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  question public.quiz_questions%rowtype;
  is_correct boolean := false;
begin
  select * into question from public.quiz_questions item
  where item.id = question_id and item.is_visible and public.can_read_revision(item.revision_id);
  if not found then
    raise exception 'Quiz question is unavailable';
  end if;

  if question.kind in ('single_choice', 'true_false') then
    select coalesce(option.is_correct, false) into is_correct
    from public.quiz_options option
    where option.id = nullif(answer ->> 'option_id', '')::uuid
      and option.question_id = question.id;
  elsif question.kind = 'matching' then
    select count(*) = (select count(*) from public.quiz_matching_pairs where question_id = question.id)
      and count(distinct left_pair.id) = (select count(*) from public.quiz_matching_pairs where question_id = question.id)
      into is_correct
    from jsonb_to_recordset(coalesce(answer -> 'pairs', '[]'::jsonb)) as submitted(left_id uuid, right_text text)
    join public.quiz_matching_pairs left_pair
      on left_pair.id = submitted.left_id and left_pair.question_id = question.id
    where left_pair.right_text = submitted.right_text;
  elsif question.kind = 'ordering' then
    select count(*) = (select count(*) from public.quiz_ordering_items where question_id = question.id)
      and bool_and(item.correct_position = submitted.ordinality - 1)
      into is_correct
    from jsonb_array_elements_text(coalesce(answer -> 'item_ids', '[]'::jsonb)) with ordinality as submitted(item_id, ordinality)
    join public.quiz_ordering_items item on item.id = submitted.item_id::uuid
      and item.question_id = question.id;
  end if;

  return jsonb_build_object('is_correct', coalesce(is_correct, false), 'explanation', question.explanation);
end;
$$;

-- Answer keys are available only through the scoring function above.
drop policy if exists quiz_options_published_read on public.quiz_options;
drop policy if exists quiz_matching_pairs_published_read on public.quiz_matching_pairs;
drop policy if exists quiz_ordering_items_published_read on public.quiz_ordering_items;
revoke select on table public.quiz_options, public.quiz_matching_pairs, public.quiz_ordering_items from anon, authenticated;

revoke all on function public.list_published_locations() from public;
revoke all on function public.get_published_location(text) from public;
revoke all on function public.submit_quiz_answer(uuid, jsonb) from public;
grant execute on function public.list_published_locations() to anon, authenticated;
grant execute on function public.get_published_location(text) to anon, authenticated;
grant execute on function public.submit_quiz_answer(uuid, jsonb) to anon, authenticated;
