# Thiết kế tính năng: Hồ sơ (Profile), Cài đặt (Settings) & Đăng xuất (Logout)

> **Superseded (2026-10-08):** Các mô tả reset “khóa lại địa điểm” trong tài liệu này đã được ADR-0012 thay thế. Reset chỉ xóa XP, tiến độ và phần thưởng đã nhận; không thay đổi `release_status` hoặc quyền truy cập nội dung.

- **Ngày tạo:** 2026-10-04
- **Người phụ trách module:** Phạm Văn Dương (`auth`, `profile`, `settings`, `home`, `passport`)
- **Tài liệu tham chiếu:** [`AGENTS.md`](../../../AGENTS.md), [`docs/TEAM_OWNERSHIP.md`](../../TEAM_OWNERSHIP.md)

---

## 1. Mục tiêu & Bối cảnh

Hiện tại ứng dụng **KoreaQuest** thiếu luồng **Đăng xuất (Sign Out)** hoàn chỉnh, trang **Cài đặt (`SettingsPage`)** còn rất sơ sài (chỉ có 2 switch và nút xóa giả định), còn trang **Hồ sơ (`ProfilePage`)** chưa hỗ trợ cập nhật ảnh đại diện cá nhân từ máy tính, chưa có bio, chưa đổi mật khẩu và chưa hỗ trợ đặt lại tiến trình học tập để kiểm thử lại hành trình.

Mục tiêu của thiết kế:
1. **Đăng xuất an toàn & nhất quán:** Xuất hiện ở cả Trang Cài đặt, Trang Hồ sơ và Menu Avatar trên Header; hiển thị hộp thoại xác nhận trước khi đăng xuất; chuyển hướng về `/login` kèm thông báo Toast.
2. **Trang Cài đặt hiện đại dạng Grouped Cards:**
   - Thẻ *Tài khoản & Bảo mật*: Hiển thị email, tên tài khoản, nút Đổi mật khẩu (mở Dialog tại chỗ).
   - Thẻ *Tùy chọn trải nghiệm*: Bật/tắt thông báo hành trình, giảm hiệu ứng chuyển động.
   - Thẻ *Dữ liệu & Tiến trình*: Xóa bộ nhớ tạm, Đặt lại tiến trình học tập (đưa về Level 1, 0 XP, khóa lại địa điểm để trải nghiệm lại).
   - Thẻ *Tài khoản*: Nút Đăng xuất màu đỏ nổi bật.
3. **Cập nhật Hồ sơ & Avatar linh hoạt:**
   - Chọn ảnh đại diện từ máy tính (`file_picker`) HOẶC chọn từ bộ Avatar văn hóa Hàn Quốc (🎎 Hanbok Explorer, 🗼 Seoul Traveler, 🦁 Haechi Guardian, 📜 Joseon Scholar, 🍲 K-Foodie, 🎵 K-Pop Fan).
   - Cập nhật Họ tên, Tên hiển thị và Bio (Giới thiệu cá nhân).
   - Lưu trạng thái trực tiếp vào repository và session của ứng dụng.
4. **Menu thao tác nhanh trên Header:** Bấm vào Avatar góc trên bên phải hiển thị Popup Menu điều hướng nhanh sang Hồ sơ, Cài đặt và Đăng xuất.

---

## 2. Kiến trúc & Phân quyền Module

- **Phạm vi sở hữu:** Thuộc trách nhiệm của **Phạm Văn Dương** (`features/auth`, `features/profile`, `features/settings`, `shared/repositories`).
- **Tệp dùng chung cần điều chỉnh (đã đối chiếu quy tắc AGENTS.md):**
  - `lib/shared/models/domain_models.dart`: Mở rộng `AppUser` thêm `bio`, `avatarBytes`, `avatarPreset`.
  - `lib/design_system/components/progress_components.dart`: Nâng cấp `UserAvatar` để hiển thị `avatarBytes` / `avatarPreset`.
  - `lib/design_system/components/app_structure.dart`: Bổ sung `PopupMenuButton` cho `UserAvatar` trong `AppHeader`.
  - `lib/shared/repositories/korea_quest_repository.dart` & `mock_korea_quest_repository.dart`: Thêm `updateUserProfile(...)` và `resetUserProgress()`.
  - `lib/features/auth/domain/auth_repository.dart` & `mock_auth_repository.dart`: Thêm `changePassword(...)`.

