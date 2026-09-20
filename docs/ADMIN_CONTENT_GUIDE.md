# KoreaQuest Admin Content

Trang quản trị nội dung nằm tại `/admin`. MVP này dùng Supabase local cho dữ liệu admin; các màn Explore/Journey hiện tại vẫn dùng mock repository và chưa đọc nội dung mới.

Dashboard có bốn khu độc lập: **Địa điểm**, **Cấp độ**, **Huy hiệu** và **Thử thách**. Có thể chuyển khu bất kỳ; chỉ trình soạn thảo một Địa điểm mới dùng luồng mười bước và cảnh báo thay đổi chưa lưu.

## Chạy nhanh bản demo không cần email

Khi chỉ cần kiểm tra giao diện và luồng nhập liệu Admin, chạy:

```powershell
flutter run -d chrome --dart-define=ADMIN_DEMO_MODE=true
```

Mở `/admin`, chọn **Đăng ký** để tạo tài khoản bằng tên đăng nhập, hoặc dùng sẵn `admin / admin123`. Tài khoản và nội dung được giữ trong bộ nhớ, sẽ mất khi tải lại ứng dụng. Chế độ này không kết nối và không nới quyền Supabase; tuyệt đối không bật trong bản production.

## Chuẩn bị

1. Cài và mở Docker Desktop.
2. Từ thư mục dự án, chạy:

   ```powershell
   supabase start
   supabase db reset
   supabase test db
   supabase status
   ```

3. Lấy API URL và anon/publishable key từ `supabase status`, rồi chạy Flutter Web:

   ```powershell
   flutter run -d chrome `
     --dart-define=SUPABASE_URL=http://127.0.0.1:54321 `
     --dart-define=SUPABASE_PUBLISHABLE_KEY=<LOCAL_ANON_OR_PUBLISHABLE_KEY>
   ```

4. Mở `http://localhost:<flutter-port>/admin`.

Tài khoản fixture chỉ dành cho local:

- Email: `admin@koreaquest.local`
- Mật khẩu: `KoreaQuestLocal123`

Không dùng tài khoản hay mật khẩu này trên staging/production. File seed không tạo sẵn nội dung văn hóa.

## Quy trình biên tập

Editor gồm 10 bước: Mở đầu → Tổng quan → Lịch sử → Điểm đến → Trải nghiệm → Ẩm thực → Fun Facts → Quiz tổng kết → Du lịch → Kiểm tra & Xuất bản.

- Mỗi bước được lưu thủ công, theo transaction riêng và có optimistic lock. Nếu Admin bỏ qua nhiều bước, thao tác kiểm tra/xuất bản sẽ lưu toàn bộ bước đang bẩn trước.
- Bản nháp được phép thiếu dữ liệu.
- Xuất bản được kiểm tra lại ở database, không chỉ ở giao diện.
- Một Địa điểm có tối đa một Bản nháp và một Phiên bản đã Xuất bản.
- Sửa nội dung đã Xuất bản sẽ tạo Phiên bản Bản nháp mới; độc giả vẫn thấy bản cũ tới khi publish thành công.
- Chỉ có một **Quiz tổng kết**. Bản nháp có thể chứa 0–20 câu; để Xuất bản cần 10–20 câu đang hiển thị.
- Quiz hỗ trợ: một đáp án, Đúng/Sai, nối cặp và sắp xếp/timeline. Câu hỏi có thể đính kèm ảnh hoặc YouTube.
- Ảnh dùng URL HTTP(S); video dùng URL YouTube. Media cần credit, URL nguồn và mô tả thay thế trước khi publish.
- Nguồn tham khảo có trạng thái kiểm chứng; cần ít nhất một nguồn đang hiển thị và đã kiểm chứng để publish.
- Thumbnail bản đồ không bắt buộc; ứng dụng dùng ảnh bìa làm fallback.

## Cấu trúc Supabase

- Migration nền: `supabase/migrations/20260830151124_admin_content_schema.sql`
- Hồ sơ/Hộ chiếu/gameplay: `supabase/migrations/20260920100000_profile_passport_gameplay.sql`
- Migration luồng Stitch/gameplay: `supabase/migrations/20260918120000_stitch_journey_model.sql`
- Migration sửa metadata function: `supabase/migrations/20260919090000_fix_database_function_lint.sql`
- Fixture local: `supabase/seed.sql`
- pgTAP: `supabase/tests/database/admin_content_schema_test.sql`
- Tài liệu model: `docs/STITCH_DATA_MODEL.md`

RLS chỉ cho phép public đọc Phiên bản đã Xuất bản. Ghi nội dung yêu cầu người dùng đã đăng nhập và tồn tại trong `public.admin_users`. Các thao tác lưu, validate, publish và archive đi qua RPC security-definer có kiểm tra quyền.

Tiến trình người chơi được lưu riêng và ghim vào đúng Phiên bản nội dung lúc bắt đầu. Các bảng XP, Dấu mộc, đáp án và tiến độ chỉ cho chủ tài khoản đọc; không cấp quyền ghi trực tiếp để tránh tự cộng thưởng. API gameplay bảo mật sẽ được triển khai cùng màn Journey.

## Production

Không chạy seed local trên production. Tạo tài khoản admin bằng quy trình bảo mật riêng, sau đó thêm UUID người dùng vào `public.admin_users`. Cấu hình URL/key bằng biến build; không ghi key vào repository.
