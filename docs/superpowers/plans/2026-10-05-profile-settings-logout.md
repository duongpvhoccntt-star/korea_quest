# Profile, Settings & Logout Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement full-featured Profile editing with device & cultural avatar selection, modern Grouped Cards Settings page with password change dialog, learning progress reset, and universal Logout confirmation across Header, Profile, and Settings.

**Architecture:** Extend core domain models (`AppUser`) with avatar and bio fields, update repository interfaces and mock implementations with reactive state updates, introduce a clean `ChangePasswordDialog` and `AvatarSelectorModal`, modernize `SettingsPage` with grouped cards using design system tokens, and wire up `AppHeader` avatar dropdown menu with confirmation-guarded sign out.

**Tech Stack:** Flutter 3.x, Dart 3.12+, Flutter Riverpod 3.0+, GoRouter 17+, `file_picker` 10.3+.

## Global Constraints

- Material 3 tokens from `lib/design_system/` (AppColors, AppRadius, AppSpacing, AppShadows) only; no hardcoded styling.
- All code changes must preserve clean build and pass: `dart format .`, `flutter analyze`, `flutter test`, `flutter build web`.
- Module ownership adheres to Phạm Văn Dương (`features/auth`, `features/profile`, `features/settings`, `shared/repositories`).
- Maintain full backwards compatibility for tests and existing screen layouts.

---

### Task 1: Domain & Model Enhancement (`AppUser` & `UserAvatar`)

**Files:**
- Modify: `lib/shared/models/domain_models.dart:9-24`
- Modify: `lib/design_system/components/progress_components.dart:6-25`
- Test: `test/shared/models/domain_models_test.dart`
- Test: `test/design_system/user_avatar_test.dart`

**Interfaces:**
- Consumes: Dart typed data (`Uint8List`).
- Produces:
  ```dart
  class AppUser {
    const AppUser({
      required this.id,
      required this.fullName,
      required this.displayName,
      required this.handle,
      required this.joinedDate,
      this.bio,
      this.avatarPreset,
      this.avatarBytes,
    });
    final String id;
    final String fullName;
    final String displayName;
    final String handle;
    final DateTime joinedDate;
    final String? bio;
    final String? avatarPreset;
    final Uint8List? avatarBytes;

    AppUser copyWith({...});
  }

  class UserAvatar extends StatelessWidget {
    const UserAvatar({
      required this.displayName,
      super.key,
      this.radius = 22,
      this.avatarPreset,
      this.avatarBytes,
    });
    ...
  }
  ```

- [ ] **Step 1: Write failing tests for AppUser and UserAvatar**

Create `test/shared/models/domain_models_test.dart`:
```dart
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:korea_quest/shared/models/domain_models.dart';

void main() {
  test('AppUser supports bio, avatarPreset, avatarBytes and copyWith', () {
    final bytes = Uint8List.fromList([1, 2, 3]);
    final user = AppUser(
      id: 'u1',
      fullName: 'Phạm Văn Dương',
      displayName: 'Dương',
      handle: 'duong.kq',
      joinedDate: DateTime(2026, 8, 2),
      bio: 'Người khám phá Seoul',
      avatarPreset: 'hanbok',
      avatarBytes: bytes,
    );

    expect(user.bio, 'Người khám phá Seoul');
    expect(user.avatarPreset, 'hanbok');
    expect(user.avatarBytes, bytes);

    final updated = user.copyWith(
      displayName: 'Dương Phạm',
      bio: 'Yêu văn hóa Hàn',
      avatarPreset: 'seoul',
    );
    expect(updated.displayName, 'Dương Phạm');
    expect(updated.bio, 'Yêu văn hóa Hàn');
    expect(updated.avatarPreset, 'seoul');
    expect(updated.fullName, 'Phạm Văn Dương');
  });
}
```

