-- Qualify PL/pgSQL identifiers so runtime resolution is deterministic.

create or replace function public.submit_quiz_answer_vi(question_id uuid, answer jsonb)
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
    select count(*) = (select count(*) from public.quiz_matching_pairs pair_count where pair_count.question_id = question.id)
      and count(distinct left_pair.id) = (select count(*) from public.quiz_matching_pairs pair_count where pair_count.question_id = question.id)
      into is_correct
    from jsonb_to_recordset(coalesce(answer -> 'pairs', '[]'::jsonb)) as submitted(left_id uuid, right_text text)
    join public.quiz_matching_pairs left_pair
      on left_pair.id = submitted.left_id and left_pair.question_id = question.id
    where left_pair.right_text = submitted.right_text;
  elsif question.kind = 'ordering' then
    select count(*) = (select count(*) from public.quiz_ordering_items ordering_count where ordering_count.question_id = question.id)
      and bool_and(item.correct_position = submitted.ordinality - 1)
      into is_correct
    from jsonb_array_elements_text(coalesce(answer -> 'item_ids', '[]'::jsonb)) with ordinality as submitted(item_id, ordinality)
    join public.quiz_ordering_items item on item.id = submitted.item_id::uuid
      and item.question_id = question.id;
  end if;

  return jsonb_build_object('is_correct', coalesce(is_correct, false), 'explanation', question.explanation);
end;
$$;

create or replace function public.complete_location_stage(
  target_slug text, stage_number integer, requested_locale text default 'vi'
) returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  target_user uuid := auth.uid(); v_journey_id uuid; v_location_id uuid; v_revision_id uuid;
  stage_value public.journey_stage; before_xp integer; awarded integer := 0;
  operation_started timestamptz := clock_timestamp(); stamp_new boolean := false; inserted integer;
begin
  if target_user is null then raise exception 'Authentication required.' using errcode = '42501'; end if;
  if stage_number not between 1 and 9 then raise exception 'Invalid stage.' using errcode = '22023'; end if;
  v_journey_id := private.ensure_game_journey(target_user, target_slug);
  select journey.location_id, journey.revision_id into v_location_id, v_revision_id
  from public.explorer_journeys journey where journey.id = v_journey_id;
  stage_value := (array['opening','overview','history','highlights','experiences','foods','fun_facts','final_quiz','travel'])[stage_number]::public.journey_stage;
  select coalesce(summary.total_xp, 0) into before_xp
  from public.explorer_progress_summary summary where summary.user_id = target_user for update;
  insert into public.explorer_stage_progress (journey_id, stage, status, started_at, completed_at)
  values (v_journey_id, stage_value, 'completed', now(), now())
  on conflict (journey_id, stage) do update set
    status = 'completed', started_at = coalesce(public.explorer_stage_progress.started_at, excluded.started_at),
    completed_at = coalesce(public.explorer_stage_progress.completed_at, excluded.completed_at);
  insert into public.explorer_xp_ledger (user_id, journey_id, amount, reason, reference_key)
  values (target_user, v_journey_id, 20, 'stage_completed', 'stage:' || v_location_id || ':' || stage_value::text)
  on conflict (user_id, reference_key) do nothing;
  get diagnostics inserted = row_count; awarded := awarded + inserted * 20;
  if stage_number = 4 then
    insert into public.explorer_content_views (user_id, revision_id, kind, content_id)
    select target_user, v_revision_id, 'highlight', item.id
    from public.location_highlights item where item.revision_id = v_revision_id and item.is_visible
    on conflict (user_id, kind, content_id) do nothing;
  elsif stage_number = 5 then
    insert into public.explorer_content_views (user_id, revision_id, kind, content_id)
    select target_user, v_revision_id, 'experience', item.id
    from public.location_experiences item where item.revision_id = v_revision_id and item.is_visible
    on conflict (user_id, kind, content_id) do nothing;
  elsif stage_number = 6 then
    insert into public.explorer_content_views (user_id, revision_id, kind, content_id)
    select target_user, v_revision_id, 'food', item.id
    from public.location_foods item where item.revision_id = v_revision_id and item.is_visible
    on conflict (user_id, kind, content_id) do nothing;
  elsif stage_number = 7 then
    insert into public.explorer_content_views (user_id, revision_id, kind, content_id)
    select target_user, v_revision_id, 'fun_fact', item.id
    from public.location_fun_facts item where item.revision_id = v_revision_id and item.is_visible
    on conflict (user_id, kind, content_id) do nothing;
  end if;
  if stage_number = 9 then
    update public.explorer_journeys set status = 'completed', current_stage = 'travel',
      completed_at = coalesce(completed_at, now()), updated_at = now() where id = v_journey_id;
    insert into public.explorer_xp_ledger (user_id, journey_id, amount, reason, reference_key)
    values (target_user, v_journey_id, 50, 'location_completed', 'location:' || v_location_id)
    on conflict (user_id, reference_key) do nothing;
    get diagnostics inserted = row_count; awarded := awarded + inserted * 50;
    insert into public.explorer_stamps (user_id, location_id, revision_id, journey_id)
    values (target_user, v_location_id, v_revision_id, v_journey_id)
    on conflict (user_id, location_id) do nothing;
    get diagnostics inserted = row_count; stamp_new := inserted = 1;
  else
    update public.explorer_journeys set current_stage =
      (array['overview','history','highlights','experiences','foods','fun_facts','final_quiz','travel'])[stage_number]::public.journey_stage,
      updated_at = now() where id = v_journey_id;
  end if;
  perform private.refresh_progression(target_user);
  return private.reward_result(target_user, before_xp, awarded, operation_started, stamp_new, requested_locale);
