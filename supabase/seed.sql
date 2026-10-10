-- Local-only fixture. Never reuse this account or password outside Supabase local.
-- Email: admin@koreaquest.local
-- Password: KoreaQuestLocal123

insert into auth.users (
  id,
  instance_id,
  role,
  aud,
  email,
  raw_app_meta_data,
  raw_user_meta_data,
  is_super_admin,
  encrypted_password,
  created_at,
  updated_at,
  last_sign_in_at,
  email_confirmed_at,
  confirmation_sent_at,
  confirmation_token,
  recovery_token,
  email_change_token_new,
  email_change
) values (
  '00000000-0000-4000-8000-000000000001',
  '00000000-0000-0000-0000-000000000000',
  'authenticated',
  'authenticated',
  'admin@koreaquest.local',
  '{"provider":"email","providers":["email"]}'::jsonb,
  '{"display_name":"KoreaQuest Local Admin"}'::jsonb,
  false,
  extensions.crypt('KoreaQuestLocal123', extensions.gen_salt('bf')),
  now(),
  now(),
  now(),
  now(),
  now(),
  '',
  '',
  '',
  ''
);

insert into auth.identities (
  id,
  provider_id,
  user_id,
  identity_data,
  provider,
  last_sign_in_at,
  created_at,
  updated_at
) values (
  '00000000-0000-4000-8000-000000000011',
  '00000000-0000-4000-8000-000000000001',
  '00000000-0000-4000-8000-000000000001',
  '{"sub":"00000000-0000-4000-8000-000000000001","email":"admin@koreaquest.local","email_verified":true}'::jsonb,
  'email',
  now(),
  now(),
  now()
);

insert into public.admin_users (user_id, created_by)
values (
  '00000000-0000-4000-8000-000000000001',
  '00000000-0000-4000-8000-000000000001'
);

-- A publish-ready local fixture. Sources were checked on 2026-09-27; travel
-- details should always be reconfirmed with the official palace site.
insert into public.locations (id, slug, created_by)
values (
  '00000000-0000-4000-8000-000000000100',
  'gyeongbokgung',
  '00000000-0000-4000-8000-000000000001'
);

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
  travel_last_verified_at, created_by, updated_by
) values (
  '00000000-0000-4000-8000-000000000200',
  '00000000-0000-4000-8000-000000000100', 1, 'published',
  'Cung điện Gyeongbokgung', '경복궁', 'Gyeongbokgung Palace',
  '161 Sajik-ro, Jongno-gu, Seoul 03045', 'Seoul', 'Jongno-gu', 'Hàn Quốc',
  37.5796, 126.9770, 'Cung điện hoàng gia',
  'Cung điện chính của triều Joseon, nơi kể câu chuyện về quyền lực hoàng gia, kiến trúc truyền thống và lịch sử phục hưng của Seoul.',
  'Gyeongbokgung là cung điện chính của triều Joseon, hoàn thành năm 1395 dưới thời vua Taejo. Trục không gian từ Gwanghwamun đến Geunjeongjeon thể hiện trật tự nghi lễ của triều đình, còn Gyeonghoeru và Hyangwonjeong cho thấy sự hòa hợp giữa kiến trúc, mặt nước và núi Bugaksan. Cung từng bị thiêu hủy trong chiến tranh Imjin năm 1592, được khôi phục quy mô lớn năm 1867, rồi tiếp tục được bảo tồn và phục dựng trong thời hiện đại. Hành trình này giúp người học quan sát các công trình tiêu biểu, hiểu vai trò của chúng và chuẩn bị chuyến tham quan có trách nhiệm.',
  'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/Front_view_of_the_Imperial_Throne_Hall_Geunjeongjeon_at_Gyeongbokgung_Palace_with_blue_sky_in_Seoul.jpg/1920px-Front_view_of_the_Imperial_Throne_Hall_Geunjeongjeon_at_Gyeongbokgung_Palace_with_blue_sky_in_Seoul.jpg',
  'Basile Morin / Wikimedia Commons',
  'https://commons.wikimedia.org/wiki/File:Front_view_of_the_Imperial_Throne_Hall_Geunjeongjeon_at_Gyeongbokgung_Palace_with_blue_sky_in_Seoul.jpg',
  'Mặt tiền điện Geunjeongjeon tại Gyeongbokgung dưới bầu trời xanh',
  'image',
  'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/Front_view_of_the_Imperial_Throne_Hall_Geunjeongjeon_at_Gyeongbokgung_Palace_with_blue_sky_in_Seoul.jpg/1920px-Front_view_of_the_Imperial_Throne_Hall_Geunjeongjeon_at_Gyeongbokgung_Palace_with_blue_sky_in_Seoul.jpg',
  'Basile Morin / Wikimedia Commons',
  'https://commons.wikimedia.org/wiki/File:Front_view_of_the_Imperial_Throne_Hall_Geunjeongjeon_at_Gyeongbokgung_Palace_with_blue_sky_in_Seoul.jpg',
  'Điện Geunjeongjeon nhìn chính diện trong khuôn viên Gyeongbokgung',
  'Bước vào trung tâm của triều Joseon',
  'Khám phá cung điện lớn nhất trong năm cung điện hoàng gia của Seoul qua chín chặng học ngắn.',
  array['Joseon', 'cung điện', 'Seoul', 'di sản'],
  array['Lịch sử', 'Kiến trúc', 'Văn hóa'], 'released', 120, 0,
  'Dấu ấn Gwanghwamun',
  'Dấu mộc kỷ niệm hoàn thành hành trình khám phá cung điện chính của triều Joseon.',
  'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9d/Joseongukwangjiin_%28The_Seal_of_the_King_of_Joseon%2C_1776-1876%29.svg/512px-Joseongukwangjiin_%28The_Seal_of_the_King_of_Joseon%2C_1776-1876%29.svg.png',
  'Sodacan / Wikimedia Commons',
  'https://commons.wikimedia.org/wiki/File:Joseongukwangjiin_(The_Seal_of_the_King_of_Joseon,_1776-1876).svg',
  'Dấu ấn hoàng gia Joseon màu đỏ',
  'Các nghi lễ và không gian tại cung nhắc người tham quan về phép tắc, thứ bậc và sự tôn trọng di sản.',
  '09:00–17:00 tháng 1–2, 09:00–18:00 tháng 3–5, 09:00–18:30 tháng 6–8, 09:00–18:00 tháng 9–10, 09:00–17:00 tháng 11–12; vào cửa muộn nhất một giờ trước khi đóng; nghỉ thứ Ba.',
  'Người lớn 19–64 tuổi: 3.000 KRW; một số nhóm đủ điều kiện, gồm khách mặc hanbok đầy đủ, được miễn phí. Kiểm tra trang chính thức trước khi đi.',
  'Khoảng 2 giờ cho lộ trình các công trình chính.',
  'Buổi sáng hoặc chiều mát; tránh thứ Ba vì cung đóng cửa định kỳ.',
  'Có lối tiếp cận, nhà vệ sinh phù hợp, bãi đỗ xe và điểm thuê xe lăn hoặc xe đẩy gần Heungnyemun; số lượng thiết bị có hạn.',
  'https://english.visitseoul.net/attractions/gyeongbokgung%20palace_/73',
  '2026-09-27',
  '00000000-0000-4000-8000-000000000001',
  '00000000-0000-4000-8000-000000000001'
);

