-- Give every Namsan learning item media that matches its subject instead of
-- repeating the same tower photo. All images are hosted by Wikimedia Commons;
-- their linked file pages retain the author and licence information.

do $$
declare
  namsan_revision uuid;
  commons_credit text := 'Wikimedia Commons (see linked file)';

  tower_itaewon_url text := 'https://commons.wikimedia.org/wiki/Special:FilePath/N-Seoul%20tower%20from%20Itaewon%20bridge%20pinhole.jpg';
  tower_itaewon_source text := 'https://commons.wikimedia.org/wiki/File:N-Seoul_tower_from_Itaewon_bridge_pinhole.jpg';
  tower_day_url text := 'https://commons.wikimedia.org/wiki/Special:FilePath/N%20Seoul%20Tower%20%2813952097192%29.jpg';
  tower_day_source text := 'https://commons.wikimedia.org/wiki/File:N_Seoul_Tower_(13952097192).jpg';
  tower_panorama_url text := 'https://commons.wikimedia.org/wiki/Special:FilePath/N%20Seoul%20Tower%20Panorama%20Night.jpg';
  tower_panorama_source text := 'https://commons.wikimedia.org/wiki/File:N_Seoul_Tower_Panorama_Night.jpg';
  tower_night_view_url text := 'https://commons.wikimedia.org/wiki/Special:FilePath/View%20from%20N%20Seoul%20Tower%20at%20night.jpg';
  tower_night_view_source text := 'https://commons.wikimedia.org/wiki/File:View_from_N_Seoul_Tower_at_night.jpg';
  view_north_url text := 'https://commons.wikimedia.org/wiki/Special:FilePath/N%20Seoul%20Tower%20view%20north.jpg';
  view_north_source text := 'https://commons.wikimedia.org/wiki/File:N_Seoul_Tower_view_north.jpg';
  view_south_url text := 'https://commons.wikimedia.org/wiki/Special:FilePath/N%20Seoul%20Tower%20view%20south%20wide.jpg';
  view_south_source text := 'https://commons.wikimedia.org/wiki/File:N_Seoul_Tower_view_south_wide.jpg';
  cable_car_url text := 'https://commons.wikimedia.org/wiki/Special:FilePath/Korea-Seoul-Namsan%20Cable%20Car-01.jpg';
  cable_car_source text := 'https://commons.wikimedia.org/wiki/File:Korea-Seoul-Namsan_Cable_Car-01.jpg';
  park_tower_url text := 'https://commons.wikimedia.org/wiki/Special:FilePath/N-Seoul-Tower%20and%20Namsan%20Park%20%2826876783888%29.jpg';
  park_tower_source text := 'https://commons.wikimedia.org/wiki/File:N-Seoul-Tower_and_Namsan_Park_(26876783888).jpg';
  park_entrance_url text := 'https://commons.wikimedia.org/wiki/Special:FilePath/Namsan%20Park%20Entrance.jpg';
  park_entrance_source text := 'https://commons.wikimedia.org/wiki/File:Namsan_Park_Entrance.jpg';
  park_path_url text := 'https://commons.wikimedia.org/wiki/Special:FilePath/Namsan%20Park%2C%20Seoul%2C%20South%20Korea%20%28Unsplash%29.jpg';
  park_path_source text := 'https://commons.wikimedia.org/wiki/File:Namsan_Park,_Seoul,_South_Korea_(Unsplash).jpg';
  love_locks_url text := 'https://commons.wikimedia.org/wiki/Special:FilePath/Heart-Shaped%20Love%20Locks%20on%20the%20N%20Seoul%20Tower.jpg';
  love_locks_source text := 'https://commons.wikimedia.org/wiki/File:Heart-Shaped_Love_Locks_on_the_N_Seoul_Tower.jpg';
  bibimbap_url text := 'https://commons.wikimedia.org/wiki/Special:FilePath/Korean%20cuisine-Bibimbap-01.jpg';
  bibimbap_source text := 'https://commons.wikimedia.org/wiki/File:Korean_cuisine-Bibimbap-01.jpg';
  tteokbokki_url text := 'https://commons.wikimedia.org/wiki/Special:FilePath/Korean%20snack-Tteokbokki-01.jpg';
  tteokbokki_source text := 'https://commons.wikimedia.org/wiki/File:Korean_snack-Tteokbokki-01.jpg';
  yujacha_url text := 'https://commons.wikimedia.org/wiki/Special:FilePath/Korean%20tea-Yujacha-01.jpg';
  yujacha_source text := 'https://commons.wikimedia.org/wiki/File:Korean_tea-Yujacha-01.jpg';
