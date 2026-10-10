# Guest Account & Post-Exploration Registration Prompt Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Allow users to explore KoreaQuest immediately as a guest by simply entering a display name (no password/email needed), and celebrate location completion with a Korean-styled prompt suggesting full registration while preserving their XP and progress.

**Architecture:** Extend `AuthUser` and `AuthRepository` with a first-class `isGuest` session. Provide rapid guest entry on both Landing Page and Auth Page via a dedicated `GuestNameDialog`. When completing the final stage of a location or journey summary, trigger `GuestRegistrationPromptDialog` for guest users, pre-populating the registration form and migrating progress upon sign-up.

**Tech Stack:** Flutter, Flutter Riverpod, GoRouter, Material 3 with KoreaQuest design tokens.

## Global Constraints
- Material 3 only.
- No hardcoded colors, spacing, or radius in UI screens — use tokens from `lib/design_system/`.
- Do not commit, push, or merge unless explicitly requested by the user.
- All 4 verification commands must pass: `dart format .`, `flutter analyze`, `flutter test`, `flutter build web`.
- Update `docs/DATABASE_MODEL_DISCUSSION.md` with domain model updates.

---

### Task 1: Domain Model & Auth Repository Interface

**Files:**
- Modify: `lib/features/auth/domain/auth_models.dart`
- Modify: `lib/features/auth/domain/auth_repository.dart`
- Test: `test/features/auth/mock_auth_repository_test.dart`

**Interfaces:**
- `AuthUser`: add field `final bool isGuest` (default `false`).
- `AuthRepository`: add `Future<AuthUser> signInAsGuest({required String name});`.

- [ ] **Step 1: Write the failing unit test**

Create/update `test/features/auth/mock_auth_repository_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:korea_quest/features/auth/data/mock_auth_repository.dart';
import 'package:korea_quest/features/auth/domain/auth_models.dart';

void main() {
  group('MockAuthRepository - Guest Account', () {
    late MockAuthRepository repo;

    setUp(() {
      repo = MockAuthRepository();
    });

    tearDown(() {
      repo.dispose();
    });

    test('signInAsGuest throws AuthException when name is empty', () async {
      expect(
        () => repo.signInAsGuest(name: '   '),
        throwsA(isA<AuthException>()),
      );
    });

    test('signInAsGuest creates an AuthUser with isGuest = true', () async {
      final user = await repo.signInAsGuest(name: 'Minh Anh');
      expect(user.displayName, equals('Minh Anh'));
      expect(user.isGuest, isTrue);
      expect(repo.currentUser?.displayName, equals('Minh Anh'));
      expect(repo.currentUser?.isGuest, isTrue);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/auth/mock_auth_repository_test.dart`
Expected: Compilation error or failure because `isGuest` and `signInAsGuest` do not exist yet.

- [ ] **Step 3: Update `auth_models.dart` and `auth_repository.dart`**

In `lib/features/auth/domain/auth_models.dart`:
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

In `lib/features/auth/domain/auth_repository.dart`:
```dart
abstract class AuthRepository {
  AuthUser? get currentUser;
  Stream<AuthUser?> watchCurrentUser();
  Future<AuthUser> signIn({required String identity, required String password});
  Future<AuthUser> signInAsGuest({required String name});
  Future<AuthUser> register({
    required String fullName,
    required String displayName,
    required String email,
    required String password,
  });
  Future<void> sendPasswordResetEmail({required String email});
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
  Future<void> signOut();
}
```

---

### Task 2: Implement Guest Sign-in in Repositories

**Files:**
- Modify: `lib/features/auth/data/mock_auth_repository.dart`
- Modify: `lib/features/auth/data/supabase_auth_repository.dart`
- Modify: `lib/shared/repositories/mock_korea_quest_repository.dart`
- Test: `test/features/auth/mock_auth_repository_test.dart`

**Interfaces:**
- Consumes: `signInAsGuest({required String name})` from Task 1.
- Produces: active guest session in `authRepositoryProvider` and synced display name in `koreaQuestRepositoryProvider`.

- [ ] **Step 1: Implement `signInAsGuest` in `MockAuthRepository`**

