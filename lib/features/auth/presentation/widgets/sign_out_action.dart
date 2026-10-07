import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:korea_quest/design_system/components/app_feedback.dart';
import 'package:korea_quest/features/auth/domain/auth_models.dart';
import 'package:korea_quest/features/auth/presentation/providers/auth_providers.dart';

Future<void> confirmAndSignOut(BuildContext context, WidgetRef ref) async {
  final confirmed = await ConfirmationDialog.show(
    context,
    title: 'Đăng xuất khỏi KoreaQuest?',
    message: 'Bạn có chắc chắn muốn đăng xuất tài khoản hiện tại?',
    confirmLabel: 'Đăng xuất',
  );
  if (!confirmed || !context.mounted) return;

  try {
    await ref.read(authRepositoryProvider).signOut();
    if (!context.mounted) return;
    AppToast.show(context, 'Đã đăng xuất thành công.');
    context.go('/login');
  } on AuthException catch (error) {
    if (context.mounted) AppToast.show(context, error.message);
  } catch (_) {
    if (context.mounted) {
      AppToast.show(context, 'Không thể đăng xuất. Vui lòng thử lại.');
    }
  }
}
