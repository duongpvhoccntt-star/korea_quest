-- End-to-end level, achievement, passport, and gameplay reward read/write model.

-- Product-approved one-time reset. Keeping it in this transaction guarantees
-- that an RPC/schema failure also rolls the destructive reset back.
delete from public.passport_share_links;
delete from public.leaderboard_entries;
delete from public.explorer_challenge_goal_progress;
delete from public.explorer_challenge_progress;
delete from public.explorer_badges;
delete from public.explorer_achievement_progress;
delete from public.explorer_daily_visits;
delete from public.explorer_content_views;
delete from public.explorer_stamps;
delete from public.explorer_quiz_answers;
delete from public.explorer_quiz_attempts;
delete from public.explorer_stage_progress;
delete from public.explorer_xp_ledger;
delete from public.explorer_journeys;
delete from public.level_definitions;

update public.explorer_progress_summary
set total_xp = 0,
    current_streak = 0,
    longest_streak = 0,
    last_visit_date = null,
    correct_answer_count = 0,
    completed_location_count = 0,
    content_view_count = 0,
    updated_at = now();

alter table public.level_definitions
  add column if not exists title_i18n jsonb not null default '{}'::jsonb;

alter table public.achievement_definitions
  add column if not exists title_i18n jsonb not null default '{}'::jsonb,
  add column if not exists description_i18n jsonb not null default '{}'::jsonb;

alter table public.explorer_quiz_answers
  drop constraint if exists explorer_quiz_answer_xp_valid;
alter table public.explorer_quiz_answers
  add constraint explorer_quiz_answer_xp_valid check (awarded_xp in (0, 2, 10));

insert into public.level_definitions (
  level_number, min_xp, title, title_i18n, icon_url, is_active
) values
  (1, 0, 'Tân binh', '{"vi":"Tân binh","en":"Rookie","ko":"새내기"}', '', true),
  (2, 150, 'Người học việc', '{"vi":"Người học việc","en":"Apprentice","ko":"견습생"}', '', true),
  (3, 350, 'Lữ khách', '{"vi":"Lữ khách","en":"Traveler","ko":"여행자"}', '', true),
  (4, 650, 'Nhà thám hiểm', '{"vi":"Nhà thám hiểm","en":"Explorer","ko":"탐험가"}', '', true),
  (5, 1000, 'Người kể chuyện', '{"vi":"Người kể chuyện","en":"Storyteller","ko":"이야기꾼"}', '', true),
  (6, 1500, 'Sứ giả văn hóa', '{"vi":"Sứ giả văn hóa","en":"Culture Ambassador","ko":"문화 사절"}', '', true),
  (7, 2200, 'Chuyên gia KoreaQuest', '{"vi":"Chuyên gia KoreaQuest","en":"KoreaQuest Expert","ko":"KoreaQuest 전문가"}', '', true),
  (8, 3000, 'Bậc thầy khám phá', '{"vi":"Bậc thầy khám phá","en":"Master Explorer","ko":"탐험의 달인"}', '', true)
on conflict (level_number) do update set
  min_xp = excluded.min_xp,
  title = excluded.title,
  title_i18n = excluded.title_i18n,
  is_active = true,
  updated_at = now();

update public.achievement_definitions
set is_active = false, updated_at = now()
where slug not in (
  'first-step', 'culture-explorer', 'wise-beginning', 'challenge-master',
  'curious-explorer', 'treasure-of-knowledge', 'steady-journey',
  'koreaquest-secret'
);

