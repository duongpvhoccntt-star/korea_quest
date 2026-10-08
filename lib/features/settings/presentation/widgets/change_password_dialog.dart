import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:korea_quest/design_system/colors/app_colors.dart';
import 'package:korea_quest/design_system/components/app_buttons.dart';
import 'package:korea_quest/design_system/components/app_feedback.dart';
import 'package:korea_quest/design_system/components/app_fields.dart';
import 'package:korea_quest/design_system/radius/app_radius.dart';
import 'package:korea_quest/design_system/spacing/app_spacing.dart';
import 'package:korea_quest/features/auth/domain/auth_models.dart';
import 'package:korea_quest/features/auth/presentation/providers/auth_providers.dart';
import 'package:korea_quest/l10n/app_strings.dart';

class ChangePasswordDialog extends ConsumerStatefulWidget {
  const ChangePasswordDialog({super.key});

  static Future<bool?> show(BuildContext context) => showDialog<bool>(
    context: context,
    builder: (_) => const ChangePasswordDialog(),
  );

  @override
  ConsumerState<ChangePasswordDialog> createState() =>
      _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<ChangePasswordDialog> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _error;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final strings = appStrings(context);
    final current = _currentPasswordController.text;
    final next = _newPasswordController.text;
    final confirm = _confirmPasswordController.text;

    if (current.isEmpty || next.isEmpty || confirm.isEmpty) {
      setState(() => _error = strings.fillAllFields);
      return;
    }

    if (next.length < 8) {
      setState(() => _error = strings.passwordMin8);
      return;
    }

    if (next != confirm) {
      setState(() => _error = strings.passwordMismatch);
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ref
          .read(authRepositoryProvider)
          .changePassword(currentPassword: current, newPassword: next);
      if (mounted) {
        Navigator.pop(context, true);
        AppToast.show(context, strings.changePasswordSuccess);
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = strings.genericError;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = appStrings(context);
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: AppColors.palePink,
                    child: Icon(
                      Icons.lock_reset_rounded,
                      color: AppColors.koreanRed,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    strings.changePassword,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              PasswordField(
                label: strings.currentPassword,
                controller: _currentPasswordController,
              ),
              const SizedBox(height: AppSpacing.md),
              PasswordField(
                label: strings.newPassword,
                controller: _newPasswordController,
              ),
              const SizedBox(height: AppSpacing.md),
              PasswordField(
                label: strings.confirmNewPassword,
                controller: _confirmPasswordController,
              ),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _error!,
                  style: const TextStyle(
                    color: AppColors.koreanRed,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  SecondaryButton(
                    label: strings.cancel,
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                  ),
                  PrimaryButton(
                    label: strings.updatePassword,
                    isLoading: _isLoading,
                    onPressed: _isLoading ? null : _submit,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
