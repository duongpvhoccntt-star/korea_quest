import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:korea_quest/design_system/components/app_feedback.dart';
import 'package:korea_quest/features/auth/domain/auth_models.dart';
import 'package:korea_quest/features/auth/presentation/providers/auth_providers.dart';
import 'package:korea_quest/l10n/app_strings.dart';

Future<void> confirmAndSignOut(BuildContext context, WidgetRef ref) async {
  final strings = appStrings(context);
  final confirmed = await ConfirmationDialog.show(
    context,
    title: strings.signOutQuestion,
    message: strings.signOutMessage,
    confirmLabel: strings.signOut,
  );
  if (!confirmed || !context.mounted) return;

  try {
    await ref.read(authRepositoryProvider).signOut();
    if (!context.mounted) return;
    AppToast.show(context, strings.signOutSuccess);
    context.go('/login');
  } on AuthException catch (error) {
    if (context.mounted) AppToast.show(context, error.message);
  } catch (_) {
    if (context.mounted) {
      AppToast.show(context, strings.signOutError);
    }
  }
}
