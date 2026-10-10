begin;

create extension if not exists pgtap with schema extensions;

select plan(83);

select has_type(
  'public',
  'location_revision_status',
  'location revision status enum exists'
);
select has_table('public', 'admin_users', 'admin allowlist exists');
select has_table('public', 'locations', 'location identities exist');
select has_table('public', 'location_revisions', 'versioned content exists');
select has_table('public', 'quiz_questions', 'quiz questions exist');
select has_type('public', 'content_locale', 'content locale enum exists');
select has_type(
  'public',
  'translation_review_status',
  'translation review status enum exists'
);
select has_table(
  'public',
  'location_revision_translations',
  'location translation overlays exist'
);
select has_function(
  'public',
  'list_published_locations',
  array['text'],
  'localized location list RPC exists'
);
select has_function(
  'public',
  'admin_save_location_translation',
  array['uuid', 'text', 'jsonb'],
  'admin translation save RPC exists'
);
select has_function(
  'public',
  'create_location_draft',
  array['text', 'jsonb'],
  'draft creation RPC exists'
);
select has_function(
  'public',
  'publish_location_revision',
  array['uuid', 'integer'],
  'publish RPC exists'
);
select hasnt_type('public', 'quiz_stage', 'old per-stage quiz enum is removed');
select has_column(
  'public',
  'location_revisions',
  'hook_media_kind',
  'opening media supports image or YouTube'
);
select has_column('public', 'location_history', 'image_gallery', 'history supports image galleries');
select has_column('public', 'location_highlights', 'image_gallery', 'highlights support image galleries');
select has_column('public', 'location_experiences', 'image_gallery', 'experiences support image galleries');
select has_column('public', 'location_foods', 'image_gallery', 'foods support image galleries');
select col_type_is('public', 'location_history', 'image_gallery', 'jsonb', 'history gallery uses jsonb');
select col_type_is('public', 'location_highlights', 'image_gallery', 'jsonb', 'highlight gallery uses jsonb');
select col_type_is('public', 'location_experiences', 'image_gallery', 'jsonb', 'experience gallery uses jsonb');
select col_type_is('public', 'location_foods', 'image_gallery', 'jsonb', 'food gallery uses jsonb');
select ok(
  private.is_valid_image_gallery(
    (
      select jsonb_agg(jsonb_build_object(
        'url', 'https://example.com/' || index || '.jpg',
        'credit', '',
        'source_url', '',
        'alt', ''
      ))
      from generate_series(1, 10) index
    )
  ),
  'gallery accepts ten structurally valid images'
);
select ok(
  not private.is_valid_image_gallery(
    (
      select jsonb_agg(jsonb_build_object(
        'url', 'https://example.com/' || index || '.jpg',
        'credit', '',
        'source_url', '',
        'alt', ''
      ))
      from generate_series(1, 11) index
    )
  ),
  'gallery rejects more than ten images'
);
select ok(
  not private.is_valid_image_gallery('[{"url":"https://example.com/image.jpg"}]'::jsonb),
  'gallery rejects images missing required metadata keys'
);
select hasnt_column(
  'public',
  'location_fun_facts',
  'unlock_after_stage',
  'fun facts are no longer gated by a content stage'
);
select hasnt_column(
  'public',
  'location_revisions',
  'prerequisite_location_id',
  'locations no longer depend on a prerequisite location'
);
select hasnt_column(
  'public',
  'explorer_progress_summary',
  'unlocked_fun_fact_count',
  'progress summary no longer tracks unlock-specific counters'
);
select hasnt_table(
  'public',
  'explorer_fun_fact_unlocks',
  'unlock-specific fun fact history has been removed'
);
select is(
  (
    select array_agg(value.enumlabel::text order by value.enumsortorder)
    from pg_type type
    join pg_namespace namespace on namespace.oid = type.typnamespace
    join pg_enum value on value.enumtypid = type.oid
    where namespace.nspname = 'public'
      and type.typname = 'stage_progress_status'
  ),
  array['not_started', 'in_progress', 'completed']::text[],
  'stage progress contains no locked or available state'
);
select is(
  (
    select array_agg(value.enumlabel::text order by value.enumsortorder)
    from pg_type type
    join pg_namespace namespace on namespace.oid = type.typnamespace
    join pg_enum value on value.enumtypid = type.oid
    where namespace.nspname = 'public'
      and type.typname = 'achievement_metric'
  ),
  array[
    'completed_locations',
    'correct_answers',
    'streak_days',
    'completed_specific_location',
    'challenge_completion',
    'content_views'
  ]::text[],
  'achievement metrics use content views instead of unlock counts'
);
select has_table(
  'public',
  'location_transport_options',
  'travel transport options are structured'
);
select has_table(
  'public',
  'explorer_journeys',
  'player journeys pin a content revision'
);
select has_table(
  'public',
  'explorer_stage_progress',
  'per-stage player progress exists'
);
select has_table(
  'public',
  'explorer_xp_ledger',
  'idempotent XP ledger exists'
);
select has_table(
  'public',
  'explorer_stamps',
  'one location completion stamp can be awarded'
);
select has_table('public', 'explorer_profiles', 'private explorer profiles exist');
select has_table('public', 'user_preferences', 'synced user preferences exist');
select has_table(
  'public',
  'passport_share_links',
  'revocable passport share links exist'
);
select has_table(
  'public',
  'achievement_definitions',
  'achievement configuration exists'
);
select has_table(
  'public',
  'challenge_definitions',
  'challenge configuration exists'
);
select has_table(
  'public',
  'explorer_memories',
  'private memory journal exists'
);
select has_table(
  'public',
  'leaderboard_entries',
  'weekly leaderboard snapshots exist'
);
select has_function(
  'public',
  'record_daily_visit',
  array[]::text[],
  'interactive daily visit RPC exists'
);
select has_function(
  'public',
  'resolve_shared_passport',
  array['text', 'text'],
  'privacy-filtered passport resolver exists'
);
select has_column(
  'public',
  'level_definitions',
  'title_i18n',
  'level titles support vi, en, and ko'
);
select has_column(
  'public',
  'achievement_definitions',
  'title_i18n',
  'achievement titles are localized'
);
select has_column(
  'public',
  'achievement_definitions',
  'description_i18n',
  'achievement descriptions are localized'
);
select has_function(
  'public',
  'get_my_progress',
  array['text'],
  'server-authoritative progress read RPC exists'
);
select has_function(
  'public',
  'get_my_achievements',
  array['text'],
  'achievement collection read RPC exists'
);
select has_function(
  'public',
  'get_my_passport',
  array['text'],
  'private passport read RPC exists'
);
select has_function(
  'public',
  'complete_location_stage',
  array['text', 'integer', 'text'],
  'idempotent stage completion RPC exists'
);
select has_function(
  'public',
  'reset_my_progress',
  array['text'],
  'transactional personal reset RPC exists'
);
select is(
  (select count(*) from public.level_definitions where is_active),
  8::bigint,
  'MVP seeds eight active levels'
);
select is(
  (select count(*) from public.achievement_definitions where is_active),
  8::bigint,
  'MVP seeds eight active achievements'
);
select has_function(
  'public',
  'admin_get_game_config',
  array[]::text[],
  'admin game configuration RPC exists'
);
select has_function(
  'public',
  'record_content_view',
  array['content_view_kind', 'uuid', 'uuid'],
  'unique content view RPC exists'
);
select has_function(
  'public',
  'get_published_location',
  array['text', 'text'],
  'published location detail RPC exists'
);
select has_function(
  'public',
  'save_location_section_with_galleries',
  array['uuid', 'integer', 'text', 'jsonb'],
  'gallery-aware section save RPC exists'
);
select has_function(
  'public',
  'validate_location_revision_with_galleries',
  array['uuid'],
  'gallery-aware publication validator exists'
);
select has_function(
  'public',
  'join_challenge',
  array['uuid'],
  'challenge enrollment RPC exists'
);
select has_function(
  'public',
  'claim_challenge_reward',
  array['uuid'],
  'idempotent challenge reward RPC exists'
);
select is(
  private.word_count('mot hai ba'),
  3,
  'word count helper supports publication length rules'
);
select like(
  pg_get_functiondef('public.validate_location_revision(uuid)'::regprocedure),
  '%quiz_count not between 5 and 30%',
  'publication validator accepts 5 to 30 final quiz questions'
);
select like(
  pg_get_functiondef('public.validate_location_revision(uuid)'::regprocedure),
  '%not between 2 and 6%',
  'publication validator accepts 2 to 6 single-choice answers'
);
select like(
  pg_get_functiondef('public.validate_location_revision(uuid)'::regprocedure),
  '%question.explanation) not between 10 and 200%',
  'publication validator accepts quiz explanations from 10 to 200 words'
);
select unlike(
  pg_get_functiondef('public.validate_location_revision(uuid)'::regprocedure),
  '%Cần ít nhất một nguồn hiển thị%',
  'publication validator does not require a content source'
);
select ok(
  not exists (
    select 1
    from public.location_history
    where media_kind = 'image'
      and not private.is_blank(media_url)
      and jsonb_array_length(image_gallery) = 0
  ),
  'existing singular history images are backfilled into galleries'
);

