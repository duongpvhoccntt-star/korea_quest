// ignore_for_file: lines_longer_than_80_chars
import 'package:korea_quest/features/explore/domain/location_content_repository.dart';
import 'package:korea_quest/features/explore/domain/published_location.dart';

/// Dữ liệu mock cho Gyeongbokgung — lấy từ supabase/seed.sql.
/// Dùng khi SUPABASE_URL / SUPABASE_PUBLISHABLE_KEY chưa được cấu hình
/// để app vẫn chạy được trên local mà không cần key.
class MockLocationContentRepository implements LocationContentRepository {
  const MockLocationContentRepository();

  static const _thumbUrl =
      'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/Front_view_of_the_Imperial_Throne_Hall_Geunjeongjeon_at_Gyeongbokgung_Palace_with_blue_sky_in_Seoul.jpg/1920px-Front_view_of_the_Imperial_Throne_Hall_Geunjeongjeon_at_Gyeongbokgung_Palace_with_blue_sky_in_Seoul.jpg';
  static const _thumbCredit = 'Basile Morin / Wikimedia Commons';
  static const _thumbSourceUrl =
      'https://commons.wikimedia.org/wiki/File:Front_view_of_the_Imperial_Throne_Hall_Geunjeongjeon_at_Gyeongbokgung_Palace_with_blue_sky_in_Seoul.jpg';
  static const _thumbAlt =
      'Mặt tiền điện Geunjeongjeon tại Gyeongbokgung dưới bầu trời xanh';

  static const _coverMedia = <String, dynamic>{
    'kind': 'image',
    'url': _thumbUrl,
    'credit': _thumbCredit,
    'source_url': _thumbSourceUrl,
    'alt': _thumbAlt,
    'images': <dynamic>[
      <String, dynamic>{
        'url': _thumbUrl,
        'credit': _thumbCredit,
        'source_url': _thumbSourceUrl,
        'alt': _thumbAlt,
      },
    ],
  };

  static const _hookMedia = <String, dynamic>{
    'kind': 'image',
    'url': _thumbUrl,
    'credit': _thumbCredit,
    'source_url': _thumbSourceUrl,
    'alt': 'Điện Geunjeongjeon nhìn chính diện trong khuôn viên Gyeongbokgung',
    'images': <dynamic>[
      <String, dynamic>{
        'url': _thumbUrl,
        'credit': _thumbCredit,
        'source_url': _thumbSourceUrl,
        'alt':
            'Điện Geunjeongjeon nhìn chính diện trong khuôn viên Gyeongbokgung',
      },
    ],
  };

  // ---------------------------------------------------------------------------
  // Summary
  // ---------------------------------------------------------------------------

  static const _summary = <String, dynamic>{
    'id': '00000000-0000-4000-8000-000000000100',
    'slug': 'gyeongbokgung',
    'name': 'Cung điện Gyeongbokgung',
    'korean_name': '경복궁',
    'english_name': 'Gyeongbokgung Palace',
    'city': 'Seoul',
    'short_description':
        'Cung điện chính của triều Joseon, nơi kể câu chuyện về quyền lực hoàng gia, kiến trúc truyền thống và lịch sử phục hưng của Seoul.',
    'thumbnail_url': _thumbUrl,
    'thumbnail_alt': _thumbAlt,
    'release_status': 'released',
    'categories': <dynamic>['Lịch sử', 'Kiến trúc', 'Văn hóa'],
    'estimated_duration_minutes': 120,
    'requested_locale': 'vi',
    'resolved_locale': 'vi',
    'is_fallback': false,
  };

  // ---------------------------------------------------------------------------
  // Detail
  // ---------------------------------------------------------------------------

