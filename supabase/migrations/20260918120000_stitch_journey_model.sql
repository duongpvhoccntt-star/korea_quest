-- Align the CMS and gameplay model with the nine-stage Stitch journey.
-- Existing published revisions stay immutable; player journeys pin a revision.

create type public.location_release_status as enum ('coming_soon', 'released');
create type public.source_verification_status as enum (
  'unverified',
  'verified',
  'needs_review'
);
create type public.culture_guideline_kind as enum ('do', 'dont');
create type public.transport_mode as enum ('metro', 'bus', 'taxi', 'walk', 'other');
create type public.journey_stage as enum (
  'opening',
  'overview',
  'history',
  'highlights',
  'experiences',
  'foods',
  'fun_facts',
  'final_quiz',
  'travel'
);
create type public.journey_status as enum ('in_progress', 'completed', 'abandoned');
create type public.stage_progress_status as enum (
  'locked',
  'available',
  'in_progress',
  'completed'
);
create type public.quiz_attempt_status as enum ('in_progress', 'submitted');
create type public.xp_reason as enum (
  'first_correct_answer',
  'first_quiz_pass',
  'location_completed',
  'achievement'
);

alter table public.location_revisions
  add column english_name text not null default '',
  add column region text not null default '',
  add column categories text[] not null default '{}',
  add column release_status public.location_release_status not null default 'coming_soon',
  add column estimated_duration_minutes integer,
  add column published_at timestamptz,
  add column cover_image_alt text not null default '',
  add column thumbnail_url text not null default '',
  add column thumbnail_credit text not null default '',
  add column thumbnail_source_url text not null default '',
  add column thumbnail_alt text not null default '',
  add column hook_media_kind public.content_media_kind not null default 'youtube',
  add column hook_media_url text not null default '',
  add column hook_media_credit text not null default '',
  add column hook_media_source_url text not null default '',
  add column hook_media_alt text not null default '',
  add column stamp_name text not null default '',
  add column stamp_description text not null default '',
  add column stamp_image_url text not null default '',
  add column stamp_image_credit text not null default '',
  add column stamp_image_source_url text not null default '',
  add column stamp_image_alt text not null default '',
  add column experience_featured_fact text not null default '',
  add column accessibility_info text not null default '',
  add column travel_official_source_url text not null default '',
  add constraint location_revisions_estimated_duration_positive
    check (estimated_duration_minutes is null or estimated_duration_minutes > 0);

update public.location_revisions
set hook_media_url = hook_video_url,
    hook_media_credit = hook_video_credit,
    hook_media_source_url = cover_image_source_url
where hook_video_url <> '';

alter table public.location_sources
  add column verification_status public.source_verification_status
    not null default 'unverified',
  add column verified_at date,
  add column is_official boolean not null default false,
  add column is_visible boolean not null default true;

alter table public.location_quick_facts
  add column is_visible boolean not null default true;

alter table public.location_history
  add column categories text[] not null default '{}',
  add column media_alt text not null default '',
  add column is_visible boolean not null default true;

alter table public.location_highlights
  add column categories text[] not null default '{}',
  add column media_alt text not null default '',
  add column is_visible boolean not null default true;

alter table public.location_experiences
  add column media_alt text not null default '',
  add column is_visible boolean not null default true;

alter table public.location_foods
  add column image_alt text not null default '',
  add column is_visible boolean not null default true;

alter table public.location_fun_facts
  add column title text not null default '',
  add column category text not null default '',
  add column icon_name text not null default '',
  add column media_kind public.content_media_kind not null default 'image',
  add column media_url text not null default '',
  add column media_credit text not null default '',
  add column media_source_url text not null default '',
  add column media_alt text not null default '',
  add column unlock_after_stage smallint not null default 1,
  add column is_visible boolean not null default true,
  add constraint location_fun_facts_unlock_stage_range
    check (unlock_after_stage between 1 and 7);

alter table public.quiz_questions
  add column media_alt text not null default '',
  add column is_visible boolean not null default true;

