# Auth Guest Mode & Remove Home Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove Home Page (`/home`) and enforce screen locking on Auth/Landing pages until the user signs in or explicitly selects Guest Mode ("Tiếp tục làm Khách").

**Architecture:** Add a `guestModeProvider` using Riverpod in `auth_providers.dart`. Enforce strict route redirection in `app_router.dart` for unauthenticated users who have not enabled guest mode. Update UI components (`AppHeader`, `AppFooter`, `AuthPage`) to support Guest Mode activation and replace all `/home` routes with `/explore`.

**Tech Stack:** Flutter, Dart, Riverpod (`flutter_riverpod`), `go_router`.

## Global Constraints

- Material 3 — no Material 2.
- Design System tokens from `lib/design_system/` must be used for colors, spacing, radius.
- Must run `dart format .`, `flutter analyze`, `flutter test`, `flutter build web` upon completion.

---

### Task 1: Add Guest Mode Provider

**Files:**
- Modify: `lib/features/auth/presentation/providers/auth_providers.dart`
- Test: `test/features/auth/guest_mode_provider_test.dart`

**Interfaces:**
- Produces: `guestModeProvider` (Notifier/StateNotifier providing `bool` state, `enableGuestMode()`, `disableGuestMode()`).

- [ ] **Step 1: Write the failing test for GuestModeNotifier**

Create `test/features/auth/guest_mode_provider_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:korea_quest/features/auth/presentation/providers/auth_providers.dart';

void main() {
  test('guestModeProvider initial value is false and can be toggled', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(guestModeProvider), isFalse);

    container.read(guestModeProvider.notifier).enableGuestMode();
    expect(container.read(guestModeProvider), isTrue);

    container.read(guestModeProvider.notifier).disableGuestMode();
    expect(container.read(guestModeProvider), isFalse);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/auth/guest_mode_provider_test.dart`
Expected: FAIL (getter/provider `guestModeProvider` not found)

- [ ] **Step 3: Implement `guestModeProvider`**

In `lib/features/auth/presentation/providers/auth_providers.dart`:
```dart
class GuestModeNotifier extends StateNotifier<bool> {
  GuestModeNotifier() : super(false);

  void enableGuestMode() => state = true;
  void disableGuestMode() => state = false;
}

final guestModeProvider = StateNotifierProvider<GuestModeNotifier, bool>((ref) {
  return GuestModeNotifier();
});
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/auth/guest_mode_provider_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/auth/presentation/providers/auth_providers.dart test/features/auth/guest_mode_provider_test.dart
git commit -m "feat(auth): add guestModeProvider for managing guest mode state"
```

---

### Task 2: Update Auth Page to Include Guest Mode Button

**Files:**
- Modify: `lib/features/auth/presentation/pages/auth_page.dart`

**Interfaces:**
- Consumes: `guestModeProvider` from `lib/features/auth/presentation/providers/auth_providers.dart`
- Produces: UI button in `AuthPage` ("Khám phá với tư cách Khách" / "Continue as Guest") that calls `ref.read(guestModeProvider.notifier).enableGuestMode()` and navigates to `/explore`.

- [ ] **Step 1: Add Guest Mode button in `AuthPage`**

In `lib/features/auth/presentation/pages/auth_page.dart`, in `_AuthFormPanel`, add an action button for Guest Mode below the form or demo accounts:
```dart
const SizedBox(height: AppSpacing.md),
OutlinedButton.icon(
  onPressed: isLoading
      ? null
      : () {
          ref.read(guestModeProvider.notifier).enableGuestMode();
          context.go('/explore');
        },
  icon: const Icon(Icons.explore_outlined, color: AppColors.teal),
  label: Text(
    appStrings(context).exploreAsGuest ?? 'Khám phá với tư cách Khách',
    style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.w700),
  ),
  style: OutlinedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.md),
    side: const BorderSide(color: AppColors.teal),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.medium)),
  ),
),
```

Also update login/register redirects: replace any default fallback `redirectTo ?? '/home'` with `redirectTo ?? '/explore'`.

- [ ] **Step 2: Run flutter analyze**

Run: `flutter analyze`
Expected: PASS

- [ ] **Step 3: Commit**

```bash
git add lib/features/auth/presentation/pages/auth_page.dart
git commit -m "feat(auth): add Guest Mode button to AuthPage and update redirect defaults to /explore"
```

---

### Task 3: Update AppHeader, AppFooter, and SystemStatePage to Replace /home with /explore

**Files:**
- Modify: `lib/design_system/components/app_structure.dart`
- Modify: `lib/features/system_states/presentation/pages/system_state_page.dart`

**Interfaces:**
- Consumes: `guestModeProvider`, `authUserStreamProvider`.

