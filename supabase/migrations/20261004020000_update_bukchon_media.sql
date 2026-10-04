-- Replace the Bukchon generic image with item-specific, credited Commons media.
-- Each image is linked to its file page for attribution and license details.

do $$
declare
  revision_uuid uuid := '00000000-0000-4000-8000-000000000600';
  pano_url text := 'https://commons.wikimedia.org/wiki/Special:FilePath/Bukchon%20Hanok%20Village%20in%20Seoul.jpg';
  pano_source text := 'https://commons.wikimedia.org/wiki/File:Bukchon_Hanok_Village_in_Seoul.jpg';
  street_url text := 'https://commons.wikimedia.org/wiki/Special:FilePath/Bukchon-ro%2011-gil%20street%20with%20hanok%20houses%20and%20blue%20sky%20in%20Bukchon%20Hanok%20Village%20Seoul.jpg';
  street_source text := 'https://commons.wikimedia.org/wiki/File:Bukchon-ro_11-gil_street_with_hanok_houses_and_blue_sky_in_Bukchon_Hanok_Village_Seoul.jpg';
  dusk_url text := 'https://commons.wikimedia.org/wiki/Special:FilePath/Hanok%20house%20at%20the%20corner%20of%20a%20sloping%20street%20at%20blue%20hour%20in%20Bukchon%20Hanok%20Village%20in%20Seoul.jpg';
  dusk_source text := 'https://commons.wikimedia.org/wiki/File:Hanok_house_at_the_corner_of_a_sloping_street_at_blue_hour_in_Bukchon_Hanok_Village_in_Seoul.jpg';
  historic_url text := 'https://commons.wikimedia.org/wiki/Special:FilePath/Gahoe-dong%20in%20the%201910s.jpg';
  historic_source text := 'https://commons.wikimedia.org/wiki/File:Gahoe-dong_in_the_1910s.jpg';
  alley_url text := 'https://commons.wikimedia.org/wiki/Special:FilePath/Bukchon-ro%2012-gil.jpg';
  alley_source text := 'https://commons.wikimedia.org/wiki/File:Bukchon-ro_12-gil.jpg';
  roof_url text := 'https://commons.wikimedia.org/wiki/Special:FilePath/Hanok%20Roofs%20at%20Night%2C%20Bukcheon%20Village%2C%20Seoul.jpg';
  roof_source text := 'https://commons.wikimedia.org/wiki/File:Hanok_Roofs_at_Night%2C_Bukcheon_Village%2C_Seoul.jpg';
  beverage_url text := 'https://commons.wikimedia.org/wiki/Special:FilePath/Korean%20beverage-Baesuk-01.jpg';
  beverage_source text := 'https://commons.wikimedia.org/wiki/File:Korean_beverage-Baesuk-01.jpg';
  tteok_url text := 'https://commons.wikimedia.org/wiki/Special:FilePath/Korean%20rice%20cake%20Korean%20tteok.jpg';
  tteok_source text := 'https://commons.wikimedia.org/wiki/File:Korean_rice_cake_Korean_tteok.jpg';
  meal_url text := 'https://commons.wikimedia.org/wiki/Special:FilePath/Korean%20food-kore%20yemekleri.JPG';
  meal_source text := 'https://commons.wikimedia.org/wiki/File:Korean_food-kore_yemekleri.JPG';
