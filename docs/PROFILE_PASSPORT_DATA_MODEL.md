# Hồ sơ, Hộ chiếu và gameplay

Các migration chính:

- `20260920100000_profile_passport_gameplay.sql` — bảng, RLS, Storage và RPC quản trị;
- `20260920103000_fix_admin_save_challenge.sql` — sửa RPC lưu Thử thách;
- `20260920110000_progression_engine.sql` — tự tính chỉ số, Huy hiệu và tiến độ Thử thách;
- `20260920113000_fix_progression_refresh.sql` — sửa và sắp thứ tự làm mới tiến độ.

## Ranh giới dữ liệu

- Supabase Auth giữ email và mật khẩu. `explorer_profiles` chỉ giữ thông tin hiển thị; `full_name` luôn riêng tư.
- `user_preferences` đồng bộ locale, múi giờ, thông báo, giảm chuyển động và lựa chọn tham gia bảng xếp hạng.
- `explorer_xp_ledger` là nguồn dữ liệu gốc. `explorer_progress_summary` là projection cho màn Hồ sơ.
- Tem bưu chính trên giao diện chính là Dấu mộc trong `explorer_stamps`, được trao sau khi hoàn tất Hành trình.
- Huy hiệu dùng `achievement_definitions`, tiến độ dùng `explorer_achievement_progress`, bản ghi đã trao dùng `explorer_badges`.
- Thử thách dùng `challenge_definitions` + `challenge_goals`; tiến độ cá nhân là dữ liệu backend-owned.

## Riêng tư và chia sẻ

Hộ chiếu mặc định riêng tư. `passport_share_links` lưu SHA-256 hash, không lưu token thô. Mỗi người chỉ có một liên kết đang hoạt động; tạo lại liên kết sẽ thu hồi liên kết cũ. Chủ sở hữu chọn chia sẻ cấp độ/XP, dấu mộc, huy hiệu, hành trình gần đây và thống kê. Email và họ tên pháp lý không nằm trong payload công khai.

Ảnh Sổ lưu niệm nằm trong bucket riêng tư `explorer-memories`, giới hạn JPEG/PNG/WebP, 5 MB/ảnh và 30 ảnh/tài khoản. Đường dẫn bắt đầu bằng UUID chủ sở hữu. Ứng dụng hoặc Edge Function cần tạo signed URL ngắn hạn khi dựng trang chia sẻ; không biến bucket thành public.

## Quyền Admin

Admin chỉ cấu hình:

- `level_definitions` — ngưỡng XP và danh hiệu;
- `achievement_definitions` — điều kiện Huy hiệu;
- `challenge_definitions` + `challenge_goals` — thời gian, mục tiêu, phần thưởng.

Admin không được sửa Hồ sơ, XP, dấu mộc, ảnh hoặc tiến độ cá nhân. Tiêu chí Huy hiệu bị khóa sau lần trao đầu; Thử thách đã bắt đầu không cho đổi tiêu chí/phần thưởng.

## Đăng nhập thử nghiệm

Local Supabase cho phép email/password mà không xác nhận email (`enable_confirmations = false`). Đây chỉ là cấu hình phát triển; production phải bật xác nhận email và quy trình cấp quyền Admin riêng.
