-- Fix the challenge admin RPC: updated_at was listed without a value.

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
    (payload ->> 'reward_achievement_id')::uuid,
    coalesce((payload ->> 'status')::public.challenge_status, 'draft'), now()
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

revoke all on function public.admin_save_challenge(jsonb) from public;
grant execute on function public.admin_save_challenge(jsonb) to authenticated;