---

## 3. Thiết kế chi tiết từng màn hình & thành phần

### 3.1. Đổi mật khẩu (`ChangePasswordDialog`)
- **Vị trí gọi:** Từ thẻ "Tài khoản & Bảo mật" trong `SettingsPage`.
- **Giao diện Modal Dialog:**
  - Ô nhập "Mật khẩu hiện tại" (obscureText, toggle ẩn/hiện).
  - Ô nhập "Mật khẩu mới" (tối thiểu 8 ký tự).
  - Ô nhập "Xác nhận mật khẩu mới" (kiểm tra khớp mật khẩu mới).
  - Nút "Hủy" và nút "Cập nhật mật khẩu".
- **Xử lý:**
  - Kiểm tra mật khẩu hiện tại với tài khoản đang đăng nhập trong `MockAuthRepository`.
  - Nếu sai $\rightarrow$ báo lỗi inline hoặc toast lỗi.
  - Nếu đúng $\rightarrow$ cập nhật mật khẩu, đóng Dialog và hiện thông báo thành công.

### 3.2. Trang Cài đặt (`SettingsPage`) — Bố cục Grouped Cards
Áp dụng design tokens từ `lib/design_system/`:
1. **Card 1: Tài khoản & Bảo mật**
   - Icon: `Icons.security_rounded`
   - Dòng 1: Email / Tên đăng nhập (readonly, có badge vai trò `User` hoặc `Admin`).
   - Dòng 2: Mật khẩu (hiển thị `••••••••`, kèm nút Outline "Đổi mật khẩu").
2. **Card 2: Tùy chọn trải nghiệm**
   - Icon: `Icons.tune_rounded`
   - SwitchListTile: "Thông báo hành trình" (nhắc nhở khi có nhiệm vụ/XP mới).
   - SwitchListTile: "Giảm hiệu ứng chuyển động" (hỗ trợ accessibility).
3. **Card 3: Quản lý dữ liệu & Lưu trữ**
   - Icon: `Icons.storage_rounded`
   - Mục "Xóa bộ nhớ đệm": Dọn cache mô phỏng, hiện Toast xác nhận.
   - Mục "Đặt lại tiến trình học tập" (`DangerButton` hoặc tile cảnh báo đỏ):
     - Khi bấm mở `ConfirmationDialog`: Cảnh báo thao tác sẽ xóa toàn bộ XP, huy hiệu, dấu mộc và khóa lại các địa điểm đã qua.
     - Xác nhận $\rightarrow$ gọi `koreaQuestRepository.resetUserProgress()`, làm mới Riverpod providers, hiển thị Toast "Đã đặt lại tiến trình học tập về ban đầu".
4. **Card 4: Tài khoản & Đăng xuất**
   - Nút `DangerButton` kích thước lớn: "Đăng xuất tài khoản".
   - Bấm $\rightarrow$ hiển thị `ConfirmationDialog` ("Đăng xuất khỏi KoreaQuest?").
   - Xác nhận $\rightarrow$ gọi `authRepository.signOut()`, hiện Toast và router chuyển hướng về `/login`.

