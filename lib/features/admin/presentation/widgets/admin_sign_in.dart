import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:korea_quest/design_system/components/app_buttons.dart';
import 'package:korea_quest/design_system/components/app_fields.dart';
import 'package:korea_quest/design_system/components/app_feedback.dart';
import 'package:korea_quest/design_system/components/responsive_content.dart';
import 'package:korea_quest/design_system/spacing/app_spacing.dart';
import 'package:korea_quest/features/admin/domain/admin_repository.dart';
import 'package:korea_quest/features/admin/presentation/providers/admin_providers.dart';

class AdminSignIn extends ConsumerStatefulWidget {
  const AdminSignIn({super.key});

  @override
  ConsumerState<AdminSignIn> createState() => _AdminSignInState();
}

class _AdminSignInState extends ConsumerState<AdminSignIn> {
  final _identity = TextEditingController();
  final _password = TextEditingController();
  bool _isLoading = false;
  bool _isRegistering = false;

  @override
  void dispose() {
    _identity.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_identity.text.trim().isEmpty || _password.text.isEmpty) {
      AppToast.show(context, 'Hãy nhập tên đăng nhập và mật khẩu.');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final repository = ref.read(adminRepositoryProvider);
      if (_isRegistering && repository is AdminRegistrationRepository) {
        await (repository as AdminRegistrationRepository).register(
          username: _identity.text.trim(),
          password: _password.text,
        );
      } else {
        await repository.signIn(
          email: _identity.text.trim(),
          password: _password.text,
        );
      }
      ref.invalidate(adminAccessProvider);
      ref.invalidate(adminLocationsProvider);
      ref.invalidate(adminGameConfigProvider);
    } catch (error) {
      if (mounted) AppToast.show(context, error.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _fillDemoAccount() {
    _identity.text = 'admin';
    _password.text = 'admin123';
    setState(() => _isRegistering = false);
  }

  @override
  Widget build(BuildContext context) {
    final supportsRegistration =
        ref.read(adminRepositoryProvider) is AdminRegistrationRepository;
    final title = supportsRegistration
        ? (_isRegistering ? 'Đăng ký Admin demo' : 'Đăng nhập Admin demo')
        : 'Đăng nhập quản trị';

    return ResponsiveContent(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    supportsRegistration
                        ? 'Không cần email. Tài khoản và dữ liệu chỉ tồn tại trong phiên demo này.'
                        : 'Chỉ tài khoản đã được thêm vào admin_users mới có quyền ghi dữ liệu.',
                  ),
                  if (supportsRegistration) ...[
                    const SizedBox(height: AppSpacing.md),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(
                          value: false,
                          icon: Icon(Icons.login_rounded),
                          label: Text('Đăng nhập'),
                        ),
                        ButtonSegment(
                          value: true,
                          icon: Icon(Icons.person_add_alt_1_rounded),
                          label: Text('Đăng ký'),
                        ),
                      ],
                      selected: {_isRegistering},
                      onSelectionChanged: _isLoading
                          ? null
                          : (selection) => setState(
                              () => _isRegistering = selection.first,
                            ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    label: supportsRegistration ? 'Tên đăng nhập' : 'Email',
                    hint: supportsRegistration ? 'Ví dụ: admin_nhom_1' : null,
                    controller: _identity,
                    prefixIcon: supportsRegistration
                        ? Icons.person_outline_rounded
                        : Icons.email_outlined,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  PasswordField(label: 'Mật khẩu', controller: _password),
                  const SizedBox(height: AppSpacing.lg),
                  PrimaryButton(
                    label: _isRegistering ? 'Tạo tài khoản' : 'Đăng nhập',
                    icon: _isRegistering
                        ? Icons.person_add_alt_1_rounded
                        : Icons.login_rounded,
                    isLoading: _isLoading,
                    onPressed: _submit,
                  ),
                  if (supportsRegistration) ...[
                    const SizedBox(height: AppSpacing.sm),
                    TextButton(
                      onPressed: _isLoading ? null : _fillDemoAccount,
                      child: const Text('Dùng nhanh: admin / admin123'),
                    ),
                  ] else ...[
                    const SizedBox(height: AppSpacing.sm),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              _identity.text = 'admin@koreaquest.com';
                              _password.text = 'KoreaQuestAdmin2026!';
                            },
                      child: const Text(
                        'Dùng nhanh: admin@koreaquest.com',
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
