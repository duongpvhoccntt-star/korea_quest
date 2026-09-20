-- Backend-owned progression derived from unique gameplay events.

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
    when 'unlocked_fun_facts' then (
      select count(*)::integer from public.explorer_fun_fact_unlocks
      where user_id = target_user
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
declare definition record; goal record; current_metric integer;
begin
  insert into public.explorer_progress_summary (
    user_id, correct_answer_count, completed_location_count,
    unlocked_fun_fact_count, content_view_count, updated_at
  ) values (
    target_user,
    private.metric_value(target_user, 'correct_answers'),
    private.metric_value(target_user, 'completed_locations'),
    private.metric_value(target_user, 'unlocked_fun_facts'),
    private.metric_value(target_user, 'content_views'),
    now()
  ) on conflict (user_id) do update set
    correct_answer_count = excluded.correct_answer_count,
    completed_location_count = excluded.completed_location_count,
    unlocked_fun_fact_count = excluded.unlocked_fun_fact_count,
    content_view_count = excluded.content_view_count,
    updated_at = now();

  for definition in
    select * from public.achievement_definitions
    where is_active
      and (available_from is null or available_from <= now())
      and (available_until is null or available_until >= now())
  loop
    current_metric := private.metric_value(target_user, definition.metric, definition.criteria_filter);
    insert into public.explorer_achievement_progress (
      user_id, achievement_id, current_value, target_value, updated_at
    ) values (target_user, definition.id, current_metric, definition.target, now())
    on conflict (user_id, achievement_id) do update set
      current_value = excluded.current_value,
      target_value = excluded.target_value,
      updated_at = now();
    if current_metric >= definition.target then
      insert into public.explorer_badges (user_id, achievement_id, source_reference)
      values (target_user, definition.id, 'achievement:' || definition.id::text)
      on conflict (user_id, achievement_id) do nothing;
      if found then
        update public.achievement_definitions
        set criteria_locked_at = coalesce(criteria_locked_at, now())
        where id = definition.id;
      end if;
    end if;
  end loop;

  for definition in
    select challenge.*
    from public.challenge_definitions challenge
    join public.explorer_challenge_progress progress
      on progress.challenge_id = challenge.id and progress.user_id = target_user
    where progress.status = 'joined'
      and challenge.status in ('scheduled', 'active')
      and now() between challenge.starts_at and challenge.ends_at
  loop
    for goal in select * from public.challenge_goals where challenge_id = definition.id loop
      current_metric := private.metric_value(target_user, goal.metric, goal.criteria_filter);
      insert into public.explorer_challenge_goal_progress (
        user_id, challenge_id, goal_id, current_value, updated_at
      ) values (target_user, definition.id, goal.id, current_metric, now())
      on conflict (user_id, goal_id) do update set
        current_value = excluded.current_value, updated_at = now();
    end loop;
    if not exists (
      select 1 from public.challenge_goals goal
      left join public.explorer_challenge_goal_progress progress
        on progress.goal_id = goal.id and progress.user_id = target_user
      where goal.challenge_id = definition.id
        and coalesce(progress.current_value, 0) < goal.target
    ) and exists (select 1 from public.challenge_goals where challenge_id = definition.id) then
      update public.explorer_challenge_progress set status = 'completed', completed_at = now()
      where user_id = target_user and challenge_id = definition.id and status = 'joined';
    end if;
  end loop;
end;
$$;

create or replace function private.progression_event_trigger()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare target_user uuid;
begin
  if tg_table_name = 'explorer_quiz_answers' then
    select journey.user_id into target_user
    from public.explorer_quiz_attempts attempt
    join public.explorer_journeys journey on journey.id = attempt.journey_id
    where attempt.id = coalesce(new.attempt_id, old.attempt_id);
  else
    target_user := coalesce(new.user_id, old.user_id);
  end if;
  if target_user is not null then perform private.refresh_progression(target_user); end if;
  return coalesce(new, old);
end;
$$;

create trigger explorer_quiz_answers_refresh_progression
after insert or update or delete on public.explorer_quiz_answers
for each row execute function private.progression_event_trigger();
create trigger explorer_journeys_refresh_progression
after insert or update or delete on public.explorer_journeys
for each row execute function private.progression_event_trigger();
create trigger explorer_fun_facts_refresh_progression
after insert or update or delete on public.explorer_fun_fact_unlocks
for each row execute function private.progression_event_trigger();
create trigger explorer_content_views_refresh_progression
after insert or delete on public.explorer_content_views
for each row execute function private.progression_event_trigger();

create or replace function private.validate_content_view()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare valid boolean;
begin
  valid := case new.kind
    when 'highlight' then exists (select 1 from public.location_highlights where id = new.content_id and revision_id = new.revision_id)
    when 'experience' then exists (select 1 from public.location_experiences where id = new.content_id and revision_id = new.revision_id)
    when 'food' then exists (select 1 from public.location_foods where id = new.content_id and revision_id = new.revision_id)
    when 'fun_fact' then exists (select 1 from public.location_fun_facts where id = new.content_id and revision_id = new.revision_id)
  end;
  if not valid then raise exception 'Nội dung không thuộc Phiên bản đã chọn.' using errcode = '23503'; end if;
  return new;
end;
$$;
create trigger explorer_content_views_validate
before insert or update on public.explorer_content_views
for each row execute function private.validate_content_view();

create or replace function public.record_content_view(
  content_kind public.content_view_kind,
  target_content_id uuid,
  target_revision_id uuid
)
returns boolean
language plpgsql
security definer
set search_path = ''
as $$
declare inserted_count integer;
begin
  if auth.uid() is null then raise exception 'Yêu cầu đăng nhập.' using errcode = '42501'; end if;
  insert into public.explorer_content_views (user_id, revision_id, kind, content_id)
  values (auth.uid(), target_revision_id, content_kind, target_content_id)
  on conflict (user_id, kind, content_id) do nothing;
  get diagnostics inserted_count = row_count;
  return inserted_count = 1;
end;
$$;

create or replace function public.join_challenge(target_challenge_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if auth.uid() is null then raise exception 'Yêu cầu đăng nhập.' using errcode = '42501'; end if;
  if not exists (
    select 1 from public.challenge_definitions
    where id = target_challenge_id and status in ('scheduled', 'active')
      and now() between starts_at and ends_at
  ) then raise exception 'Thử thách hiện không thể tham gia.' using errcode = '22023'; end if;
  insert into public.explorer_challenge_progress (user_id, challenge_id)
  values (auth.uid(), target_challenge_id) on conflict do nothing;
  perform private.refresh_progression(auth.uid());
end;
$$;

create or replace function public.claim_challenge_reward(target_challenge_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare challenge public.challenge_definitions%rowtype;
begin
  if auth.uid() is null then raise exception 'Yêu cầu đăng nhập.' using errcode = '42501'; end if;
  select * into challenge from public.challenge_definitions where id = target_challenge_id for update;
  if challenge.id is null or now() > challenge.ends_at then
    raise exception 'Phần thưởng đã hết hạn.' using errcode = '22023';
  end if;
  if not exists (
    select 1 from public.explorer_challenge_progress
    where user_id = auth.uid() and challenge_id = target_challenge_id
      and status = 'completed' and rewarded_at is null
  ) then raise exception 'Thử thách chưa hoàn thành hoặc đã nhận thưởng.' using errcode = '22023'; end if;
  if challenge.reward_xp > 0 then
    insert into public.explorer_xp_ledger (user_id, amount, reason, reference_key, challenge_id)
    values (auth.uid(), challenge.reward_xp, 'challenge', 'challenge:' || challenge.id::text, challenge.id)
    on conflict (user_id, reference_key) do nothing;
  end if;
  if challenge.reward_achievement_id is not null then
    insert into public.explorer_badges (user_id, achievement_id, source_reference)
    values (auth.uid(), challenge.reward_achievement_id, 'challenge:' || challenge.id::text)
    on conflict (user_id, achievement_id) do nothing;
    update public.achievement_definitions set criteria_locked_at = coalesce(criteria_locked_at, now())
    where id = challenge.reward_achievement_id;
  end if;
  update public.explorer_challenge_progress set status = 'rewarded', rewarded_at = now()
  where user_id = auth.uid() and challenge_id = target_challenge_id;
  return jsonb_build_object('xp', challenge.reward_xp, 'achievement_id', challenge.reward_achievement_id);
end;
$$;

-- Daily visits can immediately unlock streak-based achievements.
create or replace function public.record_daily_visit()
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  target_user uuid := auth.uid(); target_timezone text; today_local date;
  previous_date date; next_current integer; next_longest integer;
begin
  if target_user is null then raise exception 'Yêu cầu đăng nhập.' using errcode = '42501'; end if;
  select timezone into target_timezone from public.user_preferences where user_id = target_user;
  target_timezone := coalesce(target_timezone, 'Asia/Ho_Chi_Minh');
  today_local := (now() at time zone target_timezone)::date;
  insert into public.explorer_daily_visits (user_id, local_date, timezone)
  values (target_user, today_local, target_timezone) on conflict do nothing;
  select last_visit_date, current_streak, longest_streak into previous_date, next_current, next_longest
  from public.explorer_progress_summary where user_id = target_user for update;
  next_current := case when previous_date = today_local then next_current
    when previous_date = today_local - 1 then next_current + 1 else 1 end;
  next_longest := greatest(coalesce(next_longest, 0), next_current);
  update public.explorer_progress_summary set current_streak = next_current,
    longest_streak = next_longest, last_visit_date = today_local, updated_at = now()
  where user_id = target_user;
  perform private.refresh_progression(target_user);
  return jsonb_build_object('local_date', today_local, 'current_streak', next_current, 'longest_streak', next_longest);
end;
$$;

revoke all on function public.record_content_view(public.content_view_kind, uuid, uuid) from public;
revoke all on function public.join_challenge(uuid) from public;
revoke all on function public.claim_challenge_reward(uuid) from public;
grant execute on function public.record_content_view(public.content_view_kind, uuid, uuid) to authenticated;
grant execute on function public.join_challenge(uuid) to authenticated;
grant execute on function public.claim_challenge_reward(uuid) to authenticated;
