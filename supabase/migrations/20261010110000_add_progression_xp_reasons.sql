-- Additive enum changes must commit before later migrations use the values.
alter type public.xp_reason add value if not exists 'task_completed';
alter type public.xp_reason add value if not exists 'stage_completed';