alter table public.quiz_questions
  drop constraint quiz_questions_media_complete,
  add constraint quiz_questions_media_identity_complete check (
    (media_kind is null and media_url is null)
    or (media_kind is not null and media_url is not null)
  );

-- The product now has one final quiz only. Old Check-in/Culture questions are
-- intentionally removed; final-quiz questions are retained.
delete from public.quiz_questions where stage <> 'final_quiz';
drop index public.quiz_questions_revision_idx;
alter table public.quiz_questions drop column stage;
drop type public.quiz_stage;
create index quiz_questions_revision_idx
  on public.quiz_questions (revision_id, display_order);

create table public.location_culture_guidelines (
  id uuid primary key default gen_random_uuid(),
  revision_id uuid not null references public.location_revisions (id) on delete cascade,
  kind public.culture_guideline_kind not null,
  content text not null default '',
  display_order integer not null default 0,
  is_visible boolean not null default true,
  constraint location_culture_guidelines_order_nonnegative
    check (display_order >= 0),
  unique (revision_id, kind, display_order)
);

create table public.location_transport_options (
  id uuid primary key default gen_random_uuid(),
  revision_id uuid not null references public.location_revisions (id) on delete cascade,
  mode public.transport_mode not null default 'other',
  title text not null default '',
  instructions text not null default '',
  tip text not null default '',
  is_recommended boolean not null default false,
  is_visible boolean not null default true,
  display_order integer not null default 0,
  constraint location_transport_options_order_nonnegative
    check (display_order >= 0),
  unique (revision_id, display_order)
);

create table public.location_visitor_notes (
  id uuid primary key default gen_random_uuid(),
  revision_id uuid not null references public.location_revisions (id) on delete cascade,
  content text not null default '',
  is_visible boolean not null default true,
  display_order integer not null default 0,
  constraint location_visitor_notes_order_nonnegative
    check (display_order >= 0),
  unique (revision_id, display_order)
);

create index location_culture_guidelines_revision_idx
  on public.location_culture_guidelines (revision_id, kind, display_order);
create index location_transport_options_revision_idx
  on public.location_transport_options (revision_id, display_order);
create index location_visitor_notes_revision_idx
  on public.location_visitor_notes (revision_id, display_order);

create table public.explorer_journeys (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  location_id uuid not null references public.locations (id) on delete restrict,
  revision_id uuid not null references public.location_revisions (id) on delete restrict,
  status public.journey_status not null default 'in_progress',
  current_stage public.journey_stage not null default 'opening',
  started_at timestamptz not null default now(),
  completed_at timestamptz,
  updated_at timestamptz not null default now(),
  constraint explorer_journeys_completion_consistent check (
    (status = 'completed' and completed_at is not null)
    or (status <> 'completed' and completed_at is null)
  ),
  unique (user_id, location_id, revision_id)
);

create table public.explorer_stage_progress (
  id uuid primary key default gen_random_uuid(),
  journey_id uuid not null references public.explorer_journeys (id) on delete cascade,
  stage public.journey_stage not null,
  status public.stage_progress_status not null default 'locked',
  started_at timestamptz,
  completed_at timestamptz,
  unique (journey_id, stage)
);

create table public.explorer_quiz_attempts (
  id uuid primary key default gen_random_uuid(),
  journey_id uuid not null references public.explorer_journeys (id) on delete cascade,
  attempt_number integer not null,
  status public.quiz_attempt_status not null default 'in_progress',
  correct_count integer not null default 0,
  question_count integer not null default 0,
  score_percent numeric(5,2) not null default 0,
  passed boolean not null default false,
  started_at timestamptz not null default now(),
  submitted_at timestamptz,
  constraint explorer_quiz_attempt_number_positive check (attempt_number > 0),
  constraint explorer_quiz_counts_valid check (
    question_count >= 0 and correct_count between 0 and question_count
  ),
  constraint explorer_quiz_score_range check (score_percent between 0 and 100),
  unique (journey_id, attempt_number)
);