- [ ] **Step 1: Update AppHeader and AppFooter in `app_structure.dart`**

In `lib/design_system/components/app_structure.dart`:
1. Remove `(strings.home, isGuest ? '/' : '/home')` from `destinations`. The first destination should be `(strings.explore, '/explore')`.
2. Update brand lockup tap:
   ```dart
   final isGuestMode = ref.watch(guestModeProvider);
   final canAccessApp = !isGuest || isGuestMode;
   _BrandLockup(onTap: () => context.go(canAccessApp ? '/explore' : '/')),
   ```
3. Update `AppFooter` links: replace `/home` with `/explore`.
4. If `isGuest && !isGuestMode`, restrict navigation links in header to prevent broken navigation before selecting Guest mode or Signing in.

- [ ] **Step 2: Update `SystemStatePage` in `system_state_page.dart`**

In `lib/features/system_states/presentation/pages/system_state_page.dart`:
Change:
```dart
PrimaryButton(
  label: strings.backHome,
  icon: Icons.explore_outlined,
  onPressed: () => context.go('/explore'),
),
```

- [ ] **Step 3: Run flutter analyze**

Run: `flutter analyze`
Expected: PASS

- [ ] **Step 4: Commit**

```bash
git add lib/design_system/components/app_structure.dart lib/features/system_states/presentation/pages/system_state_page.dart
git commit -m "refactor(ui): update header, footer, and system state page to use /explore instead of /home"
```

---

### Task 4: Update Router Guard & Remove /home Route

**Files:**
- Modify: `lib/app/app_router.dart`

**Interfaces:**
- Consumes: `guestModeProvider`, `authRepositoryProvider`.
- Produces: Updated `appRouterProvider` enforcing auth lock when `isGuest && !isGuestMode`.

- [ ] **Step 1: Update redirect logic in `app_router.dart`**

In `lib/app/app_router.dart`:
1. Remove `import .../home_page.dart`.
2. Remove `static const home = 'home';` from `AppRouteNames`.
3. Remove `GoRoute(path: '/home', ...)` from routes.
4. Listen to `guestModeProvider`:
   ```dart
   ref.listen(guestModeProvider, (_, __) => router.refresh());
   ```
5. Update `redirect`:
   ```dart
   redirect: (context, state) {
     const authPaths = {
       '/',
       '/login',
       '/register',
       '/forgot-password',
       '/admin',
     };
     final isGuest = ref.read(authRepositoryProvider).currentUser == null;
     final isGuestMode = ref.read(guestModeProvider);

     if (isGuest) {
       if (!isGuestMode) {
         // Locked out of all app screens until signing in or choosing Guest mode
         if (!authPaths.contains(state.uri.path)) {
           return Uri(
             path: '/login',
             queryParameters: {'redirect': state.uri.toString()},
           ).toString();
         }
       } else {
         // Guest mode active: allow /explore and location/journey public content
         final allowedGuestPaths = state.uri.path == '/explore' ||
             state.uri.path.startsWith('/locations/') ||
             state.uri.path.startsWith('/journey/') ||
             state.uri.path.startsWith('/passport/shared/') ||
             authPaths.contains(state.uri.path);

         if (!allowedGuestPaths) {
           return Uri(
             path: '/login',
             queryParameters: {'redirect': state.uri.toString()},
           ).toString();
         }
       }
     }
     return null;
   },
   ```

- [ ] **Step 2: Run flutter analyze**

Run: `flutter analyze`
Expected: PASS

- [ ] **Step 3: Commit**

```bash
git add lib/app/app_router.dart
git commit -m "feat(router): enforce auth lock when unauthenticated and remove /home route"
```

---

### Task 5: Delete Home Page File

**Files:**
- Delete: `lib/features/home/presentation/pages/home_page.dart`
- Delete: `lib/features/home/`

- [ ] **Step 1: Delete `home_page.dart` and remove empty `home` directory**

Delete file `lib/features/home/presentation/pages/home_page.dart`.

- [ ] **Step 2: Run flutter analyze**

Run: `flutter analyze`
Expected: PASS with 0 errors.

- [ ] **Step 3: Commit**

```bash
git rm lib/features/home/presentation/pages/home_page.dart
git commit -m "chore(home): delete HomePage as /explore is the primary hub"
```

---

### Task 6: Full Verification Suite

- [ ] **Step 1: Format code**
Run: `dart format .`

- [ ] **Step 2: Run static analysis**
Run: `flutter analyze`

- [ ] **Step 3: Run unit and widget tests**
Run: `flutter test`

- [ ] **Step 4: Build web target to verify production build**
Run: `flutter build web`