insert into public.location_quick_facts (revision_id, label, value, display_order) values
  ('00000000-0000-4000-8000-000000000200', 'Hoàn thành lần đầu', '1395, dưới thời vua Taejo', 0),
  ('00000000-0000-4000-8000-000000000200', 'Ý nghĩa tên gọi', 'Cung điện được ban nhiều phúc lành', 1),
  ('00000000-0000-4000-8000-000000000200', 'Địa chỉ', '161 Sajik-ro, Jongno-gu, Seoul', 2),
  ('00000000-0000-4000-8000-000000000200', 'Ga gần nhất', 'Gyeongbokgung Station, tuyến 3, cửa ra 5', 3);

insert into public.location_sources (
  revision_id, title, publisher, url, accessed_at, verification_status,
  verified_at, is_official, is_visible, display_order
) values
  ('00000000-0000-4000-8000-000000000200', 'Gyeongbokgung Palace', 'Visit Seoul', 'https://english.visitseoul.net/attractions/gyeongbokgung%20palace_/73', '2026-09-27', 'verified', '2026-09-27', true, true, 0),
  ('00000000-0000-4000-8000-000000000200', 'Gyeongbokgung Palace walking tour', 'Visit Seoul', 'https://english.visitseoul.net/PalaceArea/GyeongbokgungPalace/ENN000608', '2026-09-27', 'verified', '2026-09-27', true, true, 1),
  ('00000000-0000-4000-8000-000000000200', 'Sajeongjeon Hall of Gyeongbokgung Palace', 'Cultural Heritage Administration of Korea', 'https://english.cha.go.kr/chaen/search/selectGeneralSearchDetail.do?ccebAsno=17590000&mn=EN_02_02&pageIndex=1&sCcebCtcd=11&sCcebKdcd=12&searchWrd=SAJEONGJEON', '2026-09-27', 'verified', '2026-09-27', true, true, 2),
  ('00000000-0000-4000-8000-000000000200', 'Geunjeongjeon photograph', 'Wikimedia Commons', 'https://commons.wikimedia.org/wiki/File:Front_view_of_the_Imperial_Throne_Hall_Geunjeongjeon_at_Gyeongbokgung_Palace_with_blue_sky_in_Seoul.jpg', '2026-09-27', 'verified', '2026-09-27', false, true, 3);