end;
$$;

create or replace function private.record_quiz_gameplay(
  target_question uuid, submitted_answer jsonb, is_answer_correct boolean, requested_locale text
) returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  target_user uuid := auth.uid(); target_slug text; v_journey_id uuid; v_attempt_id uuid;
  before_xp integer; awarded integer := 0; inserted integer;
  operation_started timestamptz := clock_timestamp();
begin
  select location.slug into target_slug
  from public.quiz_questions question
  join public.location_revisions revision on revision.id = question.revision_id
  join public.locations location on location.id = revision.location_id
  where question.id = target_question and revision.status = 'published' and revision.release_status = 'released';
  if target_slug is null then raise exception 'Question not found.' using errcode = '22023'; end if;
  v_journey_id := private.ensure_game_journey(target_user, target_slug);
  select coalesce(summary.total_xp, 0) into before_xp
  from public.explorer_progress_summary summary where summary.user_id = target_user for update;
  select attempt.id into v_attempt_id from public.explorer_quiz_attempts attempt
  where attempt.journey_id = v_journey_id and attempt.status = 'in_progress'
  order by attempt.attempt_number desc limit 1;
  if v_attempt_id is null then
    insert into public.explorer_quiz_attempts (journey_id, attempt_number)
    select v_journey_id, coalesce(max(attempt.attempt_number), 0) + 1
    from public.explorer_quiz_attempts attempt where attempt.journey_id = v_journey_id
    returning id into v_attempt_id;
  end if;
  insert into public.explorer_quiz_answers (attempt_id, question_id, submitted_answer, is_correct, awarded_xp)
  values (v_attempt_id, target_question, submitted_answer, is_answer_correct, case when is_answer_correct then 10 else 2 end)
  on conflict (attempt_id, question_id) do update set
    is_correct = public.explorer_quiz_answers.is_correct or excluded.is_correct,
    awarded_xp = greatest(public.explorer_quiz_answers.awarded_xp, excluded.awarded_xp);
  insert into public.explorer_xp_ledger (user_id, journey_id, amount, reason, reference_key)
  values (target_user, v_journey_id, 2, 'task_completed', 'question:' || target_question || ':completed')
  on conflict (user_id, reference_key) do nothing;
  get diagnostics inserted = row_count; awarded := awarded + inserted * 2;
  if is_answer_correct then
    insert into public.explorer_xp_ledger (user_id, journey_id, amount, reason, reference_key)
    values (target_user, v_journey_id, 8, 'first_correct_answer', 'question:' || target_question || ':correct')
    on conflict (user_id, reference_key) do nothing;
    get diagnostics inserted = row_count; awarded := awarded + inserted * 8;
  end if;
  perform private.refresh_progression(target_user);
  return private.reward_result(target_user, before_xp, awarded, operation_started, false, requested_locale);
end;
$$;
