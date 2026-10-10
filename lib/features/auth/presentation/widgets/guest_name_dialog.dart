import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:korea_quest/design_system/colors/app_colors.dart';
import 'package:korea_quest/design_system/components/app_buttons.dart';
import 'package:korea_quest/design_system/radius/app_radius.dart';
import 'package:korea_quest/design_system/shadows/app_shadows.dart';
import 'package:korea_quest/design_system/spacing/app_spacing.dart';
import 'package:korea_quest/features/auth/presentation/providers/auth_providers.dart';
import 'package:korea_quest/l10n/app_strings.dart';
import 'package:korea_quest/shared/providers/repository_providers.dart';
import 'package:korea_quest/shared/repositories/mock_korea_quest_repository.dart';

Future<void> showGuestNameDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (context) => const GuestNameDialog(),
  );
}

class GuestNameDialog extends ConsumerStatefulWidget {
  const GuestNameDialog({super.key});

  @override
  ConsumerState<GuestNameDialog> createState() => _GuestNameDialogState();
}

class _GuestNameDialogState extends ConsumerState<GuestNameDialog> {
  final _nameController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final strings = appStrings(context);
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorMessage = strings.guestNameRequired);
      return;
    }
    if (name.length > 40) {
      setState(() => _errorMessage = 'Tên không được vượt quá 40 ký tự.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authRepositoryProvider).signInAsGuest(name: name);
      final kqRepo = ref.read(koreaQuestRepositoryProvider);
      if (kqRepo is MockKoreaQuestRepository) {
        kqRepo.setGuestDisplayName(name);
      }
      ref.invalidate(currentUserProvider);
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        try {
          context.go('/explore');
        } catch (_) {
          // Context may not be within GoRouter in isolated widget tests.
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = appStrings(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.large),
            boxShadow: AppShadows.large,
            border: Border.all(color: AppColors.line),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.coral.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                    ),
                    child: const Icon(
                      Icons.person_pin_circle_rounded,
                      color: AppColors.coral,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings.playAsGuest,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: AppColors.stitchText,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        Text(
                          strings.guestNamePrompt,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.stitchMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _nameController,
                autofocus: true,
                maxLength: 40,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  labelText: strings.guestNameLabel,
                  hintText: strings.guestNameHint,
                  errorText: _errorMessage,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                  ),
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () =>
                              Navigator.of(context, rootNavigator: true).pop(),
                    child: Text(strings.cancel),
                  ),
                  PrimaryButton(
                    label: strings.startExploring,
                    icon: Icons.explore_rounded,
                    isLoading: _isLoading,
                    onPressed: _submit,
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
