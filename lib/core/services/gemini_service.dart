import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:korea_quest/core/utils/ai_dispatcher.dart';

/// State quản lý API Key của Gemini
final geminiApiKeyProvider = NotifierProvider<GeminiApiKeyNotifier, String>(
  GeminiApiKeyNotifier.new,
);

class GeminiApiKeyNotifier extends Notifier<String> {
  @override
  String build() {
    return const String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
  }

  void setKey(String newKey) {
    state = newKey.trim();
  }
}

/// State quản lý Model Gemini đang chọn
final geminiModelProvider = NotifierProvider<GeminiModelNotifier, String>(
  GeminiModelNotifier.new,
);

class GeminiModelNotifier extends Notifier<String> {
  @override
  String build() {
    return 'gemini-3.1-flash-lite';
  }

  void setModel(String newModel) {
    state = newModel.trim();
  }
}

/// Kết quả xử lý từ Gemini Service
class GeminiExecutionResult {
  const GeminiExecutionResult({
    required this.success,
    this.rawJson,
    this.textResponse,
    this.functionCalls = const [],
    this.errorMessage,
    this.usedModel,
  });

  final bool success;
  final String? rawJson;
  final String? textResponse;
  final List<String> functionCalls;
  final String? errorMessage;
  final String? usedModel;
}

final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService(ref: ref);
});

class GeminiService {
  GeminiService({required this.ref, http.Client? client})
    : _client = client ?? http.Client();

  final dynamic ref;
  final http.Client _client;

  // Danh sách các model fallback dự phòng nếu model được chọn báo 404
  static const List<String> _fallbackModels = [
    'gemini-3.1-flash-lite',
    'gemini-2.0-flash-lite',
    'gemini-2.0-flash',
    'gemini-1.5-flash-latest',
    'gemini-1.5-flash',
    'gemini-pro',
  ];

  static String? _workingEndpoint;

  String _getApiKey() {
    if (ref is Ref) return (ref as Ref).read(geminiApiKeyProvider);
    if (ref is WidgetRef) return (ref as WidgetRef).read(geminiApiKeyProvider);
    if (ref is ProviderContainer) {
      return (ref as ProviderContainer).read(geminiApiKeyProvider);
    }
    return '';
  }

  String _getSelectedModel() {
    if (ref is Ref) return (ref as Ref).read(geminiModelProvider);
    if (ref is WidgetRef) return (ref as WidgetRef).read(geminiModelProvider);
    if (ref is ProviderContainer) {
      return (ref as ProviderContainer).read(geminiModelProvider);
    }
    return 'gemini-3.1-flash-lite';
  }

