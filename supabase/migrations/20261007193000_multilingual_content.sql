-- Multilingual content overlays for location revisions.
-- Vietnamese remains the canonical revision. English and Korean store only
-- localized, user-facing text while structure, media, scoring and XP stay shared.

create type public.content_locale as enum ('vi', 'en', 'ko');
create type public.translation_review_status as enum (
  'draft',
  'needs_review',
  'approved'
);

create table public.location_revision_translations (
  revision_id uuid not null references public.location_revisions (id) on delete cascade,
  locale public.content_locale not null,
  status public.translation_review_status not null default 'draft',
  content jsonb not null default '{"summary": {}, "detail": {}}'::jsonb,
  source_lock_version integer not null,
  created_at timestamptz not null default now(),
  created_by uuid references auth.users (id) on delete set null,
  updated_at timestamptz not null default now(),
  updated_by uuid references auth.users (id) on delete set null,
  approved_at timestamptz,
  approved_by uuid references auth.users (id) on delete set null,
  primary key (revision_id, locale),
  constraint location_translation_content_object check (jsonb_typeof(content) = 'object'),
  constraint location_translation_source_lock_positive check (source_lock_version > 0),
  constraint location_translation_approval_consistent check (
    (status = 'approved' and approved_at is not null)
    or (status <> 'approved')
  )
);

create index location_revision_translations_public_idx
  on public.location_revision_translations (revision_id, locale)
  where status = 'approved';

alter table public.location_revision_translations enable row level security;

create policy location_revision_translations_admin_access
on public.location_revision_translations
for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

create policy location_revision_translations_published_read
on public.location_revision_translations
for select
to anon, authenticated
using (
  status = 'approved'
  and public.can_read_revision(revision_id)
);

revoke all on table public.location_revision_translations from anon, authenticated;
grant select on table public.location_revision_translations to anon, authenticated;

insert into public.location_revision_translations (
  revision_id, locale, status, content, source_lock_version,
  created_by, updated_by, approved_at, approved_by
)
select
  revision.id, 'vi', 'approved', '{"summary": {}, "detail": {}}'::jsonb,
  revision.lock_version, revision.created_by, revision.updated_by,
  coalesce(revision.updated_at, now()), revision.updated_by
from public.location_revisions revision
on conflict (revision_id, locale) do nothing;

create or replace function private.sync_revision_translation_state()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if tg_op = 'INSERT' then
    insert into public.location_revision_translations (
      revision_id, locale, status, content, source_lock_version,
      created_by, updated_by, approved_at, approved_by
    ) values (
      new.id, 'vi', 'approved', '{"summary": {}, "detail": {}}'::jsonb,
      new.lock_version, new.created_by, new.updated_by,
      coalesce(new.updated_at, now()), new.updated_by
    ) on conflict (revision_id, locale) do nothing;

    if new.base_revision_id is not null then
      insert into public.location_revision_translations (
        revision_id, locale, status, content, source_lock_version,
        created_by, updated_by
      )
      select
        new.id, translation.locale, 'needs_review', translation.content,
        new.lock_version, auth.uid(), auth.uid()
      from public.location_revision_translations translation
      where translation.revision_id = new.base_revision_id
        and translation.locale <> 'vi'
      on conflict (revision_id, locale) do nothing;
    end if;
    return new;
  end if;

  if new.lock_version is distinct from old.lock_version then
    update public.location_revision_translations translation
    set status = case
          when translation.locale = 'vi' then 'approved'::public.translation_review_status
          else 'needs_review'::public.translation_review_status
        end,
        source_lock_version = new.lock_version,
        updated_at = now(),
        updated_by = auth.uid(),
        approved_at = case when translation.locale = 'vi' then now() else null end,
        approved_by = case when translation.locale = 'vi' then auth.uid() else null end
    where translation.revision_id = new.id;
  end if;
  return new;
end;
$$;

create trigger sync_revision_translation_state
after insert or update of lock_version on public.location_revisions
for each row execute function private.sync_revision_translation_state();