In `lib/features/auth/data/mock_auth_repository.dart`:
Add implementation for `signInAsGuest`:
```dart
  @override
  Future<AuthUser> signInAsGuest({required String name}) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw const AuthException('Vui lòng nhập tên của bạn.');
    }
    final guestUser = AuthUser(
      id: 'guest-${DateTime.now().millisecondsSinceEpoch}',
      usernameOrEmail: 'guest@koreaquest.local',
      displayName: trimmedName,
      role: UserRole.user,
      isGuest: true,
    );
    _currentUser = guestUser;
    _userController.add(guestUser);
    return guestUser;
  }
```

- [ ] **Step 2: Implement `signInAsGuest` in `SupabaseAuthRepository`**

In `lib/features/auth/data/supabase_auth_repository.dart`:
```dart
  @override
  Future<AuthUser> signInAsGuest({required String name}) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw const AuthException('Vui lòng nhập tên của bạn.');
    }
    final guestUser = AuthUser(
      id: 'guest-${DateTime.now().millisecondsSinceEpoch}',
      usernameOrEmail: 'guest@koreaquest.local',
      displayName: trimmedName,
      role: UserRole.user,
      isGuest: true,
    );
    _currentUser = guestUser;
    return guestUser;
  }
```

- [ ] **Step 3: Update `MockKoreaQuestRepository` to synchronize guest name**

In `lib/shared/repositories/mock_korea_quest_repository.dart`:
Add support to update `currentUser` display name when guest signs in so that all profile and header readers see the guest name.
```dart
  void setGuestDisplayName(String name) {
    if (name.trim().isNotEmpty) {
      _user = _user.copyWith(displayName: name.trim(), fullName: name.trim());
    }
  }
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/auth/mock_auth_repository_test.dart`
Expected: ALL PASS.

---

### Task 3: Localization Strings

**Files:**
- Modify: `lib/l10n/app_en.arb`
- Modify: `lib/l10n/app_ko.arb`
- Modify: `lib/l10n/app_strings.dart`

**Interfaces:**
- Produces: getters in `AppStrings` for guest mode, dialogs, celebration, and migration prompts.

- [ ] **Step 1: Add ARB keys in `app_en.arb` and `app_ko.arb`**

In `lib/l10n/app_en.arb`:
```json
  "playAsGuest": "Play as Guest",
  "guestNamePrompt": "Enter your nickname to explore Korea",
  "guestNameLabel": "Your Name / Nickname",
  "guestNameHint": "e.g. Min-woo, Sarah...",
  "guestNameRequired": "Please enter your name.",
  "guestBadge": "Guest",
  "startExploring": "Start Exploring",
  "guestCelebrationTitle": "Congratulations {name} on completing {location}!",
  "guestCelebrationMessage": "You've earned XP and stamps in this journey! Register an official account to permanently save your progress, rewards, and passport stamps.",
  "registerAndSaveProgress": "Register & Save Progress",
  "continueAsGuest": "Maybe Later / Continue as Guest"
```

In `lib/l10n/app_ko.arb`:
```json
  "playAsGuest": "게스트로 플레이",
  "guestNamePrompt": "한국 탐험을 시작할 이름을 입력하세요",
  "guestNameLabel": "이름 / 닉네임",
  "guestNameHint": "예: 민우, 지수...",
  "guestNameRequired": "이름을 입력해주세요.",
  "guestBadge": "게스트",
  "startExploring": "탐험 시작하기",
  "guestCelebrationTitle": "{name}님, {location} 탐험 완료를 축하합니다!",
  "guestCelebrationMessage": "이번 여정에서 XP와 스탬프를 획득했습니다! 진행 상황과 보상을 영구 보관하려면 정식 계정으로 가입하세요.",
  "registerAndSaveProgress": "가입하고 진행 상황 저장",
  "continueAsGuest": "나중에 하기 / 게스트로 계속"
```

- [ ] **Step 2: Update `lib/l10n/app_strings.dart` with fallback getters**

