begin;

create extension if not exists pgtap with schema extensions;

select plan(33);

select has_type(
  'public',
  'location_revision_status',
  'location revision status enum exists'
);
select has_table('public', 'admin_users', 'admin allowlist exists');
select has_table('public', 'locations', 'location identities exist');
select has_table('public', 'location_revisions', 'versioned content exists');
select has_table('public', 'quiz_questions', 'quiz questions exist');
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
select has_column(
  'public',
  'location_fun_facts',
  'unlock_after_stage',
  'fun facts can unlock after a content stage'
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
  array['text'],
  'privacy-filtered passport resolver exists'
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
select ok(
  cardinality(
    public.validate_location_revision(
      (select id from public.location_revisions where status = 'draft' limit 1)
    )
  ) > 0,
  'incomplete draft returns publication errors'
);

reset role;
set local role anon;

select is(
  (select count(*) from public.locations),
  0::bigint,
  'anonymous users cannot read drafts'
);

select * from finish();
rollback;