create or replace function private.jsonb_deep_merge(base jsonb, localized jsonb)
returns jsonb
language sql
immutable
set search_path = ''
as $$
  select case
    when jsonb_typeof(base) = 'array' and jsonb_typeof(localized) = 'array'
      then coalesce((
        select jsonb_agg(
          case
            when base -> index is null then localized -> index
            when localized -> index is null then base -> index
            else private.jsonb_deep_merge(base -> index, localized -> index)
          end order by index
        )
        from generate_series(
          0,
          greatest(jsonb_array_length(base), jsonb_array_length(localized)) - 1
        ) index
      ), '[]'::jsonb)
    when jsonb_typeof(base) <> 'object' or jsonb_typeof(localized) <> 'object'
      then localized
    else coalesce((
      select jsonb_object_agg(
        key,
        case
          when base -> key is not null and localized -> key is not null
            then private.jsonb_deep_merge(base -> key, localized -> key)
          else coalesce(localized -> key, base -> key)
        end
      )
      from (
        select jsonb_object_keys(base) as key
        union
        select jsonb_object_keys(localized) as key
      ) keys
    ), '{}'::jsonb)
  end;
$$;

alter function public.list_published_locations()
  rename to list_published_locations_vi;
alter function public.get_published_location(text)
  rename to get_published_location_vi;
alter function public.submit_quiz_answer(uuid, jsonb)
  rename to submit_quiz_answer_vi;

revoke all on function public.list_published_locations_vi() from public;
revoke all on function public.get_published_location_vi(text) from public;
revoke all on function public.submit_quiz_answer_vi(uuid, jsonb) from public;

create or replace function public.list_published_locations(
  requested_locale text default 'vi'
)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  with normalized as (
    select case when requested_locale in ('vi', 'en', 'ko')
      then requested_locale else 'vi' end as locale
  ), base_items as (
    select item
    from jsonb_array_elements(public.list_published_locations_vi()) item
  )
  select coalesce(jsonb_agg(
    private.jsonb_deep_merge(
      base.item,
      case when normalized.locale = 'vi'
        then '{}'::jsonb
        else coalesce(translation.content -> 'summary', '{}'::jsonb)
      end
    ) || jsonb_build_object(
      'requested_locale', normalized.locale,
      'resolved_locale', case when translation.revision_id is null then 'vi' else normalized.locale end,
      'is_fallback', normalized.locale <> 'vi' and translation.revision_id is null
    )
  ), '[]'::jsonb)
  from base_items base
  cross join normalized
  left join public.location_revisions revision
    on revision.location_id = (base.item ->> 'id')::uuid
    and revision.status = 'published'
  left join public.location_revision_translations translation
    on translation.revision_id = revision.id
    and translation.locale::text = normalized.locale
    and translation.status = 'approved';
$$;