insert into public.achievement_definitions (
  slug, title, korean_title, description, category, icon_url, metric, target,
  criteria_filter, is_secret, is_limited, is_active, display_order,
  title_i18n, description_i18n
) values
  ('first-step', 'Bước chân đầu tiên', '첫걸음', 'Hoàn thành địa điểm đầu tiên.', 'journey', '', 'completed_locations', 1, '{}', false, false, true, 1,
   '{"vi":"Bước chân đầu tiên","en":"First Step","ko":"첫걸음"}',
   '{"vi":"Hoàn thành địa điểm đầu tiên.","en":"Complete your first destination.","ko":"첫 번째 장소를 완료하세요."}'),
  ('culture-explorer', 'Nhà thám hiểm văn hóa', '문화 탐험가', 'Hoàn thành 3 địa điểm.', 'journey', '', 'completed_locations', 3, '{}', false, false, true, 2,
   '{"vi":"Nhà thám hiểm văn hóa","en":"Culture Explorer","ko":"문화 탐험가"}',
   '{"vi":"Hoàn thành 3 địa điểm.","en":"Complete 3 destinations.","ko":"장소 3곳을 완료하세요."}'),
  ('wise-beginning', 'Khởi đầu thông thái', '지혜로운 시작', 'Trả lời đúng 10 câu.', 'quiz', '', 'correct_answers', 10, '{}', false, false, true, 3,
   '{"vi":"Khởi đầu thông thái","en":"Wise Beginning","ko":"지혜로운 시작"}',
   '{"vi":"Trả lời đúng 10 câu.","en":"Answer 10 questions correctly.","ko":"문제 10개를 맞히세요."}'),
  ('challenge-master', 'Bậc thầy thử thách', '도전의 달인', 'Trả lời đúng 50 câu.', 'quiz', '', 'correct_answers', 50, '{}', false, false, true, 4,
   '{"vi":"Bậc thầy thử thách","en":"Challenge Master","ko":"도전의 달인"}',
   '{"vi":"Trả lời đúng 50 câu.","en":"Answer 50 questions correctly.","ko":"문제 50개를 맞히세요."}'),
  ('curious-explorer', 'Người ham khám phá', '호기심 많은 탐험가', 'Xem 10 nội dung văn hóa.', 'content', '', 'content_views', 10, '{}', false, false, true, 5,
   '{"vi":"Người ham khám phá","en":"Curious Explorer","ko":"호기심 많은 탐험가"}',
   '{"vi":"Xem 10 nội dung văn hóa.","en":"View 10 culture items.","ko":"문화 콘텐츠 10개를 확인하세요."}'),
  ('treasure-of-knowledge', 'Kho tàng tri thức', '지식의 보물창고', 'Xem 50 nội dung văn hóa.', 'content', '', 'content_views', 50, '{}', false, false, true, 6,
   '{"vi":"Kho tàng tri thức","en":"Treasure of Knowledge","ko":"지식의 보물창고"}',
   '{"vi":"Xem 50 nội dung văn hóa.","en":"View 50 culture items.","ko":"문화 콘텐츠 50개를 확인하세요."}'),
  ('steady-journey', 'Hành trình bền bỉ', '꾸준한 여정', 'Duy trì chuỗi học 3 ngày.', 'streak', '', 'streak_days', 3, '{}', false, false, true, 7,
   '{"vi":"Hành trình bền bỉ","en":"Steady Journey","ko":"꾸준한 여정"}',
   '{"vi":"Duy trì chuỗi học 3 ngày.","en":"Maintain a 3-day learning streak.","ko":"3일 연속 학습하세요."}'),
  ('koreaquest-secret', 'Bí mật KoreaQuest', 'KoreaQuest의 비밀', 'Duy trì chuỗi học 7 ngày.', 'streak', '', 'streak_days', 7, '{}', true, false, true, 8,
   '{"vi":"Bí mật KoreaQuest","en":"KoreaQuest Secret","ko":"KoreaQuest의 비밀"}',
   '{"vi":"Duy trì chuỗi học 7 ngày.","en":"Maintain a 7-day learning streak.","ko":"7일 연속 학습하세요."}')
on conflict (slug) do update set
  title = excluded.title,
  korean_title = excluded.korean_title,
  description = excluded.description,
  category = excluded.category,
  metric = excluded.metric,
  target = excluded.target,
  criteria_filter = excluded.criteria_filter,
  is_secret = excluded.is_secret,
  is_limited = excluded.is_limited,
  is_active = true,
  display_order = excluded.display_order,
  title_i18n = excluded.title_i18n,
  description_i18n = excluded.description_i18n,
  updated_at = now();