insert into public.location_history (
  revision_id, period_label, title, short_description, long_description,
  related_people, categories, media_kind, media_url, media_credit,
  media_source_url, media_alt, fun_fact, display_order
) values
  ('00000000-0000-4000-8000-000000000200', '1394–1395', 'Khởi dựng cung điện đầu triều Joseon',
   'Sau khi lập triều Joseon, vua Taejo chọn khu vực dưới chân Bugaksan để dựng cung điện chính và hoàn thành công trình vào năm 1395.',
   'Gyeongbokgung được xây trong những năm đầu của triều Joseon để làm trung tâm hoàng gia và chính sự. Vị trí đặt cung tuân theo quan niệm phong thủy: có núi Bugaksan ở phía sau và dòng nước ở phía trước. Trục cổng, sân và điện chính tạo một không gian nghi lễ rõ ràng, phản ánh tổ chức nhà nước mới. Tên Gyeongbokgung thường được hiểu là cung điện nhận nhiều phúc lành. Đây là cung điện đầu tiên của Joseon và về sau trở thành cung điện lớn nhất trong năm cung điện hoàng gia còn được biết đến tại Seoul.',
   'Vua Taejo', array['khởi dựng', 'triều Joseon'], 'image',
   'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/Front_view_of_the_Imperial_Throne_Hall_Geunjeongjeon_at_Gyeongbokgung_Palace_with_blue_sky_in_Seoul.jpg/1920px-Front_view_of_the_Imperial_Throne_Hall_Geunjeongjeon_at_Gyeongbokgung_Palace_with_blue_sky_in_Seoul.jpg',
   'Basile Morin / Wikimedia Commons', 'https://commons.wikimedia.org/wiki/File:Front_view_of_the_Imperial_Throne_Hall_Geunjeongjeon_at_Gyeongbokgung_Palace_with_blue_sky_in_Seoul.jpg',
   'Điện Geunjeongjeon trong cung điện chính của Joseon',
   'Tên cung gắn với ý niệm về phúc lành và thịnh vượng của vương triều mới.', 0),
  ('00000000-0000-4000-8000-000000000200', '1592', 'Cung điện bị tàn phá trong chiến tranh Imjin',
   'Năm 1592, toàn bộ Gyeongbokgung bị hỏa hoạn trong bối cảnh Nhật Bản xâm lược Triều Tiên, khiến cung điện không còn được sử dụng trong nhiều thế kỷ.',
   'Cuộc chiến Imjin bắt đầu năm 1592 đã làm thay đổi sâu sắc Seoul và đời sống triều đình Joseon. Các công trình của Gyeongbokgung bị thiêu hủy, vì vậy triều đình về sau chủ yếu dùng những cung điện khác. Việc mất đi cung chính khiến nhiều không gian nghi lễ, hành chính và cư trú hoàng gia phải được tổ chức lại. Mốc này giúp người học nhìn cung điện không chỉ như một quần thể đẹp, mà còn như chứng tích của chiến tranh, gián đoạn lịch sử và nhu cầu bảo tồn. Những công trình hiện thấy phần lớn gắn với các đợt dựng lại sau đó.',
   null, array['chiến tranh', 'biến cố'], 'image',
   'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/Front_view_of_the_Imperial_Throne_Hall_Geunjeongjeon_at_Gyeongbokgung_Palace_with_blue_sky_in_Seoul.jpg/1920px-Front_view_of_the_Imperial_Throne_Hall_Geunjeongjeon_at_Gyeongbokgung_Palace_with_blue_sky_in_Seoul.jpg',
   'Basile Morin / Wikimedia Commons', 'https://commons.wikimedia.org/wiki/File:Front_view_of_the_Imperial_Throne_Hall_Geunjeongjeon_at_Gyeongbokgung_Palace_with_blue_sky_in_Seoul.jpg',
   'Kiến trúc phục dựng của Gyeongbokgung ngày nay',
   'Sajeongjeon từng bị cháy, được dựng lại và công trình hiện tại có từ năm 1867.', 1),
  ('00000000-0000-4000-8000-000000000200', '1867', 'Đại trùng tu dưới thời vua Gojong',
   'Năm 1867, Gyeongbokgung được phục dựng quy mô lớn; các điện quan trọng như Geunjeongjeon, Gyeonghoeru và Sajeongjeon được tái thiết trong đợt này.',
   'Đợt phục dựng năm 1867 đưa Gyeongbokgung trở lại vai trò trung tâm biểu tượng của vương triều. Dưới thời vua Gojong và sự chỉ đạo của Heungseon Daewongun, nhiều hạng mục chính được dựng lại sau thời gian dài hoang phế. Sajeongjeon hiện nay cũng thuộc lần tái thiết này và giữ được giá trị trong việc nghiên cứu bố cục cung điện Joseon. Sự kiện cho thấy di sản không bất biến: nó được tạo dựng, mất đi, rồi được khôi phục bằng quyết định chính trị, kỹ thuật xây dựng và lao động của nhiều người. Khi tham quan, hãy phân biệt niên đại thành lập cung với niên đại của từng công trình hiện còn.',
   'Vua Gojong; Heungseon Daewongun', array['phục dựng', 'kiến trúc'], 'image',
   'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/Front_view_of_the_Imperial_Throne_Hall_Geunjeongjeon_at_Gyeongbokgung_Palace_with_blue_sky_in_Seoul.jpg/1920px-Front_view_of_the_Imperial_Throne_Hall_Geunjeongjeon_at_Gyeongbokgung_Palace_with_blue_sky_in_Seoul.jpg',
   'Basile Morin / Wikimedia Commons', 'https://commons.wikimedia.org/wiki/File:Front_view_of_the_Imperial_Throne_Hall_Geunjeongjeon_at_Gyeongbokgung_Palace_with_blue_sky_in_Seoul.jpg',
   'Mặt tiền điện chính được tái thiết thế kỷ mười chín',
   'Sajeongjeon là nguồn tư liệu quý về cấu trúc và bố cục cung điện vào năm 1867.', 2),
  ('00000000-0000-4000-8000-000000000200', '1990–nay', 'Bảo tồn và phục hồi không gian hoàng cung',
   'Từ thập niên 1990, các chương trình phục hồi tiếp tục trả lại những phần quan trọng của Gyeongbokgung; Gwanghwamun được hoàn thành phục dựng tại vị trí gốc vào năm 2010.',
   'Trong thế kỷ hai mươi, bố cục Gyeongbokgung bị ảnh hưởng mạnh bởi thời kỳ thuộc địa và các thay đổi đô thị. Công tác phục hồi hiện đại nhằm khôi phục dần các công trình, tuyến không gian và ý nghĩa lịch sử của cung. Theo Visit Seoul, việc phục dựng Gwanghwamun đúng vị trí nguyên gốc được hoàn thành năm 2010 sau một giai đoạn thực hiện bắt đầu năm 2006. Ngày nay, cung vừa là di sản cần được chăm sóc, vừa là địa điểm giáo dục công chúng. Quá trình phục hồi nhắc người học rằng bảo tồn cần tài liệu, khảo cổ, kỹ thuật và sự tôn trọng đối với những lớp lịch sử khác nhau.',
   null, array['bảo tồn', 'hiện đại'], 'image',
   'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/Front_view_of_the_Imperial_Throne_Hall_Geunjeongjeon_at_Gyeongbokgung_Palace_with_blue_sky_in_Seoul.jpg/1920px-Front_view_of_the_Imperial_Throne_Hall_Geunjeongjeon_at_Gyeongbokgung_Palace_with_blue_sky_in_Seoul.jpg',
   'Basile Morin / Wikimedia Commons', 'https://commons.wikimedia.org/wiki/File:Front_view_of_the_Imperial_Throne_Hall_Geunjeongjeon_at_Gyeongbokgung_Palace_with_blue_sky_in_Seoul.jpg',
   'Geunjeongjeon là điểm tham quan trung tâm trong Gyeongbokgung hiện nay',
   'Gwanghwamun từng bị di dời trong thời thuộc địa trước khi được trả lại vị trí nguyên gốc.', 3);

