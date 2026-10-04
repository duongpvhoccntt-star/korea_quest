-- Keep explorer profile data in sync with metadata supplied by Auth sign-up.

create or replace function private.bootstrap_explorer_account()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  suggested_name text;
  supplied_full_name text;
begin
  suggested_name := coalesce(
    nullif(btrim(new.raw_user_meta_data ->> 'display_name'), ''),
    nullif(btrim(new.raw_user_meta_data ->> 'full_name'), ''),
    split_part(new.email, '@', 1),
    'Nhà thám hiểm'
  );
  supplied_full_name := coalesce(
    nullif(btrim(new.raw_user_meta_data ->> 'full_name'), ''),
    suggested_name
  );

  insert into public.explorer_profiles (user_id, display_name, full_name)
  values (new.id, suggested_name, supplied_full_name)
  on conflict (user_id) do update set
    display_name = excluded.display_name,
    full_name = excluded.full_name,
    updated_at = now();

  insert into public.user_preferences (user_id)
  values (new.id) on conflict (user_id) do nothing;

  insert into public.explorer_progress_summary (user_id)
  values (new.id) on conflict (user_id) do nothing;

  return new;
end;
$$;

update public.explorer_profiles as profile
set
  display_name = coalesce(
    nullif(btrim(auth_user.raw_user_meta_data ->> 'display_name'), ''),
    profile.display_name
  ),
  full_name = coalesce(
    nullif(btrim(auth_user.raw_user_meta_data ->> 'full_name'), ''),
    profile.full_name
  ),
  updated_at = now()
from auth.users as auth_user
where profile.user_id = auth_user.id
  and (
    nullif(btrim(auth_user.raw_user_meta_data ->> 'display_name'), '') is not null
    or nullif(btrim(auth_user.raw_user_meta_data ->> 'full_name'), '') is not null
  );