create or replace function private.game_locale(requested_locale text)
returns text language sql immutable set search_path = '' as $$
  select case when requested_locale in ('vi', 'en', 'ko') then requested_locale else 'vi' end;
$$;

create or replace function private.game_progress_json(target_user uuid, requested_locale text)
returns jsonb language sql stable security definer set search_path = '' as $$
  with total as (
    select coalesce((select total_xp from public.explorer_progress_summary where user_id = target_user), 0)::integer as xp,
           coalesce((select current_streak from public.explorer_progress_summary where user_id = target_user), 0)::integer as streak
  ), current_level as (
    select level.* from public.level_definitions level, total
    where level.is_active and level.min_xp <= total.xp
    order by level.min_xp desc limit 1
  ), next_level as (
    select level.* from public.level_definitions level, current_level
    where level.is_active and level.min_xp > current_level.min_xp
    order by level.min_xp limit 1
  )
  select jsonb_build_object(
    'level', coalesce(current_level.level_number, 1),
    'title', coalesce(current_level.title_i18n ->> private.game_locale(requested_locale), current_level.title, ''),
    'current_xp', total.xp,
    'next_level_xp', coalesce(next_level.min_xp, total.xp),
    'streak_days', total.streak,
    'is_max_level', next_level.id is null
  ) from total left join current_level on true left join next_level on true;
$$;

create or replace function public.get_my_progress(requested_locale text default 'vi')
returns jsonb language plpgsql stable security definer set search_path = '' as $$
begin
  if auth.uid() is null then raise exception 'Authentication required.' using errcode = '42501'; end if;
  return private.game_progress_json(auth.uid(), requested_locale);
end;
$$;

create or replace function public.get_my_achievements(requested_locale text default 'vi')
returns jsonb language plpgsql security definer set search_path = '' as $$
declare target_user uuid := auth.uid(); normalized text := private.game_locale(requested_locale);
begin
  if target_user is null then raise exception 'Authentication required.' using errcode = '42501'; end if;
  perform private.refresh_progression(target_user);
  return coalesce((
    select jsonb_agg(jsonb_build_object(
      'id', definition.id,
      'slug', definition.slug,
      'title', case when definition.is_secret and badge.id is null then
        case normalized when 'en' then 'Secret achievement' when 'ko' then '비밀 업적' else 'Thành tích bí mật' end
        else coalesce(definition.title_i18n ->> normalized, definition.title) end,
      'description', case when definition.is_secret and badge.id is null then
        case normalized when 'en' then 'Keep exploring to reveal this achievement.' when 'ko' then '계속 탐험하여 업적을 공개하세요.' else 'Tiếp tục khám phá để mở khóa thành tích này.' end
        else coalesce(definition.description_i18n ->> normalized, definition.description) end,
      'icon_url', case when definition.is_secret and badge.id is null then '' else definition.icon_url end,
      'category', definition.category,
      'is_secret', definition.is_secret,
      'is_earned', badge.id is not null,
      'current_value', case when definition.is_secret and badge.id is null then null else least(coalesce(progress.current_value, 0), definition.target) end,
      'target_value', case when definition.is_secret and badge.id is null then null else definition.target end,
      'earned_at', badge.earned_at
    ) order by definition.display_order, definition.slug)
    from public.achievement_definitions definition
    left join public.explorer_badges badge on badge.achievement_id = definition.id and badge.user_id = target_user
    left join public.explorer_achievement_progress progress on progress.achievement_id = definition.id and progress.user_id = target_user
    where definition.is_active or badge.id is not null
  ), '[]'::jsonb);
end;
$$;