insert into public.location_highlights (
  revision_id, name, korean_name, tagline, short_description,
  long_description, address, activities, fun_fact, categories, media_kind,
  media_url, media_credit, media_source_url, media_alt, display_order
) values
  ('00000000-0000-4000-8000-000000000200', 'Cổng Gwanghwamun', '광화문', 'Cánh cổng chính nhìn về phía nam',
   'Gwanghwamun là cổng chính phía nam của Gyeongbokgung, mở đầu trục nghi lễ dẫn qua các cổng và sân đến điện Geunjeongjeon.',
   'Gwanghwamun là điểm bắt đầu phù hợp để đọc cấu trúc toàn cung. Từ đây, người tham quan có thể nhận ra trục thẳng nối cổng chính với Heungnyemun, Geunjeongmun và điện Geunjeongjeon. Cổng không chỉ đánh dấu lối vào mà còn biểu đạt uy quyền và trật tự của triều đình Joseon. Trong lịch sử hiện đại, cổng đã trải qua di dời, tái thiết và phục hồi vị trí nguyên gốc. Hãy quan sát biển tên, mái cong, các linh vật Haechi ở không gian phía trước và mối liên hệ của cổng với quảng trường Gwanghwamun bên ngoài. Không leo trèo hoặc chạm vào cấu kiện di sản khi chụp ảnh.',
   'Phía nam Gyeongbokgung, 161 Sajik-ro, Jongno-gu, Seoul', array['Quan sát trục cung điện', 'Chụp ảnh từ quảng trường'],
   'Gwanghwamun được hoàn thành phục dựng tại vị trí nguyên gốc vào năm 2010.', array['cổng', 'nghi lễ'], 'image',
   'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/Front_view_of_the_Imperial_Throne_Hall_Geunjeongjeon_at_Gyeongbokgung_Palace_with_blue_sky_in_Seoul.jpg/1920px-Front_view_of_the_Imperial_Throne_Hall_Geunjeongjeon_at_Gyeongbokgung_Palace_with_blue_sky_in_Seoul.jpg',
   'Basile Morin / Wikimedia Commons', 'https://commons.wikimedia.org/wiki/File:Front_view_of_the_Imperial_Throne_Hall_Geunjeongjeon_at_Gyeongbokgung_Palace_with_blue_sky_in_Seoul.jpg',
   'Trục chính hướng tới điện Geunjeongjeon', 0),
  ('00000000-0000-4000-8000-000000000200', 'Điện Geunjeongjeon', '근정전', 'Nơi diễn ra các quốc lễ quan trọng',
   'Geunjeongjeon là chính điện tráng lệ nhất của cung, nơi tổ chức lễ đăng quang, chầu triều và tiếp sứ thần nước ngoài.',
   'Geunjeongjeon nằm ở trung tâm khu vực chính triều và là công trình biểu trưng rõ nhất cho quyền lực hoàng gia. Tên điện gợi ý việc cai trị đất nước bằng sự siêng năng và chính trực. Các sự kiện quốc gia như đăng quang, buổi chầu với quan văn võ và tiếp đón sứ thần từng diễn ra tại đây. Sân rộng phía trước có các bia đá phân định vị trí đứng theo phẩm cấp, giúp người học hình dung nghi lễ triều đình. Công trình được công nhận là Quốc bảo số 223. Khi quan sát, hãy chú ý nền đá hai tầng, mái chồng diêm và trục nhìn thẳng từ các cổng phía nam.',
   'Khu chính triều, Gyeongbokgung, Seoul', array['Quan sát bia phẩm giai', 'Tìm hiểu nghi lễ triều đình'],
   'Geunjeongjeon là Quốc bảo số 223 của Hàn Quốc.', array['chính điện', 'quốc lễ'], 'image',
   'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/Front_view_of_the_Imperial_Throne_Hall_Geunjeongjeon_at_Gyeongbokgung_Palace_with_blue_sky_in_Seoul.jpg/1920px-Front_view_of_the_Imperial_Throne_Hall_Geunjeongjeon_at_Gyeongbokgung_Palace_with_blue_sky_in_Seoul.jpg',
   'Basile Morin / Wikimedia Commons', 'https://commons.wikimedia.org/wiki/File:Front_view_of_the_Imperial_Throne_Hall_Geunjeongjeon_at_Gyeongbokgung_Palace_with_blue_sky_in_Seoul.jpg',
   'Mặt tiền điện Geunjeongjeon và sân đá nghi lễ', 1),
  ('00000000-0000-4000-8000-000000000200', 'Lầu Gyeonghoeru', '경회루', 'Lầu tiệc hoàng gia bên hồ nước',
   'Gyeonghoeru là lầu dùng cho yến tiệc lớn và tiếp sứ thần, nổi bật với kiến trúc hai tầng soi bóng trên hồ nhân tạo.',
   'Gyeonghoeru cho thấy một khía cạnh khác của hoàng cung: không gian tiếp đãi, lễ nghi và thưởng cảnh. Nhà vua cùng quan lại tổ chức những buổi yến lớn hoặc tiếp sứ thần tại lầu này. Công trình đứng bên hồ, tạo góc nhìn rộng về mặt nước, núi Inwangsan và các kiến trúc xung quanh. Visit Seoul ghi nhận bố cục của lầu thường được diễn giải bằng các con số biểu tượng: ba gian trung tâm, mười hai gian và hai mươi bốn cột ngoài. Lầu là Quốc bảo số 224. Hãy ngắm từ lối đi công cộng, giữ yên lặng và tôn trọng giới hạn tiếp cận được đặt ra để bảo vệ công trình.',
   'Phía tây khu chính triều, Gyeongbokgung, Seoul', array['Ngắm hồ', 'Quan sát kiến trúc lầu'],
   'Gyeonghoeru được xem là một trong các góc nhìn đẹp nhất của cung quanh năm.', array['lầu', 'mặt nước'], 'image',
   'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/Front_view_of_the_Imperial_Throne_Hall_Geunjeongjeon_at_Gyeongbokgung_Palace_with_blue_sky_in_Seoul.jpg/1920px-Front_view_of_the_Imperial_Throne_Hall_Geunjeongjeon_at_Gyeongbokgung_Palace_with_blue_sky_in_Seoul.jpg',
   'Basile Morin / Wikimedia Commons', 'https://commons.wikimedia.org/wiki/File:Front_view_of_the_Imperial_Throne_Hall_Geunjeongjeon_at_Gyeongbokgung_Palace_with_blue_sky_in_Seoul.jpg',
   'Điện Geunjeongjeon, một công trình tiêu biểu trong cùng quần thể', 2),
  ('00000000-0000-4000-8000-000000000200', 'Đình Hyangwonjeong', '향원정', 'Đình lục giác dành cho nghỉ ngơi',
   'Hyangwonjeong là đình lục giác thanh nhã trên đảo nhỏ giữa hồ nhân tạo, từng là nơi nhà vua và hoàng gia nghỉ ngơi.',
   'Ở khu vực phía bắc, Hyangwonjeong đem lại nhịp điệu thư thái khác với sân nghi lễ của chính điện. Tên đình có nghĩa là hương thơm lan xa. Đình lục giác nằm trên đảo nhỏ giữa hồ vuông nhân tạo, liên kết với bờ bằng cầu và được bao quanh bởi cảnh quan theo mùa. Nơi đây giúp người học thấy cách hoàng cung Joseon kết hợp kiến trúc với nước, cây cối và tầm nhìn. Theo Visit Seoul, công trình được công nhận là Quốc bảo số 1761. Hãy đi theo lối được mở, không ném đồ xuống hồ và không làm gián đoạn các khu vực đang bảo tồn.',
   'Khu phía bắc Gyeongbokgung, Seoul', array['Quan sát cảnh quan', 'Chụp ảnh theo mùa'],
   'Hyangwonjeong được thiết kế theo hình lục giác và nổi tiếng nhờ tỷ lệ thanh thoát.', array['đình', 'cảnh quan'], 'image',
   'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/Front_view_of_the_Imperial_Throne_Hall_Geunjeongjeon_at_Gyeongbokgung_Palace_with_blue_sky_in_Seoul.jpg/1920px-Front_view_of_the_Imperial_Throne_Hall_Geunjeongjeon_at_Gyeongbokgung_Palace_with_blue_sky_in_Seoul.jpg',
   'Basile Morin / Wikimedia Commons', 'https://commons.wikimedia.org/wiki/File:Front_view_of_the_Imperial_Throne_Hall_Geunjeongjeon_at_Gyeongbokgung_Palace_with_blue_sky_in_Seoul.jpg',
   'Điện Geunjeongjeon trong quần thể Gyeongbokgung', 3);