Create `test/design_system/user_avatar_test.dart`:
```dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:korea_quest/design_system/components/progress_components.dart';

void main() {
  testWidgets('UserAvatar displays initial character fallback', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: UserAvatar(displayName: 'Dương')),
      ),
    );
    expect(find.text('D'), findsOneWidget);
  });

  testWidgets('UserAvatar displays preset emoji when avatarPreset is provided', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: UserAvatar(displayName: 'Dương', avatarPreset: 'hanbok'),
        ),
      ),
    );
    expect(find.text('🎎'), findsOneWidget);
  });

  testWidgets('UserAvatar displays memory image when avatarBytes is provided', (tester) async {
    // 1x1 transparent png bytes
    final pngBytes = Uint8List.fromList([
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
      0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
      0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
      0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
      0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
      0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
    ]);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UserAvatar(displayName: 'Dương', avatarBytes: pngBytes),
        ),
      ),
    );
    expect(find.byType(CircleAvatar), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run tests to verify failure**

Run: `flutter test test/shared/models/domain_models_test.dart test/design_system/user_avatar_test.dart`
Expected: Compilation errors or test failures due to missing parameters and `copyWith`.

- [ ] **Step 3: Update AppUser in `lib/shared/models/domain_models.dart`**

Add `bio`, `avatarPreset`, `avatarBytes`, and `copyWith` method to `AppUser`.
Ensure typed import `import 'dart:typed_data';` is included.

- [ ] **Step 4: Update UserAvatar in `lib/design_system/components/progress_components.dart`**

Add preset map (e.g. `hanbok`: '🎎', `seoul`: '🗼', `haechi`: '🦁', `scholar`: '📜', `foodie`: '🍲', `kpop`: '🎵') and rendering logic for memory image and preset emoji in `UserAvatar`.

- [ ] **Step 5: Run tests to verify they pass**

Run: `flutter test test/shared/models/domain_models_test.dart test/design_system/user_avatar_test.dart`
Expected: ALL PASS.

---

### Task 2: Repository & Auth Methods (`changePassword`, `updateUserProfile`, `resetUserProgress`)

**Files:**
- Modify: `lib/features/auth/domain/auth_repository.dart`
- Modify: `lib/features/auth/data/mock_auth_repository.dart`
- Modify: `lib/features/auth/data/supabase_auth_repository.dart`
- Modify: `lib/shared/repositories/korea_quest_repository.dart`
- Modify: `lib/shared/repositories/mock_korea_quest_repository.dart`
- Modify: `lib/shared/repositories/supabase_korea_quest_repository.dart`
- Test: `test/features/auth/auth_password_test.dart`
- Test: `test/shared/repositories/korea_quest_repository_test.dart`

**Interfaces:**
- AuthRepository:
  ```dart
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
  ```
- KoreaQuestRepository:
  ```dart
  Future<AppUser> updateUserProfile({
    String? fullName,
    String? displayName,
    String? bio,
    String? avatarPreset,
    Uint8List? avatarBytes,
  });
  Future<void> resetUserProgress();
  ```

- [ ] **Step 1: Write failing tests for repository methods**

Create `test/features/auth/auth_password_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:korea_quest/features/auth/data/mock_auth_repository.dart';
import 'package:korea_quest/features/auth/domain/auth_models.dart';

void main() {
  late MockAuthRepository repo;

  setUp(() {
    repo = MockAuthRepository();
  });

  test('changePassword fails with incorrect current password', () async {
    await repo.signIn(identity: 'duong@example.com', password: 'user123');
    expect(
      () => repo.changePassword(
        currentPassword: 'wrongpassword',
        newPassword: 'newpassword123',
      ),
      throwsA(isA<AuthException>()),
    );
  });

  test('changePassword fails if new password is too short', () async {
    await repo.signIn(identity: 'duong@example.com', password: 'user123');
    expect(
      () => repo.changePassword(
        currentPassword: 'user123',
        newPassword: 'short',
      ),
      throwsA(isA<AuthException>()),
    );
  });

  test('changePassword succeeds and allows login with new password', () async {
    await repo.signIn(identity: 'duong@example.com', password: 'user123');
    await repo.changePassword(
      currentPassword: 'user123',
      newPassword: 'newuser1234',
    );
    await repo.signOut();
    final user = await repo.signIn(
      identity: 'duong@example.com',
      password: 'newuser1234',
    );
    expect(user.displayName, 'Phạm Văn Dương');
  });
}
```

Create `test/shared/repositories/korea_quest_repository_test.dart`:
```dart
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:korea_quest/shared/models/domain_models.dart';
import 'package:korea_quest/shared/repositories/mock_korea_quest_repository.dart';

