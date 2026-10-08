-- Lower the minimum publication length from 25 to 10 words while preserving
-- the 200-word maximum introduced by the previous validation migration.

do $migration$
declare
  function_definition text;
  updated_definition text;
  validation_pattern constant text := 'not between 25 and 200';
  expected_replacements constant integer := 12;
  replacement_count integer;
begin
  function_definition := pg_get_functiondef(
    'public.validate_location_revision(uuid)'::regprocedure
  );

  replacement_count := (
    length(function_definition)
    - length(replace(function_definition, validation_pattern, ''))
  ) / length(validation_pattern);

  if replacement_count <> expected_replacements then
    raise exception
      'Expected % publication word-limit checks, found %',
      expected_replacements,
      replacement_count;
  end if;

  updated_definition := replace(
    function_definition,
    validation_pattern,
    'not between 10 and 200'
  );
  updated_definition := replace(updated_definition, '25–200', '10–200');

  execute updated_definition;
end;
$migration$;
