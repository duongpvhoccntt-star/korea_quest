-- Published Bukchon Hanok Village content. Visitor rules and travel details
-- were checked on 2026-10-04. Reconfirm official restrictions before travel.

do $$
declare
  location_uuid uuid := '00000000-0000-4000-8000-000000000500';
  revision_uuid uuid := '00000000-0000-4000-8000-000000000600';
  revision_version integer;
  image_url text := 'https://commons.wikimedia.org/wiki/Special:FilePath/Bukchon%20Hanok%20Village.jpg';
  image_source text := 'https://commons.wikimedia.org/wiki/Category:Bukchon_Hanok_Village';
begin
  insert into public.locations (id, slug)
  values (location_uuid, 'bukchon-hanok')
  on conflict (slug) do nothing;

  select id into location_uuid from public.locations where slug = 'bukchon-hanok';

  if not exists (
    select 1 from public.location_revisions
    where location_id = location_uuid and status = 'published'
  ) then
    select coalesce(max(version_number) + 1, 1) into revision_version
    from public.location_revisions where location_id = location_uuid;

    insert into public.location_revisions (
      id, location_id, version_number, status, name, korean_name, english_name,
      address, city, region, country, latitude, longitude, location_type,
      short_description, long_description, cover_image_url, cover_image_credit,
      cover_image_source_url, cover_image_alt, hook_media_kind, hook_media_url,
      hook_media_credit, hook_media_source_url, hook_media_alt, hook_title,
      hook_caption, tags, categories, release_status, estimated_duration_minutes,
      display_order, stamp_name, stamp_description, stamp_image_url,
      stamp_image_credit, stamp_image_source_url, stamp_image_alt,
      experience_featured_fact, opening_hours, ticket_price, recommended_duration,
      best_time_to_visit, accessibility_info, travel_official_source_url,
      travel_last_verified_at
    ) values (
      revision_uuid, location_uuid, revision_version, 'published',
      'Làng Cổ Bukchon Hanok', '북촌한옥마을', 'Bukchon Hanok Village',
      '37 Gyedong-gil, Jongno-gu, Seoul 03059', 'Seoul', 'Jongno-gu', 'Hàn Quốc',
      37.5826, 126.9830, 'Làng truyền thống và khu dân cư',
      'Khu làng hanok có cư dân sinh sống giữa các cung điện lịch sử của Seoul, nơi kiến trúc truyền thống, xưởng thủ công và đời sống thường nhật cùng tồn tại.',
      'Bukchon, nghĩa là “làng phía bắc”, nằm giữa Gyeongbokgung và Changdeokgung. Hàng trăm ngôi nhà hanok tạo nên những con dốc và ngõ nhỏ đặc trưng, nhưng đây không phải công viên chủ đề: đó là một khu dân cư thật. Hành trình này hướng người học quan sát cấu trúc hanok, tìm hiểu quan hệ giữa di sản và đời sống đô thị, đồng thời thực hành cách tham quan yên tĩnh, tôn trọng không gian riêng tư và các khung giờ hạn chế.',
      image_url, 'Wikimedia Commons', image_source, 'Mái nhà hanok ở Bukchon, Seoul',
      'image', image_url, 'Wikimedia Commons', image_source, 'Con dốc giữa các mái hanok tại Bukchon',
      'Đi chậm để đọc câu chuyện của một khu phố hanok đang sống',
      'Khám phá kiến trúc, thủ công và quy tắc tôn trọng cư dân tại Bukchon.',
      array['Seoul', 'Bukchon', 'hanok', 'Joseon', 'khu dân cư'],
      array['Kiến trúc', 'Lịch sử đô thị', 'Văn hóa sống'], 'released', 120, 1,
      'Dấu ấn mái ngói Bukchon', 'Dấu mộc dành cho người hoàn thành hành trình tìm hiểu hanok và văn hóa tham quan có trách nhiệm.',
      image_url, 'Wikimedia Commons', image_source, 'Mái ngói hanok dùng làm biểu tượng dấu mộc',
      'Bukchon là một khu dân cư đang hoạt động; sự yên tĩnh là một phần thiết yếu của trải nghiệm.',
      'Khu tham quan hạn chế: 10:00–17:00. Nguồn chính thức có khác biệt về ngày áp dụng theo khu vực, vì vậy cần kiểm tra hướng dẫn Seoul Hanok ngay trước chuyến đi.',
      'Miễn phí vào làng; bảo tàng, xưởng thủ công và chương trình trải nghiệm có thể có chính sách riêng.',
      'Khoảng 2–3 giờ cho một vòng đi bộ chậm, bao gồm thời gian nghỉ và ghé không gian công cộng.',
      'Buổi sáng hoặc đầu giờ chiều trong khung giờ được phép; tránh giờ đông và không ở lại sau giờ hạn chế.',
      'Đường làng có dốc, bậc và bề mặt không bằng phẳng; hãy chọn giày phù hợp. Liên hệ Bukchon Traditional Culture Center nếu cần hỗ trợ cụ thể.',
      'https://english.visitseoul.net/other/Bukchon-Hanok-Village/ENP000261', '2026-10-04'
    );

    insert into public.location_quick_facts (revision_id, label, value, display_order) values
      (revision_uuid, 'Tên gọi', 'Bukchon nghĩa là “làng phía bắc”', 0),
      (revision_uuid, 'Giờ tham quan hạn chế', '10:00–17:00', 1),
      (revision_uuid, 'Phí vào làng', 'Miễn phí', 2);

    insert into public.location_sources (revision_id, title, publisher, url, accessed_at, verification_status, verified_at, is_official, is_visible, display_order) values
      (revision_uuid, 'Bukchon Hanok Village', 'Visit Seoul', 'https://english.visitseoul.net/other/Bukchon-Hanok-Village/ENP000261', '2026-10-04', 'verified', '2026-10-04', true, true, 0),
      (revision_uuid, 'Bukchon Hanok Village', 'Korea Tourism Organization', 'https://english.visitkorea.or.kr/svc/contents/contentsView.do?vcontsId=97932', '2026-10-04', 'verified', '2026-10-04', true, true, 1),
      (revision_uuid, 'Main facilities in Bukchon', 'Seoul Hanok Portal', 'https://hanok.seoul.go.kr/front/util/bcgTour03.do?lang=ENG', '2026-10-04', 'verified', '2026-10-04', true, true, 2);

    insert into public.location_history (revision_id, period_label, title, short_description, long_description, related_people, categories, media_kind, media_url, media_credit, media_source_url, media_alt, fun_fact, display_order) values
      (revision_uuid, 'Triều đại Joseon', 'Một khu phố ở phía bắc trung tâm cũ', 'Bukchon nằm về phía bắc của Cheonggyecheon và Jongno, giữa các cung điện Gyeongbokgung và Changdeokgung.', 'Tên Bukchon nghĩa là làng phía bắc. Vị trí của khu phố giải thích vì sao nơi đây gắn chặt với trung tâm lịch sử Seoul và vẫn giữ nhiều ngôi nhà hanok từ thời Joseon. Khi đi trong làng, hãy nhận ra mối liên hệ giữa đường dốc, lô đất và các cung điện lân cận thay vì xem từng ngôi nhà như một vật trưng bày tách rời. Kiến trúc ở đây là một phần của cấu trúc đô thị lịch sử.', null, array['Joseon', 'đô thị'], 'image', image_url, 'Wikimedia Commons', image_source, 'Cảnh quan hanok ở Bukchon', 'Bukchon không phải tên một tòa nhà mà là tên của cả khu phố.', 0),
      (revision_uuid, 'Thế kỷ XX', 'Nhà hanok tiếp tục là nơi ở', 'Khác với một bảo tàng ngoài trời, Bukchon duy trì vai trò khu dân cư trong quá trình Seoul hiện đại hóa.', 'Giá trị của Bukchon nằm ở sự tiếp nối: hanok là nhà ở, đồng thời một số không gian thích nghi thành trung tâm văn hóa, nhà khách, quán trà, nhà hàng hoặc xưởng thủ công. Sự thay đổi công năng này cho thấy bảo tồn không chỉ là giữ nguyên vật liệu mà còn là duy trì đời sống phù hợp. Người học cần phân biệt khu vực công cộng được mời ghé thăm với ngôi nhà riêng của cư dân.', null, array['cư dân', 'bảo tồn'], 'image', image_url, 'Wikimedia Commons', image_source, 'Ngõ nhỏ Bukchon có nhà ở hanok', 'Nhiều hanok hiện vẫn là không gian sinh hoạt của cư dân Seoul.', 1),
      (revision_uuid, 'Cuối thế kỷ XX–nay', 'Thủ công và văn hóa mở cửa có chọn lọc', 'Các hanok công cộng, xưởng và trung tâm văn hóa tạo cơ hội tìm hiểu kiến trúc và nghề thủ công truyền thống.', 'Seoul Hanok Portal giới thiệu nhiều cơ sở công cộng ở Bukchon, từ Bukchon Traditional Culture Center đến các xưởng thủ công. Các điểm này cho phép khách học sâu hơn về vật liệu, trang trí và cách sử dụng không gian hanok. Tuy nhiên, giờ mở cửa của từng cơ sở khác nhau. Vì vậy, nên xem chương trình của địa điểm trước khi đến và không coi một cửa mở là sự cho phép bước vào các nhà riêng xung quanh.', null, array['thủ công', 'văn hóa'], 'image', image_url, 'Wikimedia Commons', image_source, 'Không gian hanok công cộng ở Bukchon', 'Nhiều trải nghiệm văn hóa diễn ra trong hanok công cộng, không phải nhà riêng.', 2),
      (revision_uuid, 'Hiện nay', 'Du lịch yên tĩnh để bảo vệ đời sống địa phương', 'Seoul áp dụng giờ và quy tắc tham quan nhằm cân bằng lượng khách với quyền riêng tư của cư dân.', 'Các nguồn chính thức đều nhấn mạnh Bukchon là nơi cư dân sinh sống. Hướng dẫn tham quan yêu cầu giữ yên lặng, không chụp không gian riêng tư, không xả rác và không dùng loa hoặc megaphone. Đây không phải những lưu ý phụ: chúng là chìa khóa để di sản và đời sống cùng tồn tại. Khi hoàn thành chặng Bukchon, người học cần chứng minh hiểu rằng cư xử đúng quan trọng không kém việc biết tên một mái nhà cổ.', null, array['du lịch có trách nhiệm', 'cộng đồng'], 'image', image_url, 'Wikimedia Commons', image_source, 'Mái hanok trong một khu dân cư', 'Bukchon có khung giờ hạn chế khách du lịch tại một số khu vực.', 3);

    insert into public.location_highlights (revision_id, name, korean_name, tagline, short_description, long_description, address, activities, fun_fact, categories, media_kind, media_url, media_credit, media_source_url, media_alt, display_order) values
      (revision_uuid, 'Ngõ Gahoe-dong', '가회동 골목', 'Con dốc quan sát mái ngói hanok', 'Các con ngõ Gahoe-dong tập trung nhiều hanok và cho thấy rõ địa hình dốc của Bukchon.', 'Gahoe-dong là một phần quan trọng của trải nghiệm Bukchon vì mật độ hanok và những góc nhìn thay đổi dần khi đi lên dốc. Hãy đi sát lề, giữ giọng nhỏ và không đứng chắn lối ra vào nhà dân. Thay vì cố tìm một bức ảnh giống nhau, hãy quan sát các chi tiết lợp mái, cổng, tường và khoảng sân được nhìn thấy từ không gian công cộng. Không quay phim hoặc chụp vào bên trong nhà riêng.', 'Gahoe-dong, Bukchon, Jongno-gu, Seoul', array['Đi bộ yên tĩnh', 'Quan sát kiến trúc'], 'Đây là khu dân cư nên các lối đi cũng là lối sinh hoạt hằng ngày.', array['kiến trúc', 'cư dân'], 'image', image_url, 'Wikimedia Commons', image_source, 'Ngõ hanok dốc tại Bukchon', 0),
      (revision_uuid, 'Bukchon Traditional Culture Center', '북촌문화센터', 'Điểm học tập trong hanok công cộng', 'Trung tâm cung cấp thông tin văn hóa và là điểm phù hợp để bắt đầu tìm hiểu Bukchon.', 'Một hanok công cộng tạo điều kiện để khách tiếp cận văn hóa mà không xâm phạm đời sống riêng tư. Trung tâm có lịch riêng, vì vậy hãy xem giờ hoạt động và chương trình trước khi đến. Tại đây, người học có thể đặt câu hỏi về cấu trúc hanok, nhận thông tin lộ trình và tìm hiểu các hoạt động văn hóa. Giữ phép lịch sự của không gian học tập: không tự ý chạm vào hiện vật, nói nhỏ và tuân theo hướng dẫn của nhân viên.', '37 Gyedong-gil, Jongno-gu, Seoul', array['Tìm thông tin', 'Học về hanok'], 'Trung tâm nằm tại địa chỉ chính thức thường dùng cho Bukchon.', array['văn hóa', 'hanok công cộng'], 'image', image_url, 'Wikimedia Commons', image_source, 'Bukchon Traditional Culture Center', 1),
      (revision_uuid, 'Xưởng thủ công Bukchon', '북촌 공방', 'Nơi nghề truyền thống gặp đời sống đương đại', 'Nhiều xưởng và cơ sở công cộng giới thiệu nghề như nhuộm, thắt nút, sơn mài hoặc trang trí truyền thống.', 'Các xưởng ở Bukchon cho thấy hanok không chỉ là một kiểu nhà, mà còn là bối cảnh cho kỹ năng thủ công truyền từ người làm nghề sang người học. Chỉ tham gia khi cơ sở đang mở và có quy định cho khách. Không mặc định mọi xưởng đều cho phép chụp ảnh hoặc ghé tự do. Việc hỏi trước, tôn trọng số lượng khách và mua sản phẩm một cách có trách nhiệm giúp trải nghiệm hỗ trợ cộng đồng sáng tạo địa phương.', 'Bukchon-ro và Gyedong-gil, Jongno-gu, Seoul', array['Xem thủ công', 'Tham gia chương trình hợp lệ'], 'Giờ hoạt động khác nhau tùy từng xưởng.', array['thủ công', 'văn hóa sống'], 'image', image_url, 'Wikimedia Commons', image_source, 'Xưởng thủ công trong khu Bukchon', 2),
      (revision_uuid, 'Những mái nhà giữa hai cung điện', '북촌 한옥 지붕', 'Cảnh quan lịch sử giữa lòng Seoul', 'Mái ngói và đường ngõ Bukchon tạo lớp chuyển tiếp giữa Gyeongbokgung, Changdeokgung và Seoul hiện đại.', 'Quan sát mái nhà từ các điểm công cộng giúp hiểu Bukchon theo quy mô khu phố. Hãy tìm nhịp lặp của mái ngói, tường thấp và khoảng đệm trước hiên nhà, rồi so sánh với các tòa nhà hiện đại ở xa. Điều quan trọng là không trèo lên bờ tường, không dùng thiết bị bay và không chen vào cửa nhà để có góc ảnh. Cảnh quan đẹp nhất khi không làm gián đoạn sinh hoạt của người đang sống tại đó.', 'Bukchon Hanok Village, Jongno-gu, Seoul', array['Quan sát cảnh quan', 'Vẽ phác kiến trúc'], 'Bukchon được bao quanh bởi các địa danh lịch sử lớn của Seoul.', array['cảnh quan', 'lịch sử đô thị'], 'image', image_url, 'Wikimedia Commons', image_source, 'Mái ngói hanok nhìn từ lối đi công cộng', 3);

    insert into public.location_experiences (revision_id, name, korean_name, short_description, long_description, origin_meaning, recognizable_features, dos, donts, related_experience, media_kind, media_url, media_credit, media_source_url, media_alt, display_order) values
      (revision_uuid, 'Đi bộ im lặng', '조용한 산책', 'Đi chậm và giảm âm lượng để khu phố vẫn là nơi ở dễ chịu cho cư dân.', 'Đi bộ im lặng là trải nghiệm quan trọng nhất tại Bukchon. Điều này không có nghĩa là bạn không được trò chuyện, mà là giữ âm lượng vừa đủ, không hò hét, không dùng loa và không tụ tập chắn ngõ. Hãy để ý biển nhắc nhở, hướng dẫn về khu hạn chế và thời gian phải rời khỏi khu vực. Sự tôn trọng này giúp người học nhìn thấy di sản như một không gian sống thay vì một phông nền để tiêu dùng hình ảnh.', 'Thực hành du lịch có trách nhiệm trong khu dân cư.', array['Ngõ hẹp', 'Biển nhắc giữ yên lặng'], array['Đi nhóm nhỏ', 'Giữ giờ tham quan'], array['Không dùng megaphone', 'Không gây tiếng ồn'], 'Kết hợp với lộ trình đi bộ Bukchon', 'image', image_url, 'Wikimedia Commons', image_source, 'Ngõ Bukchon trong khu dân cư', 0),
      (revision_uuid, 'Tìm hiểu hanok công cộng', '공공한옥 탐방', 'Ưu tiên không gian mở chính thức để học về nhà truyền thống.', 'Thay vì cố gắng vào một ngôi nhà có vẻ cổ, hãy chọn một hanok công cộng hoặc trung tâm văn hóa có giờ mở cửa rõ ràng. Ở đó, khách có thể đọc thông tin, xem chương trình và hỏi nhân viên về quy tắc tham gia. Cách tiếp cận này tạo ranh giới đúng giữa học hỏi và xâm phạm riêng tư. Nếu một hoạt động yêu cầu đặt chỗ, hãy đặt trước thay vì chờ được ngoại lệ tại chỗ.', 'Hanok công cộng là cầu nối giữa bảo tồn và giáo dục.', array['Trung tâm văn hóa', 'Xưởng công cộng'], array['Kiểm tra lịch', 'Hỏi trước khi chụp ảnh'], array['Không tự mở cổng', 'Không đi vào nhà riêng'], 'Bukchon Traditional Culture Center và các cơ sở được công bố', 'image', image_url, 'Wikimedia Commons', image_source, 'Không gian hanok mở cho công chúng', 1),
      (revision_uuid, 'Ghi chép kiến trúc', '한옥 관찰 기록', 'Dùng quan sát và phác thảo để nhận ra chi tiết hanok từ lối đi công cộng.', 'Bukchon phù hợp cho một bài thực hành quan sát: ghi lại mái ngói, đường cong mái, cổng, tường và cách công trình thích ứng với dốc. Chỉ ghi chép hoặc chụp ảnh từ khu vực công cộng; không hướng máy vào sân hoặc nội thất riêng tư. Một bản phác thảo nhanh hoặc nhật ký từ vựng giúp chuyến đi có mục tiêu học tập rõ hơn và giảm áp lực phải tạo nội dung ồn ào cho mạng xã hội.', 'Quan sát chậm là cách học phù hợp với nhịp sống của khu dân cư.', array['Mái ngói', 'Cổng gỗ', 'Đường dốc'], array['Ghi chép từ lối công cộng', 'Nhường đường cho cư dân'], array['Không dùng drone', 'Không chặn lối vào nhà'], 'Tìm hiểu cấu trúc hanok', 'image', image_url, 'Wikimedia Commons', image_source, 'Chi tiết mái ngói hanok tại Bukchon', 2);

    insert into public.location_foods (revision_id, name, korean_name, short_description, long_description, ingredients, flavors, special_feature, experience_places, image_url, image_credit, image_source_url, image_alt, display_order) values
      (revision_uuid, 'Trà truyền thống', '전통차', 'Quán trà trong hoặc gần hanok là một cách nghỉ chân nhẹ nhàng sau khi đi bộ.', 'Trà truyền thống là loại trải nghiệm phù hợp với nhịp tham quan chậm ở Bukchon, nhưng thực đơn và cửa hàng thay đổi theo thời điểm. Hãy kiểm tra nơi đang hoạt động, hỏi về thành phần nếu có dị ứng và dùng đồ uống trong khu vực cho phép. Đừng mang cốc hoặc bao bì đi qua những ngõ hẹp rồi bỏ lại rác. Coi đây là cơ hội quan sát văn hóa quán trà, không phải một danh sách nhà hàng cố định.', array['trà', 'mật ong hoặc trái cây tùy loại'], array['ấm', 'ngọt nhẹ', 'thảo mộc'], 'Cửa hàng thực tế thay đổi theo mùa và lịch vận hành.', array['Khu Bukchon và Anguk'], image_url, 'Wikimedia Commons', image_source, 'Không gian hanok ở Bukchon', 0),
      (revision_uuid, 'Bánh gạo và đồ ngọt Hàn Quốc', '한과와 떡', 'Một phần bánh nhỏ phù hợp để nghỉ ngắn, với điều kiện tôn trọng quy định của cửa hàng và khu dân cư.', 'Bánh gạo hoặc đồ ngọt truyền thống thường được dùng như món ăn nhẹ cùng trà, nhưng lựa chọn cụ thể cần xem tại chỗ. Nếu mua mang đi, giữ bao bì cho đến khi tìm được nơi bỏ rác phù hợp và không ăn uống trước cửa nhà dân. Hỏi về thành phần vì nhiều món chứa hạt, đậu, bột gạo hoặc mật. Chọn khẩu phần nhỏ để không biến lối đi công cộng thành nơi tụ tập đông người.', array['bột gạo', 'đậu', 'mật hoặc đường tùy món'], array['dẻo', 'ngọt', 'nhẹ'], 'Nên xem thành phần và giờ mở cửa của từng cửa hàng.', array['Khu Anguk và Bukchon'], image_url, 'Wikimedia Commons', image_source, 'Mái nhà Bukchon gần các dịch vụ địa phương', 1),
      (revision_uuid, 'Bữa ăn Hàn Quốc gần Anguk', '안국 한식', 'Khu vực quanh Anguk có nhiều lựa chọn ăn uống; hãy chọn địa điểm không làm ảnh hưởng cư dân Bukchon.', 'Một bữa ăn Hàn Quốc có thể là điểm dừng trước hoặc sau khi tham quan Bukchon. Vì làng là khu dân cư, hãy ưu tiên các nhà hàng hợp pháp ở tuyến phố thương mại xung quanh thay vì dừng ăn trong ngõ. Kiểm tra giờ mở cửa, quy định đặt chỗ, lựa chọn chay và dị ứng trực tiếp với cửa hàng. Dữ liệu này mô tả loại trải nghiệm, không xác nhận thực đơn cố định của một cơ sở cụ thể.', array['cơm', 'rau', 'món phụ', 'canh tùy nhà hàng'], array['mặn', 'ấm', 'đa dạng'], 'Thực đơn và cửa hàng thay đổi; kiểm tra trực tiếp trước chuyến đi.', array['Khu Anguk, Jongno-gu'], image_url, 'Wikimedia Commons', image_source, 'Phố Bukchon gần khu vực dịch vụ', 2);

    insert into public.location_fun_facts (revision_id, title, category, fact, icon_name, unlock_after_stage, display_order) values
      (revision_uuid, 'Tên của làng', 'Ngôn ngữ', 'Bukchon nghĩa là “làng phía bắc”, vì khu phố nằm về phía bắc của Cheonggyecheon và Jongno.', 'north', 1, 0),
      (revision_uuid, 'Giữa các cung điện', 'Địa lý', 'Bukchon nằm giữa Gyeongbokgung và Changdeokgung, tạo kết nối trực tiếp với trung tâm lịch sử Seoul.', 'account_balance', 3, 1),
      (revision_uuid, 'Hàng trăm hanok', 'Kiến trúc', 'Các nguồn du lịch chính thức mô tả Bukchon có hàng trăm ngôi nhà hanok, nhiều ngôi có nguồn gốc từ thời Joseon.', 'roofing', 5, 2),
      (revision_uuid, 'Di sản đang sống', 'Cộng đồng', 'Bukchon là khu dân cư; tham quan yên tĩnh và tôn trọng không gian riêng tư là một phần của bảo tồn.', 'volume_off', 6, 3);

    insert into public.location_transport_options (revision_id, mode, title, instructions, tip, is_recommended, display_order) values
      (revision_uuid, 'metro', 'Tàu điện ngầm đến ga Anguk', 'Theo Visit Seoul, đi tuyến 3 đến ga Anguk, ra cửa số 3 rồi đi bộ khoảng 516 m đến khu làng.', 'Xem bản đồ và biển chỉ dẫn tại chỗ vì lối tiếp cận có thể thay đổi theo khu hạn chế.', true, 0),
      (revision_uuid, 'walk', 'Đi bộ từ Gyeongbokgung hoặc Changdeokgung', 'Kết hợp Bukchon với các cung điện lân cận bằng một lộ trình đi bộ, nhưng dành thời gian cho dốc và ngõ hẹp.', 'Không đi vào khu hạn chế ngoài giờ và ưu tiên lối đi công cộng.', false, 1),
      (revision_uuid, 'bus', 'Xe buýt đô thị đến khu Anguk', 'Dùng ứng dụng giao thông hiện hành để chọn điểm dừng quanh ga Anguk hoặc Jongno phù hợp với điểm xuất phát.', 'Tuyến xe buýt thay đổi; xác nhận thông tin thời gian thực trước khi đi.', false, 2);

    insert into public.location_visitor_notes (revision_id, content, display_order) values
      (revision_uuid, 'Bukchon là khu dân cư. Giữ giọng nhỏ, không chạy nhảy, không dùng loa, megaphone hoặc thiết bị gây ồn.', 0),
      (revision_uuid, 'Không chụp ảnh, quay phim vào không gian riêng tư, nội thất, sân hoặc qua cửa mở của nhà dân khi chưa có sự đồng ý.', 1),
      (revision_uuid, 'Tuân thủ giờ tham quan và biển khu hạn chế; kiểm tra trang Seoul Hanok chính thức trước chuyến đi vì quy định có thể thay đổi.', 2);

    insert into public.quiz_questions (id, revision_id, kind, prompt, explanation, is_visible, display_order) values
      ('00000000-0000-4000-8000-000000000601', revision_uuid, 'single_choice', 'Tên “Bukchon” có nghĩa là gì?', 'Bukchon nghĩa là “làng phía bắc”, gắn với vị trí của khu phố ở phía bắc các địa danh trung tâm lịch sử Seoul.', true, 0),
      ('00000000-0000-4000-8000-000000000602', revision_uuid, 'single_choice', 'Bukchon nằm giữa hai cung điện nào?', 'Các nguồn chính thức mô tả Bukchon nằm giữa Gyeongbokgung và Changdeokgung.', true, 1),
      ('00000000-0000-4000-8000-000000000603', revision_uuid, 'single_choice', 'Bukchon khác bảo tàng ngoài trời ở điểm nào?', 'Bukchon vẫn là khu dân cư nơi người dân Seoul sinh sống; vì vậy du khách cần tôn trọng đời sống địa phương.', true, 2),
      ('00000000-0000-4000-8000-000000000604', revision_uuid, 'single_choice', 'Khung giờ tham quan hạn chế được nêu trong dữ liệu là?', 'Visit Seoul và VisitKorea đều nêu khung 10:00–17:00 cho khu vực hạn chế; kiểm tra lại quy định trước khi đi.', true, 3),
      ('00000000-0000-4000-8000-000000000605', revision_uuid, 'single_choice', 'Phí vào Bukchon Hanok Village là bao nhiêu?', 'VisitKorea nêu phí vào làng là miễn phí; các hoạt động hoặc cơ sở riêng có thể có chính sách khác.', true, 4),
      ('00000000-0000-4000-8000-000000000606', revision_uuid, 'single_choice', 'Hành vi nào phù hợp nhất khi đi trong ngõ Bukchon?', 'Giữ âm lượng nhỏ, đi nhóm gọn và nhường đường thể hiện sự tôn trọng với cư dân.', true, 5),
      ('00000000-0000-4000-8000-000000000607', revision_uuid, 'single_choice', 'Bạn có nên chụp vào bên trong một căn nhà khi cửa đang mở không?', 'Không. Hướng dẫn chính thức yêu cầu không chụp không gian riêng tư, ngay cả khi cửa mở, nếu không có sự đồng ý.', true, 6),
      ('00000000-0000-4000-8000-000000000608', revision_uuid, 'single_choice', 'Ga tàu điện ngầm nào được Visit Seoul hướng dẫn để đến Bukchon?', 'Visit Seoul hướng dẫn đi tuyến 3 đến ga Anguk, cửa ra số 3, rồi đi bộ đến khu làng.', true, 7),
      ('00000000-0000-4000-8000-000000000609', revision_uuid, 'single_choice', 'Không gian nào phù hợp nhất để tìm hiểu hanok sâu hơn?', 'Hanok công cộng, trung tâm văn hóa và xưởng có giờ mở cửa là các không gian học tập phù hợp, thay vì nhà riêng.', true, 8),
      ('00000000-0000-4000-8000-000000000610', revision_uuid, 'single_choice', 'Vì sao “silent tourism” quan trọng tại Bukchon?', 'Du lịch yên tĩnh giảm tác động lên khu dân cư và giúp bảo tồn di sản như một không gian sống.', true, 9);

    insert into public.quiz_options (question_id, option_text, is_correct, display_order) values
      ('00000000-0000-4000-8000-000000000601', 'Làng phía bắc', true, 0), ('00000000-0000-4000-8000-000000000601', 'Làng trên núi', false, 1), ('00000000-0000-4000-8000-000000000601', 'Làng ven biển', false, 2), ('00000000-0000-4000-8000-000000000601', 'Làng hoàng gia', false, 3),
      ('00000000-0000-4000-8000-000000000602', 'Gyeongbokgung và Changdeokgung', true, 0), ('00000000-0000-4000-8000-000000000602', 'Deoksugung và Changgyeonggung', false, 1), ('00000000-0000-4000-8000-000000000602', 'Gyeongbokgung và Jongmyo', false, 2), ('00000000-0000-4000-8000-000000000602', 'Changdeokgung và Namsangol', false, 3),
      ('00000000-0000-4000-8000-000000000603', 'Đây là khu dân cư đang sống', true, 0), ('00000000-0000-4000-8000-000000000603', 'Không có người ở', false, 1), ('00000000-0000-4000-8000-000000000603', 'Chỉ mở cho đoàn phim', false, 2), ('00000000-0000-4000-8000-000000000603', 'Là công viên giải trí', false, 3),
      ('00000000-0000-4000-8000-000000000604', '10:00–17:00', true, 0), ('00000000-0000-4000-8000-000000000604', '07:00–22:00', false, 1), ('00000000-0000-4000-8000-000000000604', 'Mở 24 giờ', false, 2), ('00000000-0000-4000-8000-000000000604', '19:00–23:00', false, 3),
      ('00000000-0000-4000-8000-000000000605', 'Miễn phí', true, 0), ('00000000-0000-4000-8000-000000000605', '10.000 KRW', false, 1), ('00000000-0000-4000-8000-000000000605', '20.000 KRW', false, 2), ('00000000-0000-4000-8000-000000000605', 'Chỉ thu theo nhóm', false, 3),
      ('00000000-0000-4000-8000-000000000606', 'Giữ âm lượng nhỏ và nhường đường', true, 0), ('00000000-0000-4000-8000-000000000606', 'Dùng loa giới thiệu đoàn', false, 1), ('00000000-0000-4000-8000-000000000606', 'Tụ tập trước cổng nhà dân', false, 2), ('00000000-0000-4000-8000-000000000606', 'Chạy trong ngõ hẹp', false, 3),
      ('00000000-0000-4000-8000-000000000607', 'Không, nếu chưa được đồng ý', true, 0), ('00000000-0000-4000-8000-000000000607', 'Có, vì cửa đang mở', false, 1), ('00000000-0000-4000-8000-000000000607', 'Có, nếu dùng zoom', false, 2), ('00000000-0000-4000-8000-000000000607', 'Có, nếu đi cùng nhóm', false, 3),
      ('00000000-0000-4000-8000-000000000608', 'Anguk', true, 0), ('00000000-0000-4000-8000-000000000608', 'Seoul Station', false, 1), ('00000000-0000-4000-8000-000000000608', 'Hongik University', false, 2), ('00000000-0000-4000-8000-000000000608', 'Jamsil', false, 3),
      ('00000000-0000-4000-8000-000000000609', 'Hanok công cộng hoặc trung tâm văn hóa', true, 0), ('00000000-0000-4000-8000-000000000609', 'Bất kỳ nhà riêng nào', false, 1), ('00000000-0000-4000-8000-000000000609', 'Sân nhà dân', false, 2), ('00000000-0000-4000-8000-000000000609', 'Cổng đóng kín', false, 3),
      ('00000000-0000-4000-8000-000000000610', 'Bảo vệ đời sống cư dân và di sản sống', true, 0), ('00000000-0000-4000-8000-000000000610', 'Để quay video dễ hơn', false, 1), ('00000000-0000-4000-8000-000000000610', 'Để không cần biển chỉ dẫn', false, 2), ('00000000-0000-4000-8000-000000000610', 'Để kéo dài giờ tham quan', false, 3);
  end if;
end;
$$;