create or replace function private.passport_stamps_json(target_user uuid, requested_locale text)
returns jsonb language sql stable security definer set search_path = '' as $$
  select coalesce(jsonb_agg(jsonb_build_object(
    'location_id', location.id,
    'slug', location.slug,
    'name', coalesce(translation.content #>> '{summary,name}', revision.name),
    'korean_name', coalesce(translation.content #>> '{summary,korean_name}', revision.korean_name),
    'stamp_name', coalesce(translation.content #>> '{detail,stamp_name}', revision.stamp_name),
    'stamp_description', coalesce(translation.content #>> '{detail,stamp_description}', revision.stamp_description),
    'stamp_image_url', revision.stamp_image_url,
    'stamp_image_alt', coalesce(translation.content #>> '{detail,stamp_image_alt}', revision.stamp_image_alt),
    'earned_at', stamp.awarded_at
  ) order by stamp.awarded_at desc), '[]'::jsonb)
  from public.explorer_stamps stamp
  join public.locations location on location.id = stamp.location_id
  join lateral (
    select item.* from public.location_revisions item
    where item.location_id = location.id
    order by (item.status = 'published') desc, item.published_at desc nulls last, item.version_number desc
    limit 1
  ) revision on true
  left join public.location_revision_translations translation
    on translation.revision_id = revision.id
   and translation.locale::text = private.game_locale(requested_locale)
   and translation.status = 'approved'
  where stamp.user_id = target_user;
$$;

create or replace function public.get_my_passport(requested_locale text default 'vi')
returns jsonb language plpgsql security definer set search_path = '' as $$
declare target_user uuid := auth.uid();
begin
  if target_user is null then raise exception 'Authentication required.' using errcode = '42501'; end if;
  return jsonb_build_object(
    'profile', (select jsonb_build_object(
      'id', profile.user_id, 'full_name', profile.full_name,
      'display_name', profile.display_name, 'handle', coalesce(profile.handle, ''),
      'joined_at', profile.joined_at, 'avatar_path', profile.avatar_path
    ) from public.explorer_profiles profile where profile.user_id = target_user),
    'progress', private.game_progress_json(target_user, requested_locale),
    'stamps', private.passport_stamps_json(target_user, requested_locale),
    'share_active', exists(select 1 from public.passport_share_links where user_id = target_user and revoked_at is null)
  );
end;
$$;

create or replace function private.ensure_game_journey(target_user uuid, target_slug text)
returns uuid language plpgsql security definer set search_path = '' as $$
declare target_location uuid; target_revision uuid; saved_journey uuid;
begin
  select location.id, revision.id into target_location, target_revision
  from public.locations location join public.location_revisions revision on revision.location_id = location.id
  where location.slug = target_slug and location.archived_at is null
    and revision.status = 'published' and revision.release_status = 'released';
  if target_location is null then raise exception 'Released location not found.' using errcode = '22023'; end if;
  insert into public.explorer_journeys (user_id, location_id, revision_id)
  values (target_user, target_location, target_revision)
  on conflict (user_id, location_id, revision_id) do update set updated_at = now()
  returning id into saved_journey;
  return saved_journey;
end;
$$;

create or replace function private.reward_result(
  target_user uuid, before_xp integer, awarded_xp integer,
  operation_started timestamptz, stamp_awarded boolean, requested_locale text
) returns jsonb language sql stable security definer set search_path = '' as $$
  select jsonb_build_object(
    'awarded_xp', awarded_xp,
    'already_awarded', awarded_xp = 0 and not stamp_awarded,
    'old_progress', private.game_progress_json(target_user, requested_locale) || jsonb_build_object('current_xp', before_xp),
    'progress', private.game_progress_json(target_user, requested_locale),
    'new_achievements', coalesce((select jsonb_agg(jsonb_build_object(
      'id', definition.id, 'title', coalesce(definition.title_i18n ->> private.game_locale(requested_locale), definition.title)
    )) from public.explorer_badges badge join public.achievement_definitions definition on definition.id = badge.achievement_id
      where badge.user_id = target_user and badge.earned_at >= operation_started), '[]'::jsonb),
    'stamp_awarded', stamp_awarded
  );
$$;

create or replace function public.complete_location_stage(
  target_slug text, stage_number integer, requested_locale text default 'vi'
) returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  target_user uuid := auth.uid(); journey_id uuid; location_id uuid; target_revision_id uuid;
  stage_value public.journey_stage; before_xp integer; awarded integer := 0;
  operation_started timestamptz := clock_timestamp(); stamp_new boolean := false; inserted integer;
begin
  if target_user is null then raise exception 'Authentication required.' using errcode = '42501'; end if;
  if stage_number not between 1 and 9 then raise exception 'Invalid stage.' using errcode = '22023'; end if;
  journey_id := private.ensure_game_journey(target_user, target_slug);
  select journey.location_id, journey.revision_id into location_id, target_revision_id
  from public.explorer_journeys journey where journey.id = journey_id;
  stage_value := (array['opening','overview','history','highlights','experiences','foods','fun_facts','final_quiz','travel'])[stage_number]::public.journey_stage;
  select coalesce(total_xp, 0) into before_xp from public.explorer_progress_summary where user_id = target_user for update;
  insert into public.explorer_stage_progress (journey_id, stage, status, started_at, completed_at)
  values (journey_id, stage_value, 'completed', now(), now())
  on conflict (journey_id, stage) do update set
    status = 'completed', started_at = coalesce(public.explorer_stage_progress.started_at, excluded.started_at),
    completed_at = coalesce(public.explorer_stage_progress.completed_at, excluded.completed_at);
  insert into public.explorer_xp_ledger (user_id, journey_id, amount, reason, reference_key)
  values (target_user, journey_id, 20, 'stage_completed', 'stage:' || location_id || ':' || stage_value::text)
  on conflict (user_id, reference_key) do nothing;
  get diagnostics inserted = row_count; awarded := awarded + inserted * 20;
  if stage_number = 4 then
    insert into public.explorer_content_views (user_id, revision_id, kind, content_id)
    select target_user, target_revision_id, 'highlight', item.id
    from public.location_highlights item where item.revision_id = target_revision_id and item.is_visible
    on conflict (user_id, kind, content_id) do nothing;
  elsif stage_number = 5 then
    insert into public.explorer_content_views (user_id, revision_id, kind, content_id)
    select target_user, target_revision_id, 'experience', item.id
    from public.location_experiences item where item.revision_id = target_revision_id and item.is_visible
    on conflict (user_id, kind, content_id) do nothing;
  elsif stage_number = 6 then
    insert into public.explorer_content_views (user_id, revision_id, kind, content_id)
    select target_user, target_revision_id, 'food', item.id
    from public.location_foods item where item.revision_id = target_revision_id and item.is_visible
    on conflict (user_id, kind, content_id) do nothing;
  elsif stage_number = 7 then
    insert into public.explorer_content_views (user_id, revision_id, kind, content_id)
    select target_user, target_revision_id, 'fun_fact', item.id
    from public.location_fun_facts item where item.revision_id = target_revision_id and item.is_visible
    on conflict (user_id, kind, content_id) do nothing;
  end if;
  if stage_number = 9 then
    update public.explorer_journeys set status = 'completed', current_stage = 'travel',
      completed_at = coalesce(completed_at, now()), updated_at = now() where id = journey_id;
    insert into public.explorer_xp_ledger (user_id, journey_id, amount, reason, reference_key)
    values (target_user, journey_id, 50, 'location_completed', 'location:' || location_id)
    on conflict (user_id, reference_key) do nothing;
    get diagnostics inserted = row_count; awarded := awarded + inserted * 50;
    insert into public.explorer_stamps (user_id, location_id, revision_id, journey_id)
    values (target_user, location_id, target_revision_id, journey_id)
    on conflict (user_id, location_id) do nothing;
    get diagnostics inserted = row_count; stamp_new := inserted = 1;
  else
    update public.explorer_journeys set current_stage =
      (array['overview','history','highlights','experiences','foods','fun_facts','final_quiz','travel'])[stage_number]::public.journey_stage,
      updated_at = now() where id = journey_id;
  end if;
  perform private.refresh_progression(target_user);
  return private.reward_result(target_user, before_xp, awarded, operation_started, stamp_new, requested_locale);
end;
$$;

create or replace function private.record_quiz_gameplay(
  target_question uuid, submitted_answer jsonb, is_answer_correct boolean, requested_locale text
) returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  target_user uuid := auth.uid(); target_slug text; journey_id uuid; attempt_id uuid;
  before_xp integer; awarded integer := 0; inserted integer;
  operation_started timestamptz := clock_timestamp();
begin
  select location.slug into target_slug
  from public.quiz_questions question
  join public.location_revisions revision on revision.id = question.revision_id
  join public.locations location on location.id = revision.location_id
  where question.id = target_question and revision.status = 'published' and revision.release_status = 'released';
  if target_slug is null then raise exception 'Question not found.' using errcode = '22023'; end if;
  journey_id := private.ensure_game_journey(target_user, target_slug);
  select coalesce(total_xp, 0) into before_xp from public.explorer_progress_summary where user_id = target_user for update;
  select id into attempt_id from public.explorer_quiz_attempts
  where journey_id = record_quiz_gameplay.journey_id and status = 'in_progress'
  order by attempt_number desc limit 1;
  if attempt_id is null then
    insert into public.explorer_quiz_attempts (journey_id, attempt_number)
    select record_quiz_gameplay.journey_id, coalesce(max(attempt_number), 0) + 1
    from public.explorer_quiz_attempts where journey_id = record_quiz_gameplay.journey_id
    returning id into attempt_id;
  end if;
  insert into public.explorer_quiz_answers (attempt_id, question_id, submitted_answer, is_correct, awarded_xp)
  values (attempt_id, target_question, submitted_answer, is_answer_correct, case when is_answer_correct then 10 else 2 end)
  on conflict (attempt_id, question_id) do update set
    is_correct = public.explorer_quiz_answers.is_correct or excluded.is_correct,
    awarded_xp = greatest(public.explorer_quiz_answers.awarded_xp, excluded.awarded_xp);
  insert into public.explorer_xp_ledger (user_id, journey_id, amount, reason, reference_key)
  values (target_user, journey_id, 2, 'task_completed', 'question:' || target_question || ':completed')
  on conflict (user_id, reference_key) do nothing;
  get diagnostics inserted = row_count; awarded := awarded + inserted * 2;
  if is_answer_correct then
    insert into public.explorer_xp_ledger (user_id, journey_id, amount, reason, reference_key)
    values (target_user, journey_id, 8, 'first_correct_answer', 'question:' || target_question || ':correct')
    on conflict (user_id, reference_key) do nothing;
    get diagnostics inserted = row_count; awarded := awarded + inserted * 8;
  end if;
  perform private.refresh_progression(target_user);
  return private.reward_result(target_user, before_xp, awarded, operation_started, false, requested_locale);
end;
$$;

create or replace function public.submit_quiz_answer(
  question_id uuid, answer jsonb, requested_locale text default 'vi'
) returns jsonb language plpgsql volatile security definer set search_path = '' as $$
declare result jsonb := public.submit_quiz_answer_vi(question_id, answer); translated_explanation text;
begin
  if requested_locale in ('en', 'ko') then
    select quiz_item ->> 'explanation' into translated_explanation
    from public.quiz_questions question
    join public.location_revision_translations translation on translation.revision_id = question.revision_id
      and translation.locale::text = requested_locale and translation.status = 'approved'
    cross join lateral jsonb_array_elements(coalesce(translation.content #> '{detail,quiz}', '[]'::jsonb))
      with ordinality as localized_quiz(quiz_item, position)
    where question.id = submit_quiz_answer.question_id and localized_quiz.position = question.display_order + 1 limit 1;
  end if;
  if translated_explanation is not null then result := jsonb_set(result, '{explanation}', to_jsonb(translated_explanation)); end if;
  if auth.uid() is not null then
    result := result || jsonb_build_object('reward', private.record_quiz_gameplay(question_id, answer, (result ->> 'is_correct')::boolean, requested_locale));
  end if;
  return result;
end;
$$;

create or replace function public.reset_my_progress(requested_locale text default 'vi')
returns jsonb language plpgsql security definer set search_path = '' as $$
declare target_user uuid := auth.uid();
begin
  if target_user is null then raise exception 'Authentication required.' using errcode = '42501'; end if;
  delete from public.passport_share_links where user_id = target_user;
  delete from public.leaderboard_entries where user_id = target_user;
  delete from public.explorer_challenge_goal_progress where user_id = target_user;
  delete from public.explorer_challenge_progress where user_id = target_user;
  delete from public.explorer_badges where user_id = target_user;
  delete from public.explorer_achievement_progress where user_id = target_user;
  delete from public.explorer_daily_visits where user_id = target_user;
  delete from public.explorer_content_views where user_id = target_user;
  delete from public.explorer_stamps where user_id = target_user;
  delete from public.explorer_xp_ledger where user_id = target_user;
  delete from public.explorer_journeys where user_id = target_user;
  update public.explorer_progress_summary set total_xp = 0, current_streak = 0, longest_streak = 0,
    last_visit_date = null, correct_answer_count = 0, completed_location_count = 0,
    content_view_count = 0, updated_at = now() where user_id = target_user;
  return private.game_progress_json(target_user, requested_locale);
end;
$$;

create or replace function private.protect_reached_level()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  if exists (select 1 from public.explorer_progress_summary where total_xp >= old.min_xp) then
    if tg_op = 'DELETE' then
      raise exception 'A reached level cannot be deleted.' using errcode = '22023';
    elsif new.level_number <> old.level_number or new.min_xp > old.min_xp then
      raise exception 'A reached level cannot be renumbered or moved to a higher XP threshold.' using errcode = '22023';
    end if;
  end if;
  if tg_op = 'DELETE' then return old; end if;
  return new;
end;
$$;
drop trigger if exists level_definitions_protect_reached on public.level_definitions;
create trigger level_definitions_protect_reached before update or delete on public.level_definitions
for each row execute function private.protect_reached_level();

drop function if exists public.resolve_shared_passport(text);
create function public.resolve_shared_passport(raw_token text, requested_locale text default 'vi')
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare link public.passport_share_links%rowtype;
begin
  select * into link from public.passport_share_links
  where token_hash = encode(extensions.digest(raw_token, 'sha256'), 'hex') and revoked_at is null;
  if link.id is null then return null; end if;
  return jsonb_build_object(
    'profile', (select jsonb_build_object('display_name', display_name, 'avatar_path', avatar_path, 'joined_at', joined_at)
      from public.explorer_profiles where user_id = link.user_id),
    'progress', case when link.include_level_xp then private.game_progress_json(link.user_id, requested_locale) end,
    'stamps', case when link.include_stamps then private.passport_stamps_json(link.user_id, requested_locale) else '[]'::jsonb end,
    'achievements', case when link.include_badges then coalesce((select jsonb_agg(jsonb_build_object(
      'id', definition.id, 'title', coalesce(definition.title_i18n ->> private.game_locale(requested_locale), definition.title),
      'description', coalesce(definition.description_i18n ->> private.game_locale(requested_locale), definition.description),
      'icon_url', definition.icon_url, 'earned_at', badge.earned_at, 'is_earned', true
    ) order by badge.earned_at desc) from public.explorer_badges badge join public.achievement_definitions definition on definition.id = badge.achievement_id
      where badge.user_id = link.user_id), '[]'::jsonb) else '[]'::jsonb end
  );
end;
$$;

revoke all on function public.get_my_progress(text) from public;
revoke all on function public.get_my_achievements(text) from public;
revoke all on function public.get_my_passport(text) from public;
revoke all on function public.complete_location_stage(text, integer, text) from public;
revoke all on function public.reset_my_progress(text) from public;
revoke all on function public.resolve_shared_passport(text, text) from public;
grant execute on function public.get_my_progress(text) to authenticated;
grant execute on function public.get_my_achievements(text) to authenticated;
grant execute on function public.get_my_passport(text) to authenticated;
grant execute on function public.complete_location_stage(text, integer, text) to authenticated;
grant execute on function public.reset_my_progress(text) to authenticated;
grant execute on function public.resolve_shared_passport(text, text) to anon, authenticated;
