# Thiết Kế Trang Đăng Nhập / Đăng Ký & Tài Khoản Test Admin

## 1. Mục Tiêu
Cung cấp màn hình Đăng nhập & Đăng ký hoàn chỉnh, thân thiện và linh hoạt cho KoreaQuest, đồng thời tích hợp sẵn tài khoản thử nghiệm **Admin (`admin` / `admin123`)** và **Người dùng (`duong@example.com` / `user123`)** giúp lập trình viên và kiểm thử viên có thể:
1. Đăng nhập / Đăng ký người dùng bình thường để trải nghiệm luồng khám phá văn hóa (`/home`).
2. Đăng nhập nhanh với quyền Quản trị viên (`admin`) bằng 1-chạm hoặc nhập thông tin, tự động điều hướng sang trang quản trị dữ liệu (`/admin`).
3. Đảm bảo trang `/admin` hoạt động trơn tru với `DemoAdminRepository` khi chưa cấu hình Supabase backend thật.

---

## 2. Phạm Vi & Quyền Sở Hữu Module (Ownership)
- **Module chính:** `lib/features/auth/` (do **Phạm Văn Dương** phụ trách theo [`docs/TEAM_OWNERSHIP.md`](file:///c:/Users/ADMIN/korea_quest/docs/TEAM_OWNERSHIP.md)).
- **Module liên kết:** 
  - `lib/features/admin/`: Kết nối phiên đăng nhập admin giữa `auth` và `adminRepositoryProvider`.
  - `lib/app/app_config.dart` & `lib/features/admin/presentation/providers/admin_providers.dart`: Cho phép dự phòng (fallback) tự động sang `DemoAdminRepository` khi chưa có cấu hình Supabase runtime để việc test trang admin không bị chặn.
  - `lib/design_system/`: Sử dụng toàn bộ token về màu (`AppColors`), khoảng cách (`AppSpacing`), bo góc (`AppRadius`), nút (`AppButtons`), input (`AppFields`).

---

## 3. Kiến Trúc Dữ Liệu & State Management

### 3.1. Mô hình vai trò người dùng (Domain Model)
Tạo file `lib/features/auth/domain/auth_models.dart`:
```dart
enum UserRole { user, admin }

class AuthUser {
  const AuthUser({
    required this.id,
    required this.usernameOrEmail,
    required this.displayName,
    required this.role,
  });

  final String id;
  final String usernameOrEmail;
  final String displayName;
  final UserRole role;

  bool get isAdmin => role == UserRole.admin;
}
```

### 3.2. Repository & Quản lý phiên (Data Layer)
Tạo `lib/features/auth/domain/auth_repository.dart` và `lib/features/auth/data/mock_auth_repository.dart`:
- Lưu danh sách tài khoản hợp lệ trong bộ nhớ:
  - `admin` (mật khẩu `admin123`, vai trò `UserRole.admin`)
  - `duong@example.com` (mật khẩu `user123`, vai trò `UserRole.user`)
  - Cho phép thêm tài khoản mới khi thực hiện `register(...)`.
- Phương thức:
  - `Future<AuthUser> signIn({required String identity, required String password})`
  - `Future<AuthUser> register({required String fullName, required String displayName, required String email, required String password})`
  - `Future<void> signOut()`
  - `Stream<AuthUser?> watchCurrentUser()`

### 3.3. Tích hợp với Admin Module
Khi người dùng đăng nhập với vai trò `UserRole.admin`:
- Đồng thời gọi `ref.read(adminRepositoryProvider).signIn(email: 'admin', password: 'admin123')`.
- Cập nhật `adminAccessProvider` và điều hướng ngay lập tức sang `/admin`.
- Khi người dùng đăng nhập tài khoản thường: điều hướng sang `/home`.

---

## 4. Giao Diện Người Dùng (`AuthPage`)

### 4.1. Cấu trúc trang
File: `lib/features/auth/presentation/pages/auth_page.dart`
- **Bộ chuyển đổi chế độ (Segmented Control / Tabs):**
  - Tab 1: **Đăng nhập** (`/login`)
  - Tab 2: **Đăng ký** (`/register`)
- **Khối nhập liệu:**
  - *Chế độ Đăng ký:* Trường Họ và tên, Tên hiển thị, Email/Tên đăng nhập, Mật khẩu.
  - *Chế độ Đăng nhập:* Trường Email/Tên đăng nhập, Mật khẩu.
- **Khối Tài khoản thử nghiệm (Quick Demo Credentials):**
  - Đặt dưới dạng thẻ tiện ích (Callout Card) với giao diện trang nhã, viền nét đứt hoặc màu nền nhẹ (`AppColors.sandLight` / `AppColors.paper`).
  - Gồm 2 nút 1-chạm:
    1. **"Dùng thử Admin" (admin / admin123)**: Tự động điền tài khoản admin và đăng nhập thẳng vào `/admin`.
    2. **"Dùng thử Học viên" (duong@example.com)**: Tự động điền tài khoản học viên và đăng nhập thẳng vào `/home`.
- **Nút hành động chính (PrimaryButton):**
  - Đăng nhập / Đăng ký với hiệu ứng loading spinner khi đang xử lý.
  - Hiển thị thông báo lỗi rõ ràng qua `AppToast` nếu sai mật khẩu hoặc thiếu trường thông tin.

---

## 5. Cải Tiến Cấu Hình Admin Backend (`AppConfig`)
Trong môi trường phát triển cục bộ và kiểm thử web:
- Cập nhật `AppConfig.hasAdminBackend` và `adminRepositoryProvider`: nếu không có cấu hình Supabase, mặc định kích hoạt `DemoAdminRepository` thay vì báo lỗi thiếu biến môi trường, đảm bảo việc kiểm thử trang quản trị diễn ra liền mạch và ổn định 100%.

---

## 6. Kế Hoạch Kiểm Thử (Verification Plan)
1. **Unit Test (`test/features/auth/auth_repository_test.dart`)**:
   - Kiểm tra đăng nhập tài khoản `admin` trả về role `admin`.
   - Kiểm tra đăng nhập sai mật khẩu ném lỗi hợp lệ.
   - Kiểm tra đăng ký tài khoản mới và đăng nhập lại thành công.
2. **Widget Test (`test/features/auth/auth_page_test.dart`)**:
   - Kiểm tra hiển thị nút đăng nhập nhanh Admin và Học viên.
   - Kiểm tra nhấn nút "Dùng thử Admin" điều hướng đến `/admin`.
3. **Bộ lệnh kiểm tra bắt buộc của dự án**:
   - `dart format .`
   - `flutter analyze`
   - `flutter test`
   - `flutter build web`
