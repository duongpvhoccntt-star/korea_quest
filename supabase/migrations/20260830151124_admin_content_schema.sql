create extension if not exists pgcrypto with schema extensions;

create schema if not exists private;
revoke all on schema private from public, anon, authenticated;

create type public.location_revision_status as enum (
  'draft',
  'published',
  'archived'
);

create type public.content_media_kind as enum ('image', 'youtube');

create type public.quiz_stage as enum (
  'check_in',
  'culture',
  'final_quiz'
);

create type public.quiz_question_kind as enum (
  'single_choice',
  'true_false',
  'matching',
  'ordering'
);

create table public.admin_users (
  user_id uuid primary key references auth.users (id) on delete cascade,
  created_at timestamptz not null default now(),
  created_by uuid references auth.users (id) on delete set null
);

create table public.locations (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  archived_at timestamptz,
  created_at timestamptz not null default now(),
  created_by uuid references auth.users (id) on delete set null,
  constraint locations_slug_format check (
    slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'
  )
);

create table public.location_revisions (
  id uuid primary key default gen_random_uuid(),
  location_id uuid not null references public.locations (id) on delete cascade,
  version_number integer not null,
  status public.location_revision_status not null default 'draft',
  base_revision_id uuid references public.location_revisions (id) on delete set null,
  lock_version integer not null default 1,
  name text not null default '',
  korean_name text not null default '',
  address text not null default '',
  city text not null default '',
  country text not null default '',
  latitude double precision,
  longitude double precision,
  location_type text not null default '',
  short_description text not null default '',
  long_description text not null default '',
  cover_image_url text not null default '',
  cover_image_credit text not null default '',
  cover_image_source_url text not null default '',
  hook_video_url text not null default '',
  hook_video_credit text not null default '',
  hook_title text not null default '',
  hook_caption text not null default '',
  tags text[] not null default '{}',
  display_order integer not null default 0,
  prerequisite_location_id uuid references public.locations (id) on delete restrict,
  opening_hours text not null default '',
  ticket_price text not null default '',
  transportation text not null default '',
  recommended_duration text not null default '',
  best_time_to_visit text not null default '',
  visitor_notes text not null default '',
  travel_last_verified_at date,
  created_at timestamptz not null default now(),
  created_by uuid references auth.users (id) on delete set null,
  updated_at timestamptz not null default now(),
  updated_by uuid references auth.users (id) on delete set null,
  constraint location_revisions_version_positive check (version_number > 0),
  constraint location_revisions_lock_positive check (lock_version > 0),
  constraint location_revisions_display_order_nonnegative check (display_order >= 0),
  constraint location_revisions_latitude_range check (
    latitude is null or latitude between -90 and 90
  ),
  constraint location_revisions_longitude_range check (
    longitude is null or longitude between -180 and 180
  ),
  constraint location_revisions_not_own_prerequisite check (
    prerequisite_location_id is null or prerequisite_location_id <> location_id
  ),
  unique (location_id, version_number)
);

create unique index location_revisions_one_draft
  on public.location_revisions (location_id)
  where status = 'draft';

create unique index location_revisions_one_published
  on public.location_revisions (location_id)
  where status = 'published';

create index location_revisions_status_idx
  on public.location_revisions (status, location_id);

create table public.location_quick_facts (
  id uuid primary key default gen_random_uuid(),
  revision_id uuid not null references public.location_revisions (id) on delete cascade,
  label text not null default '',
  value text not null default '',
  display_order integer not null default 0,
  constraint location_quick_facts_order_nonnegative check (display_order >= 0),
  unique (revision_id, display_order)
);

create table public.location_sources (
  id uuid primary key default gen_random_uuid(),
  revision_id uuid not null references public.location_revisions (id) on delete cascade,
  title text not null default '',
  publisher text not null default '',
  url text not null default '',
  accessed_at date,
  display_order integer not null default 0,
  constraint location_sources_order_nonnegative check (display_order >= 0),
  unique (revision_id, display_order)
);

create table public.location_history (
  id uuid primary key default gen_random_uuid(),
  revision_id uuid not null references public.location_revisions (id) on delete cascade,
  period_label text not null default '',
  title text not null default '',
  short_description text not null default '',
  long_description text not null default '',
  related_people text,
  media_kind public.content_media_kind not null default 'image',
  media_url text not null default '',
  media_credit text not null default '',
  media_source_url text not null default '',
  fun_fact text not null default '',
  display_order integer not null default 0,
  constraint location_history_order_nonnegative check (display_order >= 0),
  unique (revision_id, display_order)
);

create table public.location_highlights (
  id uuid primary key default gen_random_uuid(),
  revision_id uuid not null references public.location_revisions (id) on delete cascade,
  name text not null default '',
  korean_name text not null default '',
  tagline text not null default '',
  short_description text not null default '',
  long_description text not null default '',
  address text not null default '',
  activities text[] not null default '{}',
  fun_fact text not null default '',
  media_kind public.content_media_kind not null default 'image',
  media_url text not null default '',
  media_credit text not null default '',
  media_source_url text not null default '',
  display_order integer not null default 0,
  constraint location_highlights_order_nonnegative check (display_order >= 0),
  unique (revision_id, display_order)
);

create table public.location_experiences (
  id uuid primary key default gen_random_uuid(),
  revision_id uuid not null references public.location_revisions (id) on delete cascade,
  name text not null default '',
  korean_name text not null default '',
  short_description text not null default '',
  long_description text not null default '',
  origin_meaning text not null default '',
  recognizable_features text[] not null default '{}',
  dos text[] not null default '{}',
  donts text[] not null default '{}',
  related_experience text not null default '',
  media_kind public.content_media_kind not null default 'image',
  media_url text not null default '',
  media_credit text not null default '',
  media_source_url text not null default '',
  display_order integer not null default 0,
  constraint location_experiences_order_nonnegative check (display_order >= 0),
  unique (revision_id, display_order)
);

create table public.location_foods (
  id uuid primary key default gen_random_uuid(),
  revision_id uuid not null references public.location_revisions (id) on delete cascade,
  name text not null default '',
  korean_name text not null default '',
  short_description text not null default '',
  long_description text not null default '',
  ingredients text[] not null default '{}',
  flavors text[] not null default '{}',
  special_feature text not null default '',
  experience_places text[] not null default '{}',
  image_url text not null default '',
  image_credit text not null default '',
  image_source_url text not null default '',
  display_order integer not null default 0,
  constraint location_foods_order_nonnegative check (display_order >= 0),
  unique (revision_id, display_order)
);

create table public.location_fun_facts (
  id uuid primary key default gen_random_uuid(),
  revision_id uuid not null references public.location_revisions (id) on delete cascade,
  fact text not null default '',
  display_order integer not null default 0,
  constraint location_fun_facts_order_nonnegative check (display_order >= 0),
  unique (revision_id, display_order)
);

create table public.quiz_questions (
  id uuid primary key default gen_random_uuid(),
  revision_id uuid not null references public.location_revisions (id) on delete cascade,
  stage public.quiz_stage not null,
  kind public.quiz_question_kind not null,
  prompt text not null default '',
  explanation text not null default '',
  media_kind public.content_media_kind,
  media_url text,
  media_credit text,
  media_source_url text,
  display_order integer not null default 0,
  constraint quiz_questions_order_nonnegative check (display_order >= 0),
  constraint quiz_questions_media_complete check (
    (media_kind is null and media_url is null and media_credit is null and media_source_url is null)
    or
    (media_kind is not null and media_url is not null and media_credit is not null and media_source_url is not null)
  ),
  unique (revision_id, display_order)
);

create unique index quiz_questions_unique_prompt
  on public.quiz_questions (revision_id, lower(btrim(prompt)));