  static const _detail = <String, dynamic>{
    'id': '00000000-0000-4000-8000-000000000100',
    'slug': 'gyeongbokgung',
    'name': 'Cung điện Gyeongbokgung',
    'korean_name': '경복궁',
    'english_name': 'Gyeongbokgung Palace',
    'address': '161 Sajik-ro, Jongno-gu, Seoul 03045',
    'city': 'Seoul',
    'region': 'Jongno-gu',
    'country': 'Hàn Quốc',
    'location_type': 'Cung điện hoàng gia',
    'short_description':
        'Cung điện chính của triều Joseon, nơi kể câu chuyện về quyền lực hoàng gia, kiến trúc truyền thống và lịch sử phục hưng của Seoul.',
    'long_description':
        'Gyeongbokgung là cung điện chính của triều Joseon, hoàn thành năm 1395 dưới thời vua Taejo. Trục không gian từ Gwanghwamun đến Geunjeongjeon thể hiện trật tự nghi lễ của triều đình, còn Gyeonghoeru và Hyangwonjeong cho thấy sự hòa hợp giữa kiến trúc, mặt nước và núi Bugaksan.',
    'release_status': 'released',
    'estimated_duration_minutes': 120,
    'tags': <dynamic>['Joseon', 'cung điện', 'Seoul', 'di sản'],
    'categories': <dynamic>['Lịch sử', 'Kiến trúc', 'Văn hóa'],
    'cover_media': _coverMedia,
    'hook_media': _hookMedia,
    'hook_title': 'Bước vào trung tâm của triều Joseon',
    'hook_caption':
        'Khám phá cung điện lớn nhất trong năm cung điện hoàng gia của Seoul qua chín chặng học ngắn.',
    'experience_featured_fact':
        'Các nghi lễ và không gian tại cung nhắc người tham quan về phép tắc, thứ bậc và sự tôn trọng di sản.',
    'opening_hours':
        '09:00–17:00 tháng 1–2, 09:00–18:00 tháng 3–5, 09:00–18:30 tháng 6–8, 09:00–18:00 tháng 9–10, 09:00–17:00 tháng 11–12; vào cửa muộn nhất một giờ trước khi đóng; nghỉ thứ Ba.',
    'ticket_price':
        'Người lớn 19–64 tuổi: 3.000 KRW; một số nhóm đủ điều kiện, gồm khách mặc hanbok đầy đủ, được miễn phí.',
    'recommended_duration': 'Khoảng 2 giờ cho lộ trình các công trình chính.',
    'best_time_to_visit':
        'Buổi sáng hoặc chiều mát; tránh thứ Ba vì cung đóng cửa định kỳ.',
    'accessibility_info':
        'Có lối tiếp cận, nhà vệ sinh phù hợp, bãi đỗ xe và điểm thuê xe lăn hoặc xe đẩy gần Heungnyemun.',
    'stamp_name': 'Dấu ấn Gwanghwamun',
    'stamp_description':
        'Dấu mộc kỷ niệm hoàn thành hành trình khám phá cung điện chính của triều Joseon.',
    'stamp_image_url':
        'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9d/Joseongukwangjiin_%28The_Seal_of_the_King_of_Joseon%2C_1776-1876%29.svg/512px-Joseongukwangjiin_%28The_Seal_of_the_King_of_Joseon%2C_1776-1876%29.svg.png',
    'quick_facts': <dynamic>[
      <String, dynamic>{
        'label': 'Hoàn thành lần đầu',
        'value': '1395, dưới thời vua Taejo',
      },
      <String, dynamic>{
        'label': 'Ý nghĩa tên gọi',
        'value': 'Cung điện được ban nhiều phúc lành',
      },
      <String, dynamic>{
        'label': 'Địa chỉ',
        'value': '161 Sajik-ro, Jongno-gu, Seoul',
      },
      <String, dynamic>{
        'label': 'Ga gần nhất',
        'value': 'Gyeongbokgung Station, tuyến 3, cửa ra 5',
      },
    ],
    'history': <dynamic>[
      <String, dynamic>{
        'id': 'h-1',
        'period_label': '1394–1395',
        'title': 'Khởi dựng cung điện đầu triều Joseon',
        'short_description':
            'Sau khi lập triều Joseon, vua Taejo chọn khu vực dưới chân Bugaksan để dựng cung điện chính và hoàn thành công trình vào năm 1395.',
        'long_description':
            'Gyeongbokgung được xây trong những năm đầu của triều Joseon để làm trung tâm hoàng gia và chính sự. Vị trí đặt cung tuân theo quan niệm phong thủy: có núi Bugaksan ở phía sau và dòng nước ở phía trước.',
        'related_people': 'Vua Taejo',
        'categories': <dynamic>['khởi dựng', 'triều Joseon'],
        'fun_fact':
            'Tên cung gắn với ý niệm về phúc lành và thịnh vượng của vương triều mới.',
        'media': <String, dynamic>{
          'kind': 'image',
          'url': _thumbUrl,
          'credit': _thumbCredit,
          'source_url': _thumbSourceUrl,
          'alt': 'Điện Geunjeongjeon trong cung điện chính của Joseon',
          'images': <dynamic>[
            <String, dynamic>{
              'url': _thumbUrl,
              'credit': _thumbCredit,
              'source_url': _thumbSourceUrl,
              'alt': 'Điện Geunjeongjeon',
            },
          ],
        },
      },
      <String, dynamic>{
        'id': 'h-2',
        'period_label': '1592',
        'title': 'Cung điện bị tàn phá trong chiến tranh Imjin',
        'short_description':
            'Năm 1592, toàn bộ Gyeongbokgung bị hỏa hoạn trong bối cảnh Nhật Bản xâm lược Triều Tiên, khiến cung điện không còn được sử dụng trong nhiều thế kỷ.',
        'long_description':
            'Cuộc chiến Imjin bắt đầu năm 1592 đã làm thay đổi sâu sắc Seoul và đời sống triều đình Joseon. Các công trình của Gyeongbokgung bị thiêu hủy.',
        'related_people': null,
        'categories': <dynamic>['chiến tranh', 'biến cố'],
        'fun_fact':
            'Sajeongjeon từng bị cháy, được dựng lại và công trình hiện tại có từ năm 1867.',
        'media': <String, dynamic>{
          'kind': 'image',
          'url': _thumbUrl,
          'credit': _thumbCredit,
          'source_url': _thumbSourceUrl,
          'alt': 'Kiến trúc phục dựng của Gyeongbokgung ngày nay',
          'images': <dynamic>[
            <String, dynamic>{
              'url': _thumbUrl,
              'credit': _thumbCredit,
              'source_url': _thumbSourceUrl,
              'alt': 'Gyeongbokgung',
            },
          ],
        },
      },
      <String, dynamic>{
        'id': 'h-3',
        'period_label': '1867',
        'title': 'Đại trùng tu dưới thời vua Gojong',
        'short_description':
            'Năm 1867, Gyeongbokgung được phục dựng quy mô lớn; các điện quan trọng như Geunjeongjeon, Gyeonghoeru và Sajeongjeon được tái thiết.',
        'long_description':
            'Đợt phục dựng năm 1867 đưa Gyeongbokgung trở lại vai trò trung tâm biểu tượng của vương triều. Dưới thời vua Gojong và sự chỉ đạo của Heungseon Daewongun, nhiều hạng mục chính được dựng lại.',
        'related_people': 'Vua Gojong; Heungseon Daewongun',
        'categories': <dynamic>['phục dựng', 'kiến trúc'],
        'fun_fact':
            'Sajeongjeon là nguồn tư liệu quý về cấu trúc và bố cục cung điện vào năm 1867.',
        'media': <String, dynamic>{
          'kind': 'image',
          'url': _thumbUrl,
          'credit': _thumbCredit,
          'source_url': _thumbSourceUrl,
          'alt': 'Mặt tiền điện chính được tái thiết thế kỷ mười chín',
          'images': <dynamic>[
            <String, dynamic>{
              'url': _thumbUrl,
              'credit': _thumbCredit,
              'source_url': _thumbSourceUrl,
              'alt': 'Gyeongbokgung 1867',
            },
          ],
        },
      },
      <String, dynamic>{
        'id': 'h-4',
        'period_label': '1990–nay',
        'title': 'Bảo tồn và phục hồi không gian hoàng cung',
        'short_description':
            'Từ thập niên 1990, các chương trình phục hồi tiếp tục trả lại những phần quan trọng của Gyeongbokgung; Gwanghwamun được hoàn thành phục dựng tại vị trí gốc vào năm 2010.',
        'long_description':
            'Công tác phục hồi hiện đại nhằm khôi phục dần các công trình, tuyến không gian và ý nghĩa lịch sử của cung.',
        'related_people': null,
        'categories': <dynamic>['bảo tồn', 'hiện đại'],
        'fun_fact':
            'Gwanghwamun từng bị di dời trong thời thuộc địa trước khi được trả lại vị trí nguyên gốc.',
        'media': <String, dynamic>{
          'kind': 'image',
          'url': _thumbUrl,
          'credit': _thumbCredit,
          'source_url': _thumbSourceUrl,
          'alt':
              'Geunjeongjeon là điểm tham quan trung tâm trong Gyeongbokgung hiện nay',
          'images': <dynamic>[
            <String, dynamic>{
              'url': _thumbUrl,
              'credit': _thumbCredit,
              'source_url': _thumbSourceUrl,
              'alt': 'Gyeongbokgung modern',
            },
          ],
        },
      },
    ],
    'highlights': <dynamic>[
      <String, dynamic>{
        'id': 'hl-1',
        'name': 'Cổng Gwanghwamun',
        'korean_name': '광화문',
        'tagline': 'Cánh cổng chính nhìn về phía nam',
        'short_description':
            'Gwanghwamun là cổng chính phía nam của Gyeongbokgung, mở đầu trục nghi lễ dẫn qua các cổng và sân đến điện Geunjeongjeon.',
        'long_description':
            'Gwanghwamun là điểm bắt đầu phù hợp để đọc cấu trúc toàn cung. Từ đây, người tham quan có thể nhận ra trục thẳng nối cổng chính với Heungnyemun, Geunjeongmun và điện Geunjeongjeon.',
        'address': 'Phía nam Gyeongbokgung, 161 Sajik-ro, Jongno-gu, Seoul',
        'activities': <dynamic>[
          'Quan sát trục cung điện',
          'Chụp ảnh từ quảng trường',
        ],
        'fun_fact':
            'Gwanghwamun được hoàn thành phục dựng tại vị trí nguyên gốc vào năm 2010.',
        'categories': <dynamic>['cổng', 'nghi lễ'],
        'media': <String, dynamic>{
          'kind': 'image',
          'url': _thumbUrl,
          'credit': _thumbCredit,
          'source_url': _thumbSourceUrl,
          'alt': 'Trục chính hướng tới điện Geunjeongjeon',
          'images': <dynamic>[
            <String, dynamic>{
              'url': _thumbUrl,
              'credit': _thumbCredit,
              'source_url': _thumbSourceUrl,
              'alt': 'Gwanghwamun',
            },
          ],
        },
      },
      <String, dynamic>{
        'id': 'hl-2',
        'name': 'Điện Geunjeongjeon',
        'korean_name': '근정전',
        'tagline': 'Nơi diễn ra các quốc lễ quan trọng',
        'short_description':
            'Geunjeongjeon là chính điện tráng lệ nhất của cung, nơi tổ chức lễ đăng quang, chầu triều và tiếp sứ thần nước ngoài.',
        'long_description':
            'Geunjeongjeon nằm ở trung tâm khu vực chính triều và là công trình biểu trưng rõ nhất cho quyền lực hoàng gia. Công trình được công nhận là Quốc bảo số 223.',
        'address': 'Khu chính triều, Gyeongbokgung, Seoul',
        'activities': <dynamic>[
          'Quan sát bia phẩm giai',
          'Tìm hiểu nghi lễ triều đình',
        ],
        'fun_fact': 'Geunjeongjeon là Quốc bảo số 223 của Hàn Quốc.',
        'categories': <dynamic>['chính điện', 'quốc lễ'],
        'media': <String, dynamic>{
          'kind': 'image',
          'url': _thumbUrl,
          'credit': _thumbCredit,
          'source_url': _thumbSourceUrl,
          'alt': 'Mặt tiền điện Geunjeongjeon và sân đá nghi lễ',
          'images': <dynamic>[
            <String, dynamic>{
              'url': _thumbUrl,
              'credit': _thumbCredit,
              'source_url': _thumbSourceUrl,
              'alt': 'Geunjeongjeon',
            },
          ],
        },
      },
      <String, dynamic>{
        'id': 'hl-3',
        'name': 'Lầu Gyeonghoeru',
        'korean_name': '경회루',
        'tagline': 'Lầu tiệc hoàng gia bên hồ nước',
        'short_description':
            'Gyeonghoeru là lầu dùng cho yến tiệc lớn và tiếp sứ thần, nổi bật với kiến trúc hai tầng soi bóng trên hồ nhân tạo.',
        'long_description':
            'Gyeonghoeru cho thấy một khía cạnh khác của hoàng cung: không gian tiếp đãi, lễ nghi và thưởng cảnh. Lầu là Quốc bảo số 224.',
        'address': 'Phía tây khu chính triều, Gyeongbokgung, Seoul',
        'activities': <dynamic>['Ngắm hồ', 'Quan sát kiến trúc lầu'],
        'fun_fact':
            'Gyeonghoeru được xem là một trong các góc nhìn đẹp nhất của cung quanh năm.',
        'categories': <dynamic>['lầu', 'mặt nước'],
        'media': <String, dynamic>{
          'kind': 'image',
          'url': _thumbUrl,
          'credit': _thumbCredit,
          'source_url': _thumbSourceUrl,
          'alt':
              'Điện Geunjeongjeon, một công trình tiêu biểu trong cùng quần thể',
          'images': <dynamic>[
            <String, dynamic>{
              'url': _thumbUrl,
              'credit': _thumbCredit,
              'source_url': _thumbSourceUrl,
              'alt': 'Gyeonghoeru',
            },
          ],
        },
      },
      <String, dynamic>{
        'id': 'hl-4',
        'name': 'Đình Hyangwonjeong',
        'korean_name': '향원정',
        'tagline': 'Đình lục giác dành cho nghỉ ngơi',
        'short_description':
            'Hyangwonjeong là đình lục giác thanh nhã trên đảo nhỏ giữa hồ nhân tạo, từng là nơi nhà vua và hoàng gia nghỉ ngơi.',
        'long_description':
            'Ở khu vực phía bắc, Hyangwonjeong đem lại nhịp điệu thư thái khác với sân nghi lễ. Đình lục giác nằm trên đảo nhỏ giữa hồ vuông nhân tạo.',
        'address': 'Khu phía bắc Gyeongbokgung, Seoul',
        'activities': <dynamic>['Quan sát cảnh quan', 'Chụp ảnh theo mùa'],
        'fun_fact':
            'Hyangwonjeong được thiết kế theo hình lục giác và nổi tiếng nhờ tỷ lệ thanh thoát.',
        'categories': <dynamic>['đình', 'cảnh quan'],
        'media': <String, dynamic>{
          'kind': 'image',
          'url': _thumbUrl,
          'credit': _thumbCredit,
          'source_url': _thumbSourceUrl,
          'alt': 'Điện Geunjeongjeon trong quần thể Gyeongbokgung',
          'images': <dynamic>[
            <String, dynamic>{
              'url': _thumbUrl,
              'credit': _thumbCredit,
              'source_url': _thumbSourceUrl,
              'alt': 'Hyangwonjeong',
            },
          ],
        },
      },
    ],
    'experiences': <dynamic>[
      <String, dynamic>{
        'id': 'exp-1',
        'name': 'Theo dõi nghi lễ đổi gác',
        'korean_name': '수문장 교대의식',
        'short_description':
            'Nghi lễ tái hiện giúp người xem nhận ra trang phục, nhạc hiệu và vai trò bảo vệ cổng trong không gian hoàng cung Joseon.',
        'long_description':
            'Nghi lễ đổi gác hoàng gia là một cách sinh động để tiếp cận lịch sử thay vì chỉ đọc bảng giới thiệu.',
        'origin_meaning': 'Tái hiện hoạt động canh gác tại cổng hoàng cung',
        'recognizable_features': <dynamic>[
          'Trang phục lính gác',
          'Đội hình nghi lễ',
          'Nhạc hiệu',
        ],
        'dos': <dynamic>['Kiểm tra lịch trong ngày', 'Đứng sau vạch hướng dẫn'],
        'donts': <dynamic>['Không chặn lối đi', 'Không chạm đạo cụ'],
        'related_experience': 'Tìm hiểu Gwanghwamun trước khi xem nghi lễ',
        'media': <String, dynamic>{
          'kind': 'image',
          'url': _thumbUrl,
          'credit': _thumbCredit,
          'source_url': _thumbSourceUrl,
          'alt': 'Không gian nghi lễ trước điện Geunjeongjeon',
          'images': <dynamic>[
            <String, dynamic>{
              'url': _thumbUrl,
              'credit': _thumbCredit,
              'source_url': _thumbSourceUrl,
              'alt': 'Nghi lễ đổi gác',
            },
          ],
        },
      },
      <String, dynamic>{
        'id': 'exp-2',
        'name': 'Tham quan trong hanbok',
        'korean_name': '한복 체험',
        'short_description':
            'Mặc hanbok đầy đủ là cách cảm nhận chất liệu và dáng trang phục truyền thống; khách đủ điều kiện được miễn vé vào cổng.',
        'long_description':
            'Hanbok là trang phục truyền thống Hàn Quốc, thường được du khách thuê ở khu vực gần Gyeongbokgung để kết hợp với chuyến tham quan.',
        'origin_meaning': 'Trải nghiệm trang phục truyền thống Hàn Quốc',
        'recognizable_features': <dynamic>[
          'Jeogori',
          'Chima hoặc baji',
          'Màu sắc truyền thống',
        ],
        'dos': <dynamic>['Xem quy định hanbok', 'Đi giày thoải mái'],
        'donts': <dynamic>[
          'Không leo lên công trình',
          'Không cản lối khách khác',
        ],
        'related_experience':
            'Kết hợp với hành trình chụp ảnh và học về nghi lễ',
        'media': <String, dynamic>{
          'kind': 'image',
          'url': _thumbUrl,
          'credit': _thumbCredit,
          'source_url': _thumbSourceUrl,
          'alt':
              'Điện Geunjeongjeon là bối cảnh phổ biến khi tham quan Gyeongbokgung',
          'images': <dynamic>[
            <String, dynamic>{
              'url': _thumbUrl,
              'credit': _thumbCredit,
              'source_url': _thumbSourceUrl,
              'alt': 'Hanbok tại cung',
            },
          ],
        },
      },
    ],
    'culture_guidelines': <dynamic>[
      <String, dynamic>{
        'kind': 'do',
        'content':
            'Đi theo lối được mở và quan sát biển hướng dẫn tại từng khu vực.',
      },
      <String, dynamic>{
        'kind': 'do',
        'content':
            'Giữ âm lượng vừa phải để tôn trọng không gian di sản và các đoàn tham quan.',
      },
      <String, dynamic>{
        'kind': 'dont',
        'content':
            'Không chạm, leo trèo hoặc đặt đạo cụ lên cấu kiện kiến trúc.',
      },
      <String, dynamic>{
        'kind': 'dont',
        'content':
            'Không ném tiền, thức ăn hoặc vật dụng xuống hồ và vườn cảnh.',
      },
    ],
    'foods': <dynamic>[
      <String, dynamic>{
        'id': 'food-1',
        'name': 'Bibimbap',
        'korean_name': '비빔밥',
        'short_description':
            'Cơm trộn Hàn Quốc kết hợp cơm, rau, gia vị và thường có trứng hoặc thịt, phù hợp cho bữa trưa sau khi tham quan cung điện.',
        'long_description':
            'Bibimbap là món cơm trộn với nhiều thành phần được sắp riêng trước khi ăn. Sự đa dạng màu sắc khiến món ăn phù hợp để giới thiệu nguyên tắc cân bằng nguyên liệu trong ẩm thực Hàn Quốc.',
        'ingredients': <dynamic>['cơm', 'rau củ', 'gochujang', 'trứng'],
        'flavors': <dynamic>['cay nhẹ', 'mặn ngọt', 'tươi'],
        'special_feature':
            'Người ăn tự trộn các thành phần để điều chỉnh hương vị.',
        'experience_places': <dynamic>[
          'Nhà hàng khu Jongno',
          'Khu Gwanghwamun',
        ],
        'image_url': _thumbUrl,
        'image_credit': _thumbCredit,
        'image_source_url': _thumbSourceUrl,
        'image_alt':
            'Kiến trúc Gyeongbokgung, điểm tham quan gần khu ẩm thực Jongno',
      },
      <String, dynamic>{
        'id': 'food-2',
        'name': 'Tteokbokki',
        'korean_name': '떡볶이',
        'short_description':
            'Bánh gạo cay trong sốt gochujang là món ăn đường phố quen thuộc, thích hợp để tìm hiểu vị cay ngọt phổ biến của ẩm thực Seoul.',
        'long_description':
            'Tteokbokki dùng bánh gạo mềm nấu trong sốt đỏ có gochujang, thường ăn kèm chả cá, hành lá hoặc trứng.',
        'ingredients': <dynamic>['bánh gạo', 'gochujang', 'chả cá', 'hành lá'],
        'flavors': <dynamic>['cay', 'ngọt', 'đậm đà'],
        'special_feature':
            'Độ cay và nguyên liệu ăn kèm thay đổi theo từng quán.',
        'experience_places': <dynamic>[
          'Quán ăn khu Jongno',
          'Chợ và phố ẩm thực Seoul',
        ],
        'image_url': _thumbUrl,
        'image_credit': _thumbCredit,
        'image_source_url': _thumbSourceUrl,
        'image_alt':
            'Gyeongbokgung, điểm xuất phát cho hành trình ẩm thực tại Seoul',
      },
      <String, dynamic>{
        'id': 'food-3',
        'name': 'Trà yuja',
        'korean_name': '유자차',
        'short_description':
            'Trà yuja là thức uống ấm pha từ mứt thanh yên, có vị thơm ngọt chua và phù hợp để nghỉ chân sau khi đi bộ.',
        'long_description':
            'Yuja-cha thường được pha bằng cách hòa mứt thanh yên với nước ấm, tạo nên hương thơm cam quýt và vị ngọt chua dịu.',
        'ingredients': <dynamic>['thanh yên', 'mứt yuja', 'nước ấm'],
        'flavors': <dynamic>['thơm', 'ngọt', 'chua nhẹ'],
        'special_feature': 'Mứt yuja có thể được pha nóng hoặc lạnh tùy mùa.',
        'experience_places': <dynamic>[
          'Quán trà khu Bukchon',
          'Quán cà phê quanh Gwanghwamun',
        ],
        'image_url': _thumbUrl,
        'image_credit': _thumbCredit,
        'image_source_url': _thumbSourceUrl,
        'image_alt': 'Gyeongbokgung gần các khu phố có quán trà truyền thống',
      },
    ],
    'fun_facts': <dynamic>[
      <String, dynamic>{
        'id': 'ff-1',
        'title': 'Ý nghĩa tên cung',
        'category': 'Ngôn ngữ',
        'fact':
            'Gyeongbokgung thường được diễn giải là cung điện được ban nhiều phúc lành, phản ánh kỳ vọng thịnh vượng của triều Joseon mới.',
        'icon_name': 'auto_awesome',
        'unlock_after_stage': 1,
      },
      <String, dynamic>{
        'id': 'ff-2',
        'title': 'Quốc bảo trong cung',
        'category': 'Di sản',
        'fact':
            'Geunjeongjeon và Gyeonghoeru đều là Quốc bảo; Hyangwonjeong cũng được công nhận giá trị cao trong hệ thống di sản Hàn Quốc.',
        'icon_name': 'account_balance',
        'unlock_after_stage': 3,
      },
      <String, dynamic>{
        'id': 'ff-3',
        'title': 'Sân đá có thứ bậc',
        'category': 'Nghi lễ',
        'fact':
            'Trước Geunjeongjeon có các bia đá chỉ vị trí đứng của quan lại, giúp trật tự phẩm cấp hiện diện ngay trong kiến trúc.',
        'icon_name': 'format_list_numbered',
        'unlock_after_stage': 4,
      },
      <String, dynamic>{
        'id': 'ff-4',
        'title': 'Đình trên đảo nhỏ',
        'category': 'Cảnh quan',
        'fact':
            'Hyangwonjeong là đình lục giác nằm trên đảo giữa hồ nhân tạo, thể hiện cách cung điện kết nối kiến trúc với mặt nước.',
        'icon_name': 'water',
        'unlock_after_stage': 6,
      },
    ],
    'quiz': <dynamic>[
      <String, dynamic>{
        'id': '00000000-0000-4000-8000-000000000301',
        'category': 'Lịch sử',
        'kind': 'single_choice',
        'prompt': 'Gyeongbokgung được hoàn thành lần đầu vào năm nào?',
        'explanation':
            'Gyeongbokgung được hoàn thành vào năm 1395 dưới thời vua Taejo, sau khi triều Joseon mới thành lập và chọn nơi đây làm cung điện chính.',
        'options': <dynamic>[
          <String, dynamic>{'id': 'q1-a', 'text': '1392', 'is_correct': false},
          <String, dynamic>{'id': 'q1-b', 'text': '1395', 'is_correct': true},
          <String, dynamic>{'id': 'q1-c', 'text': '1592', 'is_correct': false},
          <String, dynamic>{'id': 'q1-d', 'text': '1867', 'is_correct': false},
        ],
      },
      <String, dynamic>{
        'id': '00000000-0000-4000-8000-000000000302',
        'category': 'Kiến trúc',
        'kind': 'single_choice',
        'prompt': 'Cổng chính phía nam của Gyeongbokgung có tên là gì?',
        'explanation':
            'Gwanghwamun là cổng chính phía nam, mở đầu trục nghi lễ đi qua các cổng nội cung tới điện Geunjeongjeon.',
        'options': <dynamic>[
          <String, dynamic>{
            'id': 'q2-a',
            'text': 'Gwanghwamun',
            'is_correct': true,
          },
          <String, dynamic>{
            'id': 'q2-b',
            'text': 'Heungnyemun',
            'is_correct': false,
          },
          <String, dynamic>{
            'id': 'q2-c',
            'text': 'Geunjeongmun',
            'is_correct': false,
          },
          <String, dynamic>{
            'id': 'q2-d',
            'text': 'Sinmumun',
            'is_correct': false,
          },
        ],
      },
      <String, dynamic>{
        'id': '00000000-0000-4000-8000-000000000303',
        'category': 'Văn hóa',
        'kind': 'single_choice',
        'prompt':
            'Công trình nào là chính điện tổ chức quốc lễ và tiếp sứ thần?',
        'explanation':
            'Geunjeongjeon là chính điện tráng lệ nhất của cung. Lễ đăng quang, buổi chầu quan lại và tiếp đón sứ thần nước ngoài từng diễn ra tại đây.',
        'options': <dynamic>[
          <String, dynamic>{
            'id': 'q3-a',
            'text': 'Geunjeongjeon',
            'is_correct': true,
          },
          <String, dynamic>{
            'id': 'q3-b',
            'text': 'Gyeonghoeru',
            'is_correct': false,
          },
          <String, dynamic>{
            'id': 'q3-c',
            'text': 'Hyangwonjeong',
            'is_correct': false,
          },
          <String, dynamic>{
            'id': 'q3-d',
            'text': 'Sajeongjeon',
            'is_correct': false,
          },
        ],
      },
      <String, dynamic>{
        'id': '00000000-0000-4000-8000-000000000304',
        'category': 'Văn hóa',
        'kind': 'single_choice',
        'prompt': 'Gyeonghoeru chủ yếu gắn với hoạt động nào của hoàng gia?',
        'explanation':
            'Gyeonghoeru là lầu dùng cho yến tiệc lớn và tiếp sứ thần. Công trình bên hồ cho thấy không gian tiếp đãi trang trọng của hoàng gia Joseon.',
        'options': <dynamic>[
          <String, dynamic>{
            'id': 'q4-a',
            'text': 'Yến tiệc và tiếp sứ thần',
            'is_correct': true,
          },
          <String, dynamic>{
            'id': 'q4-b',
            'text': 'Nơi ở của quân lính',
            'is_correct': false,
          },
          <String, dynamic>{
            'id': 'q4-c',
            'text': 'Kho lương của cung',
            'is_correct': false,
          },
          <String, dynamic>{
            'id': 'q4-d',
            'text': 'Trường học hoàng gia',
            'is_correct': false,
          },
        ],
      },
      <String, dynamic>{
        'id': '00000000-0000-4000-8000-000000000305',
        'category': 'Kiến trúc',
        'kind': 'single_choice',
        'prompt': 'Đình lục giác trên đảo nhỏ giữa hồ là công trình nào?',
        'explanation':
            'Hyangwonjeong là đình lục giác trên đảo nhỏ giữa hồ nhân tạo. Nơi đây từng phục vụ nghỉ ngơi cho nhà vua và hoàng gia.',
        'options': <dynamic>[
          <String, dynamic>{
            'id': 'q5-a',
            'text': 'Hyangwonjeong',
            'is_correct': true,
          },
          <String, dynamic>{
            'id': 'q5-b',
            'text': 'Gyeonghoeru',
            'is_correct': false,
          },
          <String, dynamic>{
            'id': 'q5-c',
            'text': 'Gwanghwamun',
            'is_correct': false,
          },
          <String, dynamic>{
            'id': 'q5-d',
            'text': 'Gangnyeongjeon',
            'is_correct': false,
          },
        ],
      },
    ],
    'travel': <String, dynamic>{
      'opening_hours':
          '09:00–17:00 tháng 1–2, 09:00–18:00 tháng 3–5, 09:00–18:30 tháng 6–8, 09:00–18:00 tháng 9–10, 09:00–17:00 tháng 11–12; vào cửa muộn nhất một giờ trước khi đóng; nghỉ thứ Ba.',
      'ticket_price':
          'Người lớn 19–64 tuổi: 3.000 KRW; một số nhóm đủ điều kiện, gồm khách mặc hanbok đầy đủ, được miễn phí.',
      'recommended_duration': 'Khoảng 2 giờ cho lộ trình các công trình chính.',
      'best_time_to_visit':
          'Buổi sáng hoặc chiều mát; tránh thứ Ba vì cung đóng cửa định kỳ.',
      'accessibility_info':
          'Có lối tiếp cận, nhà vệ sinh phù hợp, bãi đỗ xe và điểm thuê xe lăn hoặc xe đẩy gần Heungnyemun.',
      'official_source_url':
          'https://english.visitseoul.net/attractions/gyeongbokgung%20palace_/73',
      'last_verified_at': '2026-09-27',
      'visitor_notes': <dynamic>[
        'Cung đóng cửa vào thứ Ba; giờ mở cửa và hoạt động đặc biệt có thể thay đổi, hãy kiểm tra nguồn chính thức trước chuyến đi.',
        'Vào cửa muộn nhất một giờ trước giờ đóng; dành khoảng hai giờ cho tuyến các công trình chính.',
        'Tôn trọng biển giới hạn, không chạm kiến trúc, không leo trèo và giữ sạch mặt nước trong khu di sản.',
      ],
      'transport_options': <dynamic>[
        <String, dynamic>{
          'mode': 'metro',
          'title': 'Tàu điện ngầm tuyến 3',
          'instructions':
              'Xuống ga Gyeongbokgung, đi ra cửa 5 và đi bộ khoảng 492 mét đến cung điện.',
          'tip':
              'Đây là lựa chọn thuận tiện cho lối vào chính; kiểm tra chỉ dẫn tại ga.',
          'is_recommended': true,
        },
        <String, dynamic>{
          'mode': 'metro',
          'title': 'Tàu điện ngầm tuyến 5',
          'instructions':
              'Xuống ga Gwanghwamun, đi ra cửa 2 và đi bộ khoảng 471 mét.',
          'tip': 'Phù hợp khi kết hợp tham quan quảng trường Gwanghwamun.',
          'is_recommended': false,
        },
        <String, dynamic>{
          'mode': 'walk',
          'title': 'Đi bộ từ Bukchon',
          'instructions':
              'Đi bộ theo tuyến phố phù hợp từ Bukchon Hanok Village đến khu Gyeongbokgung.',
          'tip': 'Chọn giày thoải mái vì có nhiều sân đá và quãng đường đi bộ.',
          'is_recommended': false,
        },
      ],
    },
    'requested_locale': 'vi',
    'resolved_locale': 'vi',
    'is_fallback': false,
  };

