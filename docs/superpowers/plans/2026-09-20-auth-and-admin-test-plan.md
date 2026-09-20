# Trang Đăng Nhập / Đăng Ký & Tài Khoản Test Admin Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Xây dựng trang Đăng nhập / Đăng ký hoàn chỉnh, thân thiện có tích hợp sẵn tài khoản Admin thử nghiệm (`admin` / `admin123`) giúp kiểm thử trực tiếp trang Admin (`/admin`).

**Architecture:** Sử dụng kiến trúc Feature-First (`lib/features/auth/`), phân tách domain/data/presentation với Riverpod. Tích hợp phiên Admin với `adminRepositoryProvider` để tự động mở khóa trang `/admin` khi người dùng đăng nhập bằng quyền Admin.

**Tech Stack:** Flutter, Flutter Riverpod, GoRouter, KoreaQuest Design System.

## Global Constraints
- Tuân thủ ownership trong `docs/TEAM_OWNERSHIP.md` (`features/auth` - Phạm Văn Dương).
- Không hard-code màu sắc/spacing, sử dụng design tokens trong `lib/design_system/`.
- Không xóa/revert các thay đổi uncommitted hiện có.
- Tuân thủ quy trình kiểm tra bắt buộc trước khi bàn giao: `dart format .`, `flutter analyze`, `flutter test`, `flutter build web`.

---

### Task 1: Auth Domain & Repository (`lib/features/auth/`)

**Files:**
- Create: `lib/features/auth/domain/auth_models.dart`
- Create: `lib/features/auth/domain/auth_repository.dart`
- Create: `lib/features/auth/data/mock_auth_repository.dart`
- Create: `lib/features/auth/presentation/providers/auth_providers.dart`
- Test: `test/features/auth/auth_repository_test.dart`

**Interfaces:**
- Produces: `enum UserRole { user, admin }`, `class AuthUser`, `abstract class AuthRepository`, `authRepositoryProvider`, `authSessionProvider`.

- [ ] **Step 1: Write the failing test for MockAuthRepository**
- [ ] **Step 2: Run test to verify it fails**
- [ ] **Step 3: Implement Auth models, repository interface, and MockAuthRepository**
- [ ] **Step 4: Run test to verify it passes**

---

### Task 2: Cấu hình Fallback Demo Admin (`AppConfig` & `admin_providers.dart`)

**Files:**
- Modify: `lib/app/app_config.dart`
- Modify: `lib/features/admin/presentation/providers/admin_providers.dart`
- Test: `test/admin_route_test.dart`, `test/demo_admin_repository_test.dart`

**Interfaces:**
- Produces: `AppConfig.hasAdminBackend` cho phép chạy `DemoAdminRepository` khi chưa có biến môi trường Supabase.

- [ ] **Step 1: Cập nhật AppConfig và adminRepositoryProvider**
- [ ] **Step 2: Chạy kiểm thử hồi quy cho module Admin**

---

### Task 3: Giao diện AuthPage với Chuyển Đổi Tab & Tài Khoản Test Admin

**Files:**
- Modify: `lib/features/auth/presentation/pages/auth_page.dart`
- Test: `test/features/auth/auth_page_test.dart`

**Interfaces:**
- Consumes: `authRepositoryProvider`, `adminRepositoryProvider`, design tokens (`AppColors`, `AppSpacing`, `AppButtons`, `AppFields`).

- [ ] **Step 1: Viết widget test cho AuthPage với nút dùng thử Admin và Học viên**
- [ ] **Step 2: Cập nhật AuthPage với giao diện SegmentedButton, Quick Demo Credentials, và logic điều hướng**
- [ ] **Step 3: Chạy widget test để xác nhận passed**

---

### Task 4: Kiểm tra toàn diện & Bàn giao

- [ ] **Step 1: Chạy `dart format .`**
- [ ] **Step 2: Chạy `flutter analyze`**
- [ ] **Step 3: Chạy `flutter test`**
- [ ] **Step 4: Chạy `flutter build web`**
