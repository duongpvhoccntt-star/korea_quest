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
    String? fragment,
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

    test('dispatches navigateToProfile correctly via ProviderContainer', () {
      final mockRouter = MockGoRouter();
      final container = ProviderContainer(
        overrides: [appRouterProvider.overrideWithValue(mockRouter)],
      );

      final result = dispatchAiFunction(container, 'navigateToProfile');

      expect(result, isTrue);
      expect(mockRouter.lastNavigatedNamed, AppRouteNames.profile);
    });

    test('returns false for unknown function', () {
      final mockRouter = MockGoRouter();
      final container = ProviderContainer(
        overrides: [appRouterProvider.overrideWithValue(mockRouter)],
      );

      final result = dispatchAiFunction(container, 'unknownTool');

      expect(result, isFalse);
      expect(mockRouter.lastNavigatedNamed, isNull);
    });
  });
}