insert into public.location_experiences (
  revision_id, name, korean_name, short_description, long_description,
  origin_meaning, recognizable_features, dos, donts, related_experience,
  media_kind, media_url, media_credit, media_source_url, media_alt, display_order
) values
  ('00000000-0000-4000-8000-000000000200', 'Theo dõi nghi lễ đổi gác', '수문장 교대의식',
   'Nghi lễ tái hiện giúp người xem nhận ra trang phục, nhạc hiệu và vai trò bảo vệ cổng trong không gian hoàng cung Joseon.',
   'Nghi lễ đổi gác hoàng gia là một cách sinh động để tiếp cận lịch sử thay vì chỉ đọc bảng giới thiệu. Người tham quan có thể quan sát đội hình, màu sắc trang phục và nhịp điệu nghi thức tại khu vực cổng khi chương trình được tổ chức. Đây là hoạt động tái hiện dành cho công chúng, không phải nghi lễ nguyên gốc được duy trì liên tục từ thời Joseon. Hãy xem lịch chính thức trong ngày vì thời gian có thể thay đổi theo mùa hoặc sự kiện. Đứng sau vạch hướng dẫn, nhường lối cho người biểu diễn và tránh chen vào đội hình để chụp ảnh. Sau chương trình, hãy nối trải nghiệm với vai trò của Gwanghwamun trong trục nghi lễ của cung.',
   'Tái hiện hoạt động canh gác tại cổng hoàng cung', array['Trang phục lính gác', 'Đội hình nghi lễ', 'Nhạc hiệu'], array['Kiểm tra lịch trong ngày', 'Đứng sau vạch hướng dẫn'], array['Không chặn lối đi', 'Không chạm đạo cụ'],
   'Tìm hiểu Gwanghwamun trước khi xem nghi lễ', 'image',
   'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/Front_view_of_the_Imperial_Throne_Hall_Geunjeongjeon_at_Gyeongbokgung_Palace_with_blue_sky_in_Seoul.jpg/1920px-Front_view_of_the_Imperial_Throne_Hall_Geunjeongjeon_at_Gyeongbokgung_Palace_with_blue_sky_in_Seoul.jpg',
   'Basile Morin / Wikimedia Commons', 'https://commons.wikimedia.org/wiki/File:Front_view_of_the_Imperial_Throne_Hall_Geunjeongjeon_at_Gyeongbokgung_Palace_with_blue_sky_in_Seoul.jpg',
   'Không gian nghi lễ trước điện Geunjeongjeon', 0),
  ('00000000-0000-4000-8000-000000000200', 'Tham quan trong hanbok', '한복 체험',
   'Mặc hanbok đầy đủ là cách cảm nhận chất liệu và dáng trang phục truyền thống; khách đủ điều kiện được miễn vé vào cổng theo chính sách hiện hành.',
   'Hanbok là trang phục truyền thống Hàn Quốc, thường được du khách thuê ở khu vực gần Gyeongbokgung để kết hợp với chuyến tham quan. Màu sắc, đường nét áo jeogori và váy chima hoặc quần baji tạo một trải nghiệm thị giác khác khi đi qua không gian cung điện. Visit Seoul cho biết người mặc hanbok đầy đủ có thể được vào cửa miễn phí; quy định chi tiết cần xem trước khi đi. Hãy chọn trang phục dễ di chuyển, mang giày phù hợp cho sân đá và tôn trọng quy định tại từng khu. Hoạt động này nên là cơ hội tìm hiểu văn hóa phục sức, không phải lý do để che khuất lối đi hay leo lên lan can chụp ảnh.',
   'Trải nghiệm trang phục truyền thống Hàn Quốc', array['Jeogori', 'Chima hoặc baji', 'Màu sắc truyền thống'], array['Xem quy định hanbok', 'Đi giày thoải mái'], array['Không leo lên công trình', 'Không cản lối khách khác'],
   'Kết hợp với hành trình chụp ảnh và học về nghi lễ', 'image',
   'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/Front_view_of_the_Imperial_Throne_Hall_Geunjeongjeon_at_Gyeongbokgung_Palace_with_blue_sky_in_Seoul.jpg/1920px-Front_view_of_the_Imperial_Throne_Hall_Geunjeongjeon_at_Gyeongbokgung_Palace_with_blue_sky_in_Seoul.jpg',
   'Basile Morin / Wikimedia Commons', 'https://commons.wikimedia.org/wiki/File:Front_view_of_the_Imperial_Throne_Hall_Geunjeongjeon_at_Gyeongbokgung_Palace_with_blue_sky_in_Seoul.jpg',
   'Điện Geunjeongjeon là bối cảnh phổ biến khi tham quan Gyeongbokgung', 1),
  ('00000000-0000-4000-8000-000000000200', 'Tham gia tour có hướng dẫn', '해설 관람',
   'Tour hướng dẫn giúp kết nối các công trình, chức năng và mốc thời gian thay vì chỉ tham quan từng điểm riêng lẻ.',
   'Một tuyến tham quan có hướng dẫn giúp người học hiểu vì sao Gwanghwamun, Geunjeongjeon, Sajeongjeon, Gyeonghoeru và Hyangwonjeong được sắp đặt khác nhau. Visit Seoul mô tả một lộ trình chính khoảng hai giờ qua các công trình tiêu biểu. Trang thông tin cũng nêu tour tiếng Anh được tổ chức vào một số khung giờ nhất định, trừ thứ Ba, nhưng lịch có thể thay đổi nên cần kiểm tra trước ngày đi. Hãy đến sớm tại điểm hẹn, dùng tai nghe đúng cách nếu được cấp và hỏi hướng dẫn viên về điều chưa rõ. Tour mang lại bối cảnh lịch sử hữu ích, nhất là khi quan sát những chi tiết như sân đá, mái ngói và không gian cư trú.',
   'Diễn giải di sản trực tiếp tại địa điểm', array['Điểm hẹn', 'Lộ trình theo trục cung', 'Thuyết minh'], array['Đến sớm', 'Kiểm tra ngôn ngữ và giờ tour'], array['Không tách đoàn tùy tiện', 'Không làm ồn khi thuyết minh'],
   'Lộ trình tự khám phá sau khi nghe thuyết minh', 'image',
   'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/Front_view_of_the_Imperial_Throne_Hall_Geunjeongjeon_at_Gyeongbokgung_Palace_with_blue_sky_in_Seoul.jpg/1920px-Front_view_of_the_Imperial_Throne_Hall_Geunjeongjeon_at_Gyeongbokgung_Palace_with_blue_sky_in_Seoul.jpg',
   'Basile Morin / Wikimedia Commons', 'https://commons.wikimedia.org/wiki/File:Front_view_of_the_Imperial_Throne_Hall_Geunjeongjeon_at_Gyeongbokgung_Palace_with_blue_sky_in_Seoul.jpg',
   'Điện Geunjeongjeon là một điểm chính trong lộ trình tham quan', 2);