create or replace function public.get_published_location(
  target_slug text,
  requested_locale text default 'vi'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  normalized_locale text := case when requested_locale in ('vi', 'en', 'ko')
    then requested_locale else 'vi' end;
  base jsonb;
  localized jsonb;
begin
  base := public.get_published_location_vi(target_slug);
  if base is null then return null; end if;

  if normalized_locale <> 'vi' then
    select translation.content -> 'detail' into localized
    from public.location_revision_translations translation
    where translation.revision_id = (base ->> 'revision_id')::uuid
      and translation.locale::text = normalized_locale
      and translation.status = 'approved';
  end if;

  return private.jsonb_deep_merge(base, coalesce(localized, '{}'::jsonb))
    || jsonb_build_object(
      'requested_locale', normalized_locale,
      'resolved_locale', case when localized is null then 'vi' else normalized_locale end,
      'is_fallback', normalized_locale <> 'vi' and localized is null
    );
end;
$$;

create or replace function public.submit_quiz_answer(
  question_id uuid,
  answer jsonb,
  requested_locale text default 'vi'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  result jsonb := public.submit_quiz_answer_vi(question_id, answer);
  translated_explanation text;
begin
  if requested_locale in ('en', 'ko') then
    select quiz_item ->> 'explanation' into translated_explanation
    from public.quiz_questions question
    join public.location_revision_translations translation
      on translation.revision_id = question.revision_id
      and translation.locale::text = requested_locale
      and translation.status = 'approved'
    cross join lateral jsonb_array_elements(
      coalesce(translation.content #> '{detail,quiz}', '[]'::jsonb)
    ) with ordinality as localized_quiz(quiz_item, position)
    where question.id = submit_quiz_answer.question_id
      and localized_quiz.position = question.display_order + 1
    limit 1;
  end if;
  return case when translated_explanation is null then result
    else jsonb_set(result, '{explanation}', to_jsonb(translated_explanation)) end;
end;
$$;

create or replace function public.admin_list_location_translations(
  target_revision_id uuid
)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  perform private.assert_admin();
  return coalesce((
    select jsonb_agg(jsonb_build_object(
      'locale', translation.locale,
      'status', translation.status,
      'content', translation.content,
      'source_lock_version', translation.source_lock_version,
      'updated_at', translation.updated_at,
      'approved_at', translation.approved_at
    ) order by translation.locale)
    from public.location_revision_translations translation
    where translation.revision_id = target_revision_id
  ), '[]'::jsonb);
end;
$$;

create or replace function public.admin_save_location_translation(
  target_revision_id uuid,
  target_locale text,
  translated_content jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  revision public.location_revisions%rowtype;
  saved public.location_revision_translations%rowtype;
begin
  perform private.assert_admin();
  if target_locale not in ('en', 'ko') then
    raise exception 'Chỉ có thể lưu bản dịch tiếng Anh hoặc tiếng Hàn.' using errcode = '22023';
  end if;
  if jsonb_typeof(translated_content) <> 'object' then
    raise exception 'Nội dung bản dịch phải là JSON object.' using errcode = '22023';
  end if;
  select * into revision from public.location_revisions where id = target_revision_id;
  if not found then raise exception 'Không tìm thấy Phiên bản nội dung.' using errcode = 'P0002'; end if;

  insert into public.location_revision_translations (
    revision_id, locale, status, content, source_lock_version,
    created_by, updated_by
  ) values (
    revision.id, target_locale::public.content_locale, 'needs_review',
    translated_content, revision.lock_version, auth.uid(), auth.uid()
  )
  on conflict (revision_id, locale) do update
  set content = excluded.content,
      status = 'needs_review',
      source_lock_version = excluded.source_lock_version,
      updated_at = now(),
      updated_by = auth.uid(),
      approved_at = null,
      approved_by = null
  returning * into saved;

  return jsonb_build_object(
    'locale', saved.locale, 'status', saved.status,
    'content', saved.content, 'source_lock_version', saved.source_lock_version,
    'updated_at', saved.updated_at, 'approved_at', saved.approved_at
  );
end;
$$;

create or replace function public.admin_approve_location_translation(
  target_revision_id uuid,
  target_locale text
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  saved public.location_revision_translations%rowtype;
  current_lock integer;
begin
  perform private.assert_admin();
  if target_locale not in ('en', 'ko') then
    raise exception 'Chỉ có thể duyệt bản dịch tiếng Anh hoặc tiếng Hàn.' using errcode = '22023';
  end if;
  select lock_version into current_lock from public.location_revisions where id = target_revision_id;
  update public.location_revision_translations translation
  set status = 'approved', approved_at = now(), approved_by = auth.uid(),
      updated_at = now(), updated_by = auth.uid()
  where translation.revision_id = target_revision_id
    and translation.locale::text = target_locale
    and translation.source_lock_version = current_lock
  returning * into saved;
  if not found then
    raise exception 'Bản dịch chưa tồn tại hoặc nội dung tiếng Việt đã thay đổi.' using errcode = 'P0001';
  end if;
  return jsonb_build_object(
    'locale', saved.locale, 'status', saved.status,
    'content', saved.content, 'source_lock_version', saved.source_lock_version,
    'updated_at', saved.updated_at, 'approved_at', saved.approved_at
  );
end;
$$;

revoke all on function public.list_published_locations(text) from public;
revoke all on function public.get_published_location(text, text) from public;
revoke all on function public.submit_quiz_answer(uuid, jsonb, text) from public;
revoke all on function public.admin_list_location_translations(uuid) from public;
revoke all on function public.admin_save_location_translation(uuid, text, jsonb) from public;
revoke all on function public.admin_approve_location_translation(uuid, text) from public;
grant execute on function public.list_published_locations(text) to anon, authenticated;
grant execute on function public.get_published_location(text, text) to anon, authenticated;
grant execute on function public.submit_quiz_answer(uuid, jsonb, text) to anon, authenticated;
grant execute on function public.admin_list_location_translations(uuid) to authenticated;
grant execute on function public.admin_save_location_translation(uuid, text, jsonb) to authenticated;
grant execute on function public.admin_approve_location_translation(uuid, text) to authenticated;
