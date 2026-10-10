# Design Spec: Auth Guest Mode Guard & Home Page Removal

**Ngày tạo**: 2026-10-10
**Tác giả**: Antigravity Assistant (Pair-programming với User)
**Trạng thái**: Chờ duyệt (Draft / User Review)

---

## 1. Tổng quan (Overview)

Theo yêu cầu từ phía người dùng:
1. **Loại bỏ Trang chủ (`/home`)**: Do ứng dụng đã có trang Khám phá (`/explore`) đóng vai trò là Hub chính để tìm kiếm địa điểm, xem tiến trình và học tập.
2. **Khóa màn hình & Quản lý Chế độ khách (Guest Mode)**:
   - Khi ở màn hình Đăng nhập / Đăng ký hoặc khi chưa đăng nhập, người dùng **không thể** truy cập tự do vào các màn hình ứng dụng (như Khám phá, Hộ chiếu, Thành tích, Cá nhân, Settings).
   - Màn hình bị khóa cho đến khi người dùng thực hiện một trong hai hành động:
     - **Đăng nhập / Đăng ký tài khoản thành công**.
     - **Chọn nút "Tiếp tục với tư cách Khách" (Guest Mode)** trên màn hình Đăng nhập / Đăng ký hoặc Landing page.

---

## 2. Thiết kế Kiến trúc & Luồng Dữ liệu (Architecture & Data Flow)

### 2.1 Quản lý trạng thái Guest Mode (Riverpod)

- Thêm `guestModeNotifierProvider` kiểu `StateNotifier<bool>` (hoặc `Notifier<bool>`) trong `lib/features/auth/presentation/providers/auth_providers.dart`:
  - Trạng thái ban đầu: `false`.
  - Phương thức `enableGuestMode()`: Đặt trạng thái thành `true`.
  - Phương thức `disableGuestMode()`: Đặt trạng thái thành `false`.
- Khi người dùng đăng nhập (`signIn`), đăng ký (`register`), hoặc đăng xuất (`signOut`), `guestModeProvider` tự động được reset về `false`.

### 2.2 Luồng điều hướng & Router Guard (`lib/app/app_router.dart`)

Cập nhật hàm `redirect` trong `GoRouter`:

```dart
final authUser = ref.read(authRepositoryProvider).currentUser;
final isGuest = authUser == null;
final isGuestMode = ref.read(guestModeNotifierProvider);

// Danh sách các đường dẫn công khai hoàn toàn khi chưa chọn Guest Mode
const authPaths = {
  '/',
  '/login',
  '/register',
  '/forgot-password',
  '/admin',
};

if (isGuest) {
  if (!isGuestMode) {
    // Chưa đăng nhập VÀ chưa chọn Chế độ khách -> Khóa mọi màn hình khác
    if (!authPaths.contains(state.uri.path)) {
      return Uri(
        path: '/login',
        queryParameters: {'redirect': state.uri.toString()},
      ).toString();
    }
  } else {
    // Chưa đăng nhập NHƯNG đã chọn Chế độ khách -> Cho phép /explore & xem địa điểm
    final allowedGuestPaths = state.uri.path == '/explore' ||
        state.uri.path.startsWith('/locations/') ||
        state.uri.path.startsWith('/journey/') ||
        state.uri.path.startsWith('/passport/shared/') ||
        authPaths.contains(state.uri.path);

    if (!allowedGuestPaths) {
      // Nếu cố vào /passport, /profile, /achievements -> Chuyển về /login để yêu cầu tạo tài khoản
      return Uri(
        path: '/login',
        queryParameters: {'redirect': state.uri.toString()},
      ).toString();
    }
  }
}
```

- Cập nhật `appRouterProvider` lắng nghe sự thay đổi của `guestModeNotifierProvider`:
  ```dart
  ref.listen(guestModeNotifierProvider, (_, __) => router.refresh());
  ```

---

## 3. Loại bỏ Trang chủ (`/home`)

1. **Xóa file & Route**:
   - Xóa `lib/features/home/presentation/pages/home_page.dart` và thư mục `lib/features/home/`.
   - Xóa `AppRouteNames.home` và `GoRoute(path: '/home', ...)` khỏi `app_router.dart`.

2. **Cập nhật các liên kết tham chiếu (Redirect & Navigation)**:
   - Sau khi Đăng nhập / Đăng ký thành công: Mặc định điều hướng về `/explore` (thay vì `/home`).
   - `AppHeader`:
     - Nhấp vào Brand Logo (`_BrandLockup`): Nếu đã đăng nhập hoặc ở Guest Mode -> chuyển về `/explore`; nếu chưa chọn Guest Mode -> chuyển về `/login` hoặc `/`.
     - Loại bỏ link "Trang chủ" (`strings.home`). Danh sách navigation link bắt đầu bằng "Khám phá" (`/explore`).
   - `AppFooter`: Thay thế tất cả các link hướng tới `/home` thành `/explore`.
   - `SystemStatePage`: Nút "Về trang chủ" (`strings.backHome`) điều hướng về `/explore`.

---

## 4. Giao diện Màn hình Auth & Chế độ Khách

1. **Nút "Tiếp tục làm Khách" (Continue as Guest)**:
   - Thêm nút nổi bật tại màn hình Auth (`AuthPage` trong `/login` và `/register`) bên dưới các tùy chọn đăng nhập / đăng ký:
     - Nhãn: "Khám phá với tư cách Khách" / "Tiếp tục làm Khách".
     - Icon: `Icons.explore_outlined`.
     - Xử lý khi nhấn: Gọi `ref.read(guestModeNotifierProvider.notifier).enableGuestMode()`, sau đó gọi `context.go('/explore')`.
   - Tại `LandingPage` (`/`): Nút "Bắt đầu hành trình" hoặc thêm nút phụ "Khám phá ngay (Guest Mode)" sẽ bật `guestModeProvider` và chuyển sang `/explore`.

2. **Trạng thái Header khi ở Màn hình Auth / Lock**:
   - Nếu `isGuest` và `!isGuestMode`: `AppHeader` chỉ hiển thị Logo, Bộ chọn Ngôn ngữ, Nút "Đăng nhập" và "Đăng ký" (ẩn các tab navigation `/explore`, `/passport`, `/achievements`, `/profile`).

---

## 5. Kế hoạch Kiểm thử & Xác minh (Verification Plan)

1. **Chạy `flutter analyze` & `flutter test`**:
   - Xác nhận không có lỗi biên dịch do thiếu `HomePage` hoặc `AppRouteNames.home`.
2. **Kiểm tra luồng Khóa màn hình (Auth Guard Test)**:
   - Mở ứng dụng lần đầu khi chưa đăng nhập. Nhập trực tiếp URL `/explore`, `/passport`, `/profile`.
   - **Kỳ vọng**: Luôn bị đẩy về màn hình `/login`.
3. **Kiểm tra luồng Chế độ khách (Guest Mode Test)**:
   - Tại màn `/login` hoặc `/register`, bấm nút "Khám phá với tư cách Khách".
   - **Kỳ vọng**: Màn hình mở ra `/explore`. Người dùng có thể xem danh sách địa điểm, thông tin địa điểm.
   - Thử bấm vào `/passport` hoặc `/profile` khi ở Guest Mode -> Chuyển hướng về `/login` kèm thông báo yêu cầu Đăng nhập.
4. **Kiểm tra luồng Đăng nhập / Đăng ký**:
   - Thực hiện Đăng nhập / Quick Login Student -> Hệ thống tự động chuyển về `/explore`.
   - Thực hiện Đăng xuất -> Hệ thống reset Guest Mode và đưa về `/login`.