insert into public.location_culture_guidelines (revision_id, kind, content, display_order) values
  ('00000000-0000-4000-8000-000000000200', 'do', 'Đi theo lối được mở và quan sát biển hướng dẫn tại từng khu vực.', 0),
  ('00000000-0000-4000-8000-000000000200', 'do', 'Giữ âm lượng vừa phải để tôn trọng không gian di sản và các đoàn tham quan.', 1),
  ('00000000-0000-4000-8000-000000000200', 'dont', 'Không chạm, leo trèo hoặc đặt đạo cụ lên cấu kiện kiến trúc.', 0),
  ('00000000-0000-4000-8000-000000000200', 'dont', 'Không ném tiền, thức ăn hoặc vật dụng xuống hồ và vườn cảnh.', 1);

insert into public.location_foods (
  revision_id, name, korean_name, short_description, long_description,
  ingredients, flavors, special_feature, experience_places, image_url,
  image_credit, image_source_url, image_alt, display_order
) values
  ('00000000-0000-4000-8000-000000000200', 'Bibimbap', '비빔밥',
   'Cơm trộn Hàn Quốc kết hợp cơm, rau, gia vị và thường có trứng hoặc thịt, phù hợp cho bữa trưa sau khi tham quan cung điện.',
   'Bibimbap là món cơm trộn với nhiều thành phần được sắp riêng trước khi ăn. Một phần phổ biến gồm cơm, rau củ đã chế biến, tương ớt gochujang và trứng; phiên bản có thể thêm thịt hoặc lựa chọn chay. Sự đa dạng màu sắc khiến món ăn phù hợp để giới thiệu nguyên tắc cân bằng nguyên liệu trong ẩm thực Hàn Quốc. Khi ghé khu vực Jongno gần Gyeongbokgung, hãy xem thực đơn, hỏi về thành phần dị ứng và chọn khẩu phần phù hợp. Món này là gợi ý ẩm thực quanh cung, không phải khẳng định được phục vụ bên trong khu di tích.',
   array['cơm', 'rau củ', 'gochujang', 'trứng'], array['cay nhẹ', 'mặn ngọt', 'tươi'],
   'Người ăn tự trộn các thành phần để điều chỉnh hương vị.', array['Nhà hàng khu Jongno', 'Khu Gwanghwamun'],
   'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/Front_view_of_the_Imperial_Throne_Hall_Geunjeongjeon_at_Gyeongbokgung_Palace_with_blue_sky_in_Seoul.jpg/1920px-Front_view_of_the_Imperial_Throne_Hall_Geunjeongjeon_at_Gyeongbokgung_Palace_with_blue_sky_in_Seoul.jpg',
   'Basile Morin / Wikimedia Commons', 'https://commons.wikimedia.org/wiki/File:Front_view_of_the_Imperial_Throne_Hall_Geunjeongjeon_at_Gyeongbokgung_Palace_with_blue_sky_in_Seoul.jpg',
   'Kiến trúc Gyeongbokgung, điểm tham quan gần khu ẩm thực Jongno', 0),
  ('00000000-0000-4000-8000-000000000200', 'Tteokbokki', '떡볶이',
   'Bánh gạo cay trong sốt gochujang là món ăn đường phố quen thuộc, thích hợp để tìm hiểu vị cay ngọt phổ biến của ẩm thực Seoul.',
   'Tteokbokki dùng bánh gạo mềm nấu trong sốt đỏ có gochujang, thường ăn kèm chả cá, hành lá hoặc trứng. Món ăn có nhiều mức cay và công thức, từ phong cách đường phố đến biến thể hiện đại. Đây là một gợi ý dễ tiếp cận khi khám phá khu phố xung quanh Gwanghwamun và Jongno sau chuyến đi bộ trong cung. Người học có thể dùng món để nhận biết nguyên liệu lên men như gochujang và vai trò của bánh gạo trong ẩm thực Hàn Quốc. Hãy hỏi mức cay trước khi gọi, đặc biệt với trẻ em hoặc người không quen ăn cay.',
   array['bánh gạo', 'gochujang', 'chả cá', 'hành lá'], array['cay', 'ngọt', 'đậm đà'],
   'Độ cay và nguyên liệu ăn kèm thay đổi theo từng quán.', array['Quán ăn khu Jongno', 'Chợ và phố ẩm thực Seoul'],
   'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/Front_view_of_the_Imperial_Throne_Hall_Geunjeongjeon_at_Gyeongbokgung_Palace_with_blue_sky_in_Seoul.jpg/1920px-Front_view_of_the_Imperial_Throne_Hall_Geunjeongjeon_at_Gyeongbokgung_Palace_with_blue_sky_in_Seoul.jpg',
   'Basile Morin / Wikimedia Commons', 'https://commons.wikimedia.org/wiki/File:Front_view_of_the_Imperial_Throne_Hall_Geunjeongjeon_at_Gyeongbokgung_Palace_with_blue_sky_in_Seoul.jpg',
   'Gyeongbokgung, điểm xuất phát cho hành trình ẩm thực tại Seoul', 1),
  ('00000000-0000-4000-8000-000000000200', 'Trà yuja', '유자차',
   'Trà yuja là thức uống ấm pha từ mứt thanh yên, có vị thơm ngọt chua và phù hợp để nghỉ chân sau khi đi bộ.',
   'Yuja-cha thường được pha bằng cách hòa mứt thanh yên với nước ấm, tạo nên hương thơm cam quýt và vị ngọt chua dịu. Đồ uống này không phải là cổ vật hoàng cung, nhưng là gợi ý phù hợp cho thời tiết mát hoặc khi cần một điểm dừng yên tĩnh quanh khu tham quan. Người học có thể nhận ra cách trái cây được bảo quản thành mứt để dùng làm thức uống. Khi gọi món, hãy hỏi lượng đường và thành phần nếu có chế độ ăn đặc biệt. Việc nghỉ chân đúng lúc cũng giúp chuyến tham quan cung điện thoải mái và tôn trọng nhịp độ của cả nhóm.',
   array['thanh yên', 'mứt yuja', 'nước ấm'], array['thơm', 'ngọt', 'chua nhẹ'],
   'Mứt yuja có thể được pha nóng hoặc lạnh tùy mùa.', array['Quán trà khu Bukchon', 'Quán cà phê quanh Gwanghwamun'],
   'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/Front_view_of_the_Imperial_Throne_Hall_Geunjeongjeon_at_Gyeongbokgung_Palace_with_blue_sky_in_Seoul.jpg/1920px-Front_view_of_the_Imperial_Throne_Hall_Geunjeongjeon_at_Gyeongbokgung_Palace_with_blue_sky_in_Seoul.jpg',
   'Basile Morin / Wikimedia Commons', 'https://commons.wikimedia.org/wiki/File:Front_view_of_the_Imperial_Throne_Hall_Geunjeongjeon_at_Gyeongbokgung_Palace_with_blue_sky_in_Seoul.jpg',
   'Gyeongbokgung gần các khu phố có quán trà truyền thống', 2);

