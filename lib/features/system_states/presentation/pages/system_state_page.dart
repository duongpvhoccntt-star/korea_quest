import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:korea_quest/design_system/components/app_buttons.dart';
import 'package:korea_quest/design_system/components/app_structure.dart';
import 'package:korea_quest/design_system/components/responsive_content.dart';
import 'package:korea_quest/design_system/spacing/app_spacing.dart';

enum SystemStateKind { forbidden, offline, error, notFound }

class SystemStatePage extends StatelessWidget {
  const SystemStatePage({required this.kind, super.key});

  final SystemStateKind kind;

  @override
  Widget build(BuildContext context) {
    final (code, title, message, icon) = switch (kind) {
      SystemStateKind.forbidden => (
        '403',
        'Bạn chưa có quyền truy cập',
        'Hãy quay lại khu vực hành trình của bạn.',
        Icons.lock_outline_rounded,
      ),
      SystemStateKind.offline => (
        'OFFLINE',
        'Bạn đang ngoại tuyến',
        'Kiểm tra kết nối và thử lại khi mạng ổn định.',
        Icons.cloud_off_outlined,
      ),
      SystemStateKind.error => (
        '500',
        'Có điều gì đó chưa đúng',
        'Trạng thái lỗi khung đã sẵn sàng cho các feature dùng chung.',
        Icons.error_outline_rounded,
      ),
      SystemStateKind.notFound => (
        '404',
        'Không tìm thấy trang',
        'Đường dẫn này không thuộc bản đồ KoreaQuest.',
        Icons.explore_off_outlined,
      ),
    };
    return AppScaffold(
      body: ResponsiveContent(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 72),
                const SizedBox(height: AppSpacing.md),
                Text(code, style: Theme.of(context).textTheme.displaySmall),
                Text(title, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: AppSpacing.sm),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: 'Về trang chủ',
                  icon: Icons.home_outlined,
                  onPressed: () => context.go('/home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