begin
  select revision.id into namsan_revision
  from public.locations location
  join public.location_revisions revision on revision.location_id = location.id
  where location.slug = 'namsan' and revision.status = 'published';

  if namsan_revision is null then
    raise exception 'Published Namsan revision is missing';
  end if;

  update public.location_history
  set media_url = case display_order
        when 0 then tower_day_url
        when 1 then tower_itaewon_url
        when 2 then view_north_url
        when 3 then tower_panorama_url
      end,
      media_credit = commons_credit,
      media_source_url = case display_order
        when 0 then tower_day_source
        when 1 then tower_itaewon_source
        when 2 then view_north_source
        when 3 then tower_panorama_source
      end,
      media_alt = case display_order
        when 0 then 'Namsan Seoul Tower, công trình được xây dựng trên đỉnh Namsan'
        when 1 then 'Namsan Seoul Tower trong đường chân trời Seoul, minh họa vai trò tháp truyền phát'
        when 2 then 'Góc nhìn về Seoul từ Namsan Seoul Tower, gắn với đài quan sát mở cho công chúng'
        when 3 then 'Namsan Seoul Tower trong toàn cảnh đêm Seoul'
      end
  where revision_id = namsan_revision;

  update public.location_highlights
  set media_url = case display_order
        when 0 then view_south_url
        when 1 then tower_day_url
        when 2 then park_tower_url
        when 3 then cable_car_url
      end,
      media_credit = commons_credit,
      media_source_url = case display_order
        when 0 then view_south_source
        when 1 then tower_day_source
        when 2 then park_tower_source
        when 3 then cable_car_source
      end,
      media_alt = case display_order
        when 0 then 'Toàn cảnh Seoul từ đài quan sát Namsan Seoul Tower'
        when 1 then 'Namsan Seoul Tower và khu dịch vụ cho khách tham quan'
        when 2 then 'Namsan Seoul Tower giữa cảnh quan xanh của công viên Namsan'
        when 3 then 'Cáp treo Namsan, phương tiện tiếp cận khu tháp'
      end
  where revision_id = namsan_revision;

  update public.location_experiences
  set media_url = case display_order
        when 0 then tower_night_view_url
        when 1 then park_path_url
        when 2 then love_locks_url
      end,
      media_credit = commons_credit,
      media_source_url = case display_order
        when 0 then tower_night_view_source
        when 1 then park_path_source
        when 2 then love_locks_source
      end,
      media_alt = case display_order
        when 0 then 'Seoul nhìn từ Namsan Seoul Tower vào ban đêm'
        when 1 then 'Không gian cây xanh trên đường đi trong công viên Namsan'
        when 2 then 'Ổ khóa tình yêu hình trái tim tại Namsan Seoul Tower'
      end
  where revision_id = namsan_revision;

  update public.location_foods
  set image_url = case display_order
        when 0 then yujacha_url
        when 1 then bibimbap_url
        when 2 then tteokbokki_url
      end,
      image_credit = commons_credit,
      image_source_url = case display_order
        when 0 then yujacha_source
        when 1 then bibimbap_source
        when 2 then tteokbokki_source
      end,
      image_alt = case display_order
        when 0 then 'Yujacha, đồ uống nóng kiểu Hàn Quốc cho thời gian nghỉ tại tháp'
        when 1 then 'Bibimbap, ví dụ cho bữa ăn Hàn Quốc tại khu dịch vụ'
        when 2 then 'Tteokbokki, món ăn nhẹ Hàn Quốc dùng trong thời gian nghỉ'
      end
  where revision_id = namsan_revision;

  update public.location_fun_facts
  set media_kind = 'image',
      media_url = case display_order
        when 0 then park_tower_url
        when 1 then tower_itaewon_url
        when 2 then view_north_url
        when 3 then tower_panorama_url
      end,
      media_credit = commons_credit,
      media_source_url = case display_order
        when 0 then park_tower_source
        when 1 then tower_itaewon_source
        when 2 then view_north_source
        when 3 then tower_panorama_source
      end,
      media_alt = case display_order
        when 0 then 'Tháp Namsan và ngọn núi tạo nên độ cao quan sát của địa điểm'
        when 1 then 'Namsan Seoul Tower, tháp đa năng kết hợp truyền phát và du lịch'
        when 2 then 'Khung cảnh Seoul nhìn từ độ cao Namsan'
        when 3 then 'Namsan Seoul Tower rực sáng trong cảnh đêm Seoul'
      end
  where revision_id = namsan_revision;

  update public.quiz_questions
  set media_kind = 'image',
      media_url = case display_order
        when 0 then tower_day_url
        when 1 then tower_itaewon_url
        when 2 then park_tower_url
        when 3 then tower_day_url
        when 4 then tower_day_url
        when 5 then park_entrance_url
        when 6 then cable_car_url
        when 7 then view_north_url
        when 8 then love_locks_url
        when 9 then tower_night_view_url
      end,
      media_credit = commons_credit,
      media_source_url = case display_order
        when 0 then tower_day_source
        when 1 then tower_itaewon_source
        when 2 then park_tower_source
        when 3 then tower_day_source
        when 4 then tower_day_source
        when 5 then park_entrance_source
        when 6 then cable_car_source
        when 7 then view_north_source
        when 8 then love_locks_source
        when 9 then tower_night_view_source
      end,
      media_alt = case display_order
        when 0 then 'Namsan Seoul Tower, minh họa mốc mở cửa cho công chúng'
        when 1 then 'Namsan Seoul Tower, công trình truyền phát và đài quan sát'
        when 2 then 'Namsan Seoul Tower trên núi Namsan'
        when 3 then 'Namsan Seoul Tower, công trình cao khoảng 236,7 mét'
        when 4 then 'Namsan Seoul Tower và khu plaza ở các tầng thấp'
        when 5 then 'Lối vào công viên Namsan, điểm tiếp cận xe buýt vòng'
        when 6 then 'Cáp treo Namsan từ khu Myeongdong lên gần tháp'
        when 7 then 'Góc nhìn từ đài quan sát Namsan Seoul Tower'
        when 8 then 'Khu ổ khóa tình yêu tại Namsan, nơi cần giữ gìn không gian chung'
        when 9 then 'Cảnh đêm Seoul nhìn từ Namsan Seoul Tower'
      end
  where revision_id = namsan_revision;
end;
$$;
