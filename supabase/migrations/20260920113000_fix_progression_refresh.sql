-- Avoid PL/pgSQL record/alias ambiguity and evaluate challenge completion
-- before challenge-based achievements in the same event.

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
