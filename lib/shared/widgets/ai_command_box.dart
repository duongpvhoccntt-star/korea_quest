import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:korea_quest/core/services/gemini_service.dart';
import 'package:korea_quest/core/utils/ai_dispatcher.dart';
import 'package:korea_quest/design_system/colors/app_colors.dart';
import 'package:korea_quest/design_system/radius/app_radius.dart';
import 'package:korea_quest/design_system/spacing/app_spacing.dart';

/// Widget nút AI và khung nhập lệnh AI Function Calling
class AiCommandWidget extends ConsumerStatefulWidget {
  const AiCommandWidget({super.key});

  @override
  ConsumerState<AiCommandWidget> createState() => _AiCommandWidgetState();
}

class _AiCommandWidgetState extends ConsumerState<AiCommandWidget> {
  bool _isOpen = false;
  bool _isLoading = false;
  bool _showRawJson = true;
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();

  GeminiExecutionResult? _lastResult;

  @override
  void dispose() {
    _promptController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _sendPrompt() async {
    final text = _promptController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _lastResult = null;
    });

    final geminiService = ref.read(geminiServiceProvider);
    final result = await geminiService.sendPrompt(text);

    if (mounted) {
      setState(() {
        _isLoading = false;
        _lastResult = result;
      });
    }
  }

  void _showApiKeyDialog() {
    final currentKey = ref.read(geminiApiKeyProvider);
    final currentModel = ref.read(geminiModelProvider);
    _apiKeyController.text = currentKey;
    final modelController = TextEditingController(text: currentModel);

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.paper,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
        title: const Row(
          children: [
            Icon(Icons.tune, color: AppColors.navy),
            SizedBox(width: AppSpacing.xs),
            Text(
              'Cấu hình Gemini AI',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Model đang chọn:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: modelController,
              decoration: InputDecoration(
                hintText: 'gemini-3.1-flash-lite',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Gemini API Key:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _apiKeyController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'AIzaSy...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navy,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              ref
                  .read(geminiApiKeyProvider.notifier)
                  .setKey(_apiKeyController.text);
              ref
                  .read(geminiModelProvider.notifier)
                  .setModel(modelController.text);
              Navigator.of(ctx).pop();
            },
            child: const Text('Lưu cài đặt'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final apiKey = ref.watch(geminiApiKeyProvider);

    if (!_isOpen) {
      return FloatingActionButton.extended(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        elevation: 6,
        onPressed: () => setState(() => _isOpen = true),
        icon: const Icon(Icons.auto_awesome, size: 20),
        label: const Text('AI Lệnh thoại'),
      );
    }

    return Container(
      width: 380,
      constraints: const BoxConstraints(maxHeight: 520),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: const BoxDecoration(
              color: AppColors.navy,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadius.large),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.smart_toy_outlined,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.xs),
                const Expanded(
                  child: Text(
                    'AI Dispatcher (Gemini)',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Cài đặt API Key',
                  icon: Icon(
                    apiKey.isEmpty ? Icons.key_off : Icons.key,
                    color: apiKey.isEmpty ? AppColors.gold : Colors.white70,
                    size: 18,
                  ),
                  onPressed: _showApiKeyDialog,
                ),
                IconButton(
                  tooltip: 'Đóng',
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white70,
                    size: 18,
                  ),
                  onPressed: () => setState(() => _isOpen = false),
                ),
              ],
            ),
          ),

          // Content body
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nút debug trực tiếp (bước 1)
                  Row(
                    children: [
                      const Text(
                        'Thử nghiệm:',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.muted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      ActionChip(
                        avatar: const Icon(
                          Icons.person_outline,
                          size: 14,
                          color: AppColors.navy,
                        ),
                        label: const Text(
                          'Mở Hồ sơ ngay',
                          style: TextStyle(fontSize: 12, color: AppColors.navy),
                        ),
                        backgroundColor: AppColors.cream,
                        onPressed: () {
                          dispatchAiFunction(ref, 'navigateToProfile');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã gọi: navigateToProfile'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Ô nhập lệnh
                  TextField(
                    controller: _promptController,
                    minLines: 1,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 14, color: AppColors.ink),
                    decoration: InputDecoration(
                      hintText: 'Nhập lệnh (vd: "Chuyển sang trang hồ sơ")...',
                      hintStyle: const TextStyle(
                        fontSize: 13,
                        color: AppColors.muted,
                      ),
                      filled: true,
                      fillColor: AppColors.cream,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                        borderSide: const BorderSide(color: AppColors.line),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                        borderSide: const BorderSide(color: AppColors.line),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                        borderSide: const BorderSide(
                          color: AppColors.navy,
                          width: 1.5,
                        ),
                      ),
                    ),
                    onSubmitted: (_) => _sendPrompt(),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Nút Gửi lệnh
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.navy,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sm,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.small),
                        ),
                      ),
                      onPressed: _isLoading ? null : _sendPrompt,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send_rounded, size: 16),
                      label: Text(
                        _isLoading ? 'Đang gọi Gemini...' : 'Gửi lệnh tới AI',
                      ),
                    ),
                  ),

                  // Khu vực hiển thị kết quả
                  if (_lastResult != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    const Divider(color: AppColors.line),
                    const SizedBox(height: AppSpacing.xs),

                    // Lỗi nếu có
                    if (_lastResult!.errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.small),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: AppColors.danger,
                              size: 16,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Text(
                                _lastResult!.errorMessage!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.danger,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                    ],

                    // Function call được thực thi
                    if (_lastResult!.functionCalls.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: AppColors.green.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadius.small),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              color: AppColors.green,
                              size: 16,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Text(
                                'Function Calling: ${_lastResult!.functionCalls.join(", ")} -> Đã chuyển trang!',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.green,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                    ],

                    // Phản hồi văn bản thông thường
                    if (_lastResult!.textResponse != null) ...[
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: AppColors.cream,
                          borderRadius: BorderRadius.circular(AppRadius.small),
                        ),
                        child: Text(
                          'AI: ${_lastResult!.textResponse}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                    ],

                    // Chi tiết Raw JSON log
                    if (_lastResult!.rawJson != null) ...[
                      InkWell(
                        onTap: () =>
                            setState(() => _showRawJson = !_showRawJson),
                        child: Row(
                          children: [
                            Icon(
                              _showRawJson
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              size: 16,
                              color: AppColors.muted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _showRawJson
                                  ? 'Ẩn JSON thô'
                                  : 'Xem JSON thô từ Gemini',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_showRawJson)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.all(AppSpacing.xs),
                          decoration: BoxDecoration(
                            color: AppColors.navyLight.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(
                              AppRadius.small,
                            ),
                          ),
                          child: Text(
                            _lastResult!.rawJson!,
                            style: const TextStyle(
                              fontSize: 10,
                              fontFamily: 'monospace',
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
