-- Give each Gyeongbokgung learning item an image that matches its subject.
-- Every image points to its Wikimedia Commons file page for attribution and
-- licence details; no generic palace image is used for food or quiz content.

do $$
declare
  revision_uuid uuid := '00000000-0000-4000-8000-000000000200';
  commons_credit text := 'Wikimedia Commons (see linked file)';
  geunjeong_url text := 'https://commons.wikimedia.org/wiki/Special:FilePath/Front_view_of_the_Imperial_Throne_Hall_Geunjeongjeon_at_Gyeongbokgung_Palace_with_blue_sky_in_Seoul.jpg';
  geunjeong_source text := 'https://commons.wikimedia.org/wiki/File:Front_view_of_the_Imperial_Throne_Hall_Geunjeongjeon_at_Gyeongbokgung_Palace_with_blue_sky_in_Seoul.jpg';
  gwanghwa_url text := 'https://commons.wikimedia.org/wiki/Special:FilePath/Gwanghwamun%2C%20Gyeongbokgung.jpg';
  gwanghwa_source text := 'https://commons.wikimedia.org/wiki/File:Gwanghwamun%2C_Gyeongbokgung.jpg';
  gwanghwa_modern_url text := 'https://commons.wikimedia.org/wiki/Special:FilePath/Gwanghwamun%2020240413.jpg';
  gwanghwa_modern_source text := 'https://commons.wikimedia.org/wiki/File:Gwanghwamun_20240413.jpg';
  gyeonghoeru_url text := 'https://commons.wikimedia.org/wiki/Special:FilePath/Gyeonghoeru%20%28Royal%20Banquet%20Hall%29%20at%20Gyeongbokgung%20Palace%2C%20Seoul.jpg';
  gyeonghoeru_source text := 'https://commons.wikimedia.org/wiki/File:Gyeonghoeru_(Royal_Banquet_Hall)_at_Gyeongbokgung_Palace,_Seoul.jpg';
  gyeonghoeru_1884_url text := 'https://commons.wikimedia.org/wiki/Special:FilePath/Gyeonghoeru%201884.jpg';
  gyeonghoeru_1884_source text := 'https://commons.wikimedia.org/wiki/File:Gyeonghoeru_1884.jpg';
  gyeonghoeru_1945_url text := 'https://commons.wikimedia.org/wiki/Special:FilePath/Gyeonghoeru%20in%201945.jpg';
  gyeonghoeru_1945_source text := 'https://commons.wikimedia.org/wiki/File:Gyeonghoeru_in_1945.jpg';
  hyangwon_url text := 'https://commons.wikimedia.org/wiki/Special:FilePath/Hyangwonjeong%20Pavilion%20and%20Chwihyanggyo%20Bridge%20at%20Gyeongbokgung%20Palace%20with%20blue%20sky%20in%20Seoul.jpg';
  hyangwon_source text := 'https://commons.wikimedia.org/wiki/File:Hyangwonjeong_Pavilion_and_Chwihyanggyo_Bridge_at_Gyeongbokgung_Palace_with_blue_sky_in_Seoul.jpg';
  guard_url text := 'https://commons.wikimedia.org/wiki/Special:FilePath/Changing%20Guard%20at%20Gyeongbokgung%202018-09-05%20%2811%29.jpg';
  guard_source text := 'https://commons.wikimedia.org/wiki/File:Changing_Guard_at_Gyeongbokgung_2018-09-05_(11).jpg';
  hanbok_url text := 'https://commons.wikimedia.org/wiki/Special:FilePath/Gyeongbokgung%20Hanbok%2001%20%2832928645842%29.jpg';
  hanbok_source text := 'https://commons.wikimedia.org/wiki/File:Gyeongbokgung_Hanbok_01_(32928645842).jpg';
  bibimbap_url text := 'https://commons.wikimedia.org/wiki/Special:FilePath/Korean%20cuisine-Bibimbap-01.jpg';
  bibimbap_source text := 'https://commons.wikimedia.org/wiki/File:Korean_cuisine-Bibimbap-01.jpg';
  tteokbokki_url text := 'https://commons.wikimedia.org/wiki/Special:FilePath/Korean%20snack-Tteokbokki-01.jpg';
  tteokbokki_source text := 'https://commons.wikimedia.org/wiki/File:Korean_snack-Tteokbokki-01.jpg';
  yuja_url text := 'https://commons.wikimedia.org/wiki/Special:FilePath/Korean%20tea-Yujacha-01.jpg';
  yuja_source text := 'https://commons.wikimedia.org/wiki/File:Korean_tea-Yujacha-01.jpg';