create table public.explorer_quiz_answers (
  id uuid primary key default gen_random_uuid(),
  attempt_id uuid not null references public.explorer_quiz_attempts (id) on delete cascade,
  question_id uuid not null references public.quiz_questions (id) on delete restrict,
  submitted_answer jsonb not null default '{}'::jsonb,
  is_correct boolean not null,
  awarded_xp integer not null default 0,
  answered_at timestamptz not null default now(),
  constraint explorer_quiz_answer_xp_valid check (awarded_xp in (0, 10)),
  unique (attempt_id, question_id)
);

create table public.explorer_fun_fact_unlocks (
  user_id uuid not null references auth.users (id) on delete cascade,
  fun_fact_id uuid not null references public.location_fun_facts (id) on delete restrict,
  journey_id uuid not null references public.explorer_journeys (id) on delete cascade,
  unlocked_at timestamptz not null default now(),
  read_at timestamptz,
  primary key (user_id, fun_fact_id)
);

create table public.explorer_saved_locations (
  user_id uuid not null references auth.users (id) on delete cascade,
  location_id uuid not null references public.locations (id) on delete cascade,
  saved_at timestamptz not null default now(),
  primary key (user_id, location_id)
);

create table public.explorer_saved_highlights (
  user_id uuid not null references auth.users (id) on delete cascade,
  highlight_id uuid not null references public.location_highlights (id) on delete cascade,
  saved_at timestamptz not null default now(),
  primary key (user_id, highlight_id)
);

create table public.explorer_stamps (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  location_id uuid not null references public.locations (id) on delete restrict,
  revision_id uuid not null references public.location_revisions (id) on delete restrict,
  journey_id uuid not null unique references public.explorer_journeys (id) on delete restrict,
  awarded_at timestamptz not null default now(),
  unique (user_id, location_id)
);

create table public.explorer_xp_ledger (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  journey_id uuid references public.explorer_journeys (id) on delete restrict,
  amount integer not null,
  reason public.xp_reason not null,
  reference_key text not null,
  awarded_at timestamptz not null default now(),
  constraint explorer_xp_amount_positive check (amount > 0),
  unique (user_id, reference_key)
);

create index explorer_journeys_user_idx
  on public.explorer_journeys (user_id, status, updated_at desc);
create index explorer_stage_progress_journey_idx
  on public.explorer_stage_progress (journey_id, stage);
create index explorer_quiz_attempts_journey_idx
  on public.explorer_quiz_attempts (journey_id, attempt_number desc);
create index explorer_xp_ledger_user_idx
  on public.explorer_xp_ledger (user_id, awarded_at desc);

alter table public.location_culture_guidelines enable row level security;
alter table public.location_transport_options enable row level security;
alter table public.location_visitor_notes enable row level security;
alter table public.explorer_journeys enable row level security;
alter table public.explorer_stage_progress enable row level security;
alter table public.explorer_quiz_attempts enable row level security;
alter table public.explorer_quiz_answers enable row level security;
alter table public.explorer_fun_fact_unlocks enable row level security;
alter table public.explorer_saved_locations enable row level security;
alter table public.explorer_saved_highlights enable row level security;
alter table public.explorer_stamps enable row level security;
alter table public.explorer_xp_ledger enable row level security;

create policy location_culture_guidelines_admin_access
on public.location_culture_guidelines for all to authenticated
using (public.is_admin()) with check (public.is_admin());
create policy location_culture_guidelines_published_read
on public.location_culture_guidelines for select to anon, authenticated
using (public.can_read_revision(revision_id));

create policy location_transport_options_admin_access
on public.location_transport_options for all to authenticated
using (public.is_admin()) with check (public.is_admin());
create policy location_transport_options_published_read
on public.location_transport_options for select to anon, authenticated
using (public.can_read_revision(revision_id));

create policy location_visitor_notes_admin_access
on public.location_visitor_notes for all to authenticated
using (public.is_admin()) with check (public.is_admin());
create policy location_visitor_notes_published_read
on public.location_visitor_notes for select to anon, authenticated
using (public.can_read_revision(revision_id));

