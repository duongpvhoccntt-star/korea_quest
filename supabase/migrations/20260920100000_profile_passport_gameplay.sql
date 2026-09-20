-- Profile, private passport, achievements, challenges and leaderboard.
-- Personal progress remains backend-owned; admins only configure definitions.

create type public.achievement_metric as enum (
  'completed_locations',
  'correct_answers',
  'unlocked_fun_facts',
  'streak_days',
  'completed_specific_location',
  'challenge_completion',
  'content_views'
);
create type public.challenge_status as enum ('draft', 'scheduled', 'active', 'ended', 'archived');
create type public.challenge_participation_status as enum ('joined', 'completed', 'rewarded');
create type public.content_view_kind as enum ('highlight', 'experience', 'food', 'fun_fact');
create type public.leaderboard_period_status as enum ('open', 'closed');

alter type public.xp_reason add value if not exists 'challenge';

create table public.level_definitions (
  id uuid primary key default gen_random_uuid(),
  level_number integer not null unique,
  min_xp integer not null unique,
  title text not null,
  icon_url text not null default '',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint level_definitions_level_positive check (level_number > 0),
  constraint level_definitions_xp_nonnegative check (min_xp >= 0),
  constraint level_definitions_title_present check (btrim(title) <> '')
);

create table public.explorer_profiles (
  user_id uuid primary key references auth.users (id) on delete cascade,
  handle text,
  display_name text not null,
  korean_name text not null default '',
  full_name text not null default '',
  bio text not null default '',
  avatar_path text not null default '',
  city text not null default '',
  country_code text not null default 'VN',
  joined_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint explorer_profiles_handle_format check (
    handle is null or handle ~ '^[a-z0-9_][a-z0-9_.]{2,29}$'
  ),
  constraint explorer_profiles_display_name_present check (btrim(display_name) <> ''),
  constraint explorer_profiles_country_code_format check (country_code ~ '^[A-Z]{2}$')
);
create unique index explorer_profiles_handle_unique
  on public.explorer_profiles (lower(handle)) where handle is not null;

create table public.user_preferences (
  user_id uuid primary key references auth.users (id) on delete cascade,
  locale text not null default 'vi',
  timezone text not null default 'Asia/Ho_Chi_Minh',
  journey_notifications boolean not null default true,
  reduced_motion boolean not null default false,
  leaderboard_opt_in boolean not null default false,
  updated_at timestamptz not null default now(),
  constraint user_preferences_locale_present check (btrim(locale) <> ''),
  constraint user_preferences_timezone_present check (btrim(timezone) <> '')
);

create table public.explorer_progress_summary (
  user_id uuid primary key references auth.users (id) on delete cascade,
  total_xp integer not null default 0,
  current_streak integer not null default 0,
  longest_streak integer not null default 0,
  last_visit_date date,
  correct_answer_count integer not null default 0,
  completed_location_count integer not null default 0,
  unlocked_fun_fact_count integer not null default 0,
  content_view_count integer not null default 0,
  updated_at timestamptz not null default now(),
  constraint explorer_progress_summary_nonnegative check (
    total_xp >= 0 and current_streak >= 0 and longest_streak >= 0
    and correct_answer_count >= 0 and completed_location_count >= 0
    and unlocked_fun_fact_count >= 0 and content_view_count >= 0
  )
);

create table public.explorer_daily_visits (
  user_id uuid not null references auth.users (id) on delete cascade,
  local_date date not null,
  timezone text not null,
  first_seen_at timestamptz not null default now(),
  primary key (user_id, local_date)
);

create table public.passport_share_links (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  token_hash text not null unique,
  include_level_xp boolean not null default false,
  include_stamps boolean not null default true,
  include_badges boolean not null default true,
  include_recent_journey boolean not null default false,
  include_stats_streak boolean not null default false,
  created_at timestamptz not null default now(),
  revoked_at timestamptz
);
create unique index passport_share_links_one_active
  on public.passport_share_links (user_id) where revoked_at is null;

create table public.explorer_memories (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  storage_path text not null unique,
  caption text not null default '',
  location_id uuid references public.locations (id) on delete set null,
  journey_id uuid references public.explorer_journeys (id) on delete set null,
  taken_on date,
  display_order integer not null default 0,
  is_shared boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint explorer_memories_order_nonnegative check (display_order >= 0),
  constraint explorer_memories_owner_path check (
    split_part(storage_path, '/', 1) = user_id::text
  )
);

