# Data model theo luồng Stitch

Tài liệu này là điểm thống nhất giữa nội dung, thiết kế, Flutter và Supabase. Quyết định kiến trúc chi tiết nằm tại [ADR-0006](adr/0006-use-nine-stage-location-journey.md) và [ADR-0007](adr/0007-pin-journeys-to-content-revisions.md).

## Luồng người chơi

Hành trình có chín Chặng tuần tự:

1. Mở đầu
2. Tổng quan
3. Lịch sử
4. Điểm đến
5. Trải nghiệm
6. Ẩm thực
7. Fun Facts
8. Quiz tổng kết
9. Du lịch

Hoàn thành bảy Chặng nội dung mở Quiz. Đạt ít nhất 70% mở Chặng Du lịch. Người chơi xác nhận hoàn thành để nhận Dấu mộc đúng một lần. Quiz được làm lại nhưng XP không cộng trùng.

## Biên tập và phiên bản

`locations` giữ danh tính ổn định và slug. `location_revisions` giữ từng Phiên bản nội dung. Mỗi Địa điểm có tối đa một Bản nháp và một Phiên bản đang Xuất bản.

Admin chỉnh sửa qua mười bước, trong đó Kiểm tra & Xuất bản là bước vận hành cuối. Khi người chơi bắt đầu, `explorer_journeys.revision_id` ghim Phiên bản đang Xuất bản; vì vậy việc publish bản mới không làm đổi câu hỏi hoặc nội dung của hành trình đang dở.

Các nhóm dữ liệu chính:

| Giao diện | Bảng / trường |
| :--- | :--- |
| Mở đầu | `location_revisions.hook_media_*`, `hook_title`, `hook_caption` |
| Tổng quan | `location_revisions`, `location_quick_facts` |
| Lịch sử | `location_history` |
| Điểm đến | `location_highlights` |
| Trải nghiệm | `location_experiences`, `location_culture_guidelines` |
| Ẩm thực | `location_foods` |
| Fun Facts | `location_fun_facts` |
| Quiz tổng kết | `quiz_questions` và ba bảng đáp án |
| Du lịch | `location_revisions`, `location_transport_options`, `location_visitor_notes` |
| Nguồn | `location_sources` |

## Quiz và phần thưởng

Chỉ còn một Quiz tổng kết, không còn nhóm Check-in hay Văn hóa.

- Bản nháp: 0–20 câu.
- Xuất bản: 10–20 câu đang hiển thị.
- Dạng câu: một đáp án, Đúng/Sai, nối cặp, sắp xếp/timeline.
- Điều kiện đạt: từ 70%.
- XP: +10 cho lần trả lời đúng đầu tiên của mỗi câu; +50 cho lần đạt Quiz đầu tiên.
- `explorer_xp_ledger.reference_key` là khóa chống cộng trùng.
- `explorer_stamps` có unique `(user_id, location_id)` để mỗi Địa điểm chỉ trao một Dấu mộc.
- Huy hiệu là hệ thống thành tích riêng, không đồng nghĩa với Dấu mộc.

## Dữ liệu vận hành được bổ sung

- Tên tiếng Anh, vùng và danh mục dùng cho tìm kiếm/bộ lọc bản đồ.
- Trạng thái `coming_soon`/`released`, thời lượng khám phá dự kiến và ngày publish.
- Thumbnail tùy chọn, fallback sang ảnh bìa.
- Dấu mộc gồm tên, mô tả và media riêng.
- Media gồm loại, URL, credit, URL nguồn và alt text.
- Mỗi mục nội dung có cờ hiển thị để ẩn mà chưa cần xóa.
- Nguồn có trạng thái kiểm chứng, ngày kiểm chứng và cờ nguồn chính thức.
- Fun Fact có tiêu đề, danh mục, icon/media và Chặng mở khóa.
- Du lịch có nhiều phương án di chuyển, nhiều lưu ý, thông tin tiếp cận, nguồn chính thức và ngày kiểm chứng.

## Tiến trình người chơi

`explorer_journeys` là phiên chơi theo Địa điểm/Phiên bản. Các bảng con lưu:

- `explorer_stage_progress`: trạng thái từng Chặng.
- `explorer_quiz_attempts`, `explorer_quiz_answers`: lịch sử làm Quiz và đáp án.
- `explorer_fun_fact_unlocks`: Fun Fact đã mở/đã đọc.
- `explorer_saved_locations`, `explorer_saved_highlights`: bookmark cá nhân.
- `explorer_xp_ledger`: sổ cái XP bất biến.
- `explorer_stamps`: Dấu mộc hoàn thành.

RLS chỉ cho người chơi đọc dữ liệu của chính mình. Không cấp quyền ghi trực tiếp vào tiến trình, XP và Dấu mộc; gameplay phải dùng RPC bảo mật để chấm đáp án và trao thưởng.

## Điều kiện Xuất bản chính

- Đủ nội dung theo khoảng số lượng và số từ đã thống nhất.
- Media công khai có URL đúng loại, credit, nguồn và alt text.
- Có 3–5 thông tin nhanh; 4–6 lịch sử; 4–6 điểm đến; 3–5 trải nghiệm; 3–6 món; 4–6 Fun Facts.
- Có 10–20 câu Quiz tổng kết đang hiển thị và cấu trúc đáp án hợp lệ.
- Có ít nhất một nguồn đã kiểm chứng.
- Thông tin du lịch có phương án di chuyển, lưu ý, nguồn chính thức và ngày kiểm chứng.