create policy explorer_journeys_own_read
on public.explorer_journeys for select to authenticated
using (user_id = auth.uid());
create policy explorer_stage_progress_own_read
on public.explorer_stage_progress for select to authenticated
using (exists (
  select 1 from public.explorer_journeys journey
  where journey.id = journey_id and journey.user_id = auth.uid()
));
create policy explorer_quiz_attempts_own_read
on public.explorer_quiz_attempts for select to authenticated
using (exists (
  select 1 from public.explorer_journeys journey
  where journey.id = journey_id and journey.user_id = auth.uid()
));
create policy explorer_quiz_answers_own_read
on public.explorer_quiz_answers for select to authenticated
using (exists (
  select 1
  from public.explorer_quiz_attempts attempt
  join public.explorer_journeys journey on journey.id = attempt.journey_id
  where attempt.id = attempt_id and journey.user_id = auth.uid()
));
create policy explorer_fun_fact_unlocks_own_read
on public.explorer_fun_fact_unlocks for select to authenticated
using (user_id = auth.uid());
create policy explorer_saved_locations_own_access
on public.explorer_saved_locations for all to authenticated
using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy explorer_saved_highlights_own_access
on public.explorer_saved_highlights for all to authenticated
using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy explorer_stamps_own_read
on public.explorer_stamps for select to authenticated
using (user_id = auth.uid());
create policy explorer_xp_ledger_own_read
on public.explorer_xp_ledger for select to authenticated
using (user_id = auth.uid());

revoke all on table public.location_culture_guidelines from anon, authenticated;
revoke all on table public.location_transport_options from anon, authenticated;
revoke all on table public.location_visitor_notes from anon, authenticated;
grant select on table public.location_culture_guidelines to anon, authenticated;
grant select on table public.location_transport_options to anon, authenticated;
grant select on table public.location_visitor_notes to anon, authenticated;

revoke all on table public.explorer_journeys from anon, authenticated;
revoke all on table public.explorer_stage_progress from anon, authenticated;
revoke all on table public.explorer_quiz_attempts from anon, authenticated;
revoke all on table public.explorer_quiz_answers from anon, authenticated;
revoke all on table public.explorer_fun_fact_unlocks from anon, authenticated;
revoke all on table public.explorer_saved_locations from anon, authenticated;
revoke all on table public.explorer_saved_highlights from anon, authenticated;
revoke all on table public.explorer_stamps from anon, authenticated;
revoke all on table public.explorer_xp_ledger from anon, authenticated;
grant select on table public.explorer_journeys to authenticated;
grant select on table public.explorer_stage_progress to authenticated;
grant select on table public.explorer_quiz_attempts to authenticated;
grant select on table public.explorer_quiz_answers to authenticated;
grant select on table public.explorer_fun_fact_unlocks to authenticated;
grant select, insert, delete on table public.explorer_saved_locations to authenticated;
grant select, insert, delete on table public.explorer_saved_highlights to authenticated;
grant select on table public.explorer_stamps to authenticated;
grant select on table public.explorer_xp_ledger to authenticated;

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
      prerequisite_location_id =
        nullif(payload ->> 'prerequisite_location_id', '')::uuid,
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