  /// Gửi câu lệnh tới Gemini API kèm công cụ điều hướng
  Future<GeminiExecutionResult> sendPrompt(String prompt) async {
    final apiKey = _getApiKey();
    if (apiKey.isEmpty) {
      return const GeminiExecutionResult(
        success: false,
        errorMessage: 'Chưa cấu hình GEMINI_API_KEY. Vui lòng nhập API Key.',
      );
    }

    final selectedModel = _getSelectedModel();

    final payload = {
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': prompt},
          ],
        },
      ],
      'tools': [
        {
          'functionDeclarations': [
            {
              'name': 'navigateToProfile',
              'description':
                  'Điều hướng người dùng đến trang hồ sơ cá nhân (Profile page)',
              'parameters': {
                'type': 'OBJECT',
                'properties': <String, dynamic>{},
              },
            },
          ],
        },
      ],
    };

    // Tạo danh sách endpoint để thử: ưu tiên model được chọn, sau đó là fallback
    final endpointsToTry = <String>[
      'https://generativelanguage.googleapis.com/v1beta/models/$selectedModel:generateContent',
    ];

    if (_workingEndpoint != null &&
        !endpointsToTry.contains(_workingEndpoint)) {
      endpointsToTry.add(_workingEndpoint!);
    }

    for (final model in _fallbackModels) {
      final ep =
          'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent';
      if (!endpointsToTry.contains(ep)) {
        endpointsToTry.add(ep);
      }
    }

    String? lastRawBody;
    String? lastError;

    for (final endpoint in endpointsToTry) {
      final uri = Uri.parse('$endpoint?key=$apiKey');
      try {
        final response = await _client
            .post(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(payload),
            )
            .timeout(const Duration(seconds: 15));

        final rawBody = utf8.decode(response.bodyBytes);
        lastRawBody = rawBody;

        // In JSON thô ra console/log theo yêu cầu Bước 2
        // ignore: avoid_print
        print('[GEMINI_RAW_JSON]: $rawBody');
        debugPrint('[GEMINI_RAW_JSON]: $rawBody');

        if (response.statusCode != 200) {
          String msg = 'Lỗi HTTP ${response.statusCode}';
          bool isNotFound = response.statusCode == 404;
          try {
            final errJson = jsonDecode(rawBody) as Map<String, dynamic>;
            if (errJson.containsKey('error')) {
              msg = errJson['error']['message']?.toString() ?? msg;
              if (msg.contains('not found') || msg.contains('NOT_FOUND')) {
                isNotFound = true;
              }
            }
          } catch (_) {}

          // Nếu model này 404, tiếp tục thử model khác trong danh sách
          if (isNotFound && endpoint != endpointsToTry.last) {
            debugPrint(
              '[Gemini Fallback] Model tại $endpoint không khả dụng, đang thử model kế tiếp...',
            );
            continue;
          }

          lastError = msg;
          return GeminiExecutionResult(
            success: false,
            rawJson: rawBody,
            errorMessage: msg,
          );
        }

        // 200 OK -> Ghi nhớ endpoint hoạt động
        _workingEndpoint = endpoint;
        final modelName = endpoint.split('/models/').last.split(':').first;

        final dynamic parsedJson = jsonDecode(rawBody);
        if (parsedJson is! Map<String, dynamic>) {
          return GeminiExecutionResult(
            success: false,
            rawJson: rawBody,
            errorMessage: 'JSON phản hồi không đúng định dạng',
          );
        }

        final candidates = parsedJson['candidates'] as List<dynamic>?;
        if (candidates == null || candidates.isEmpty) {
          return GeminiExecutionResult(
            success: true,
            rawJson: rawBody,
            usedModel: modelName,
            textResponse: 'Gemini không có phản hồi cho câu lệnh này.',
          );
        }

        final content = candidates.first['content'] as Map<String, dynamic>?;
        final parts = content?['parts'] as List<dynamic>? ?? [];

        final executedCalls = <String>[];
        final textParts = <String>[];

        for (final part in parts) {
          if (part is Map<String, dynamic>) {
            // Xử lý Function Call
            if (part.containsKey('functionCall')) {
              final fCall = part['functionCall'] as Map<String, dynamic>;
              final functionName = fCall['name']?.toString() ?? '';
              final args = fCall['args'] as Map<String, dynamic>?;

              final handled = dispatchAiFunction(ref, functionName, args);
              if (handled) {
                executedCalls.add(functionName);
              }
            }

            // Xử lý Text phản hồi
            if (part.containsKey('text')) {
              final t = part['text']?.toString() ?? '';
              if (t.isNotEmpty) {
                textParts.add(t);
              }
            }
          }
        }

        return GeminiExecutionResult(
          success: true,
          rawJson: rawBody,
          usedModel: modelName,
          textResponse: textParts.isNotEmpty ? textParts.join('\n') : null,
          functionCalls: executedCalls,
        );
      } catch (e) {
        debugPrint('[Gemini Error tại $endpoint]: $e');
        lastError = 'Lỗi kết nối hoặc xử lý: $e';
        if (endpoint != endpointsToTry.last) {
          continue;
        }
      }
    }

    return GeminiExecutionResult(
      success: false,
      rawJson: lastRawBody,
      errorMessage: lastError ?? 'Không thể kết nối tới các endpoint Gemini.',
    );
  }
}
