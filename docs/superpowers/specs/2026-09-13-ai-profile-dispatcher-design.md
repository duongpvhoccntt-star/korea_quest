# Design Spec: AI Profile Navigation Dispatcher

- **Date:** 2026-09-13
- **Feature:** AI Function Calling Dispatcher for Profile Navigation
- **Scope:** KoreaQuest Flutter application

## 1. Goal
Provide a simple, lightweight dispatcher function capable of navigating to the user's Profile page upon request, compatible with standard AI function/tool calling patterns (e.g. Gemini / OpenAI / mock calls), without requiring external AI dependencies at this stage.

## 2. Architecture & Design

### 2.1 Tool Declaration (AI Schema)
AI models need a function declaration to know when and how to call the function:
- **Tool Name:** `navigateToProfile`
- **Description:** `"Điều hướng người dùng đến trang hồ sơ cá nhân (Profile page)"`
- **Parameters:** Empty object `{}` (no parameters required for basic profile navigation).

### 2.2 Dispatcher Function
- **Location:** `lib/core/utils/ai_dispatcher.dart`
- **Signature:**
  ```dart
  bool dispatchAiFunction(
    Ref ref,
    String functionName, [
    Map<String, dynamic>? args,
  ]);
  ```
- **Behavior:**
  - Matches `functionName == 'navigateToProfile'`.
  - Executes `ref.read(appRouterProvider).goNamed(AppRouteNames.profile)`.
  - Returns `true` if handled, `false` otherwise.

### 2.3 Integration Pattern
- **Current usage (manual / simulation):**
  `dispatchAiFunction(ref, 'navigateToProfile')`
- **Future usage (AI tool response):**
  Pass the model's function call name directly into `dispatchAiFunction`.

## 3. Verification Plan
- Unit test in `test/core/utils/ai_dispatcher_test.dart` to verify that calling `dispatchAiFunction` with `'navigateToProfile'` invokes `goNamed(AppRouteNames.profile)` and returns `true`, while an unknown function returns `false`.
- Run `dart format`, `flutter analyze`, and `flutter test`.
