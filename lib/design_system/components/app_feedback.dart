import 'package:flutter/material.dart';
import 'package:korea_quest/design_system/colors/app_colors.dart';
import 'package:korea_quest/design_system/components/app_buttons.dart';
import 'package:korea_quest/design_system/spacing/app_spacing.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key, this.label = 'Đang tải dữ liệu…'});

  final String label;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.coral),
          const SizedBox(height: AppSpacing.md),
          Text(label),
        ],
      ),
    ),
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.title,
    required this.message,
    super.key,
    this.onAction,
  });

  final String title;
  final String message;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => _MessageState(
    icon: Icons.explore_off_outlined,
    title: title,
    message: message,
    action: onAction == null
        ? null
        : PrimaryButton(label: 'Khám phá ngay', onPressed: onAction),
  );
}

class ErrorState extends StatelessWidget {
  const ErrorState({
    required this.message,
    super.key,
    this.onRetry,
    this.title = 'Đã có lỗi xảy ra',
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => _MessageState(
    icon: Icons.error_outline_rounded,
    title: title,
    message: message,
    action: onRetry == null
        ? null
        : SecondaryButton(label: 'Thử lại', onPressed: onRetry),
  );
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: AppColors.muted),
          const SizedBox(height: AppSpacing.md),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(message, textAlign: TextAlign.center),
          if (action != null) ...[
            const SizedBox(height: AppSpacing.lg),
            action!,
          ],
        ],
      ),
    ),
  );
}

abstract final class AppToast {
  static void show(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    required this.title,
    required this.message,
    super.key,
    this.confirmLabel = 'Xác nhận',
  });

  final String title;
  final String message;
  final String confirmLabel;

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Xác nhận',
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => ConfirmationDialog(
            title: title,
            message: message,
            confirmLabel: confirmLabel,
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(title),
    content: Text(message),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: const Text('Hủy'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, true),
        child: Text(confirmLabel),
      ),
    ],
  );
}