create or replace function public.save_location_travel(
  revision_id uuid,
  expected_lock_version integer,
  payload jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  item jsonb;
  item_order integer := 0;
  next_lock_version integer;
begin
  perform private.lock_draft(revision_id, expected_lock_version);

  update public.location_revisions
  set opening_hours = coalesce(payload ->> 'opening_hours', ''),
      ticket_price = coalesce(payload ->> 'ticket_price', ''),
      recommended_duration = coalesce(payload ->> 'recommended_duration', ''),
      best_time_to_visit = coalesce(payload ->> 'best_time_to_visit', ''),
      accessibility_info = coalesce(payload ->> 'accessibility_info', ''),
      travel_official_source_url =
        coalesce(payload ->> 'official_source_url', ''),
      travel_last_verified_at =
        nullif(payload ->> 'last_verified_at', '')::date
  where id = revision_id;

  delete from public.location_transport_options
  where location_transport_options.revision_id = save_location_travel.revision_id;
  for item in
    select value
    from jsonb_array_elements(
      coalesce(payload -> 'transport_options', '[]'::jsonb)
    )
  loop
    insert into public.location_transport_options (
      revision_id, mode, title, instructions, tip,
      is_recommended, is_visible, display_order
    ) values (
      revision_id,
      coalesce(
        nullif(item ->> 'mode', '')::public.transport_mode,
        'other'
      ),
      coalesce(item ->> 'title', ''),
      coalesce(item ->> 'instructions', ''),
      coalesce(item ->> 'tip', ''),
      coalesce((item ->> 'is_recommended')::boolean, false),
      coalesce((item ->> 'is_visible')::boolean, true),
      item_order
    );
    item_order := item_order + 1;
  end loop;

  item_order := 0;
  delete from public.location_visitor_notes
  where location_visitor_notes.revision_id = save_location_travel.revision_id;
  for item in
    select value
    from jsonb_array_elements(
      coalesce(payload -> 'visitor_notes', '[]'::jsonb)
    )
  loop
    insert into public.location_visitor_notes (
      revision_id, content, is_visible, display_order
    ) values (
      revision_id,
      coalesce(item ->> 'content', ''),
      coalesce((item ->> 'is_visible')::boolean, true),
      item_order
    );
    item_order := item_order + 1;
  end loop;

  next_lock_version := private.finish_edit(revision_id);
  return jsonb_build_object('lock_version', next_lock_version);
end;
$$;

create or replace function public.save_location_experience_guide(
  revision_id uuid,
  expected_lock_version integer,
  payload jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  item text;
  item_order integer := 0;
  next_lock_version integer;
begin
  perform private.lock_draft(revision_id, expected_lock_version);

  update public.location_revisions
  set experience_featured_fact = coalesce(payload ->> 'featured_fact', '')
  where id = revision_id;

  delete from public.location_culture_guidelines
  where location_culture_guidelines.revision_id =
    save_location_experience_guide.revision_id;

  for item in
    select jsonb_array_elements_text(coalesce(payload -> 'dos', '[]'::jsonb))
  loop
    insert into public.location_culture_guidelines (
      revision_id, kind, content, display_order
    ) values (revision_id, 'do', item, item_order);
    item_order := item_order + 1;
  end loop;

  item_order := 0;
  for item in
    select jsonb_array_elements_text(coalesce(payload -> 'donts', '[]'::jsonb))
  loop
    insert into public.location_culture_guidelines (
      revision_id, kind, content, display_order
    ) values (revision_id, 'dont', item, item_order);
    item_order := item_order + 1;
  end loop;

  next_lock_version := private.finish_edit(revision_id);
  return jsonb_build_object('lock_version', next_lock_version);
end;
$$;

revoke all on function public.save_location_experience_guide(
  uuid, integer, jsonb
) from public;
grant execute on function public.save_location_experience_guide(
  uuid, integer, jsonb
) to authenticated;

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
        unlock_after_stage, is_visible, display_order
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
        coalesce(nullif(item ->> 'unlock_after_stage', '')::smallint, 1),
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

  if revision.prerequisite_location_id is not null and not exists (
    select 1
    from public.location_revisions prerequisite
    join public.locations prerequisite_location
      on prerequisite_location.id = prerequisite.location_id
    where prerequisite.location_id = revision.prerequisite_location_id
      and prerequisite.status = 'published'
      and prerequisite_location.archived_at is null
  ) then
    errors := array_append(
      errors,
      'Địa điểm tiên quyết phải đang được Xuất bản.'
    );
  end if;

  return errors;
end;
$$;

create or replace function private.set_revision_published_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.status = 'published' and old.status <> 'published' then
    new.published_at := coalesce(new.published_at, now());
  end if;
  return new;
end;
$$;

create trigger location_revisions_set_published_at
before update of status on public.location_revisions
for each row execute function private.set_revision_published_at();

update public.location_revisions
set published_at = updated_at
where status = 'published' and published_at is null;

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
      'prerequisite_location_id', revision.prerequisite_location_id,
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
    media_credit, media_source_url, media_alt, unlock_after_stage, is_visible,
    display_order
  )
  select new_revision_id, title, fact, category, icon_name, media_kind,
    media_url, media_credit, media_source_url, media_alt, unlock_after_stage,
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
