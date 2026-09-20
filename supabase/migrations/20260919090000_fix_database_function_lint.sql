-- Keep the published migration immutable while correcting function metadata
-- and an array initializer flagged by plpgsql_check on the linked database.

alter function private.assert_admin() stable;

do $migration$
declare
  function_sql text;
  corrected_sql text;
begin
  select pg_get_functiondef(
    'public.validate_location_revision(uuid)'::regprocedure
  ) into function_sql;

  corrected_sql := replace(
    function_sql,
    'errors text[] := ''{}'';',
    'errors text[] := array[]::text[];'
  );

  if corrected_sql = function_sql then
    corrected_sql := replace(
      function_sql,
      'errors text[] := ''{}''::text[];',
      'errors text[] := array[]::text[];'
    );
  end if;

  if corrected_sql = function_sql then
    raise exception
      'Không tìm thấy khai báo errors trong validate_location_revision.';
  end if;

  execute corrected_sql;
end;
$migration$;
