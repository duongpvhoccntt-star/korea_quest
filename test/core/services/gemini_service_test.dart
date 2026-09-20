import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:korea_quest/app/app_router.dart';
import 'package:korea_quest/core/services/gemini_service.dart';

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
  group('GeminiService', () {
    test('returns error if API Key is empty', () async {
      final container = ProviderContainer();
      final service = GeminiService(ref: container);

      final result = await service.sendPrompt('Mở hồ sơ');

      expect(result.success, isFalse);
      expect(result.errorMessage, contains('Chưa cấu hình GEMINI_API_KEY'));
    });

    test('dispatches navigateToProfile when functionCall returned', () async {
      final mockRouter = MockGoRouter();
      final mockHttpClient = MockClient((request) async {
        final mockResponse = {
          'candidates': [
            {
              'content': {
                'parts': [
                  {
                    'functionCall': {
                      'name': 'navigateToProfile',
                      'args': <String, dynamic>{},
                    },
                  },
                ],
              },
            },
          ],
        };
        return http.Response(jsonEncode(mockResponse), 200);
      });

      final container = ProviderContainer(
        overrides: [appRouterProvider.overrideWithValue(mockRouter)],
      );
      container.read(geminiApiKeyProvider.notifier).setKey('test_key');

      final service = GeminiService(ref: container, client: mockHttpClient);
      final result = await service.sendPrompt('Mở trang hồ sơ');

      expect(result.success, isTrue);
      expect(result.functionCalls, contains('navigateToProfile'));
      expect(mockRouter.lastNavigatedNamed, AppRouteNames.profile);
    });

    test('returns text response when plain text returned', () async {
      final mockRouter = MockGoRouter();
      final mockHttpClient = MockClient((request) async {
        final mockResponse = {
          'candidates': [
            {
              'content': {
                'parts': [
                  {'text': 'Hôm nay thời tiết rất đẹp!'},
                ],
              },
            },
          ],
        };
        return http.Response(
          jsonEncode(mockResponse),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final container = ProviderContainer(
        overrides: [appRouterProvider.overrideWithValue(mockRouter)],
      );
      container.read(geminiApiKeyProvider.notifier).setKey('test_key');

      final service = GeminiService(ref: container, client: mockHttpClient);
      final result = await service.sendPrompt('Trời hôm nay thế nào');

      expect(result.success, isTrue);
      expect(result.textResponse, 'Hôm nay thời tiết rất đẹp!');
      expect(result.functionCalls, isEmpty);
      expect(mockRouter.lastNavigatedNamed, isNull);
    });

    test(
      'falls back to next model if first model returns 404 Not Found',
      () async {
        final mockRouter = MockGoRouter();
        int callCount = 0;
        final mockHttpClient = MockClient((request) async {
          callCount++;
          if (callCount == 1) {
            return http.Response(
              '{"error": {"code": 404, "message": "models/gemini-2.0-flash is not found"}}',
              404,
            );
          }
          final mockResponse = {
            'candidates': [
              {
                'content': {
                  'parts': [
                    {
                      'functionCall': {
                        'name': 'navigateToProfile',
                        'args': <String, dynamic>{},
                      },
                    },
                  ],
                },
              },
            ],
          };
          return http.Response(jsonEncode(mockResponse), 200);
        });

        final container = ProviderContainer(
          overrides: [appRouterProvider.overrideWithValue(mockRouter)],
        );
        container.read(geminiApiKeyProvider.notifier).setKey('test_key');

        final service = GeminiService(ref: container, client: mockHttpClient);
        final result = await service.sendPrompt('Mở trang hồ sơ');

        expect(result.success, isTrue);
        expect(callCount, 2);
        expect(result.functionCalls, contains('navigateToProfile'));
        expect(mockRouter.lastNavigatedNamed, AppRouteNames.profile);
      },
    );
  });
}
