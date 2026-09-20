# AI Profile Navigation Dispatcher Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Provide a simple, lightweight dispatcher function capable of navigating to the user's Profile page upon request, compatible with AI function/tool calling.

**Architecture:** A standalone utility module `lib/core/utils/ai_dispatcher.dart` that defines AI tool declaration metadata and a `dispatchAiFunction(Ref ref, String functionName, [Map<String, dynamic>? args])` function interacting with Riverpod's `appRouterProvider`.

**Tech Stack:** Flutter, Flutter Riverpod, GoRouter.

## Global Constraints
- Must adhere to KoreaQuest clean code guidelines and AGENTS.md.
- Must not hard-code colors/spacing; uses Riverpod `Ref` and `appRouterProvider`.
- Must pass `dart format .`, `flutter analyze`, and `flutter test`.

---

### Task 1: Create AI Dispatcher Utility and Test

**Files:**
- Create: `lib/core/utils/ai_dispatcher.dart`
- Test: `test/core/utils/ai_dispatcher_test.dart`

**Interfaces:**
- Produces:
  - `const navigateToProfileTool = {...}`
  - `bool dispatchAiFunction(Ref ref, String functionName, [Map<String, dynamic>? args])`

- [ ] **Step 1: Write the failing unit test**

Create `test/core/utils/ai_dispatcher_test.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:korea_quest/app/app_router.dart';
import 'package:korea_quest/core/utils/ai_dispatcher.dart';

class MockGoRouter extends Fake implements GoRouter {
  String? lastNavigatedNamed;

  @override
  void goNamed(
    String name, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
    Object? extra,
  }) {
    lastNavigatedNamed = name;
  }
}

void main() {
  group('AI Profile Dispatcher', () {
    test('tool definition exists and matches contract', () {
      expect(navigateToProfileTool['name'], 'navigateToProfile');
      expect(navigateToProfileTool['description'], isNotEmpty);
    });

    test('dispatches navigateToProfile correctly', () {
      final mockRouter = MockGoRouter();
      final container = ProviderContainer(
        overrides: [
          appRouterProvider.overrideWithValue(mockRouter),
        ],
      );

      final result = dispatchAiFunction(container, 'navigateToProfile');

      expect(result, isTrue);
      expect(mockRouter.lastNavigatedNamed, AppRouteNames.profile);
    });

    test('returns false for unknown function', () {
      final mockRouter = MockGoRouter();
      final container = ProviderContainer(
        overrides: [
          appRouterProvider.overrideWithValue(mockRouter),
        ],
      );

      final result = dispatchAiFunction(container, 'unknownTool');

      expect(result, isFalse);
      expect(mockRouter.lastNavigatedNamed, isNull);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/utils/ai_dispatcher_test.dart`
Expected: Compilation failure because `ai_dispatcher.dart` does not exist yet.

- [ ] **Step 3: Implement minimal code**

Create `lib/core/utils/ai_dispatcher.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:korea_quest/app/app_router.dart';

/// Khai báo công cụ chuẩn cho AI (Gemini / OpenAI tool schema)
const navigateToProfileTool = {
  'name': 'navigateToProfile',
  'description': 'Điều hướng người dùng đến trang hồ sơ cá nhân (Profile page)',
  'parameters': {
    'type': 'object',
    'properties': {},
  },
};

/// Danh sách toàn bộ các tool AI hỗ trợ trong app
const aiTools = [
  navigateToProfileTool,
];

/// Hàm điều phối lệnh gọi hàm (Function Calling) từ AI hoặc giả lập
///
/// [refOrContainer]: Có thể truyền `WidgetRef`, `Ref` hoặc `ProviderContainer`.
/// [functionName]: Tên tool được AI gọi (ví dụ: 'navigateToProfile').
/// [args]: Tham số bổ sung nếu có.
///
/// Trả về `true` nếu xử lý thành công, `false` nếu không nhận diện được function.
bool dispatchAiFunction(
  dynamic refOrContainer,
  String functionName, [
  Map<String, dynamic>? args,
]) {
  switch (functionName) {
    case 'navigateToProfile':
      if (refOrContainer is WidgetRef) {
        refOrContainer.read(appRouterProvider).goNamed(AppRouteNames.profile);
      } else if (refOrContainer is Ref) {
        refOrContainer.read(appRouterProvider).goNamed(AppRouteNames.profile);
      } else if (refOrContainer is ProviderContainer) {
        refOrContainer.read(appRouterProvider).goNamed(AppRouteNames.profile);
      } else {
        throw ArgumentError(
          'refOrContainer must be WidgetRef, Ref, or ProviderContainer',
        );
      }
      return true;
    default:
      return false;
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/utils/ai_dispatcher_test.dart`
Expected: PASS all tests.

- [ ] **Step 5: Verify formatting and analysis**

Run: `dart format .` and `flutter analyze`
Expected: No errors.