### 3.3. Trang Hồ sơ (`ProfilePage`) & Chỉnh sửa hồ sơ (`_EditProfileForm`)
- **Màn hình Hồ sơ chính (`/profile`):**
  - Hero header: Hiển thị avatar (ảnh tùy chỉnh hoặc preset), Tên hiển thị, Handle, Bio, Cấp độ & Thanh tiến trình XP.
  - Thêm hàng hành động tiện ích:
    - Nút "Chỉnh sửa hồ sơ" (PrimaryButton)
    - Nút "Cài đặt" (SecondaryButton dẫn sang `/settings`)
    - Nút "Đăng xuất" (Ghost/DangerButton có icon đăng xuất)
- **Màn hình Chỉnh sửa hồ sơ (`/profile/edit`):**
  - **Bộ chọn Avatar (Avatar Selector):**
    - Hiển thị xem trước Avatar hiện tại (kích thước lớn).
    - Nút "Tải ảnh từ máy" (`OutlinedButton` với icon `upload_file`): Dùng `FilePicker.platform.pickFiles(type: FileType.image, withData: true)` để lấy bytes hình ảnh từ máy tính của người dùng.
    - Hàng gợi ý "Hoặc chọn nhân vật đại diện": Danh sách các chip / avatar tròn văn hóa Hàn Quốc có thể bấm chọn ngay (Hanbok Explorer, Seoul Traveler, Haechi Guardian, Joseon Scholar, K-Foodie, K-Pop Fan).
  - **Các trường thông tin:**
    - Họ và tên (`fullName`)
    - Tên hiển thị (`displayName`)
    - Câu chuyện khám phá / Bio (`bio` - nhiều dòng)
  - **Hành động:**
    - "Lưu thay đổi": Gọi `koreaQuestRepository.updateUserProfile(...)`, invalidate `currentUserProvider`, hiện Toast thành công và quay lại `/profile`.
    - "Hủy": Quay về `/profile` không lưu.

### 3.4. Dropdown Menu trên Header (`AppHeader`)
- Thay thế icon Avatar tĩnh thành `PopupMenuButton`:
  - Header item: Tên người dùng + Email + Level badge.
  - Mục 1: `Icons.person_outline_rounded` — "Hồ sơ của tôi" (`/profile`)
  - Mục 2: `Icons.settings_outlined` — "Cài đặt" (`/settings`)
  - Divider
  - Mục 3: `Icons.logout_rounded` — "Đăng xuất" (màu đỏ `AppColors.koreanRed`), kích hoạt luồng xác nhận đăng xuất.

---

## 4. Kế hoạch kiểm thử & Tiêu chí nghiệm thu

### 4.1. Tiêu chí nghiệm thu (Acceptance Criteria)
1. **Đăng xuất:**
   - Bấm Đăng xuất từ Header, Hồ sơ hoặc Cài đặt đều bật hộp thoại xác nhận.
   - Hủy $\rightarrow$ giữ nguyên trạng thái.
   - Xác nhận $\rightarrow$ đăng xuất thành công, chuyển hướng về `/login`, không truy cập được các route nội bộ nếu chưa đăng nhập lại.
2. **Đổi mật khẩu:**
   - Kiểm tra đúng mật khẩu cũ mới cho đổi.
   - Mật khẩu mới dưới 8 ký tự hoặc 2 ô mật khẩu mới không khớp $\rightarrow$ hiển thị thông báo lỗi rõ ràng.
   - Đổi thành công $\rightarrow$ đăng nhập được bằng mật khẩu mới.
3. **Cập nhật Hồ sơ & Avatar:**
   - Tải được ảnh từ máy hoặc chọn preset đại diện.
   - Cập nhật Họ tên, Tên hiển thị, Bio thành công và phản ánh tức thì trên toàn bộ app (Header, Profile hero, Passport).
4. **Đặt lại tiến trình:**
   - Thao tác reset tiến trình đưa XP về 0, Level về 1, khóa lại địa điểm và cập nhật giao diện ngay lập tức.
5. **Chất lượng mã nguồn:**
   - Tuân thủ quy định: `dart format .`, `flutter analyze`, `flutter test`, `flutter build web` không có lỗi.