create table public.quiz_options (
  id uuid primary key default gen_random_uuid(),
  question_id uuid not null references public.quiz_questions (id) on delete cascade,
  option_text text not null default '',
  is_correct boolean not null default false,
  display_order integer not null default 0,
  constraint quiz_options_order_nonnegative check (display_order >= 0),
  unique (question_id, display_order)
);

create table public.quiz_matching_pairs (
  id uuid primary key default gen_random_uuid(),
  question_id uuid not null references public.quiz_questions (id) on delete cascade,
  left_text text not null default '',
  right_text text not null default '',
  display_order integer not null default 0,
  constraint quiz_matching_pairs_order_nonnegative check (display_order >= 0),
  unique (question_id, display_order)
);

create table public.quiz_ordering_items (
  id uuid primary key default gen_random_uuid(),
  question_id uuid not null references public.quiz_questions (id) on delete cascade,
  item_text text not null default '',
  correct_position integer not null,
  constraint quiz_ordering_items_position_nonnegative check (correct_position >= 0),
  unique (question_id, correct_position)
);

create index location_quick_facts_revision_idx on public.location_quick_facts (revision_id);
create index location_sources_revision_idx on public.location_sources (revision_id);
create index location_history_revision_idx on public.location_history (revision_id);
create index location_highlights_revision_idx on public.location_highlights (revision_id);
create index location_experiences_revision_idx on public.location_experiences (revision_id);
create index location_foods_revision_idx on public.location_foods (revision_id);
create index location_fun_facts_revision_idx on public.location_fun_facts (revision_id);
create index quiz_questions_revision_idx on public.quiz_questions (revision_id, stage);
create index quiz_options_question_idx on public.quiz_options (question_id);
create index quiz_matching_pairs_question_idx on public.quiz_matching_pairs (question_id);
create index quiz_ordering_items_question_idx on public.quiz_ordering_items (question_id);

create or replace function private.is_blank(value text)
returns boolean
language sql
immutable
set search_path = ''
as $$
  select value is null or btrim(value) = '';
$$;

create or replace function private.is_http_url(value text)
returns boolean
language sql
immutable
set search_path = ''
as $$
  select value is not null and value ~* '^https?://[^[:space:]]+$';
$$;

create or replace function private.word_count(value text)
returns integer
language sql
immutable
set search_path = ''
as $$
  select case
    when value is null or btrim(value) = '' then 0
    else cardinality(regexp_split_to_array(btrim(value), E'\\s+'))
  end;
$$;

create or replace function private.is_youtube_url(value text)
returns boolean
language sql
immutable
set search_path = ''
as $$
  select value is not null
    and value ~* '^https?://([a-z0-9-]+\.)?(youtube\.com|youtu\.be)/[^[:space:]]+$';
$$;

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select auth.uid() is not null
    and exists (
      select 1
      from public.admin_users
      where user_id = auth.uid()
    );
$$;

revoke all on function public.is_admin() from public;
grant execute on function public.is_admin() to authenticated;

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
      and location.archived_at is null
  );
$$;

revoke all on function public.can_read_revision(uuid) from public;
grant execute on function public.can_read_revision(uuid) to anon, authenticated;

create or replace function private.prevent_published_slug_change()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.slug <> old.slug and exists (
    select 1
    from public.location_revisions
    where location_id = old.id
      and status in ('published', 'archived')
  ) then
    raise exception 'Slug không thể đổi sau lần Xuất bản đầu tiên.'
      using errcode = '22023';
  end if;
  return new;
end;
$$;

create trigger locations_prevent_published_slug_change
before update of slug on public.locations
for each row execute function private.prevent_published_slug_change();

alter table public.admin_users enable row level security;
alter table public.locations enable row level security;
alter table public.location_revisions enable row level security;
alter table public.location_quick_facts enable row level security;
alter table public.location_sources enable row level security;
alter table public.location_history enable row level security;
alter table public.location_highlights enable row level security;
alter table public.location_experiences enable row level security;
alter table public.location_foods enable row level security;
alter table public.location_fun_facts enable row level security;
alter table public.quiz_questions enable row level security;
alter table public.quiz_options enable row level security;
alter table public.quiz_matching_pairs enable row level security;
alter table public.quiz_ordering_items enable row level security;

create policy admin_users_admin_access
on public.admin_users
for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

create policy locations_admin_access
on public.locations
for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

create policy locations_published_read
on public.locations
for select
to anon, authenticated
using (
  archived_at is null
  and exists (
    select 1
    from public.location_revisions revision
    where revision.location_id = id
      and revision.status = 'published'
  )
);

create policy location_revisions_admin_access
on public.location_revisions
for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

create policy location_revisions_published_read
on public.location_revisions
for select
to anon, authenticated
using (public.can_read_revision(id));

create policy location_quick_facts_admin_access
on public.location_quick_facts
for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

create policy location_quick_facts_published_read
on public.location_quick_facts
for select
to anon, authenticated
using (public.can_read_revision(revision_id));

create policy location_sources_admin_access
on public.location_sources
for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

create policy location_history_admin_access
on public.location_history
for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

create policy location_history_published_read
on public.location_history
for select
to anon, authenticated
using (public.can_read_revision(revision_id));

create policy location_highlights_admin_access
on public.location_highlights
for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

create policy location_highlights_published_read
on public.location_highlights
for select
to anon, authenticated
using (public.can_read_revision(revision_id));

create policy location_experiences_admin_access
on public.location_experiences
for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

create policy location_experiences_published_read
on public.location_experiences
for select
to anon, authenticated
using (public.can_read_revision(revision_id));

create policy location_foods_admin_access
on public.location_foods
for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

create policy location_foods_published_read
on public.location_foods
for select
to anon, authenticated
using (public.can_read_revision(revision_id));

create policy location_fun_facts_admin_access
on public.location_fun_facts
for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

create policy location_fun_facts_published_read
on public.location_fun_facts
for select
to anon, authenticated
using (public.can_read_revision(revision_id));

create policy quiz_questions_admin_access
on public.quiz_questions
for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

create policy quiz_questions_published_read
on public.quiz_questions
for select
to anon, authenticated
using (public.can_read_revision(revision_id));

create policy quiz_options_admin_access
on public.quiz_options
for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

create policy quiz_options_published_read
on public.quiz_options
for select
to anon, authenticated
using (
  exists (
    select 1
    from public.quiz_questions question
    where question.id = quiz_options.question_id
      and public.can_read_revision(question.revision_id)
  )
);

create policy quiz_matching_pairs_admin_access
on public.quiz_matching_pairs
for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

create policy quiz_matching_pairs_published_read
on public.quiz_matching_pairs
for select
to anon, authenticated
using (
  exists (
    select 1
    from public.quiz_questions question
    where question.id = quiz_matching_pairs.question_id
      and public.can_read_revision(question.revision_id)
  )
);

create policy quiz_ordering_items_admin_access
on public.quiz_ordering_items
for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

create policy quiz_ordering_items_published_read
on public.quiz_ordering_items
for select
to anon, authenticated
using (
  exists (
    select 1
    from public.quiz_questions question
    where question.id = quiz_ordering_items.question_id
      and public.can_read_revision(question.revision_id)
  )
);

revoke all on table public.admin_users from anon, authenticated;
revoke all on table public.locations from anon, authenticated;
revoke all on table public.location_revisions from anon, authenticated;
revoke all on table public.location_quick_facts from anon, authenticated;
revoke all on table public.location_sources from anon, authenticated;
revoke all on table public.location_history from anon, authenticated;
revoke all on table public.location_highlights from anon, authenticated;
revoke all on table public.location_experiences from anon, authenticated;
revoke all on table public.location_foods from anon, authenticated;
revoke all on table public.location_fun_facts from anon, authenticated;
revoke all on table public.quiz_questions from anon, authenticated;
revoke all on table public.quiz_options from anon, authenticated;
revoke all on table public.quiz_matching_pairs from anon, authenticated;
revoke all on table public.quiz_ordering_items from anon, authenticated;