begin
  if not exists (select 1 from public.location_revisions where id = revision_uuid) then
    raise exception 'Published Gyeongbokgung revision % is missing', revision_uuid;
  end if;

  update public.location_history
  set media_url = geunjeong_url, media_credit = 'Basile Morin / Wikimedia Commons (CC BY-SA 4.0)',
      media_source_url = geunjeong_source,
      media_alt = 'Điện Geunjeongjeon, chính điện của Gyeongbokgung'
  where revision_id = revision_uuid and display_order = 0;

  update public.location_history
  set media_url = gyeonghoeru_1945_url, media_credit = commons_credit,
      media_source_url = gyeonghoeru_1945_source,
      media_alt = 'Ảnh tư liệu Gyeonghoeru năm 1945, minh họa các lớp lịch sử của cung'
  where revision_id = revision_uuid and display_order = 1;

  update public.location_history
  set media_url = gyeonghoeru_1884_url, media_credit = commons_credit,
      media_source_url = gyeonghoeru_1884_source,
      media_alt = 'Ảnh Gyeonghoeru năm 1884, sau đợt trùng tu Gyeongbokgung thế kỷ 19'
  where revision_id = revision_uuid and display_order = 2;

  update public.location_history
  set media_url = gwanghwa_modern_url, media_credit = commons_credit,
      media_source_url = gwanghwa_modern_source,
      media_alt = 'Cổng Gwanghwamun đã được phục hồi của Gyeongbokgung'
  where revision_id = revision_uuid and display_order = 3;

  update public.location_highlights
  set media_url = gwanghwa_url, media_credit = commons_credit,
      media_source_url = gwanghwa_source,
      media_alt = 'Cổng chính Gwanghwamun của cung điện Gyeongbokgung'
  where revision_id = revision_uuid and display_order = 0;

  update public.location_highlights
  set media_url = geunjeong_url, media_credit = 'Basile Morin / Wikimedia Commons (CC BY-SA 4.0)',
      media_source_url = geunjeong_source,
      media_alt = 'Mặt tiền điện Geunjeongjeon dưới bầu trời xanh'
  where revision_id = revision_uuid and display_order = 1;

  update public.location_highlights
  set media_url = gyeonghoeru_url, media_credit = commons_credit,
      media_source_url = gyeonghoeru_source,
      media_alt = 'Lầu Gyeonghoeru bên hồ trong khuôn viên Gyeongbokgung'
  where revision_id = revision_uuid and display_order = 2;

  update public.location_highlights
  set media_url = hyangwon_url, media_credit = commons_credit,
      media_source_url = hyangwon_source,
      media_alt = 'Đình Hyangwonjeong và cầu Chwihyanggyo ở Gyeongbokgung'
  where revision_id = revision_uuid and display_order = 3;

  update public.location_experiences
  set media_url = guard_url, media_credit = commons_credit,
      media_source_url = guard_source,
      media_alt = 'Nghi lễ đổi gác tại Gyeongbokgung'
  where revision_id = revision_uuid and display_order = 0;

  update public.location_experiences
  set media_url = hanbok_url, media_credit = commons_credit,
      media_source_url = hanbok_source,
      media_alt = 'Khách tham quan mặc hanbok tại Gyeongbokgung'
  where revision_id = revision_uuid and display_order = 1;

  update public.location_experiences
  set media_url = hyangwon_url, media_credit = commons_credit,
      media_source_url = hyangwon_source,
      media_alt = 'Hyangwonjeong là điểm quan sát kiến trúc và cảnh quan trong cung'
  where revision_id = revision_uuid and display_order = 2;

  update public.location_foods
  set image_url = bibimbap_url, image_credit = commons_credit,
      image_source_url = bibimbap_source,
      image_alt = 'Bibimbap, cơm trộn kiểu Hàn Quốc'
  where revision_id = revision_uuid and display_order = 0;

  update public.location_foods
  set image_url = tteokbokki_url, image_credit = commons_credit,
      image_source_url = tteokbokki_source,
      image_alt = 'Tteokbokki, bánh gạo cay kiểu Hàn Quốc'
  where revision_id = revision_uuid and display_order = 1;

  update public.location_foods
  set image_url = yuja_url, image_credit = commons_credit,
      image_source_url = yuja_source,
      image_alt = 'Yujacha, trà yuja truyền thống của Hàn Quốc'
  where revision_id = revision_uuid and display_order = 2;

  update public.location_fun_facts
  set media_kind = 'image', media_url = geunjeong_url,
      media_credit = 'Basile Morin / Wikimedia Commons (CC BY-SA 4.0)',
      media_source_url = geunjeong_source,
      media_alt = 'Điện Geunjeongjeon tại Gyeongbokgung'
  where revision_id = revision_uuid and display_order = 0;

  update public.location_fun_facts
  set media_kind = 'image', media_url = gyeonghoeru_url,
      media_credit = commons_credit, media_source_url = gyeonghoeru_source,
      media_alt = 'Lầu Gyeonghoeru trong khuôn viên Gyeongbokgung'
  where revision_id = revision_uuid and display_order = 1;

  update public.location_fun_facts
  set media_kind = 'image', media_url = geunjeong_url,
      media_credit = 'Basile Morin / Wikimedia Commons (CC BY-SA 4.0)',
      media_source_url = geunjeong_source,
      media_alt = 'Sân đá trước điện Geunjeongjeon, nơi đặt bia thứ bậc nghi lễ'
  where revision_id = revision_uuid and display_order = 2;

  update public.location_fun_facts
  set media_kind = 'image', media_url = hyangwon_url,
      media_credit = commons_credit, media_source_url = hyangwon_source,
      media_alt = 'Đình Hyangwonjeong trên đảo nhỏ giữa hồ'
  where revision_id = revision_uuid and display_order = 3;

  update public.quiz_questions
  set
    media_kind = 'image',
    media_url = case display_order
      when 0 then geunjeong_url
      when 1 then gwanghwa_url
      when 2 then geunjeong_url
      when 3 then gyeonghoeru_url
      when 4 then hyangwon_url
      when 5 then gyeonghoeru_1945_url
      when 6 then gyeonghoeru_1884_url
      when 7 then gwanghwa_url
      when 8 then gwanghwa_modern_url
      when 9 then hanbok_url
    end,
    media_credit = case display_order
      when 0 then 'Basile Morin / Wikimedia Commons (CC BY-SA 4.0)'
      when 2 then 'Basile Morin / Wikimedia Commons (CC BY-SA 4.0)'
      else commons_credit
    end,
    media_source_url = case display_order
      when 0 then geunjeong_source
      when 1 then gwanghwa_source
      when 2 then geunjeong_source
      when 3 then gyeonghoeru_source
      when 4 then hyangwon_source
      when 5 then gyeonghoeru_1945_source
      when 6 then gyeonghoeru_1884_source
      when 7 then gwanghwa_source
      when 8 then gwanghwa_modern_source
      when 9 then hanbok_source
    end,
    media_alt = case display_order
      when 0 then 'Điện Geunjeongjeon tại Gyeongbokgung'
      when 1 then 'Cổng Gwanghwamun tại Gyeongbokgung'
      when 2 then 'Chính điện Geunjeongjeon của Gyeongbokgung'
      when 3 then 'Lầu Gyeonghoeru dùng cho yến tiệc hoàng gia'
      when 4 then 'Đình Hyangwonjeong trên hồ trong cung'
      when 5 then 'Ảnh tư liệu Gyeonghoeru năm 1945'
      when 6 then 'Ảnh Gyeonghoeru năm 1884'
      when 7 then 'Cổng Gwanghwamun, lối vào khu cung điện'
      when 8 then 'Cổng Gwanghwamun đã được phục hồi'
      when 9 then 'Khách mặc hanbok tham quan Gyeongbokgung'
    end
  where revision_id = revision_uuid;
end;
$$;