begin
  update public.location_revisions
  set
    cover_image_url = pano_url,
    cover_image_credit = 'Stevenliuyi / Wikimedia Commons (CC BY-SA 4.0)',
    cover_image_source_url = pano_source,
    cover_image_alt = 'Toàn cảnh mái ngói Bukchon Hanok Village ở Seoul',
    hook_media_url = street_url,
    hook_media_credit = 'Basile Morin / Wikimedia Commons (CC BY-SA 4.0)',
    hook_media_source_url = street_source,
    hook_media_alt = 'Ngõ Bukchon-ro 11-gil với các nhà hanok dưới bầu trời xanh',
    stamp_image_url = pano_url,
    stamp_image_credit = 'Stevenliuyi / Wikimedia Commons (CC BY-SA 4.0)',
    stamp_image_source_url = pano_source,
    stamp_image_alt = 'Mái ngói Bukchon dùng làm hình dấu mộc'
  where id = revision_uuid;

  update public.location_history
  set media_url = historic_url, media_credit = 'Unknown author / Wikimedia Commons (public domain)',
      media_source_url = historic_source, media_alt = 'Gahoe-dong ở Bukchon trong thập niên 1910'
  where revision_id = revision_uuid and display_order = 0;

  update public.location_history
  set media_url = pano_url, media_credit = 'Stevenliuyi / Wikimedia Commons (CC BY-SA 4.0)',
      media_source_url = pano_source, media_alt = 'Mái ngói hanok tại Bukchon Hanok Village'
  where revision_id = revision_uuid and display_order = 1;

  update public.location_history
  set media_url = alley_url, media_credit = 'Wikimedia Commons (see linked file)',
      media_source_url = alley_source, media_alt = 'Con ngõ Bukchon-ro 12-gil, nơi có các không gian thủ công và hanok'
  where revision_id = revision_uuid and display_order = 2;

  update public.location_history
  set media_url = street_url, media_credit = 'Basile Morin / Wikimedia Commons (CC BY-SA 4.0)',
      media_source_url = street_source, media_alt = 'Ngõ Bukchon-ro 11-gil trong khu dân cư hanok'
  where revision_id = revision_uuid and display_order = 3;

  update public.location_highlights
  set media_url = street_url, media_credit = 'Basile Morin / Wikimedia Commons (CC BY-SA 4.0)',
      media_source_url = street_source, media_alt = 'Phố Bukchon-ro 11-gil có nhà hanok và bầu trời xanh'
  where revision_id = revision_uuid and display_order = 0;

  update public.location_highlights
  set media_url = dusk_url, media_credit = 'Basile Morin / Wikimedia Commons (CC BY-SA 4.0)',
      media_source_url = dusk_source, media_alt = 'Nhà hanok có cổng gỗ trên góc dốc ở Bukchon'
  where revision_id = revision_uuid and display_order = 1;

  update public.location_highlights
  set media_url = alley_url, media_credit = 'Wikimedia Commons (see linked file)',
      media_source_url = alley_source, media_alt = 'Bukchon-ro 12-gil, khu vực có các xưởng và hanok'
  where revision_id = revision_uuid and display_order = 2;

  update public.location_highlights
  set media_url = roof_url, media_credit = 'Wikimedia Commons (see linked file)',
      media_source_url = roof_source, media_alt = 'Mái hanok Bukchon nhìn vào ban đêm'
  where revision_id = revision_uuid and display_order = 3;

  update public.location_experiences
  set media_url = street_url, media_credit = 'Basile Morin / Wikimedia Commons (CC BY-SA 4.0)',
      media_source_url = street_source, media_alt = 'Ngõ hanok Bukchon phù hợp cho trải nghiệm đi bộ yên tĩnh'
  where revision_id = revision_uuid and display_order = 0;

  update public.location_experiences
  set media_url = dusk_url, media_credit = 'Basile Morin / Wikimedia Commons (CC BY-SA 4.0)',
      media_source_url = dusk_source, media_alt = 'Nhà hanok Bukchon quan sát từ lối đi công cộng'
  where revision_id = revision_uuid and display_order = 1;

  update public.location_experiences
  set media_url = pano_url, media_credit = 'Stevenliuyi / Wikimedia Commons (CC BY-SA 4.0)',
      media_source_url = pano_source, media_alt = 'Mái ngói Bukchon để quan sát và ghi chép kiến trúc'
  where revision_id = revision_uuid and display_order = 2;

  update public.location_foods
  set image_url = beverage_url, image_credit = 'Wikimedia Commons (see linked file)',
      image_source_url = beverage_source, image_alt = 'Baesuk, một đồ uống truyền thống Hàn Quốc'
  where revision_id = revision_uuid and display_order = 0;

  update public.location_foods
  set image_url = tteok_url, image_credit = 'Wikimedia Commons (see linked file)',
      image_source_url = tteok_source, image_alt = 'Tteok, bánh gạo truyền thống Hàn Quốc'
  where revision_id = revision_uuid and display_order = 1;

  update public.location_foods
  set image_url = meal_url, image_credit = 'Wikimedia Commons (see linked file)',
      image_source_url = meal_source, image_alt = 'Bữa ăn Hàn Quốc nhiều món'
  where revision_id = revision_uuid and display_order = 2;

  update public.quiz_questions
  set media_kind = 'image', media_url = case display_order
    when 0 then pano_url when 1 then pano_url when 2 then street_url
    when 3 then street_url when 4 then pano_url when 5 then street_url
    when 6 then dusk_url when 7 then street_url when 8 then dusk_url else street_url end,
    media_credit = case display_order
      when 0 then 'Stevenliuyi / Wikimedia Commons (CC BY-SA 4.0)'
      when 1 then 'Stevenliuyi / Wikimedia Commons (CC BY-SA 4.0)'
      when 4 then 'Stevenliuyi / Wikimedia Commons (CC BY-SA 4.0)'
      else 'Basile Morin / Wikimedia Commons (CC BY-SA 4.0)' end,
    media_source_url = case display_order
      when 0 then pano_source when 1 then pano_source when 4 then pano_source
      when 6 then dusk_source when 8 then dusk_source else street_source end
  where revision_id = revision_uuid;
end;
$$;

