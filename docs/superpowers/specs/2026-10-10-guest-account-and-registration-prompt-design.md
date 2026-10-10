# Design Specification: Tài khoản Khách & Gợi ý Đăng ký sau Khám phá

**Ngày tạo:** 2026-10-10  
**Chủ đề:** Thêm tính năng sử dụng tài khoản khách (chỉ cần nhập tên) và gợi ý đăng ký tài khoản chính thức sau khi hoàn thành khám phá 1 địa điểm.  
**Trạng thái:** Đã duyệt bởi người dùng  

---

## 1. Mục tiêu & Bối cảnh

KoreaQuest là ứng dụng khám phá văn hóa Hàn Quốc theo phong cách game-based learning. Để giảm thiểu rào cản tiếp cận, người dùng mới có thể trải nghiệm ngay mà không cần qua các bước đăng ký tài khoản truyền thống (email, mật khẩu).
Tính năng này cho phép:
1. Người dùng chỉ cần nhập tên/nickname để bắt đầu chơi với vai trò tài khoản khách (**Guest User**).
2. Tận hưởng đầy đủ trải nghiệm khám phá các địa điểm, vượt qua các thử thách câu hỏi (quizzes) và nhận điểm XP tức thì.
3. Khi hoàn thành khám phá một địa điểm (Stage 9 / chặng Tổng kết), ứng dụng sẽ chúc mừng và gợi ý đăng ký tài khoản chính thức để lưu lại vĩnh viễn tiến trình, XP và huy hiệu, với dữ liệu và tên khách được tự động điền sẵn.

---

## 2. Kiến trúc & Mô hình dữ liệu

### 2.1. Model `AuthUser`
- **Tệp:** `lib/features/auth/domain/auth_models.dart`
- Thêm trường:
  ```dart
  class AuthUser {
    const AuthUser({
      required this.id,
      required this.usernameOrEmail,
      required this.displayName,
      required this.role,
      this.isGuest = false,
    });

    final String id;
    final String usernameOrEmail;
    final String displayName;
    final UserRole role;
    final bool isGuest;

    bool get isAdmin => role == UserRole.admin;
  }
  ```

### 2.2. Hợp đồng Repository `AuthRepository`
- **Tệp:** `lib/features/auth/domain/auth_repository.dart`
- Thêm phương thức:
  ```dart
  Future<AuthUser> signInAsGuest({required String name});
  ```

### 2.3. Triển khai trong `MockAuthRepository` & `SupabaseAuthRepository`
- **`MockAuthRepository` (`lib/features/auth/data/mock_auth_repository.dart`):**
  - Triển khai `signInAsGuest({required String name})`:
    - Cắt tỉa khoảng trắng `name.trim()`. Báo lỗi `AuthException` nếu tên rỗng.
    - Tạo `AuthUser`:
      ```dart
      final guestUser = AuthUser(
        id: 'guest-${DateTime.now().millisecondsSinceEpoch}',
        usernameOrEmail: 'guest@koreaquest.local',
        displayName: name.trim(),
        role: UserRole.user,
        isGuest: true,
      );
      ```
    - Cập nhật `_currentUser = guestUser` và đẩy vào stream `_userController.add(guestUser)`.
  - Cập nhật hàm `register`:
    - Nếu người dùng trước đó là khách, bảo toàn tiến trình hiện tại và chuyển đổi thành `isGuest: false`.
- **`SupabaseAuthRepository` (`lib/features/auth/data/supabase_auth_repository.dart`):**
  - Cung cấp triển khai `signInAsGuest` cục bộ tương tự, cho phép trải nghiệm liền mạch không phụ thuộc vào kết nối Supabase Cloud.

### 2.4. Đồng bộ hóa với `KoreaQuestRepository`
- **Tệp:** `lib/shared/repositories/mock_korea_quest_repository.dart`
- Khi người dùng đang ở phiên khách, phương thức `getCurrentUser()` cập nhật trả về `AppUser` với `displayName` và avatar khởi tạo mang đúng tên khách để toàn bộ hệ thống (Header, Home, Profile, Passport) đồng bộ hiển thị.

---

## 3. Giao diện người dùng & Luồng tương tác

### 3.1. Điểm bắt đầu (Entry Points)
1. **Tại Landing Page (`lib/features/landing/presentation/pages/landing_page.dart`):**
   - Trong khối Hero Section, cạnh nút *"Bắt đầu hành trình"*, thêm nút *"Chơi nhanh (Khách)"* (`SecondaryButton` kèm icon `Icons.person_pin_circle_outlined`).
   - Khi bấm, hiển thị `GuestNameDialog`.
2. **Tại Auth Page (`lib/features/auth/presentation/pages/auth_page.dart`):**
   - Thêm nút / liên kết *"Trải nghiệm ngay với tư cách Khách"*.
   - Cho phép nhập tên trực tiếp hoặc mở `GuestNameDialog` để chuyển ngay sang chế độ khách.