void main() {
  late MockKoreaQuestRepository repo;

  setUp(() {
    repo = MockKoreaQuestRepository();
  });

  test('updateUserProfile updates currentUser', () async {
    final initial = await repo.getCurrentUser();
    expect(initial.displayName, 'Dương');

    final updated = await repo.updateUserProfile(
      displayName: 'Dương Pro',
      bio: 'Khám phá Seoul cổ kính',
      avatarPreset: 'seoul',
    );
    expect(updated.displayName, 'Dương Pro');
    expect(updated.bio, 'Khám phá Seoul cổ kính');
    expect(updated.avatarPreset, 'seoul');

    final fetched = await repo.getCurrentUser();
    expect(fetched.displayName, 'Dương Pro');
  });

  test('resetUserProgress resets level, xp, and locks locations', () async {
    await repo.resetUserProgress();
    final progress = await repo.getUserProgress();
    expect(progress.level, 1);
    expect(progress.currentXp, 0);

    final locations = await repo.getLocations();
    expect(locations.first.status, LocationStatus.available);
    for (var i = 1; i < locations.length; i++) {
      expect(locations[i].status, LocationStatus.locked);
    }
  });
}
```

- [ ] **Step 2: Run tests to verify failure**

Run: `flutter test test/features/auth/auth_password_test.dart test/shared/repositories/korea_quest_repository_test.dart`
Expected: FAIL (missing methods).

- [ ] **Step 3: Implement methods in AuthRepository & MockAuthRepository & SupabaseAuthRepository**

In `lib/features/auth/domain/auth_repository.dart`: add `Future<void> changePassword({required String currentPassword, required String newPassword});`.
In `lib/features/auth/data/mock_auth_repository.dart`: check `_currentUser`, match current password, validate length $\ge 8$, update `_accounts`.
In `lib/features/auth/data/supabase_auth_repository.dart`: implement via Supabase auth or fallback.

- [ ] **Step 4: Implement methods in KoreaQuestRepository & MockKoreaQuestRepository & SupabaseKoreaQuestRepository**

In `lib/shared/repositories/korea_quest_repository.dart`: add `updateUserProfile` and `resetUserProgress`.
In `lib/shared/repositories/mock_korea_quest_repository.dart`: convert static state to mutable instance state and implement `updateUserProfile` and `resetUserProgress`.
In `lib/shared/repositories/supabase_korea_quest_repository.dart`: delegate both to `_fallback`.

- [ ] **Step 5: Run tests to verify they pass**

Run: `flutter test test/features/auth/auth_password_test.dart test/shared/repositories/korea_quest_repository_test.dart`
Expected: ALL PASS.

---

### Task 3: Change Password Dialog & Modern Grouped Cards Settings Page

**Files:**
- Create: `lib/features/settings/presentation/widgets/change_password_dialog.dart`
- Modify: `lib/features/settings/presentation/pages/settings_page.dart`
- Test: `test/features/settings/settings_page_test.dart`

**Interfaces:**
- `ChangePasswordDialog.show(BuildContext context)`: Opens modal with current password, new password, confirm password, validation, and error display.
- `SettingsPage`: Grouped cards using Design Tokens:
  - Card 1: Tài khoản & Bảo mật (email, role badge, Đổi mật khẩu button)
  - Card 2: Tùy chọn trải nghiệm (Switch notifications, reducedMotion)
  - Card 3: Dữ liệu & Tiến trình (Clear cache toast, Reset progress button with confirmation dialog)
  - Card 4: Đăng xuất (Large red danger button with confirmation dialog)

- [ ] **Step 1: Write widget test for SettingsPage and ChangePasswordDialog**

Create `test/features/settings/settings_page_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:korea_quest/features/auth/presentation/providers/auth_providers.dart';
import 'package:korea_quest/features/settings/presentation/pages/settings_page.dart';
import 'package:korea_quest/features/settings/presentation/widgets/change_password_dialog.dart';

