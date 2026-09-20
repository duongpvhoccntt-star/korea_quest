import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:korea_quest/app/app_router.dart';

/// Khai báo công cụ chuẩn cho AI (Gemini / OpenAI tool declaration schema)
const navigateToProfileTool = {
  'name': 'navigateToProfile',
  'description': 'Điều hướng người dùng đến trang hồ sơ cá nhân (Profile page)',
  'parameters': {'type': 'object', 'properties': {}},
};

/// Danh sách toàn bộ các tool AI hỗ trợ trong app
const aiTools = [navigateToProfileTool];

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