  // ---------------------------------------------------------------------------
  // Interface implementation
  // ---------------------------------------------------------------------------

  @override
  Future<List<PublishedLocationSummary>> listPublishedLocations({
    String locale = 'vi',
  }) async => [
    PublishedLocationSummary.fromJson(Map<String, dynamic>.from(_summary)),
  ];

  @override
  Future<PublishedLocationDetail?> getPublishedLocation(
    String slug, {
    String locale = 'vi',
  }) async {
    if (slug != 'gyeongbokgung') return null;
    return PublishedLocationDetail.fromJson(Map<String, dynamic>.from(_detail));
  }

  @override
  Future<QuizAnswerResult> submitQuizAnswer({
    required String questionId,
    required JsonMap answer,
    String locale = 'vi',
  }) async {
    // Tìm câu hỏi trong mock data và kiểm tra đáp án
    final allQuestions = jsonMapList(_detail['quiz']);
    for (final question in allQuestions) {
      if (question.string('id') == questionId) {
        final options = question.mapList('options');
        final selectedId = answer['selected_option_id']?.toString() ?? '';
        final selected = options
            .where((o) => o.string('id') == selectedId)
            .firstOrNull;
        final isCorrect = selected?['is_correct'] == true;
        final explanation = question.string('explanation');
        return QuizAnswerResult(isCorrect: isCorrect, explanation: explanation);
      }
    }
    return const QuizAnswerResult(
      isCorrect: false,
      explanation: 'Câu hỏi không tìm thấy trong dữ liệu mock.',
    );
  }
}