void main() {
  testWidgets('SettingsPage renders all 4 grouped cards', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: SettingsPage()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tài khoản & Bảo mật'), findsOneWidget);
    expect(find.text('Tùy chọn trải nghiệm'), findsOneWidget);
    expect(find.text('Quản lý dữ liệu & Lưu trữ'), findsOneWidget);
    expect(find.text('Đăng xuất tài khoản'), findsOneWidget);
    expect(find.text('Đổi mật khẩu'), findsOneWidget);
    expect(find.text('Đặt lại tiến trình học tập'), findsOneWidget);
  });

  testWidgets('ChangePasswordDialog validates input fields', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => ChangePasswordDialog.show(context),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Đổi mật khẩu'), findsOneWidget);
    // Tap confirm without typing
    await tester.tap(find.text('Cập nhật mật khẩu'));
    await tester.pumpAndSettle();

    expect(find.text('Vui lòng điền đầy đủ các thông tin.'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify failure**

Run: `flutter test test/features/settings/settings_page_test.dart`
Expected: FAIL (missing `ChangePasswordDialog` and new cards).

- [ ] **Step 3: Implement `ChangePasswordDialog`**

In `lib/features/settings/presentation/widgets/change_password_dialog.dart`:
- Controllers for currentPassword, newPassword, confirmPassword.
- Toggle obscure text icons.
- Validation: not empty, newPassword >= 8 chars, newPassword == confirmPassword.
- Calls `ref.read(authRepositoryProvider).changePassword(...)`.
- Shows inline error or toast on error/success.

- [ ] **Step 4: Implement modernized `SettingsPage`**

In `lib/features/settings/presentation/pages/settings_page.dart`:
- Structure into clean grouped cards:
  - Account & Security: shows current user identity and button to launch `ChangePasswordDialog.show(context)`.
  - Experience Preferences: Switches for notifications and reduced motion.
  - Data & Progress: Clear temporary cache button, Reset learning progress button (with `ConfirmationDialog`, calling `koreaQuestRepository.resetUserProgress()`, invalidating `currentUserProvider`, `userProgressProvider`, `locationsProvider`, `passportStampsProvider`).
  - Account: Sign out button (with `ConfirmationDialog`, calling `ref.read(authRepositoryProvider).signOut()`, showing Toast, and navigating `context.go('/login')`).

- [ ] **Step 5: Run test to verify it passes**

Run: `flutter test test/features/settings/settings_page_test.dart`
Expected: ALL PASS.

---

### Task 4: Avatar Selection & Profile Edit Form

**Files:**
- Create: `lib/features/profile/presentation/widgets/avatar_selector_modal.dart`
- Modify: `lib/features/profile/presentation/pages/profile_page.dart`
- Test: `test/features/profile/profile_page_test.dart`

**Interfaces:**
- `AvatarSelectorModal.show(BuildContext context, {String? currentPreset, Uint8List? currentBytes})`:
  - Returns `({String? preset, Uint8List? bytes})?`.
  - Button "Tải ảnh từ máy" via `FilePicker.platform.pickFiles(type: FileType.image, withData: true)`.
  - 6 cultural preset avatars:
    - 🎎 Hanbok Explorer (`hanbok`)
    - 🗼 Seoul Traveler (`seoul`)
    - 🦁 Haechi Guardian (`haechi`)
    - 📜 Joseon Scholar (`scholar`)
    - 🍲 K-Foodie (`foodie`)
    - 🎵 K-Pop Fan (`kpop`)
- `ProfilePage`:
  - `_ProfileHero`: shows avatar, user bio, level, streak, with actions: Edit Profile, Settings (`/settings`), Logout (with confirmation).
  - `_EditProfileForm`: stateful form with TextEditingControllers initialized from `user.fullName`, `user.displayName`, `user.bio`. Allows changing avatar via `AvatarSelectorModal`. Saves updates to repository, invalidates `currentUserProvider`, toasts success, and navigates back to `/profile`.

- [ ] **Step 1: Write tests for profile page and avatar selection**

Create `test/features/profile/profile_page_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:korea_quest/features/profile/presentation/pages/profile_page.dart';

void main() {
  testWidgets('ProfilePage view mode renders hero and action buttons', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: ProfilePage()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Chỉnh sửa hồ sơ'), findsWidgets);
    expect(find.text('Cài đặt'), findsOneWidget);
    expect(find.text('Đăng xuất'), findsOneWidget);
  });

  testWidgets('ProfilePage edit mode renders editable text fields and avatar picker trigger', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: ProfilePage(isEditing: true)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Họ và tên'), findsOneWidget);
    expect(find.text('Tên hiển thị'), findsOneWidget);
    expect(find.text('Giới thiệu'), findsOneWidget);
    expect(find.text('Đổi ảnh đại diện'), findsOneWidget);
    expect(find.text('Lưu thay đổi'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify failure**

Run: `flutter test test/features/profile/profile_page_test.dart`
Expected: FAIL (missing avatar picker trigger and action buttons).

- [ ] **Step 3: Implement `AvatarSelectorModal`**

In `lib/features/profile/presentation/widgets/avatar_selector_modal.dart`:
- Modal bottom sheet or Dialog.
- Option 1: File picker button ("Tải ảnh từ máy") using `FilePicker.platform.pickFiles(type: FileType.image, withData: true)`. If picked, returns bytes.
- Option 2: Cultural presets grid/chips (6 items with emoji, name, and subtitle). If tapped, returns preset key.

- [ ] **Step 4: Update `_ProfileHero` and `_EditProfileForm` in `profile_page.dart`**

In `lib/features/profile/presentation/pages/profile_page.dart`:
- In `_ProfileHero`: Pass `user.avatarPreset` and `user.avatarBytes` to `UserAvatar`. Display `user.bio` if not null/empty. Add action buttons: "Chỉnh sửa hồ sơ", "Cài đặt" (`context.go('/settings')`), and "Đăng xuất" (calls `ConfirmationDialog` -> `signOut()` -> `context.go('/login')`).
- In `_EditProfileForm`: Convert to `ConsumerStatefulWidget`. Initialize controllers with `user.fullName`, `user.displayName`, `user.bio`. Hold temporary `selectedPreset` and `selectedBytes`. Tap on "Đổi ảnh đại diện" triggers `AvatarSelectorModal`. On "Lưu thay đổi": calls `ref.read(koreaQuestRepositoryProvider).updateUserProfile(...)`, invalidates `currentUserProvider`, shows toast "Đã cập nhật hồ sơ thành công", and redirects `context.go('/profile')`.

- [ ] **Step 5: Run test to verify it passes**

Run: `flutter test test/features/profile/profile_page_test.dart`
Expected: ALL PASS.

---

### Task 5: Header Avatar Dropdown Menu & Global Logout Flow

**Files:**
- Modify: `lib/design_system/components/app_structure.dart:150-186`
- Test: `test/design_system/app_header_menu_test.dart`

**Interfaces:**
- In `AppHeader`:
  - When logged in, wrap `UserAvatar` in `PopupMenuButton`:
    - Header item (disabled): Display Name + Level/Role badge
    - Item 1: `Icons.person_outline_rounded` - "Hồ sơ của tôi" (`/profile`)
    - Item 2: `Icons.settings_outlined` - "Cài đặt" (`/settings`)
    - Divider
    - Item 3: `Icons.logout_rounded` - "Đăng xuất" (colored `AppColors.koreanRed`)
  - Tapping "Đăng xuất":
    - Calls `ConfirmationDialog.show(context, title: 'Đăng xuất khỏi KoreaQuest?', message: 'Bạn có chắc chắn muốn đăng xuất?', confirmLabel: 'Đăng xuất')`
    - If confirmed: `await ref.read(authRepositoryProvider).signOut()`, show `AppToast.show(context, 'Đã đăng xuất thành công')`, and `context.go('/login')`.
  - In mobile menu: include "Đăng xuất" for logged-in members.

- [ ] **Step 1: Write widget test for AppHeader popup menu**

Create `test/design_system/app_header_menu_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:korea_quest/design_system/components/app_structure.dart';
import 'package:korea_quest/features/auth/domain/auth_models.dart';
import 'package:korea_quest/features/auth/presentation/providers/auth_providers.dart';

void main() {
  testWidgets('AppHeader displays popup menu for member avatar', (tester) async {
    final mockUser = const AuthUser(
      id: 'u1',
      usernameOrEmail: 'duong@example.com',
      displayName: 'Dương',
      role: UserRole.user,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authUserStreamProvider.overrideWith((ref) => Stream.value(mockUser)),
        ],
        child: const MaterialApp(
          home: Scaffold(
            appBar: AppHeader(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final avatar = find.byType(UserAvatar);
    expect(avatar, findsOneWidget);

    await tester.tap(avatar);
    await tester.pumpAndSettle();

    expect(find.text('Hồ sơ của tôi'), findsOneWidget);
    expect(find.text('Cài đặt'), findsOneWidget);
    expect(find.text('Đăng xuất'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify failure**

Run: `flutter test test/design_system/app_header_menu_test.dart`
Expected: FAIL (tapping avatar does not open menu).

- [ ] **Step 3: Implement PopupMenu in `AppHeader`**

In `lib/design_system/components/app_structure.dart`:
- Replace the static `UserAvatar` with a `PopupMenuButton` containing user info, Hồ sơ, Cài đặt, and Đăng xuất.
- Add confirmation dialog and signOut flow on logout selection.
- Update mobile drawer/menu to also provide "Đăng xuất".

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/design_system/app_header_menu_test.dart`
Expected: ALL PASS.

---

### Task 6: Full Verification & Integration Quality Check

**Files:**
- Entire repository

- [ ] **Step 1: Format codebase**
Run: `dart format .`
Expected: All files formatted without syntax issues.

- [ ] **Step 2: Analyze codebase**
Run: `flutter analyze`
Expected: `No issues found!`.

- [ ] **Step 3: Run entire test suite**
Run: `flutter test`
Expected: All tests pass (including existing 69 tests + new tests).

- [ ] **Step 4: Build web bundle**
Run: `flutter build web`
Expected: Web compilation successful.