set local role anon;
select ok(
  jsonb_path_exists(
    public.get_published_location('gyeongbokgung', 'vi'),
    '$.history[*].media.images'
  ),
  'published content exposes media.images'
);
reset role;

select set_config(
  'request.jwt.claim.sub',
  '00000000-0000-4000-8000-000000000001',
  true
);
set local role authenticated;

select ok(public.is_admin(), 'seeded local user is an admin');
select lives_ok(
  $$select public.create_location_draft('test-location', '{}'::jsonb)$$,
  'admin can create an incomplete draft'
);
select lives_ok(
  $$
    select public.save_location_section_with_galleries(
      (select id from public.location_revisions
       where location_id = (select id from public.locations where slug = 'test-location')
         and status = 'draft'),
      (select lock_version from public.location_revisions
       where location_id = (select id from public.locations where slug = 'test-location')
         and status = 'draft'),
      'history',
      '[{
        "title":"Legacy image",
        "media_kind":"image",
        "media_url":"https://example.com/legacy.jpg",
        "media_credit":"Legacy",
        "media_source_url":"https://example.com/source",
        "media_alt":"Legacy alt"
      }]'::jsonb
    )
  $$,
  'gallery-aware save accepts a legacy singular-image payload'
);
select ok(
  (
    select image_gallery -> 0 ->> 'url' = 'https://example.com/legacy.jpg'
    from public.location_history
    where revision_id = (
      select revision.id
      from public.location_revisions revision
      join public.locations location on location.id = revision.location_id
      where location.slug = 'test-location' and revision.status = 'draft'
    )
  ),
  'legacy singular image is normalized into a one-item gallery'
);
select lives_ok(
  $$
    select public.save_location_section_with_galleries(
      (select id from public.location_revisions
       where location_id = (select id from public.locations where slug = 'test-location')
         and status = 'draft'),
      (select lock_version from public.location_revisions
       where location_id = (select id from public.locations where slug = 'test-location')
         and status = 'draft'),
      'history',
      '[{
        "title":"Gallery",
        "media_kind":"image",
        "image_gallery":[
          {"url":"https://example.com/first.jpg","credit":"First","source_url":"https://example.com/1","alt":"First"},
          {"url":"https://example.com/second.jpg","credit":"Second","source_url":"https://example.com/2","alt":"Second"}
        ]
      }]'::jsonb
    )
  $$,
  'gallery-aware save accepts a multi-image payload'
);
select ok(
  (
    select jsonb_array_length(image_gallery) = 2
      and image_gallery -> 1 ->> 'url' = 'https://example.com/second.jpg'
      and media_url = 'https://example.com/first.jpg'
    from public.location_history
    where revision_id = (
      select revision.id
      from public.location_revisions revision
      join public.locations location on location.id = revision.location_id
      where location.slug = 'test-location' and revision.status = 'draft'
    )
  ),
  'multi-image save keeps order and mirrors its first image for compatibility'
);
select ok(
  cardinality(
    public.validate_location_revision_with_galleries(
      (select id from public.location_revisions where status = 'draft' limit 1)
    )
  ) > 0,
  'incomplete draft returns publication errors'
);
update public.location_history
set image_gallery = jsonb_set(image_gallery, '{0,url}', '"ftp://invalid.example/image.jpg"')
where revision_id = (
  select revision.id
  from public.location_revisions revision
  join public.locations location on location.id = revision.location_id
  where location.slug = 'test-location' and revision.status = 'draft'
);
select ok(
  private.content_image_gallery_errors(
    (
      select revision.id
      from public.location_revisions revision
      join public.locations location on location.id = revision.location_id
      where location.slug = 'test-location' and revision.status = 'draft'
    )
  ) @> array['Thư viện ảnh Lịch sử có URL ảnh không hợp lệ.'],
  'publication validation rejects non-HTTP gallery URLs'
);
select lives_ok(
  $$
    select public.create_location_draft_from_current(
      (select id from public.locations where slug = 'gyeongbokgung')
    )
  $$,
  'creating a Draft from Published copies gallery-capable content'
);
set constraints copy_content_image_galleries immediate;
select is(
  (
    select jsonb_agg(item.image_gallery order by item.display_order)
    from public.location_history item
    join public.location_revisions revision on revision.id = item.revision_id
    join public.locations location on location.id = revision.location_id
    where location.slug = 'gyeongbokgung' and revision.status = 'draft'
  ),
  (
    select jsonb_agg(item.image_gallery order by item.display_order)
    from public.location_history item
    join public.location_revisions revision on revision.id = item.revision_id
    join public.locations location on location.id = revision.location_id
    where location.slug = 'gyeongbokgung' and revision.status = 'published'
  ),
  'Draft clone preserves gallery contents and image order'
);

reset role;

update public.location_revisions
set release_status = 'coming_soon'
where location_id = (
  select id from public.locations where slug = 'gyeongbokgung'
)
  and status = 'published';

set local role anon;

select ok(
  public.list_published_locations() @> jsonb_build_array(
    jsonb_build_object(
      'slug', 'gyeongbokgung',
      'release_status', 'coming_soon'
    )
  ),
  'coming-soon location remains visible in the public summary'
);
select is(
  public.get_published_location('gyeongbokgung'),
  null::jsonb,
  'coming-soon location detail is not directly accessible'
);
select is(
  (
    select count(*)
    from public.location_revisions revision
    join public.locations location on location.id = revision.location_id
    where location.slug = 'gyeongbokgung'
      and revision.status = 'published'
  ),
  0::bigint,
  'coming-soon revision content is hidden by RLS'
);

select is(
  (select count(*) from public.locations where slug = 'test-location'),
  0::bigint,
  'anonymous users cannot read drafts'
);

select * from finish();
rollback;