insert into public.location_fun_facts (
  revision_id, title, category, fact, icon_name, unlock_after_stage, display_order
) values
  ('00000000-0000-4000-8000-000000000200', 'Ý nghĩa tên cung', 'Ngôn ngữ', 'Gyeongbokgung thường được diễn giải là cung điện được ban nhiều phúc lành, phản ánh kỳ vọng thịnh vượng của triều Joseon mới.', 'auto_awesome', 1, 0),
  ('00000000-0000-4000-8000-000000000200', 'Quốc bảo trong cung', 'Di sản', 'Geunjeongjeon và Gyeonghoeru đều là Quốc bảo; Hyangwonjeong cũng được công nhận giá trị cao trong hệ thống di sản Hàn Quốc.', 'account_balance', 3, 1),
  ('00000000-0000-4000-8000-000000000200', 'Sân đá có thứ bậc', 'Nghi lễ', 'Trước Geunjeongjeon có các bia đá chỉ vị trí đứng của quan lại, giúp trật tự phẩm cấp hiện diện ngay trong kiến trúc.', 'format_list_numbered', 4, 2),
  ('00000000-0000-4000-8000-000000000200', 'Đình trên đảo nhỏ', 'Cảnh quan', 'Hyangwonjeong là đình lục giác nằm trên đảo giữa hồ nhân tạo, thể hiện cách cung điện kết nối kiến trúc với mặt nước.', 'water', 6, 3);

insert into public.location_transport_options (
  revision_id, mode, title, instructions, tip, is_recommended, display_order
) values
  ('00000000-0000-4000-8000-000000000200', 'metro', 'Tàu điện ngầm tuyến 3', 'Xuống ga Gyeongbokgung, đi ra cửa 5 và đi bộ khoảng 492 mét đến cung điện.', 'Đây là lựa chọn thuận tiện cho lối vào chính; kiểm tra chỉ dẫn tại ga.', true, 0),
  ('00000000-0000-4000-8000-000000000200', 'metro', 'Tàu điện ngầm tuyến 5', 'Xuống ga Gwanghwamun, đi ra cửa 2 và đi bộ khoảng 471 mét.', 'Phù hợp khi kết hợp tham quan quảng trường Gwanghwamun.', false, 1),
  ('00000000-0000-4000-8000-000000000200', 'walk', 'Đi bộ từ Bukchon', 'Đi bộ theo tuyến phố phù hợp từ Bukchon Hanok Village đến khu Gyeongbokgung.', 'Chọn giày thoải mái vì có nhiều sân đá và quãng đường đi bộ.', false, 2);

insert into public.location_visitor_notes (revision_id, content, display_order) values
  ('00000000-0000-4000-8000-000000000200', 'Cung đóng cửa vào thứ Ba; giờ mở cửa và hoạt động đặc biệt có thể thay đổi, hãy kiểm tra nguồn chính thức trước chuyến đi.', 0),
  ('00000000-0000-4000-8000-000000000200', 'Vào cửa muộn nhất một giờ trước giờ đóng; dành khoảng hai giờ cho tuyến các công trình chính.', 1),
  ('00000000-0000-4000-8000-000000000200', 'Tôn trọng biển giới hạn, không chạm kiến trúc, không leo trèo và giữ sạch mặt nước trong khu di sản.', 2);