Ensure fallback getters in `appStrings(context)` provide Vietnamese and default translations when locale is vi or fallback:
- `playAsGuest`: "Chơi nhanh (Khách)"
- `guestNamePrompt`: "Nhập tên của bạn để khám phá Hàn Quốc"
- `guestNameLabel`: "Tên hiển thị / Nickname"
- `guestNameHint`: "Ví dụ: Minh Anh, Hans..."
- `guestNameRequired`: "Vui lòng nhập tên của bạn."
- `guestBadge`: "Khách"
- `startExploring`: "Vào khám phá ngay"
- `guestCelebrationTitle(name, location)`: "Chúc mừng $name đã khám phá xong $location!"
- `guestCelebrationMessage`: "Bạn đã tích lũy được điểm XP và trải nghiệm tuyệt vời! Hãy tạo tài khoản chính thức để lưu lại vĩnh viễn tiến trình, huy hiệu và dấu mộc của bạn nhé."
- `registerAndSaveProgress`: "Đăng ký & Lưu tiến trình"
- `continueAsGuest`: "Để sau / Tiếp tục khám phá"

---

### Task 4: Guest Name Dialog Component

**Files:**
- Create: `lib/features/auth/presentation/widgets/guest_name_dialog.dart`
- Test: `test/features/auth/guest_name_dialog_test.dart`

**Interfaces:**
- Produces: `showGuestNameDialog(BuildContext context)` which validates input, calls `ref.read(authRepositoryProvider).signInAsGuest(name: ...)`, updates mock repository, and navigates to `/explore`.

- [ ] **Step 1: Write widget test for `GuestNameDialog`**

In `test/features/auth/guest_name_dialog_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:korea_quest/features/auth/presentation/widgets/guest_name_dialog.dart';

void main() {
  testWidgets('GuestNameDialog displays input and validates non-empty name', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: GuestNameDialog(),
          ),
        ),
      ),
    );
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Vào khám phá ngay'), findsOneWidget);

    // Tap submit with empty name
    await tester.tap(find.text('Vào khám phá ngay'));
    await tester.pump();
    expect(find.text('Vui lòng nhập tên của bạn.'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/auth/guest_name_dialog_test.dart`
Expected: FAIL (file does not exist).

- [ ] **Step 3: Implement `GuestNameDialog`**

In `lib/features/auth/presentation/widgets/guest_name_dialog.dart`:
Create dialog with:
- `AppColors.card`, `AppColors.stitchText`, `AppColors.coral`.
- `TextEditingController` with validator (max 40 chars, not empty).
- `PrimaryButton` to submit, `SecondaryButton` to cancel.
- On success: calls `authRepository.signInAsGuest(name: ...)`, calls `ref.read(koreaQuestRepositoryProvider)` if mock to set display name, closes dialog, and navigates to `/explore`.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/auth/guest_name_dialog_test.dart`
Expected: ALL PASS.

---

### Task 5: Add Guest Entry Points & Header Status

**Files:**
- Modify: `lib/features/landing/presentation/pages/landing_page.dart`
- Modify: `lib/features/auth/presentation/pages/auth_page.dart`
- Modify: `lib/design_system/components/app_structure.dart`
- Modify: `lib/app/app_router.dart`

**Interfaces:**
- Consumes: `showGuestNameDialog` from Task 4 and `isGuest` from Task 1.

- [ ] **Step 1: Update Landing Page hero section**

In `lib/features/landing/presentation/pages/landing_page.dart`:
In `_HeroCopy` actions wrap:
Next to `PrimaryButton(label: appStrings(context).startJourney, onPressed: () => context.go('/register'))`:
Add:
```dart
SecondaryButton(
  label: appStrings(context).playAsGuest,
  icon: Icons.person_pin_circle_outlined,
  onPressed: () => showGuestNameDialog(context),
),
```

- [ ] **Step 2: Update Auth Page (`/login` & `/register`)**

In `lib/features/auth/presentation/pages/auth_page.dart`:
Add a section beneath the primary form:
"Hoặc trải nghiệm ngay không cần tài khoản"
With button: `TextButton.icon(icon: Icon(Icons.travel_explore_rounded), label: Text(appStrings(context).playAsGuest), onPressed: () => showGuestNameDialog(context))`

- [ ] **Step 3: Update `AppHeader` to show Guest indicator and upgrade option**

In `lib/design_system/components/app_structure.dart`:
When `isGuest == false` (or real user), keep current header.
When `authUser != null && authUser.isGuest`:
- In the user menu, show badge: `[Khách]`.
- Add menu item with icon `Icons.card_membership_rounded`: "Đăng ký tài khoản chính thức" -> navigates to `/register`.
- Allow guest to access `/home`, `/explore`, `/passport`, `/achievements`, `/profile`.

- [ ] **Step 4: Update Router redirect logic**

In `lib/app/app_router.dart`:
Ensure `currentUser != null` allows guest to navigate without redirecting to `/login`.

---

### Task 6: Post-Exploration Celebration & Registration Prompt Dialog

**Files:**
- Create: `lib/features/explore/presentation/widgets/guest_registration_prompt_dialog.dart`
- Modify: `lib/features/explore/presentation/pages/published_location_page.dart`
- Modify: `lib/features/explore/presentation/widgets/location_content_view.dart`
- Modify: `lib/features/journey/presentation/pages/journey_page.dart`
- Test: `test/features/explore/guest_registration_prompt_dialog_test.dart`

**Interfaces:**
- Produces: `showGuestRegistrationPromptDialog(BuildContext context, {required String locationName, required String guestName})`

- [ ] **Step 1: Write widget test for `GuestRegistrationPromptDialog`**

In `test/features/explore/guest_registration_prompt_dialog_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:korea_quest/features/explore/presentation/widgets/guest_registration_prompt_dialog.dart';