create table public.achievement_definitions (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  title text not null,
  korean_title text not null default '',
  description text not null default '',
  category text not null default 'general',
  icon_url text not null default '',
  metric public.achievement_metric not null,
  target integer not null,
  criteria_filter jsonb not null default '{}'::jsonb,
  is_secret boolean not null default false,
  is_limited boolean not null default false,
  is_active boolean not null default true,
  available_from timestamptz,
  available_until timestamptz,
  display_order integer not null default 0,
  criteria_locked_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint achievement_definitions_slug_format check (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'),
  constraint achievement_definitions_title_present check (btrim(title) <> ''),
  constraint achievement_definitions_target_positive check (target > 0),
  constraint achievement_definitions_window_valid check (
    available_until is null or available_from is null or available_until > available_from
  )
);

create table public.explorer_achievement_progress (
  user_id uuid not null references auth.users (id) on delete cascade,
  achievement_id uuid not null references public.achievement_definitions (id) on delete cascade,
  current_value integer not null default 0,
  target_value integer not null,
  updated_at timestamptz not null default now(),
  primary key (user_id, achievement_id),
  constraint explorer_achievement_progress_valid check (
    current_value >= 0 and target_value > 0
  )
);

create table public.explorer_badges (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  achievement_id uuid not null references public.achievement_definitions (id) on delete restrict,
  source_reference text not null,
  earned_at timestamptz not null default now(),
  unique (user_id, achievement_id)
);

create table public.challenge_definitions (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  title text not null,
  description text not null default '',
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  reward_xp integer not null default 0,
  reward_achievement_id uuid references public.achievement_definitions (id) on delete restrict,
  status public.challenge_status not null default 'draft',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint challenge_definitions_slug_format check (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'),
  constraint challenge_definitions_title_present check (btrim(title) <> ''),
  constraint challenge_definitions_window_valid check (ends_at > starts_at),
  constraint challenge_definitions_reward_valid check (
    reward_xp >= 0 and (reward_xp > 0 or reward_achievement_id is not null)
  )
);

create table public.challenge_goals (
  id uuid primary key default gen_random_uuid(),
  challenge_id uuid not null references public.challenge_definitions (id) on delete cascade,
  metric public.achievement_metric not null,
  target integer not null,
  criteria_filter jsonb not null default '{}'::jsonb,
  display_order integer not null default 0,
  constraint challenge_goals_target_positive check (target > 0),
  unique (challenge_id, display_order)
);

create table public.explorer_challenge_progress (
  user_id uuid not null references auth.users (id) on delete cascade,
  challenge_id uuid not null references public.challenge_definitions (id) on delete restrict,
  status public.challenge_participation_status not null default 'joined',
  joined_at timestamptz not null default now(),
  completed_at timestamptz,
  rewarded_at timestamptz,
  primary key (user_id, challenge_id)
);

create table public.explorer_challenge_goal_progress (
  user_id uuid not null,
  challenge_id uuid not null,
  goal_id uuid not null references public.challenge_goals (id) on delete cascade,
  current_value integer not null default 0,
  updated_at timestamptz not null default now(),
  primary key (user_id, goal_id),
  foreign key (user_id, challenge_id)
    references public.explorer_challenge_progress (user_id, challenge_id) on delete cascade,
  constraint explorer_challenge_goal_progress_nonnegative check (current_value >= 0)
);

create table public.explorer_content_views (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  revision_id uuid not null references public.location_revisions (id) on delete restrict,
  kind public.content_view_kind not null,
  content_id uuid not null,
  first_viewed_at timestamptz not null default now(),
  unique (user_id, kind, content_id)
);

create table public.leaderboard_periods (
  id uuid primary key default gen_random_uuid(),
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  status public.leaderboard_period_status not null default 'open',
  created_at timestamptz not null default now(),
  constraint leaderboard_periods_window_valid check (ends_at > starts_at),
  unique (starts_at, ends_at)
);

create table public.leaderboard_entries (
  id uuid primary key default gen_random_uuid(),
  period_id uuid not null references public.leaderboard_periods (id) on delete cascade,
  user_id uuid references public.explorer_profiles (user_id) on delete set null,
  score integer not null default 0,
  rank integer,
  percentile numeric(5,2),
  snapshot_display_name text not null,
  snapshot_avatar_path text not null default '',
  is_anonymized boolean not null default false,
  created_at timestamptz not null default now(),
  constraint leaderboard_entries_score_nonnegative check (score >= 0),
  constraint leaderboard_entries_rank_positive check (rank is null or rank > 0),
  constraint leaderboard_entries_percentile_valid check (
    percentile is null or percentile between 0 and 100
  )
);
create unique index leaderboard_entries_user_period_unique
  on public.leaderboard_entries (period_id, user_id) where user_id is not null;

alter table public.explorer_xp_ledger
  add column challenge_id uuid references public.challenge_definitions (id) on delete restrict,
  add column achievement_id uuid references public.achievement_definitions (id) on delete restrict;

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'explorer-memories', 'explorer-memories', false, 5242880,
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do update set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

create or replace function private.bootstrap_explorer_account()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  suggested_name text;
begin
  suggested_name := coalesce(nullif(new.raw_user_meta_data ->> 'display_name', ''), split_part(new.email, '@', 1), 'Nhà thám hiểm');
  insert into public.explorer_profiles (user_id, display_name)
  values (new.id, suggested_name) on conflict (user_id) do nothing;
  insert into public.user_preferences (user_id) values (new.id) on conflict (user_id) do nothing;
  insert into public.explorer_progress_summary (user_id) values (new.id) on conflict (user_id) do nothing;
  return new;
end;
$$;

create trigger auth_users_bootstrap_explorer_account
after insert on auth.users
for each row execute function private.bootstrap_explorer_account();

insert into public.explorer_profiles (user_id, display_name, joined_at)
select id, coalesce(nullif(raw_user_meta_data ->> 'display_name', ''), split_part(email, '@', 1), 'Nhà thám hiểm'), created_at
from auth.users on conflict (user_id) do nothing;
insert into public.user_preferences (user_id)
select id from auth.users on conflict (user_id) do nothing;
insert into public.explorer_progress_summary (user_id)
select id from auth.users on conflict (user_id) do nothing;

create or replace function private.limit_explorer_memories()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if (select count(*) from public.explorer_memories where user_id = new.user_id) >= 30 then
    raise exception 'Mỗi tài khoản chỉ được lưu tối đa 30 kỷ niệm.' using errcode = '23514';
  end if;
  return new;
end;
$$;
create trigger explorer_memories_limit
before insert on public.explorer_memories
for each row execute function private.limit_explorer_memories();

create or replace function private.lock_awarded_achievement_criteria()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if exists (select 1 from public.explorer_badges where achievement_id = old.id)
     and (new.metric, new.target, new.criteria_filter, new.is_limited, new.available_from, new.available_until)
         is distinct from
         (old.metric, old.target, old.criteria_filter, old.is_limited, old.available_from, old.available_until) then
    raise exception 'Tiêu chí Huy hiệu đã trao không thể thay đổi; hãy lưu trữ và tạo Huy hiệu mới.' using errcode = '22023';
  end if;
  return new;
end;
$$;
create trigger achievement_definitions_lock_awarded_criteria
before update on public.achievement_definitions
for each row execute function private.lock_awarded_achievement_criteria();

create or replace function private.refresh_xp_summary()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare target_user uuid := coalesce(new.user_id, old.user_id);
begin
  insert into public.explorer_progress_summary (user_id, total_xp, updated_at)
  values (
    target_user,
    coalesce((select sum(amount) from public.explorer_xp_ledger where user_id = target_user), 0),
    now()
  )
  on conflict (user_id) do update set total_xp = excluded.total_xp, updated_at = now();
  return coalesce(new, old);
end;
$$;
create trigger explorer_xp_ledger_refresh_summary
after insert or update or delete on public.explorer_xp_ledger
for each row execute function private.refresh_xp_summary();

create or replace function public.record_daily_visit()
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  target_user uuid := auth.uid();
  target_timezone text;
  today_local date;
  previous_date date;
  next_current integer;
  next_longest integer;
begin
  if target_user is null then raise exception 'Yêu cầu đăng nhập.' using errcode = '42501'; end if;
  select timezone into target_timezone from public.user_preferences where user_id = target_user;
  target_timezone := coalesce(target_timezone, 'Asia/Ho_Chi_Minh');
  today_local := (now() at time zone target_timezone)::date;
  insert into public.explorer_daily_visits (user_id, local_date, timezone)
  values (target_user, today_local, target_timezone) on conflict do nothing;
  select last_visit_date, current_streak, longest_streak
    into previous_date, next_current, next_longest
  from public.explorer_progress_summary where user_id = target_user for update;
  next_current := case
    when previous_date = today_local then next_current
    when previous_date = today_local - 1 then next_current + 1
    else 1
  end;
  next_longest := greatest(coalesce(next_longest, 0), next_current);
  update public.explorer_progress_summary set
    current_streak = next_current, longest_streak = next_longest,
    last_visit_date = today_local, updated_at = now()
  where user_id = target_user;
  return jsonb_build_object('local_date', today_local, 'current_streak', next_current, 'longest_streak', next_longest);
end;
$$;

create or replace function public.regenerate_passport_share_link(settings jsonb default '{}'::jsonb)
returns text
language plpgsql
security definer
set search_path = ''
as $$
declare
  target_user uuid := auth.uid();
  raw_token text;
begin
  if target_user is null then raise exception 'Yêu cầu đăng nhập.' using errcode = '42501'; end if;
  raw_token := replace(gen_random_uuid()::text, '-', '') || replace(gen_random_uuid()::text, '-', '');
  update public.passport_share_links set revoked_at = now()
  where user_id = target_user and revoked_at is null;
  insert into public.passport_share_links (
    user_id, token_hash, include_level_xp, include_stamps, include_badges,
    include_recent_journey, include_stats_streak
  ) values (
    target_user, encode(extensions.digest(raw_token, 'sha256'), 'hex'),
    coalesce((settings ->> 'include_level_xp')::boolean, false),
    coalesce((settings ->> 'include_stamps')::boolean, true),
    coalesce((settings ->> 'include_badges')::boolean, true),
    coalesce((settings ->> 'include_recent_journey')::boolean, false),
    coalesce((settings ->> 'include_stats_streak')::boolean, false)
  );
  return raw_token;
end;
$$;

create or replace function public.revoke_passport_share_link()
returns void
language sql
security definer
set search_path = ''
as $$
  update public.passport_share_links set revoked_at = now()
  where user_id = auth.uid() and revoked_at is null;
$$;

create or replace function public.resolve_shared_passport(raw_token text)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare link public.passport_share_links%rowtype;
begin
  select * into link from public.passport_share_links
  where token_hash = encode(extensions.digest(raw_token, 'sha256'), 'hex') and revoked_at is null;
  if link.id is null then return null; end if;
  return jsonb_build_object(
    'profile', (select jsonb_build_object(
      'handle', handle, 'display_name', display_name, 'korean_name', korean_name,
      'bio', bio, 'avatar_path', avatar_path, 'city', city, 'country_code', country_code,
      'joined_at', joined_at
    ) from public.explorer_profiles where user_id = link.user_id),
    'level_xp', case when link.include_level_xp then (
      select jsonb_build_object('total_xp', total_xp) from public.explorer_progress_summary where user_id = link.user_id
    ) end,
    'stats', case when link.include_stats_streak then (
      select to_jsonb(summary) - 'user_id' from public.explorer_progress_summary summary where user_id = link.user_id
    ) end,
    'stamps', case when link.include_stamps then coalesce((
      select jsonb_agg(jsonb_build_object('location_id', location_id, 'awarded_at', awarded_at))
      from public.explorer_stamps where user_id = link.user_id
    ), '[]'::jsonb) end,
    'badges', case when link.include_badges then coalesce((
      select jsonb_agg(jsonb_build_object('slug', definition.slug, 'title', definition.title,
        'icon_url', definition.icon_url, 'earned_at', badge.earned_at))
      from public.explorer_badges badge join public.achievement_definitions definition on definition.id = badge.achievement_id
      where badge.user_id = link.user_id
    ), '[]'::jsonb) end,
    'memories', coalesce((select jsonb_agg(jsonb_build_object(
      'storage_path', storage_path, 'caption', caption, 'taken_on', taken_on, 'display_order', display_order
    ) order by display_order) from public.explorer_memories where user_id = link.user_id and is_shared), '[]'::jsonb)
  );
end;
$$;

create or replace function private.anonymize_leaderboard_entry()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  update public.leaderboard_entries set
    snapshot_display_name = 'Nhà thám hiểm ẩn danh', snapshot_avatar_path = '', is_anonymized = true
  where user_id = old.user_id;
  return old;
end;
$$;
create trigger explorer_profiles_anonymize_leaderboard
before delete on public.explorer_profiles
for each row execute function private.anonymize_leaderboard_entry();

create or replace function public.admin_get_game_config()
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not public.is_admin() then raise exception 'Không có quyền Quản trị viên.' using errcode = '42501'; end if;
  return jsonb_build_object(
    'levels', coalesce((select jsonb_agg(to_jsonb(item) order by level_number) from public.level_definitions item), '[]'::jsonb),
    'achievements', coalesce((select jsonb_agg(to_jsonb(item) order by display_order, title) from public.achievement_definitions item), '[]'::jsonb),
    'challenges', coalesce((select jsonb_agg(to_jsonb(challenge) || jsonb_build_object(
      'goals', coalesce((select jsonb_agg(to_jsonb(goal) order by display_order) from public.challenge_goals goal where goal.challenge_id = challenge.id), '[]'::jsonb)
    ) order by starts_at desc) from public.challenge_definitions challenge), '[]'::jsonb)
  );
end;
$$;

create or replace function public.admin_save_level(payload jsonb)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare saved_id uuid;
begin
  if not public.is_admin() then raise exception 'Không có quyền Quản trị viên.' using errcode = '42501'; end if;
  insert into public.level_definitions (id, level_number, min_xp, title, icon_url, is_active, updated_at)
  values (coalesce((payload ->> 'id')::uuid, gen_random_uuid()), (payload ->> 'level_number')::integer,
    (payload ->> 'min_xp')::integer, payload ->> 'title', coalesce(payload ->> 'icon_url', ''),
    coalesce((payload ->> 'is_active')::boolean, true), now())
  on conflict (id) do update set level_number = excluded.level_number, min_xp = excluded.min_xp,
    title = excluded.title, icon_url = excluded.icon_url, is_active = excluded.is_active, updated_at = now()
  returning id into saved_id;
  return saved_id;
end;
$$;

create or replace function public.admin_save_achievement(payload jsonb)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare saved_id uuid;
begin
  if not public.is_admin() then raise exception 'Không có quyền Quản trị viên.' using errcode = '42501'; end if;
  insert into public.achievement_definitions (
    id, slug, title, korean_title, description, category, icon_url, metric, target,
    criteria_filter, is_secret, is_limited, is_active, available_from, available_until, display_order, updated_at
  ) values (
    coalesce((payload ->> 'id')::uuid, gen_random_uuid()), payload ->> 'slug', payload ->> 'title',
    coalesce(payload ->> 'korean_title', ''), coalesce(payload ->> 'description', ''),
    coalesce(payload ->> 'category', 'general'), coalesce(payload ->> 'icon_url', ''),
    (payload ->> 'metric')::public.achievement_metric, (payload ->> 'target')::integer,
    coalesce(payload -> 'criteria_filter', '{}'::jsonb), coalesce((payload ->> 'is_secret')::boolean, false),
    coalesce((payload ->> 'is_limited')::boolean, false), coalesce((payload ->> 'is_active')::boolean, true),
    (payload ->> 'available_from')::timestamptz, (payload ->> 'available_until')::timestamptz,
    coalesce((payload ->> 'display_order')::integer, 0), now()
  ) on conflict (id) do update set slug = excluded.slug, title = excluded.title,
    korean_title = excluded.korean_title, description = excluded.description, category = excluded.category,
    icon_url = excluded.icon_url, metric = excluded.metric, target = excluded.target,
    criteria_filter = excluded.criteria_filter, is_secret = excluded.is_secret,
    is_limited = excluded.is_limited, is_active = excluded.is_active,
    available_from = excluded.available_from, available_until = excluded.available_until,
    display_order = excluded.display_order, updated_at = now()
  returning id into saved_id;
  return saved_id;
end;
$$;

create or replace function public.admin_save_challenge(payload jsonb)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare saved_id uuid; goal jsonb; goal_order integer := 0;
begin
  if not public.is_admin() then raise exception 'Không có quyền Quản trị viên.' using errcode = '42501'; end if;
  if payload ? 'id' and exists (
    select 1 from public.challenge_definitions where id = (payload ->> 'id')::uuid and starts_at <= now()
  ) then
    raise exception 'Thử thách đã bắt đầu không thể đổi tiêu chí hoặc phần thưởng.' using errcode = '22023';
  end if;
  insert into public.challenge_definitions (
    id, slug, title, description, starts_at, ends_at, reward_xp, reward_achievement_id, status, updated_at
  ) values (
    coalesce((payload ->> 'id')::uuid, gen_random_uuid()), payload ->> 'slug', payload ->> 'title',
    coalesce(payload ->> 'description', ''), (payload ->> 'starts_at')::timestamptz,
    (payload ->> 'ends_at')::timestamptz, coalesce((payload ->> 'reward_xp')::integer, 0),
    (payload ->> 'reward_achievement_id')::uuid, coalesce((payload ->> 'status')::public.challenge_status, 'draft')
  ) on conflict (id) do update set slug = excluded.slug, title = excluded.title,
    description = excluded.description, starts_at = excluded.starts_at, ends_at = excluded.ends_at,
    reward_xp = excluded.reward_xp, reward_achievement_id = excluded.reward_achievement_id,
    status = excluded.status, updated_at = now()
  returning id into saved_id;
  delete from public.challenge_goals where challenge_id = saved_id;
  for goal in select value from jsonb_array_elements(coalesce(payload -> 'goals', '[]'::jsonb)) loop
    insert into public.challenge_goals (challenge_id, metric, target, criteria_filter, display_order)
    values (saved_id, (goal ->> 'metric')::public.achievement_metric, (goal ->> 'target')::integer,
      coalesce(goal -> 'criteria_filter', '{}'::jsonb), goal_order);
    goal_order := goal_order + 1;
  end loop;
  return saved_id;
end;
$$;

alter table public.level_definitions enable row level security;
alter table public.explorer_profiles enable row level security;
alter table public.user_preferences enable row level security;
alter table public.explorer_progress_summary enable row level security;
alter table public.explorer_daily_visits enable row level security;
alter table public.passport_share_links enable row level security;
alter table public.explorer_memories enable row level security;
alter table public.achievement_definitions enable row level security;
alter table public.explorer_achievement_progress enable row level security;
alter table public.explorer_badges enable row level security;
alter table public.challenge_definitions enable row level security;
alter table public.challenge_goals enable row level security;
alter table public.explorer_challenge_progress enable row level security;
alter table public.explorer_challenge_goal_progress enable row level security;
alter table public.explorer_content_views enable row level security;
alter table public.leaderboard_periods enable row level security;
alter table public.leaderboard_entries enable row level security;

create policy level_definitions_read on public.level_definitions for select to authenticated using (is_active or public.is_admin());
create policy level_definitions_admin on public.level_definitions for all to authenticated using (public.is_admin()) with check (public.is_admin());
create policy explorer_profiles_own on public.explorer_profiles for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy user_preferences_own on public.user_preferences for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy explorer_progress_summary_own on public.explorer_progress_summary for select to authenticated using (user_id = auth.uid());
create policy explorer_daily_visits_own on public.explorer_daily_visits for select to authenticated using (user_id = auth.uid());
create policy passport_share_links_own on public.passport_share_links for select to authenticated using (user_id = auth.uid());
create policy explorer_memories_own on public.explorer_memories for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy achievement_definitions_read on public.achievement_definitions for select to authenticated using (is_active or public.is_admin());
create policy achievement_definitions_admin on public.achievement_definitions for all to authenticated using (public.is_admin()) with check (public.is_admin());
create policy explorer_achievement_progress_own on public.explorer_achievement_progress for select to authenticated using (user_id = auth.uid());
create policy explorer_badges_own on public.explorer_badges for select to authenticated using (user_id = auth.uid());
create policy challenge_definitions_read on public.challenge_definitions for select to authenticated using (status <> 'archived' or public.is_admin());
create policy challenge_definitions_admin on public.challenge_definitions for all to authenticated using (public.is_admin()) with check (public.is_admin());
create policy challenge_goals_read on public.challenge_goals for select to authenticated using (exists (select 1 from public.challenge_definitions item where item.id = challenge_id and (item.status <> 'archived' or public.is_admin())));
create policy challenge_goals_admin on public.challenge_goals for all to authenticated using (public.is_admin()) with check (public.is_admin());
create policy explorer_challenge_progress_own on public.explorer_challenge_progress for select to authenticated using (user_id = auth.uid());
create policy explorer_challenge_goal_progress_own on public.explorer_challenge_goal_progress for select to authenticated using (user_id = auth.uid());
create policy explorer_content_views_own on public.explorer_content_views for select to authenticated using (user_id = auth.uid());
create policy leaderboard_periods_read on public.leaderboard_periods for select to authenticated using (true);
create policy leaderboard_entries_opt_in_read on public.leaderboard_entries for select to authenticated using (
  is_anonymized or exists (select 1 from public.user_preferences preference where preference.user_id = leaderboard_entries.user_id and preference.leaderboard_opt_in)
);

create policy explorer_memories_storage_select on storage.objects for select to authenticated
using (bucket_id = 'explorer-memories' and (storage.foldername(name))[1] = auth.uid()::text);
create policy explorer_memories_storage_insert on storage.objects for insert to authenticated
with check (bucket_id = 'explorer-memories' and (storage.foldername(name))[1] = auth.uid()::text);
create policy explorer_memories_storage_update on storage.objects for update to authenticated
using (bucket_id = 'explorer-memories' and (storage.foldername(name))[1] = auth.uid()::text)
with check (bucket_id = 'explorer-memories' and (storage.foldername(name))[1] = auth.uid()::text);
create policy explorer_memories_storage_delete on storage.objects for delete to authenticated
using (bucket_id = 'explorer-memories' and (storage.foldername(name))[1] = auth.uid()::text);

revoke all on table public.level_definitions, public.explorer_profiles,
  public.user_preferences, public.explorer_progress_summary,
  public.explorer_daily_visits, public.passport_share_links,
  public.explorer_memories, public.achievement_definitions,
  public.explorer_achievement_progress, public.explorer_badges,
  public.challenge_definitions, public.challenge_goals,
  public.explorer_challenge_progress, public.explorer_challenge_goal_progress,
  public.explorer_content_views, public.leaderboard_periods,
  public.leaderboard_entries from anon, authenticated;
grant select on public.level_definitions, public.explorer_progress_summary,
  public.explorer_daily_visits, public.passport_share_links,
  public.achievement_definitions, public.explorer_achievement_progress,
  public.explorer_badges, public.challenge_definitions, public.challenge_goals,
  public.explorer_challenge_progress, public.explorer_challenge_goal_progress,
  public.explorer_content_views, public.leaderboard_periods, public.leaderboard_entries to authenticated;
grant select, insert, update, delete on public.explorer_profiles, public.user_preferences,
  public.explorer_memories to authenticated;
grant select, insert, delete on public.explorer_saved_locations, public.explorer_saved_highlights to authenticated;
grant select on public.explorer_journeys, public.explorer_stage_progress,
  public.explorer_quiz_attempts, public.explorer_quiz_answers,
  public.explorer_fun_fact_unlocks, public.explorer_stamps, public.explorer_xp_ledger to authenticated;

revoke all on function public.record_daily_visit() from public;
revoke all on function public.regenerate_passport_share_link(jsonb) from public;
revoke all on function public.revoke_passport_share_link() from public;
revoke all on function public.resolve_shared_passport(text) from public;
revoke all on function public.admin_get_game_config() from public;
revoke all on function public.admin_save_level(jsonb) from public;
revoke all on function public.admin_save_achievement(jsonb) from public;
revoke all on function public.admin_save_challenge(jsonb) from public;
grant execute on function public.record_daily_visit() to authenticated;
grant execute on function public.regenerate_passport_share_link(jsonb) to authenticated;
grant execute on function public.revoke_passport_share_link() to authenticated;
grant execute on function public.resolve_shared_passport(text) to anon, authenticated;
grant execute on function public.admin_get_game_config() to authenticated;
grant execute on function public.admin_save_level(jsonb) to authenticated;
grant execute on function public.admin_save_achievement(jsonb) to authenticated;
grant execute on function public.admin_save_challenge(jsonb) to authenticated;
