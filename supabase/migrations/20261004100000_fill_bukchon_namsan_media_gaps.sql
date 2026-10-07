-- The published explorer renders a media placeholder whenever media.url is
-- empty. Fill the remaining Bukchon and Namsan fun-fact and quiz media gaps.

do $$
declare
  bukchon_revision uuid;
  namsan_revision uuid;
  bukchon_pano_url text := 'https://commons.wikimedia.org/wiki/Special:FilePath/Bukchon%20Hanok%20Village%20in%20Seoul.jpg';
  bukchon_pano_source text := 'https://commons.wikimedia.org/wiki/File:Bukchon_Hanok_Village_in_Seoul.jpg';
  bukchon_historic_url text := 'https://commons.wikimedia.org/wiki/Special:FilePath/Gahoe-dong%20in%20the%201910s.jpg';
  bukchon_historic_source text := 'https://commons.wikimedia.org/wiki/File:Gahoe-dong_in_the_1910s.jpg';
  bukchon_alley_url text := 'https://commons.wikimedia.org/wiki/Special:FilePath/Bukchon-ro%2012-gil.jpg';
  bukchon_alley_source text := 'https://commons.wikimedia.org/wiki/File:Bukchon-ro_12-gil.jpg';
  bukchon_street_url text := 'https://commons.wikimedia.org/wiki/Special:FilePath/Bukchon-ro%2011-gil%20street%20with%20hanok%20houses%20and%20blue%20sky%20in%20Bukchon%20Hanok%20Village%20Seoul.jpg';
  bukchon_street_source text := 'https://commons.wikimedia.org/wiki/File:Bukchon-ro_11-gil_street_with_hanok_houses_and_blue_sky_in_Bukchon_Hanok_Village_Seoul.jpg';
  namsan_url text := 'https://commons.wikimedia.org/wiki/Special:FilePath/N%20Seoul%20Tower%20%2813952097192%29.jpg';
  namsan_source text := 'https://commons.wikimedia.org/wiki/File:N_Seoul_Tower_(13952097192).jpg';
  commons_credit text := 'Wikimedia Commons (see linked file)';
begin
  select revision.id into bukchon_revision
  from public.locations location
  join public.location_revisions revision on revision.location_id = location.id
  where location.slug = 'bukchon-hanok' and revision.status = 'published';

  select revision.id into namsan_revision
  from public.locations location
  join public.location_revisions revision on revision.location_id = location.id
  where location.slug = 'namsan' and revision.status = 'published';

  if bukchon_revision is null or namsan_revision is null then
    raise exception 'Published Bukchon or Namsan revision is missing';
  end if;

  update public.location_fun_facts
  set media_kind = 'image', media_url = bukchon_historic_url,
      media_credit = 'Unknown author / Wikimedia Commons (public domain)',
      media_source_url = bukchon_historic_source,
      media_alt = 'Gahoe-dong ở Bukchon trong thập niên 1910'
  where revision_id = bukchon_revision and display_order = 0;

  update public.location_fun_facts
  set media_kind = 'image', media_url = bukchon_pano_url,
      media_credit = 'Stevenliuyi / Wikimedia Commons (CC BY-SA 4.0)',
      media_source_url = bukchon_pano_source,
      media_alt = 'Mái ngói Bukchon Hanok Village ở Seoul'
  where revision_id = bukchon_revision and display_order = 1;

  update public.location_fun_facts
  set media_kind = 'image', media_url = bukchon_alley_url,
      media_credit = commons_credit, media_source_url = bukchon_alley_source,
      media_alt = 'Con ngõ Bukchon-ro 12-gil với nhà hanok'
  where revision_id = bukchon_revision and display_order = 2;

  update public.location_fun_facts
  set media_kind = 'image', media_url = bukchon_street_url,
      media_credit = 'Basile Morin / Wikimedia Commons (CC BY-SA 4.0)',
      media_source_url = bukchon_street_source,
      media_alt = 'Ngõ Bukchon-ro 11-gil trong khu dân cư hanok'
  where revision_id = bukchon_revision and display_order = 3;

  update public.location_fun_facts
  set media_kind = 'image', media_url = namsan_url,
      media_credit = commons_credit, media_source_url = namsan_source,
      media_alt = 'Namsan Seoul Tower nhìn từ công viên Namsan'
  where revision_id = namsan_revision;

  update public.quiz_questions
  set
    media_kind = 'image', media_url = namsan_url,
    media_credit = commons_credit, media_source_url = namsan_source,
    media_alt = case display_order
      when 0 then 'Namsan Seoul Tower, minh họa câu hỏi về năm mở cửa'
      when 1 then 'Namsan Seoul Tower, công trình truyền phát và đài quan sát'
      when 2 then 'Namsan Seoul Tower trên núi Namsan'
      when 3 then 'Namsan Seoul Tower, minh họa câu hỏi về chiều cao'
      when 4 then 'Namsan Seoul Tower Plaza'
      when 5 then 'Namsan Seoul Tower, điểm đến trên núi Namsan'
      when 6 then 'Namsan Seoul Tower, điểm tiếp cận từ cáp treo'
      when 7 then 'Namsan Seoul Tower và đài quan sát'
      when 8 then 'Namsan Seoul Tower trong công viên Namsan'
      when 9 then 'Namsan Seoul Tower, điểm ngắm cảnh đêm Seoul'
    end
  where revision_id = namsan_revision;
end;
$$;