void main() {
  testWidgets('GuestRegistrationPromptDialog shows celebration text and action buttons', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GuestRegistrationPromptDialog(
            locationName: 'Gyeongbokgung',
            guestName: 'Minh Anh',
          ),
        ),
      ),
    );
    expect(find.textContaining('Minh Anh'), findsOneWidget);
    expect(find.textContaining('Gyeongbokgung'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsWidgets);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/explore/guest_registration_prompt_dialog_test.dart`
Expected: FAIL (file does not exist).

- [ ] **Step 3: Implement `GuestRegistrationPromptDialog`**

In `lib/features/explore/presentation/widgets/guest_registration_prompt_dialog.dart`:
Design dialog with:
- Korean celebratory styling: trophy/temple icon with `AppColors.coral` and `AppColors.gold`.
- Title: `appStrings(context).guestCelebrationTitle(guestName, locationName)`.
- Description: `appStrings(context).guestCelebrationMessage`.
- Primary Button: `appStrings(context).registerAndSaveProgress` -> `context.go('/register')` with query param or prefilled name.
- Secondary Button: `appStrings(context).continueAsGuest` -> closes dialog, returns to `/explore`.

- [ ] **Step 4: Integrate trigger into `PublishedLocationPage` and `JourneyPage`**

In `PublishedLocationPage`:
When user finishes Stage 9 (or on `_openStage(0)` after Stage 9):
If `ref.read(authRepositoryProvider).currentUser?.isGuest == true`:
Show `showGuestRegistrationPromptDialog`.

In `JourneyPage`:
When completing `JourneyStage.summary`:
If `ref.read(authRepositoryProvider).currentUser?.isGuest == true`:
Show `showGuestRegistrationPromptDialog`.

- [ ] **Step 5: Run tests to verify they pass**

Run: `flutter test test/features/explore/guest_registration_prompt_dialog_test.dart`
Expected: ALL PASS.

---

### Task 7: Update Documentation & Mandatory Verification

**Files:**
- Modify: `docs/DATABASE_MODEL_DISCUSSION.md`

- [ ] **Step 1: Update `docs/DATABASE_MODEL_DISCUSSION.md`**

Update Section 4 / Section 5 with note on `AuthUser.isGuest` in domain model.

- [ ] **Step 2: Run mandatory checks in order**

```bash
dart format .
flutter analyze
flutter test
flutter build web
```

All 4 commands must pass with 0 errors.