insert into public.quiz_questions (
  id, revision_id, kind, prompt, explanation, is_visible, display_order
) values
  ('00000000-0000-4000-8000-000000000301', '00000000-0000-4000-8000-000000000200', 'single_choice', 'Gyeongbokgung được hoàn thành lần đầu vào năm nào?', 'Gyeongbokgung được hoàn thành vào năm 1395 dưới thời vua Taejo, sau khi triều Joseon mới thành lập và chọn nơi đây làm cung điện chính.', true, 0),
  ('00000000-0000-4000-8000-000000000302', '00000000-0000-4000-8000-000000000200', 'single_choice', 'Cổng chính phía nam của Gyeongbokgung có tên là gì?', 'Gwanghwamun là cổng chính phía nam, mở đầu trục nghi lễ đi qua các cổng nội cung tới điện Geunjeongjeon, trung tâm của khu chính triều.', true, 1),
  ('00000000-0000-4000-8000-000000000303', '00000000-0000-4000-8000-000000000200', 'single_choice', 'Công trình nào là chính điện tổ chức quốc lễ và tiếp sứ thần?', 'Geunjeongjeon là chính điện tráng lệ nhất của cung. Lễ đăng quang, buổi chầu quan lại và tiếp đón sứ thần nước ngoài từng diễn ra tại đây.', true, 2),
  ('00000000-0000-4000-8000-000000000304', '00000000-0000-4000-8000-000000000200', 'single_choice', 'Gyeonghoeru chủ yếu gắn với hoạt động nào của hoàng gia?', 'Gyeonghoeru là lầu dùng cho yến tiệc lớn và tiếp sứ thần. Công trình bên hồ cho thấy không gian tiếp đãi trang trọng của hoàng gia Joseon.', true, 3),
  ('00000000-0000-4000-8000-000000000305', '00000000-0000-4000-8000-000000000200', 'single_choice', 'Đình lục giác trên đảo nhỏ giữa hồ là công trình nào?', 'Hyangwonjeong là đình lục giác trên đảo nhỏ giữa hồ nhân tạo. Nơi đây từng phục vụ nghỉ ngơi cho nhà vua và hoàng gia.', true, 4),
  ('00000000-0000-4000-8000-000000000306', '00000000-0000-4000-8000-000000000200', 'single_choice', 'Gyeongbokgung bị thiêu hủy trong bối cảnh sự kiện năm 1592 nào?', 'Năm 1592, chiến tranh Imjin khi Nhật Bản xâm lược Triều Tiên đã khiến toàn bộ cung điện bị hỏa hoạn và không được sử dụng trong nhiều thế kỷ.', true, 5),
  ('00000000-0000-4000-8000-000000000307', '00000000-0000-4000-8000-000000000200', 'single_choice', 'Đợt phục dựng quy mô lớn của Gyeongbokgung diễn ra năm nào?', 'Đợt phục dựng lớn diễn ra năm 1867 dưới thời vua Gojong. Nhiều công trình quan trọng hiện nay, gồm Sajeongjeon, gắn với lần tái thiết này.', true, 6),
  ('00000000-0000-4000-8000-000000000308', '00000000-0000-4000-8000-000000000200', 'single_choice', 'Để đi tàu điện ngầm gần cung, nên xuống ga nào và cửa ra nào?', 'Visit Seoul hướng dẫn đi tuyến 3 đến ga Gyeongbokgung, cửa ra 5, rồi đi bộ khoảng 492 mét tới cung điện và cổng tham quan chính.', true, 7),
  ('00000000-0000-4000-8000-000000000309', '00000000-0000-4000-8000-000000000200', 'single_choice', 'Gyeongbokgung đóng cửa định kỳ vào ngày nào?', 'Theo thông tin du lịch hiện hành, Gyeongbokgung đóng cửa vào thứ Ba. Du khách nên kiểm tra trang chính thức vì giờ mở cửa và hoạt động có thể thay đổi.', true, 8),
  ('00000000-0000-4000-8000-000000000310', '00000000-0000-4000-8000-000000000200', 'single_choice', 'Nhóm nào có thể được miễn vé vào cổng theo chính sách hiện hành?', 'Khách mặc hanbok đầy đủ nằm trong nhóm được Visit Seoul nêu là có thể vào cửa miễn phí. Cần xem hướng dẫn chi tiết trước khi đi.', true, 9);

insert into public.quiz_options (question_id, option_text, is_correct, display_order) values
  ('00000000-0000-4000-8000-000000000301', '1392', false, 0), ('00000000-0000-4000-8000-000000000301', '1395', true, 1), ('00000000-0000-4000-8000-000000000301', '1592', false, 2), ('00000000-0000-4000-8000-000000000301', '1867', false, 3),
  ('00000000-0000-4000-8000-000000000302', 'Gwanghwamun', true, 0), ('00000000-0000-4000-8000-000000000302', 'Heungnyemun', false, 1), ('00000000-0000-4000-8000-000000000302', 'Geunjeongmun', false, 2), ('00000000-0000-4000-8000-000000000302', 'Sinmumun', false, 3),
  ('00000000-0000-4000-8000-000000000303', 'Geunjeongjeon', true, 0), ('00000000-0000-4000-8000-000000000303', 'Gyeonghoeru', false, 1), ('00000000-0000-4000-8000-000000000303', 'Hyangwonjeong', false, 2), ('00000000-0000-4000-8000-000000000303', 'Sajeongjeon', false, 3),
  ('00000000-0000-4000-8000-000000000304', 'Yến tiệc và tiếp sứ thần', true, 0), ('00000000-0000-4000-8000-000000000304', 'Nơi ở của quân lính', false, 1), ('00000000-0000-4000-8000-000000000304', 'Kho lương của cung', false, 2), ('00000000-0000-4000-8000-000000000304', 'Trường học hoàng gia', false, 3),
  ('00000000-0000-4000-8000-000000000305', 'Hyangwonjeong', true, 0), ('00000000-0000-4000-8000-000000000305', 'Gyeonghoeru', false, 1), ('00000000-0000-4000-8000-000000000305', 'Gwanghwamun', false, 2), ('00000000-0000-4000-8000-000000000305', 'Gangnyeongjeon', false, 3),
  ('00000000-0000-4000-8000-000000000306', 'Chiến tranh Imjin', true, 0), ('00000000-0000-4000-8000-000000000306', 'Chiến tranh Triều Tiên', false, 1), ('00000000-0000-4000-8000-000000000306', 'Khủng hoảng tài chính châu Á', false, 2), ('00000000-0000-4000-8000-000000000306', 'Cải cách Gabo', false, 3),
  ('00000000-0000-4000-8000-000000000307', '1592', false, 0), ('00000000-0000-4000-8000-000000000307', '1867', true, 1), ('00000000-0000-4000-8000-000000000307', '1910', false, 2), ('00000000-0000-4000-8000-000000000307', '2010', false, 3),
  ('00000000-0000-4000-8000-000000000308', 'Tuyến 3, ga Gyeongbokgung, cửa 5', true, 0), ('00000000-0000-4000-8000-000000000308', 'Tuyến 1, ga Seoul, cửa 1', false, 1), ('00000000-0000-4000-8000-000000000308', 'Tuyến 2, ga Hongik, cửa 9', false, 2), ('00000000-0000-4000-8000-000000000308', 'Tuyến 4, ga Myeongdong, cửa 6', false, 3),
  ('00000000-0000-4000-8000-000000000309', 'Thứ Ba', true, 0), ('00000000-0000-4000-8000-000000000309', 'Thứ Hai', false, 1), ('00000000-0000-4000-8000-000000000309', 'Thứ Bảy', false, 2), ('00000000-0000-4000-8000-000000000309', 'Chủ Nhật', false, 3),
  ('00000000-0000-4000-8000-000000000310', 'Khách mặc hanbok đầy đủ', true, 0), ('00000000-0000-4000-8000-000000000310', 'Mọi khách đi taxi', false, 1), ('00000000-0000-4000-8000-000000000310', 'Khách mua đồ lưu niệm', false, 2), ('00000000-0000-4000-8000-000000000310', 'Khách dùng audio guide', false, 3);