grant select on table public.admin_users to authenticated;
grant select on table public.locations to anon, authenticated;
grant select on table public.location_revisions to anon, authenticated;
grant select on table public.location_quick_facts to anon, authenticated;
grant select on table public.location_sources to authenticated;
grant select on table public.location_history to anon, authenticated;
grant select on table public.location_highlights to anon, authenticated;
grant select on table public.location_experiences to anon, authenticated;
grant select on table public.location_foods to anon, authenticated;
grant select on table public.location_fun_facts to anon, authenticated;
grant select on table public.quiz_questions to anon, authenticated;
grant select on table public.quiz_options to anon, authenticated;
grant select on table public.quiz_matching_pairs to anon, authenticated;
grant select on table public.quiz_ordering_items to anon, authenticated;

create or replace function private.assert_admin()
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not public.is_admin() then
    raise exception 'Bạn không có quyền Quản trị viên.'
      using errcode = '42501';
  end if;
end;
$$;

create or replace function private.lock_draft(
  target_revision_id uuid,
  expected_lock_version integer
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  current_status public.location_revision_status;
  current_lock_version integer;
begin
  perform private.assert_admin();

  select status, lock_version
  into current_status, current_lock_version
  from public.location_revisions
  where id = target_revision_id
  for update;

  if not found then
    raise exception 'Không tìm thấy Phiên bản nội dung.'
      using errcode = 'P0002';
  end if;

  if current_status <> 'draft' then
    raise exception 'Chỉ có thể chỉnh sửa Bản nháp.'
      using errcode = '22023';
  end if;

  if current_lock_version <> expected_lock_version then
    raise exception 'Bản nháp đã được cập nhật ở nơi khác. Hãy tải lại dữ liệu.'
      using errcode = '40001';
  end if;
end;
$$;

create or replace function private.finish_edit(target_revision_id uuid)
returns integer
language plpgsql
security definer
set search_path = ''
as $$
declare
  next_lock_version integer;
begin
  update public.location_revisions
  set lock_version = lock_version + 1,
      updated_at = now(),
      updated_by = auth.uid()
  where id = target_revision_id
  returning lock_version into next_lock_version;

  return next_lock_version;
end;
$$;

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
  select location_id
  into target_location_id
  from public.location_revisions
  where id = target_revision_id;

  if target_slug is null
    or target_slug !~ '^[a-z0-9]+(?:-[a-z0-9]+)*$' then
    raise exception 'Slug chỉ gồm chữ thường không dấu, số và dấu gạch ngang.'
      using errcode = '22023';
  end if;

  update public.locations
  set slug = target_slug
  where id = target_location_id;

  update public.location_revisions
  set name = coalesce(payload ->> 'name', ''),
      korean_name = coalesce(payload ->> 'korean_name', ''),
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
      hook_video_url = coalesce(payload ->> 'hook_video_url', ''),
      hook_video_credit = coalesce(payload ->> 'hook_video_credit', ''),
      hook_title = coalesce(payload ->> 'hook_title', ''),
      hook_caption = coalesce(payload ->> 'hook_caption', ''),
      tags = array(
        select jsonb_array_elements_text(coalesce(payload -> 'tags', '[]'::jsonb))
      ),
      display_order = coalesce(nullif(payload ->> 'display_order', '')::integer, 0),
      prerequisite_location_id = nullif(payload ->> 'prerequisite_location_id', '')::uuid
  where id = target_revision_id;

  delete from public.location_quick_facts
  where revision_id = target_revision_id;

  for item in
    select value
    from jsonb_array_elements(coalesce(payload -> 'quick_facts', '[]'::jsonb))
  loop
    insert into public.location_quick_facts (
      revision_id,
      label,
      value,
      display_order
    ) values (
      target_revision_id,
      coalesce(item ->> 'label', ''),
      coalesce(item ->> 'value', ''),
      item_order
    );
    item_order := item_order + 1;
  end loop;
end;
$$;

create or replace function public.create_location_draft(
  slug text,
  payload jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  new_location_id uuid;
  new_revision_id uuid;
begin
  perform private.assert_admin();

  if slug is null or slug !~ '^[a-z0-9]+(?:-[a-z0-9]+)*$' then
    raise exception 'Slug chỉ gồm chữ thường không dấu, số và dấu gạch ngang.'
      using errcode = '22023';
  end if;

  insert into public.locations (slug, created_by)
  values (slug, auth.uid())
  returning id into new_location_id;

  insert into public.location_revisions (
    location_id,
    version_number,
    status,
    created_by,
    updated_by
  ) values (
    new_location_id,
    1,
    'draft',
    auth.uid(),
    auth.uid()
  ) returning id into new_revision_id;

  perform private.apply_overview(new_revision_id, slug, coalesce(payload, '{}'::jsonb));

  return jsonb_build_object(
    'location_id', new_location_id,
    'revision_id', new_revision_id,
    'lock_version', 1
  );
end;
$$;

revoke all on function public.create_location_draft(text, jsonb) from public;
grant execute on function public.create_location_draft(text, jsonb) to authenticated;

create or replace function public.save_location_overview(
  revision_id uuid,
  expected_lock_version integer,
  slug text,
  payload jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  next_lock_version integer;
begin
  perform private.lock_draft(revision_id, expected_lock_version);
  perform private.apply_overview(revision_id, slug, coalesce(payload, '{}'::jsonb));
  next_lock_version := private.finish_edit(revision_id);
  return jsonb_build_object('lock_version', next_lock_version);
end;
$$;

revoke all on function public.save_location_overview(uuid, integer, text, jsonb) from public;
grant execute on function public.save_location_overview(uuid, integer, text, jsonb) to authenticated;

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
  next_lock_version integer;
begin
  perform private.lock_draft(revision_id, expected_lock_version);

  update public.location_revisions
  set opening_hours = coalesce(payload ->> 'opening_hours', ''),
      ticket_price = coalesce(payload ->> 'ticket_price', ''),
      transportation = coalesce(payload ->> 'transportation', ''),
      recommended_duration = coalesce(payload ->> 'recommended_duration', ''),
      best_time_to_visit = coalesce(payload ->> 'best_time_to_visit', ''),
      visitor_notes = coalesce(payload ->> 'visitor_notes', ''),
      travel_last_verified_at = nullif(payload ->> 'last_verified_at', '')::date
  where id = revision_id;

  next_lock_version := private.finish_edit(revision_id);
  return jsonb_build_object('lock_version', next_lock_version);
end;
$$;

revoke all on function public.save_location_travel(uuid, integer, jsonb) from public;
grant execute on function public.save_location_travel(uuid, integer, jsonb) to authenticated;

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
    delete from public.location_history where location_history.revision_id = save_location_section.revision_id;
    for item in select value from jsonb_array_elements(coalesce(items, '[]'::jsonb)) loop
      insert into public.location_history (
        revision_id, period_label, title, short_description, long_description,
        related_people, media_kind, media_url, media_credit,
        media_source_url, fun_fact, display_order
      ) values (
        revision_id,
        coalesce(item ->> 'period_label', ''),
        coalesce(item ->> 'title', ''),
        coalesce(item ->> 'short_description', ''),
        coalesce(item ->> 'long_description', ''),
        nullif(item ->> 'related_people', ''),
        coalesce(nullif(item ->> 'media_kind', '')::public.content_media_kind, 'image'),
        coalesce(item ->> 'media_url', ''),
        coalesce(item ->> 'media_credit', ''),
        coalesce(item ->> 'media_source_url', ''),
        coalesce(item ->> 'fun_fact', ''),
        item_order
      );
      item_order := item_order + 1;
    end loop;

  elsif section_name = 'highlights' then
    delete from public.location_highlights where location_highlights.revision_id = save_location_section.revision_id;
    for item in select value from jsonb_array_elements(coalesce(items, '[]'::jsonb)) loop
      insert into public.location_highlights (
        revision_id, name, korean_name, tagline, short_description,
        long_description, address, activities, fun_fact, media_kind,
        media_url, media_credit, media_source_url, display_order
      ) values (
        revision_id,
        coalesce(item ->> 'name', ''),
        coalesce(item ->> 'korean_name', ''),
        coalesce(item ->> 'tagline', ''),
        coalesce(item ->> 'short_description', ''),
        coalesce(item ->> 'long_description', ''),
        coalesce(item ->> 'address', ''),
        array(select jsonb_array_elements_text(coalesce(item -> 'activities', '[]'::jsonb))),
        coalesce(item ->> 'fun_fact', ''),
        coalesce(nullif(item ->> 'media_kind', '')::public.content_media_kind, 'image'),
        coalesce(item ->> 'media_url', ''),
        coalesce(item ->> 'media_credit', ''),
        coalesce(item ->> 'media_source_url', ''),
        item_order
      );
      item_order := item_order + 1;
    end loop;

  elsif section_name = 'experiences' then
    delete from public.location_experiences where location_experiences.revision_id = save_location_section.revision_id;
    for item in select value from jsonb_array_elements(coalesce(items, '[]'::jsonb)) loop
      insert into public.location_experiences (
        revision_id, name, korean_name, short_description, long_description,
        origin_meaning, recognizable_features, dos, donts, related_experience,
        media_kind, media_url, media_credit, media_source_url, display_order
      ) values (
        revision_id,
        coalesce(item ->> 'name', ''),
        coalesce(item ->> 'korean_name', ''),
        coalesce(item ->> 'short_description', ''),
        coalesce(item ->> 'long_description', ''),
        coalesce(item ->> 'origin_meaning', ''),
        array(select jsonb_array_elements_text(coalesce(item -> 'recognizable_features', '[]'::jsonb))),
        array(select jsonb_array_elements_text(coalesce(item -> 'dos', '[]'::jsonb))),
        array(select jsonb_array_elements_text(coalesce(item -> 'donts', '[]'::jsonb))),
        coalesce(item ->> 'related_experience', ''),
        coalesce(nullif(item ->> 'media_kind', '')::public.content_media_kind, 'image'),
        coalesce(item ->> 'media_url', ''),
        coalesce(item ->> 'media_credit', ''),
        coalesce(item ->> 'media_source_url', ''),
        item_order
      );
      item_order := item_order + 1;
    end loop;

  elsif section_name = 'foods' then
    delete from public.location_foods where location_foods.revision_id = save_location_section.revision_id;
    for item in select value from jsonb_array_elements(coalesce(items, '[]'::jsonb)) loop
      insert into public.location_foods (
        revision_id, name, korean_name, short_description, long_description,
        ingredients, flavors, special_feature, experience_places,
        image_url, image_credit, image_source_url, display_order
      ) values (
        revision_id,
        coalesce(item ->> 'name', ''),
        coalesce(item ->> 'korean_name', ''),
        coalesce(item ->> 'short_description', ''),
        coalesce(item ->> 'long_description', ''),
        array(select jsonb_array_elements_text(coalesce(item -> 'ingredients', '[]'::jsonb))),
        array(select jsonb_array_elements_text(coalesce(item -> 'flavors', '[]'::jsonb))),
        coalesce(item ->> 'special_feature', ''),
        array(select jsonb_array_elements_text(coalesce(item -> 'experience_places', '[]'::jsonb))),
        coalesce(item ->> 'image_url', ''),
        coalesce(item ->> 'image_credit', ''),
        coalesce(item ->> 'image_source_url', ''),
        item_order
      );
      item_order := item_order + 1;
    end loop;

  elsif section_name = 'fun_facts' then
    delete from public.location_fun_facts where location_fun_facts.revision_id = save_location_section.revision_id;
    for item in select value from jsonb_array_elements(coalesce(items, '[]'::jsonb)) loop
      insert into public.location_fun_facts (
        revision_id, fact, display_order
      ) values (
        revision_id,
        coalesce(item ->> 'fact', ''),
        item_order
      );
      item_order := item_order + 1;
    end loop;

  elsif section_name = 'sources' then
    delete from public.location_sources where location_sources.revision_id = save_location_section.revision_id;
    for item in select value from jsonb_array_elements(coalesce(items, '[]'::jsonb)) loop
      insert into public.location_sources (
        revision_id, title, publisher, url, accessed_at, display_order
      ) values (
        revision_id,
        coalesce(item ->> 'title', ''),
        coalesce(item ->> 'publisher', ''),
        coalesce(item ->> 'url', ''),
        nullif(item ->> 'accessed_at', '')::date,
        item_order
      );
      item_order := item_order + 1;
    end loop;

  elsif section_name = 'quiz' then
    delete from public.quiz_questions where quiz_questions.revision_id = save_location_section.revision_id;
    for item in select value from jsonb_array_elements(coalesce(items, '[]'::jsonb)) loop
      insert into public.quiz_questions (
        revision_id, stage, kind, prompt, explanation, media_kind,
        media_url, media_credit, media_source_url, display_order
      ) values (
        revision_id,
        (item ->> 'stage')::public.quiz_stage,
        (item ->> 'kind')::public.quiz_question_kind,
        coalesce(item ->> 'prompt', ''),
        coalesce(item ->> 'explanation', ''),
        nullif(item ->> 'media_kind', '')::public.content_media_kind,
        nullif(item ->> 'media_url', ''),
        nullif(item ->> 'media_credit', ''),
        nullif(item ->> 'media_source_url', ''),
        item_order
      ) returning id into question_id;

      if (item ->> 'kind') in ('single_choice', 'true_false') then
        nested_order := 0;
        for nested_item in
          select value from jsonb_array_elements(coalesce(item -> 'options', '[]'::jsonb))
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
          select value from jsonb_array_elements(coalesce(item -> 'pairs', '[]'::jsonb))
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
          select value from jsonb_array_elements(coalesce(item -> 'items', '[]'::jsonb))
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

revoke all on function public.save_location_section(uuid, integer, text, jsonb) from public;
grant execute on function public.save_location_section(uuid, integer, text, jsonb) to authenticated;

create or replace function public.validate_location_revision(revision_id uuid)
returns text[]
language plpgsql
security definer
set search_path = ''
as $$
declare
  revision public.location_revisions%rowtype;
  errors text[] := '{}';
  target_location_id uuid;
begin
  perform private.assert_admin();

  select * into revision
  from public.location_revisions
  where id = revision_id;

  if not found then
    return array['Không tìm thấy Phiên bản nội dung.'];
  end if;

  target_location_id := revision.location_id;

  if revision.status <> 'draft' then
    errors := array_append(errors, 'Chỉ Bản nháp mới có thể Xuất bản.');
  end if;

  if private.is_blank(revision.name)
    or private.is_blank(revision.korean_name)
    or private.is_blank(revision.address)
    or private.is_blank(revision.city)
    or private.is_blank(revision.country)
    or private.is_blank(revision.location_type) then
    errors := array_append(errors, 'Tổng quan còn thiếu tên, tên tiếng Hàn, địa chỉ, thành phố, quốc gia hoặc loại Địa điểm.');
  end if;

  if revision.latitude is null or revision.longitude is null then
    errors := array_append(errors, 'Tọa độ latitude và longitude là bắt buộc.');
  end if;

  if private.is_blank(revision.short_description)
    or private.is_blank(revision.long_description) then
    errors := array_append(errors, 'Mô tả ngắn và mô tả chi tiết là bắt buộc.');
  end if;

  if private.word_count(revision.short_description) not between 20 and 40
    or private.word_count(revision.long_description) not between 80 and 120 then
    errors := array_append(errors, 'Mô tả Tổng quan phải đúng khoảng 20–40 và 80–120 từ.');
  end if;

  if not private.is_http_url(revision.cover_image_url)
    or private.is_blank(revision.cover_image_credit)
    or not private.is_http_url(revision.cover_image_source_url) then
    errors := array_append(errors, 'Ảnh bìa cần URL HTTP(S), credit và URL nguồn hợp lệ.');
  end if;

  if not private.is_youtube_url(revision.hook_video_url)
    or private.is_blank(revision.hook_video_credit)
    or private.is_blank(revision.hook_title)
    or private.is_blank(revision.hook_caption) then
    errors := array_append(errors, 'Media mở đầu cần video YouTube, credit, tiêu đề và caption.');
  end if;

  if cardinality(revision.tags) < 1
    or exists (
      select 1
      from unnest(revision.tags) as tag(value)
      where private.is_blank(tag.value)
    ) then
    errors := array_append(errors, 'Cần ít nhất một tag nổi bật hợp lệ.');
  end if;

  if (
    select count(*)
    from public.location_quick_facts fact
    where fact.revision_id = validate_location_revision.revision_id
  ) < 3 then
    errors := array_append(errors, 'Cần ít nhất 3 thông tin nhanh.');
  elsif exists (
    select 1
    from public.location_quick_facts fact
    where fact.revision_id = validate_location_revision.revision_id
      and (private.is_blank(fact.label) or private.is_blank(fact.value))
  ) then
    errors := array_append(errors, 'Thông tin nhanh còn thiếu label hoặc value.');
  end if;

  if (
    select count(*)
    from public.location_sources source
    where source.revision_id = validate_location_revision.revision_id
  ) < 1 then
    errors := array_append(errors, 'Cần ít nhất một Nguồn tham khảo.');
  elsif exists (
    select 1
    from public.location_sources source
    where source.revision_id = validate_location_revision.revision_id
      and (
        private.is_blank(source.title)
        or private.is_blank(source.publisher)
        or not private.is_http_url(source.url)
        or source.accessed_at is null
      )
  ) then
    errors := array_append(errors, 'Nguồn tham khảo còn thiếu tên, nhà xuất bản, URL hoặc ngày truy cập.');
  end if;

  if (
    select count(*)
    from public.location_history history
    where history.revision_id = validate_location_revision.revision_id
  ) < 4 then
    errors := array_append(errors, 'Cần ít nhất 4 mốc lịch sử.');
  elsif exists (
    select 1
    from public.location_history history
    where history.revision_id = validate_location_revision.revision_id
      and (
        private.is_blank(history.period_label)
        or private.is_blank(history.title)
        or private.is_blank(history.short_description)
        or private.is_blank(history.long_description)
        or private.is_blank(history.fun_fact)
        or private.is_blank(history.media_credit)
        or not private.is_http_url(history.media_source_url)
        or (history.media_kind = 'image' and not private.is_http_url(history.media_url))
        or (history.media_kind = 'youtube' and not private.is_youtube_url(history.media_url))
      )
  ) then
    errors := array_append(errors, 'Một hoặc nhiều mốc lịch sử còn thiếu nội dung/media bắt buộc.');
  end if;

  if exists (
    select 1
    from public.location_history history
    where history.revision_id = validate_location_revision.revision_id
      and (
        private.word_count(history.title) not between 4 and 10
        or private.word_count(history.short_description) not between 20 and 35
        or private.word_count(history.long_description) not between 70 and 120
      )
  ) then
    errors := array_append(errors, 'Mốc lịch sử phải đúng khoảng từ cho tiêu đề và hai phần mô tả.');
  end if;

  if (
    select count(*)
    from public.location_highlights highlight
    where highlight.revision_id = validate_location_revision.revision_id
  ) < 4 then
    errors := array_append(errors, 'Cần ít nhất 4 Điểm nổi bật.');
  elsif exists (
    select 1
    from public.location_highlights highlight
    where highlight.revision_id = validate_location_revision.revision_id
      and (
        private.is_blank(highlight.name)
        or private.is_blank(highlight.korean_name)
        or private.is_blank(highlight.tagline)
        or private.is_blank(highlight.short_description)
        or private.is_blank(highlight.long_description)
        or private.is_blank(highlight.address)
        or cardinality(highlight.activities) < 1
        or private.is_blank(highlight.fun_fact)
        or private.is_blank(highlight.media_credit)
        or not private.is_http_url(highlight.media_source_url)
        or (highlight.media_kind = 'image' and not private.is_http_url(highlight.media_url))
        or (highlight.media_kind = 'youtube' and not private.is_youtube_url(highlight.media_url))
      )
  ) then
    errors := array_append(errors, 'Một hoặc nhiều Điểm nổi bật còn thiếu nội dung/media bắt buộc.');
  end if;

  if exists (
    select 1
    from public.location_highlights highlight
    where highlight.revision_id = validate_location_revision.revision_id
      and (
        private.word_count(highlight.short_description) not between 25 and 40
        or private.word_count(highlight.long_description) not between 70 and 110
      )
  ) then
    errors := array_append(errors, 'Mô tả Điểm nổi bật phải đúng khoảng 25–40 và 70–110 từ.');
  end if;

  if (
    select count(*)
    from public.location_experiences experience
    where experience.revision_id = validate_location_revision.revision_id
  ) < 3 then
    errors := array_append(errors, 'Cần ít nhất 3 trải nghiệm văn hóa.');
  elsif exists (
    select 1
    from public.location_experiences experience
    where experience.revision_id = validate_location_revision.revision_id
      and (
        private.is_blank(experience.name)
        or private.is_blank(experience.korean_name)
        or private.is_blank(experience.short_description)
        or private.is_blank(experience.long_description)
        or private.is_blank(experience.origin_meaning)
        or cardinality(experience.recognizable_features) < 1
        or private.is_blank(experience.related_experience)
        or private.is_blank(experience.media_credit)
        or not private.is_http_url(experience.media_source_url)
        or (experience.media_kind = 'image' and not private.is_http_url(experience.media_url))
        or (experience.media_kind = 'youtube' and not private.is_youtube_url(experience.media_url))
      )
  ) then
    errors := array_append(errors, 'Một hoặc nhiều trải nghiệm còn thiếu nội dung/media bắt buộc.');
  end if;

  if exists (
    select 1
    from public.location_experiences experience
    where experience.revision_id = validate_location_revision.revision_id
      and (
        private.word_count(experience.short_description) not between 25 and 40
        or private.word_count(experience.long_description) not between 70 and 120
      )
  ) then
    errors := array_append(errors, 'Mô tả Trải nghiệm phải đúng khoảng 25–40 và 70–120 từ.');
  end if;

  if (
    select count(*)
    from public.location_foods food
    where food.revision_id = validate_location_revision.revision_id
  ) < 3 then
    errors := array_append(errors, 'Cần ít nhất 3 món ăn.');
  elsif exists (
    select 1
    from public.location_foods food
    where food.revision_id = validate_location_revision.revision_id
      and (
        private.is_blank(food.name)
        or private.is_blank(food.korean_name)
        or private.is_blank(food.short_description)
        or private.is_blank(food.long_description)
        or cardinality(food.ingredients) < 1
        or cardinality(food.flavors) < 1
        or private.is_blank(food.special_feature)
        or cardinality(food.experience_places) < 1
        or not private.is_http_url(food.image_url)
        or private.is_blank(food.image_credit)
        or not private.is_http_url(food.image_source_url)
      )
  ) then
    errors := array_append(errors, 'Một hoặc nhiều món ăn còn thiếu nội dung/ảnh bắt buộc.');
  end if;

  if exists (
    select 1
    from public.location_foods food
    where food.revision_id = validate_location_revision.revision_id
      and (
        private.word_count(food.short_description) not between 20 and 30
        or private.word_count(food.long_description) not between 50 and 80
      )
  ) then
    errors := array_append(errors, 'Mô tả Món ăn phải đúng khoảng 20–30 và 50–80 từ.');
  end if;

  if (
    select count(*)
    from public.location_fun_facts fun_fact
    where fun_fact.revision_id = validate_location_revision.revision_id
  ) < 4 then
    errors := array_append(errors, 'Cần ít nhất 4 fun facts.');
  elsif exists (
    select 1
    from public.location_fun_facts fun_fact
    where fun_fact.revision_id = validate_location_revision.revision_id
      and private.is_blank(fun_fact.fact)
  ) then
    errors := array_append(errors, 'Fun fact không được để trống.');
  end if;

  if exists (
    select 1
    from public.location_fun_facts fun_fact
    where fun_fact.revision_id = validate_location_revision.revision_id
      and private.word_count(fun_fact.fact) not between 15 and 35
  ) then
    errors := array_append(errors, 'Mỗi Fun Fact phải có 15–35 từ.');
  end if;

  if private.is_blank(revision.opening_hours)
    or private.is_blank(revision.ticket_price)
    or private.is_blank(revision.transportation)
    or private.is_blank(revision.recommended_duration)
    or private.is_blank(revision.best_time_to_visit)
    or private.is_blank(revision.visitor_notes)
    or revision.travel_last_verified_at is null then
    errors := array_append(errors, 'Thông tin du lịch hoặc ngày kiểm chứng còn thiếu.');
  end if;

  if (
    select count(*)
    from public.quiz_questions question
    where question.revision_id = validate_location_revision.revision_id
      and question.stage = 'check_in'
  ) <> 5 then
    errors := array_append(errors, 'Quiz Check-in cần đúng 5 câu hỏi.');
  end if;

  if (
    select count(*)
    from public.quiz_questions question
    where question.revision_id = validate_location_revision.revision_id
      and question.stage = 'culture'
  ) <> 5 then
    errors := array_append(errors, 'Quiz Văn hóa cần đúng 5 câu hỏi.');
  end if;

  if (
    select count(*)
    from public.quiz_questions question
    where question.revision_id = validate_location_revision.revision_id
      and question.stage = 'final_quiz'
  ) <> 5 then
    errors := array_append(errors, 'Quiz tổng kết riêng cần đúng 5 câu hỏi.');
  end if;

  if exists (
    select 1
    from public.quiz_questions question
    where question.revision_id = validate_location_revision.revision_id
      and (
        private.is_blank(question.prompt)
        or private.is_blank(question.explanation)
        or (
          question.media_kind = 'image'
          and (
            not private.is_http_url(question.media_url)
            or private.is_blank(question.media_credit)
            or not private.is_http_url(question.media_source_url)
          )
        )
        or (
          question.media_kind = 'youtube'
          and (
            not private.is_youtube_url(question.media_url)
            or private.is_blank(question.media_credit)
            or not private.is_http_url(question.media_source_url)
          )
        )
      )
  ) then
    errors := array_append(errors, 'Một hoặc nhiều Câu hỏi còn thiếu đề bài, giải thích hoặc media hợp lệ.');
  end if;

  if exists (
    select 1
    from public.quiz_questions question
    where question.revision_id = validate_location_revision.revision_id
      and private.word_count(question.explanation) not between 25 and 50
  ) then
    errors := array_append(errors, 'Giải thích mỗi đáp án phải có 25–50 từ.');
  end if;

  if exists (
    select 1
    from public.quiz_questions question
    where question.revision_id = validate_location_revision.revision_id
      and question.kind = 'single_choice'
      and (
        (select count(*) from public.quiz_options option where option.question_id = question.id) not between 3 and 4
        or (select count(*) from public.quiz_options option where option.question_id = question.id and option.is_correct) <> 1
        or exists (
          select 1 from public.quiz_options option
          where option.question_id = question.id and private.is_blank(option.option_text)
        )
      )
  ) then
    errors := array_append(errors, 'Câu single-choice cần 3–4 lựa chọn và đúng chính xác một đáp án.');
  end if;

  if exists (
    select 1
    from public.quiz_questions question
    where question.revision_id = validate_location_revision.revision_id
      and question.kind = 'true_false'
      and (
        (select count(*) from public.quiz_options option where option.question_id = question.id) <> 2
        or (select count(*) from public.quiz_options option where option.question_id = question.id and option.is_correct) <> 1
        or exists (
          select 1 from public.quiz_options option
          where option.question_id = question.id and private.is_blank(option.option_text)
        )
      )
  ) then
    errors := array_append(errors, 'Câu Đúng/Sai cần hai lựa chọn và đúng chính xác một đáp án.');
  end if;

  if exists (
    select 1
    from public.quiz_questions question
    where question.revision_id = validate_location_revision.revision_id
      and question.kind = 'matching'
      and (
        (select count(*) from public.quiz_matching_pairs pair where pair.question_id = question.id) not between 3 and 6
        or exists (
          select 1 from public.quiz_matching_pairs pair
          where pair.question_id = question.id
            and (private.is_blank(pair.left_text) or private.is_blank(pair.right_text))
        )
        or (
          select count(distinct lower(btrim(pair.left_text)))
          from public.quiz_matching_pairs pair
          where pair.question_id = question.id
        ) <> (
          select count(*) from public.quiz_matching_pairs pair where pair.question_id = question.id
        )
        or (
          select count(distinct lower(btrim(pair.right_text)))
          from public.quiz_matching_pairs pair
          where pair.question_id = question.id
        ) <> (
          select count(*) from public.quiz_matching_pairs pair where pair.question_id = question.id
        )
      )
  ) then
    errors := array_append(errors, 'Câu matching cần 3–6 cặp không trống và không trùng mỗi vế.');
  end if;

  if exists (
    select 1
    from public.quiz_questions question
    where question.revision_id = validate_location_revision.revision_id
      and question.kind = 'ordering'
      and (
        (select count(*) from public.quiz_ordering_items ordering_item where ordering_item.question_id = question.id) not between 3 and 6
        or exists (
          select 1 from public.quiz_ordering_items ordering_item
          where ordering_item.question_id = question.id and private.is_blank(ordering_item.item_text)
        )
      )
  ) then
    errors := array_append(errors, 'Câu ordering cần 3–6 mục không trống.');
  end if;

  if revision.prerequisite_location_id is not null and not exists (
    select 1
    from public.location_revisions prerequisite
    join public.locations prerequisite_location on prerequisite_location.id = prerequisite.location_id
    where prerequisite.location_id = revision.prerequisite_location_id
      and prerequisite.status = 'published'
      and prerequisite_location.archived_at is null
  ) then
    errors := array_append(errors, 'Địa điểm tiên quyết phải đang được Xuất bản.');
  end if;

  if revision.prerequisite_location_id is not null and exists (
    with recursive prerequisite_chain as (
      select
        current_revision.location_id,
        current_revision.prerequisite_location_id,
        array[current_revision.location_id] as visited
      from public.location_revisions current_revision
      where current_revision.id = validate_location_revision.revision_id

      union all

      select
        next_revision.location_id,
        next_revision.prerequisite_location_id,
        chain.visited || next_revision.location_id
      from prerequisite_chain chain
      join lateral (
        select candidate.location_id, candidate.prerequisite_location_id
        from public.location_revisions candidate
        join public.locations candidate_location on candidate_location.id = candidate.location_id
        where candidate.location_id = chain.prerequisite_location_id
          and candidate.status = 'published'
          and candidate_location.archived_at is null
        limit 1
      ) next_revision on true
      where chain.prerequisite_location_id is not null
        and not next_revision.location_id = any(chain.visited)
    )
    select 1
    from prerequisite_chain
    where prerequisite_location_id = target_location_id
  ) then
    errors := array_append(errors, 'Chuỗi Địa điểm tiên quyết không được tạo vòng lặp.');
  end if;

  return errors;
end;
$$;

revoke all on function public.validate_location_revision(uuid) from public;
grant execute on function public.validate_location_revision(uuid) to authenticated;

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
  validation_errors := public.validate_location_revision(revision_id);

  if cardinality(validation_errors) > 0 then
    raise exception '%', array_to_string(validation_errors, ' | ')
      using errcode = '22023';
  end if;

  select location_id into target_location_id
  from public.location_revisions
  where id = revision_id;

  update public.location_revisions
  set status = 'archived',
      updated_at = now(),
      updated_by = auth.uid()
  where location_id = target_location_id
    and status = 'published';

  update public.location_revisions
  set status = 'published',
      updated_at = now(),
      updated_by = auth.uid()
  where id = revision_id;

  update public.locations
  set archived_at = null
  where id = target_location_id;

  return jsonb_build_object(
    'location_id', target_location_id,
    'revision_id', revision_id,
    'status', 'published'
  );
end;
$$;

revoke all on function public.publish_location_revision(uuid, integer) from public;
grant execute on function public.publish_location_revision(uuid, integer) to authenticated;

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

  if exists (
    select 1
    from public.location_revisions dependent_revision
    join public.locations dependent_location on dependent_location.id = dependent_revision.location_id
    where dependent_revision.status = 'published'
      and dependent_revision.prerequisite_location_id = archive_location.location_id
      and dependent_location.archived_at is null
  ) then
    raise exception 'Không thể Lưu trữ vì Địa điểm đang là tiên quyết của nội dung đã Xuất bản.'
      using errcode = '23503';
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

revoke all on function public.archive_location(uuid) from public;
grant execute on function public.archive_location(uuid) to authenticated;

create or replace function public.admin_list_locations()
returns table (
  location_id uuid,
  slug text,
  revision_id uuid,
  revision_status public.location_revision_status,
  version_number integer,
  lock_version integer,
  name text,
  korean_name text,
  updated_at timestamptz
)
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  perform private.assert_admin();

  return query
  select
    location.id,
    location.slug,
    chosen_revision.id,
    chosen_revision.status,
    chosen_revision.version_number,
    chosen_revision.lock_version,
    chosen_revision.name,
    chosen_revision.korean_name,
    chosen_revision.updated_at
  from public.locations location
  join lateral (
    select revision.*
    from public.location_revisions revision
    where revision.location_id = location.id
    order by
      case revision.status
        when 'draft' then 0
        when 'published' then 1
        when 'archived' then 2
      end,
      revision.version_number desc
    limit 1
  ) chosen_revision on true
  order by chosen_revision.updated_at desc, location.slug;
end;
$$;

revoke all on function public.admin_list_locations() from public;
grant execute on function public.admin_list_locations() to authenticated;

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
    raise exception 'Không tìm thấy nội dung Địa điểm.' using errcode = 'P0002';
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
      'hook_video_url', revision.hook_video_url,
      'hook_video_credit', revision.hook_video_credit,
      'hook_title', revision.hook_title,
      'hook_caption', revision.hook_caption,
      'tags', to_jsonb(revision.tags),
      'display_order', revision.display_order,
      'prerequisite_location_id', revision.prerequisite_location_id,
      'quick_facts', coalesce((
        select jsonb_agg(
          jsonb_build_object('label', fact.label, 'value', fact.value)
          order by fact.display_order
        )
        from public.location_quick_facts fact
        where fact.revision_id = revision.id
      ), '[]'::jsonb)
    ),
    'history', coalesce((
      select jsonb_agg(
        jsonb_build_object(
          'period_label', history.period_label,
          'title', history.title,
          'short_description', history.short_description,
          'long_description', history.long_description,
          'related_people', history.related_people,
          'media_kind', history.media_kind,
          'media_url', history.media_url,
          'media_credit', history.media_credit,
          'media_source_url', history.media_source_url,
          'fun_fact', history.fun_fact
        ) order by history.display_order
      )
      from public.location_history history
      where history.revision_id = revision.id
    ), '[]'::jsonb),
    'highlights', coalesce((
      select jsonb_agg(
        jsonb_build_object(
          'name', highlight.name,
          'korean_name', highlight.korean_name,
          'tagline', highlight.tagline,
          'short_description', highlight.short_description,
          'long_description', highlight.long_description,
          'address', highlight.address,
          'activities', to_jsonb(highlight.activities),
          'fun_fact', highlight.fun_fact,
          'media_kind', highlight.media_kind,
          'media_url', highlight.media_url,
          'media_credit', highlight.media_credit,
          'media_source_url', highlight.media_source_url
        ) order by highlight.display_order
      )
      from public.location_highlights highlight
      where highlight.revision_id = revision.id
    ), '[]'::jsonb),
    'experiences', coalesce((
      select jsonb_agg(
        jsonb_build_object(
          'name', experience.name,
          'korean_name', experience.korean_name,
          'short_description', experience.short_description,
          'long_description', experience.long_description,
          'origin_meaning', experience.origin_meaning,
          'recognizable_features', to_jsonb(experience.recognizable_features),
          'dos', to_jsonb(experience.dos),
          'donts', to_jsonb(experience.donts),
          'related_experience', experience.related_experience,
          'media_kind', experience.media_kind,
          'media_url', experience.media_url,
          'media_credit', experience.media_credit,
          'media_source_url', experience.media_source_url
        ) order by experience.display_order
      )
      from public.location_experiences experience
      where experience.revision_id = revision.id
    ), '[]'::jsonb),
    'foods', coalesce((
      select jsonb_agg(
        jsonb_build_object(
          'name', food.name,
          'korean_name', food.korean_name,
          'short_description', food.short_description,
          'long_description', food.long_description,
          'ingredients', to_jsonb(food.ingredients),
          'flavors', to_jsonb(food.flavors),
          'special_feature', food.special_feature,
          'experience_places', to_jsonb(food.experience_places),
          'image_url', food.image_url,
          'image_credit', food.image_credit,
          'image_source_url', food.image_source_url
        ) order by food.display_order
      )
      from public.location_foods food
      where food.revision_id = revision.id
    ), '[]'::jsonb),
    'fun_facts', coalesce((
      select jsonb_agg(
        jsonb_build_object('fact', fun_fact.fact)
        order by fun_fact.display_order
      )
      from public.location_fun_facts fun_fact
      where fun_fact.revision_id = revision.id
    ), '[]'::jsonb),
    'quiz', coalesce((
      select jsonb_agg(
        jsonb_build_object(
          'stage', question.stage,
          'kind', question.kind,
          'prompt', question.prompt,
          'explanation', question.explanation,
          'media_kind', question.media_kind,
          'media_url', question.media_url,
          'media_credit', question.media_credit,
          'media_source_url', question.media_source_url,
          'options', coalesce((
            select jsonb_agg(
              jsonb_build_object('text', option.option_text, 'is_correct', option.is_correct)
              order by option.display_order
            )
            from public.quiz_options option
            where option.question_id = question.id
          ), '[]'::jsonb),
          'pairs', coalesce((
            select jsonb_agg(
              jsonb_build_object('left', pair.left_text, 'right', pair.right_text)
              order by pair.display_order
            )
            from public.quiz_matching_pairs pair
            where pair.question_id = question.id
          ), '[]'::jsonb),
          'items', coalesce((
            select jsonb_agg(
              jsonb_build_object('text', ordering_item.item_text)
              order by ordering_item.correct_position
            )
            from public.quiz_ordering_items ordering_item
            where ordering_item.question_id = question.id
          ), '[]'::jsonb)
        ) order by question.display_order
      )
      from public.quiz_questions question
      where question.revision_id = revision.id
    ), '[]'::jsonb),
    'travel', jsonb_build_object(
      'opening_hours', revision.opening_hours,
      'ticket_price', revision.ticket_price,
      'transportation', revision.transportation,
      'recommended_duration', revision.recommended_duration,
      'best_time_to_visit', revision.best_time_to_visit,
      'visitor_notes', revision.visitor_notes,
      'last_verified_at', revision.travel_last_verified_at
    ),
    'sources', coalesce((
      select jsonb_agg(
        jsonb_build_object(
          'title', source.title,
          'publisher', source.publisher,
          'url', source.url,
          'accessed_at', source.accessed_at
        ) order by source.display_order
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

revoke all on function public.get_admin_location(uuid) from public;
grant execute on function public.get_admin_location(uuid) to authenticated;

create or replace function public.create_location_draft_from_current(location_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  existing_draft public.location_revisions%rowtype;
  source_revision public.location_revisions%rowtype;
  new_revision_id uuid;
  next_version_number integer;
  source_question record;
  new_question_id uuid;
begin
  perform private.assert_admin();

  perform 1
  from public.locations
  where id = location_id
  for update;

  if not found then
    raise exception 'Không tìm thấy Địa điểm.' using errcode = 'P0002';
  end if;

  select * into existing_draft
  from public.location_revisions
  where location_revisions.location_id = create_location_draft_from_current.location_id
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
  where location_revisions.location_id = create_location_draft_from_current.location_id
    and status in ('published', 'archived')
  order by version_number desc
  limit 1;

  if not found then
    raise exception 'Không có Phiên bản nội dung để tạo Bản nháp.'
      using errcode = 'P0002';
  end if;

  select coalesce(max(version_number), 0) + 1
  into next_version_number
  from public.location_revisions
  where location_revisions.location_id = create_location_draft_from_current.location_id;

  insert into public.location_revisions (
    location_id, version_number, status, base_revision_id,
    name, korean_name, address, city, country, latitude, longitude,
    location_type, short_description, long_description,
    cover_image_url, cover_image_credit, cover_image_source_url,
    hook_video_url, hook_video_credit, hook_title, hook_caption,
    tags, display_order, prerequisite_location_id,
    opening_hours, ticket_price, transportation, recommended_duration,
    best_time_to_visit, visitor_notes, travel_last_verified_at,
    created_by, updated_by
  ) values (
    source_revision.location_id,
    next_version_number,
    'draft',
    source_revision.id,
    source_revision.name,
    source_revision.korean_name,
    source_revision.address,
    source_revision.city,
    source_revision.country,
    source_revision.latitude,
    source_revision.longitude,
    source_revision.location_type,
    source_revision.short_description,
    source_revision.long_description,
    source_revision.cover_image_url,
    source_revision.cover_image_credit,
    source_revision.cover_image_source_url,
    source_revision.hook_video_url,
    source_revision.hook_video_credit,
    source_revision.hook_title,
    source_revision.hook_caption,
    source_revision.tags,
    source_revision.display_order,
    source_revision.prerequisite_location_id,
    source_revision.opening_hours,
    source_revision.ticket_price,
    source_revision.transportation,
    source_revision.recommended_duration,
    source_revision.best_time_to_visit,
    source_revision.visitor_notes,
    source_revision.travel_last_verified_at,
    auth.uid(),
    auth.uid()
  ) returning id into new_revision_id;

  insert into public.location_quick_facts (revision_id, label, value, display_order)
  select new_revision_id, label, value, display_order
  from public.location_quick_facts
  where revision_id = source_revision.id;

  insert into public.location_sources (revision_id, title, publisher, url, accessed_at, display_order)
  select new_revision_id, title, publisher, url, accessed_at, display_order
  from public.location_sources
  where revision_id = source_revision.id;

  insert into public.location_history (
    revision_id, period_label, title, short_description, long_description,
    related_people, media_kind, media_url, media_credit, media_source_url,
    fun_fact, display_order
  )
  select
    new_revision_id, period_label, title, short_description, long_description,
    related_people, media_kind, media_url, media_credit, media_source_url,
    fun_fact, display_order
  from public.location_history
  where revision_id = source_revision.id;

  insert into public.location_highlights (
    revision_id, name, korean_name, tagline, short_description,
    long_description, address, activities, fun_fact, media_kind,
    media_url, media_credit, media_source_url, display_order
  )
  select
    new_revision_id, name, korean_name, tagline, short_description,
    long_description, address, activities, fun_fact, media_kind,
    media_url, media_credit, media_source_url, display_order
  from public.location_highlights
  where revision_id = source_revision.id;

  insert into public.location_experiences (
    revision_id, name, korean_name, short_description, long_description,
    origin_meaning, recognizable_features, dos, donts, related_experience,
    media_kind, media_url, media_credit, media_source_url, display_order
  )
  select
    new_revision_id, name, korean_name, short_description, long_description,
    origin_meaning, recognizable_features, dos, donts, related_experience,
    media_kind, media_url, media_credit, media_source_url, display_order
  from public.location_experiences
  where revision_id = source_revision.id;

  insert into public.location_foods (
    revision_id, name, korean_name, short_description, long_description,
    ingredients, flavors, special_feature, experience_places,
    image_url, image_credit, image_source_url, display_order
  )
  select
    new_revision_id, name, korean_name, short_description, long_description,
    ingredients, flavors, special_feature, experience_places,
    image_url, image_credit, image_source_url, display_order
  from public.location_foods
  where revision_id = source_revision.id;

  insert into public.location_fun_facts (revision_id, fact, display_order)
  select new_revision_id, fact, display_order
  from public.location_fun_facts
  where revision_id = source_revision.id;

  for source_question in
    select *
    from public.quiz_questions
    where revision_id = source_revision.id
    order by display_order
  loop
    insert into public.quiz_questions (
      revision_id, stage, kind, prompt, explanation, media_kind,
      media_url, media_credit, media_source_url, display_order
    ) values (
      new_revision_id,
      source_question.stage,
      source_question.kind,
      source_question.prompt,
      source_question.explanation,
      source_question.media_kind,
      source_question.media_url,
      source_question.media_credit,
      source_question.media_source_url,
      source_question.display_order
    ) returning id into new_question_id;

    insert into public.quiz_options (question_id, option_text, is_correct, display_order)
    select new_question_id, option_text, is_correct, display_order
    from public.quiz_options
    where question_id = source_question.id;

    insert into public.quiz_matching_pairs (question_id, left_text, right_text, display_order)
    select new_question_id, left_text, right_text, display_order
    from public.quiz_matching_pairs
    where question_id = source_question.id;

    insert into public.quiz_ordering_items (question_id, item_text, correct_position)
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

revoke all on function public.create_location_draft_from_current(uuid) from public;
grant execute on function public.create_location_draft_from_current(uuid) to authenticated;