### 3.2. Hộp thoại nhập tên khách (`GuestNameDialog`)
- **Tệp:** `lib/features/auth/presentation/widgets/guest_name_dialog.dart`
- **Cấu trúc:**
  - Header: Tiêu đề mang phong cách KoreaQuest, icon đại diện.
  - Body: Ô nhập văn bản `AppTextField` cho Tên hiển thị (placeholder: *"Ví dụ: Minh Anh, Hans..."*), kiểm tra hợp lệ độ dài 1-40 ký tự.
  - Actions:
    - Nút phụ: *"Để sau"* / *"Hủy"*
    - Nút chính: *"Vào khám phá ngay"* (PrimaryButton)
  - Sau khi submit thành công: Đăng nhập khách qua `ref.read(authRepositoryProvider).signInAsGuest(name: ...)` và chuyển hướng sang `/explore`.

### 3.3. Hiển thị Header cho khách (`AppHeader`)
- **Tệp:** `lib/design_system/components/app_structure.dart`
- Khi `isGuest == true`:
  - Hiển thị tên khách cùng huy hiệu nhỏ `[Khách]` (hoặc `Guest`).
  - Menu tài khoản hiển thị tùy chọn nổi bật: *"Đăng ký tài khoản chính thức"* để khách có thể chủ động nâng cấp bất kỳ lúc nào.

### 3.4. Hộp thoại vinh danh & Gợi ý đăng ký sau khám phá (`GuestRegistrationPromptDialog`)
- **Tệp:** `lib/features/explore/presentation/widgets/guest_registration_prompt_dialog.dart`
- **Kích hoạt:**
  - Trong `PublishedLocationPage` / `LocationContentView` khi người dùng ở Stage 9 (chặng cuối cùng) bấm nút hoàn thành / trở về bản đồ.
  - Hoặc trong `JourneyPage` khi ở chặng `JourneyStage.summary` bấm kết thúc.
  - Điều kiện kích hoạt: `authUser?.isGuest == true`.
- **Nội dung hộp thoại:**
  - Biểu tượng vinh danh rực rỡ mang màu sắc Hàn Quốc (Cup / Star / Stamp).
  - Tiêu đề: *"Chúc mừng [Tên khách] đã khám phá xong [Tên địa điểm]!"*
  - Mô tả: *"Bạn đã tích lũy được điểm XP và trải nghiệm tuyệt vời! Hãy tạo tài khoản chính thức để lưu lại vĩnh viễn tiến trình, huy hiệu và dấu mộc của bạn nhé."*
  - Nút chính: *"Đăng ký & Lưu tiến trình"*
    - Điều hướng sang `/register?name=[Tên khách]`.
    - Form đăng ký tự động điền sẵn tên khách.
  - Nút phụ: *"Để sau / Tiếp tục khám phá"*
    - Đóng dialog và điều hướng người dùng về `/explore`.

---

## 4. Xử lý ngoại lệ & Đa ngôn ngữ

### 4.1. Validation & Ngoại lệ
- Tên khách không được để trống hoặc chỉ có khoảng trắng.
- Tối đa 40 ký tự.
- Xử lý mượt mà khi người dùng đóng dialog mà không làm gián đoạn luồng trước đó.

### 4.2. Chuỗi ký tự đa ngôn ngữ
- Đồng bộ các chuỗi vào `lib/l10n/` (`app_en.arb`, `app_ko.arb`, `app_strings.dart`):
  - `playAsGuest`
  - `guestNamePrompt`
  - `guestNameRequired`
  - `guestBadge`
  - `guestCompletionCelebrationTitle`
  - `guestCompletionPromptMessage`
  - `registerAndSaveProgress`
  - `continueAsGuest`

---

## 5. Chiến lược kiểm thử & Xác minh

1. **Unit Test:**
   - Kiểm tra `MockAuthRepository.signInAsGuest`:
     - Tên rỗng -> ném lỗi `AuthException`.
     - Tên hợp lệ -> phát ra stream `AuthUser` với `isGuest == true`.
     - Đăng ký sau khi là khách -> chuyển `isGuest == false` và giữ nguyên trạng thái phiên.
2. **Widget Test:**
   - Kiểm tra `GuestNameDialog`: validation, nhập tên, kích hoạt callback.
   - Kiểm tra `GuestRegistrationPromptDialog`: hiển thị tên địa điểm, bấm nút đăng ký điều hướng đúng trang.
3. **Tuân thủ quy chuẩn dự án (AGENTS.md):**
   - Chạy đủ 4 lệnh kiểm tra:
     1. `dart format .`
     2. `flutter analyze`
     3. `flutter test`
     4. `flutter build web`
   - Cập nhật tài liệu `docs/DATABASE_MODEL_DISCUSSION.md` phần Domain Model.
