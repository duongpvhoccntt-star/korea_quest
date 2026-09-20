import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:korea_quest/design_system/colors/app_colors.dart';
import 'package:korea_quest/design_system/components/app_buttons.dart';
import 'package:korea_quest/design_system/components/app_feedback.dart';
import 'package:korea_quest/design_system/components/app_fields.dart';
import 'package:korea_quest/design_system/components/app_structure.dart';
import 'package:korea_quest/design_system/components/responsive_content.dart';
import 'package:korea_quest/design_system/radius/app_radius.dart';
import 'package:korea_quest/design_system/spacing/app_spacing.dart';
import 'package:korea_quest/features/admin/presentation/providers/admin_providers.dart';
import 'package:korea_quest/features/auth/presentation/providers/auth_providers.dart';

enum AuthPageMode { register, login, forgotPassword }

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({required this.mode, super.key});

  final AuthPageMode mode;

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  late AuthPageMode _mode;
  final _identityController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _displayNameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _mode = widget.mode;
  }

  @override
  void didUpdateWidget(covariant AuthPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mode != widget.mode) {
      _mode = widget.mode;
    }
  }

  @override
  void dispose() {
    _identityController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final identity = _identityController.text.trim();
    final password = _passwordController.text;

    if (identity.isEmpty) {
      AppToast.show(context, 'Vui lòng nhập email hoặc tên đăng nhập.');
      return;
    }

    if (_mode == AuthPageMode.forgotPassword) {
      AppToast.show(context, 'Đã gửi hướng dẫn khôi phục mật khẩu qua email.');
      setState(() => _mode = AuthPageMode.login);
      return;
    }

    if (password.isEmpty) {
      AppToast.show(context, 'Vui lòng nhập mật khẩu.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (_mode == AuthPageMode.register) {
        final fullName = _fullNameController.text.trim();
        final displayName = _displayNameController.text.trim();
        if (fullName.isEmpty) {
          AppToast.show(context, 'Vui lòng nhập họ và tên.');
          setState(() => _isLoading = false);
          return;
        }

        await ref
            .read(authRepositoryProvider)
            .register(
              fullName: fullName,
              displayName: displayName,
              email: identity,
              password: password,
            );
        if (mounted) {
          AppToast.show(context, 'Tạo tài khoản thành công!');
          context.go('/home');
        }
      } else {
        // Login mode
        if (identity.toLowerCase() == 'admin' && password == 'admin123') {
          ref.read(adminDemoOverrideProvider.notifier).enable();
          await ref
              .read(adminRepositoryProvider)
              .signIn(email: 'admin', password: 'admin123');
          await ref
              .read(authRepositoryProvider)
              .signIn(identity: 'admin', password: 'admin123');
          ref.invalidate(adminAccessProvider);
          ref.invalidate(adminLocationsProvider);
          if (mounted) {
            AppToast.show(context, 'Đăng nhập Quản trị viên thành công.');
            context.go('/admin');
          }
        } else {
          await ref
              .read(authRepositoryProvider)
              .signIn(identity: identity, password: password);
          if (mounted) {
            AppToast.show(context, 'Đăng nhập thành công.');
            context.go('/home');
          }
        }
      }
    } catch (error) {
      if (mounted) {
        AppToast.show(context, error.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _quickLoginAdmin() async {
    _identityController.text = 'admin';
    _passwordController.text = 'admin123';
    setState(() => _isLoading = true);

    try {
      ref.read(adminDemoOverrideProvider.notifier).enable();
      await ref
          .read(adminRepositoryProvider)
          .signIn(email: 'admin', password: 'admin123');
      await ref
          .read(authRepositoryProvider)
          .signIn(identity: 'admin', password: 'admin123');
      ref.invalidate(adminAccessProvider);
      ref.invalidate(adminLocationsProvider);
      if (mounted) {
        AppToast.show(context, 'Đăng nhập nhanh Quản trị viên thành công.');
        context.go('/admin');
      }
    } catch (error) {
      if (mounted) AppToast.show(context, error.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _quickLoginStudent() async {
    _identityController.text = 'duong@example.com';
    _passwordController.text = 'user123';
    setState(() => _isLoading = true);

    try {
      await ref
          .read(authRepositoryProvider)
          .signIn(identity: 'duong@example.com', password: 'user123');
      if (mounted) {
        AppToast.show(context, 'Đăng nhập nhanh Học viên thành công.');
        context.go('/home');
      }
    } catch (error) {
      if (mounted) AppToast.show(context, error.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRegister = _mode == AuthPageMode.register;
    final isForgot = _mode == AuthPageMode.forgotPassword;

    final title = switch (_mode) {
      AuthPageMode.register => 'Chào mừng nhà thám hiểm!',
      AuthPageMode.login => 'Tiếp tục hành trình',
      AuthPageMode.forgotPassword => 'Khôi phục mật khẩu',
    };

    final description = switch (_mode) {
      AuthPageMode.register =>
        'Tạo hồ sơ để nhận hộ chiếu KoreaQuest và bắt đầu tích lũy XP.',
      AuthPageMode.login =>
        'Đăng nhập để tiếp tục các chặng thử thách văn hóa Hàn Quốc.',
      AuthPageMode.forgotPassword =>
        'Nhập email của bạn để nhận hướng dẫn khôi phục mật khẩu.',
    };

    return AppScaffold(
      body: ResponsiveContent(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'KOREAQUEST · HÀNH TRÌNH KHÁM PHÁ',
                        style: TextStyle(
                          color: AppColors.coral,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        description,
                        style: TextStyle(color: AppColors.muted),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Segmented Button to switch between Login and Register
                      if (!isForgot) ...[
                        SegmentedButton<AuthPageMode>(
                          segments: const [
                            ButtonSegment(
                              value: AuthPageMode.login,
                              icon: Icon(Icons.login_rounded),
                              label: Text('Đăng nhập'),
                            ),
                            ButtonSegment(
                              value: AuthPageMode.register,
                              icon: Icon(Icons.person_add_alt_1_rounded),
                              label: Text('Đăng ký'),
                            ),
                          ],
                          selected: {_mode},
                          onSelectionChanged: _isLoading
                              ? null
                              : (selection) =>
                                    setState(() => _mode = selection.first),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],

                      // Form fields
                      if (isRegister) ...[
                        AppTextField(
                          label: 'Họ và tên',
                          hint: 'Phạm Văn Dương',
                          controller: _fullNameController,
                          prefixIcon: Icons.person_outline_rounded,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          label: 'Tên hiển thị',
                          hint: 'Dương',
                          controller: _displayNameController,
                          prefixIcon: Icons.badge_outlined,
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],

                      AppTextField(
                        label: isRegister
                            ? 'Email'
                            : 'Email hoặc Tên đăng nhập',
                        hint: isRegister
                            ? 'duong@example.com'
                            : 'Nhập admin hoặc email',
                        controller: _identityController,
                        prefixIcon: Icons.email_outlined,
                      ),

                      if (!isForgot) ...[
                        const SizedBox(height: AppSpacing.md),
                        PasswordField(
                          label: 'Mật khẩu',
                          controller: _passwordController,
                        ),
                      ],

                      const SizedBox(height: AppSpacing.lg),

                      // Primary action button
                      PrimaryButton(
                        label: switch (_mode) {
                          AuthPageMode.register => 'Tạo tài khoản',
                          AuthPageMode.login => 'Đăng nhập',
                          AuthPageMode.forgotPassword => 'Gửi hướng dẫn',
                        },
                        isLoading: _isLoading,
                        onPressed: _submit,
                      ),

                      const SizedBox(height: AppSpacing.xs),

                      if (_mode == AuthPageMode.login)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _isLoading
                                ? null
                                : () => setState(
                                    () => _mode = AuthPageMode.forgotPassword,
                                  ),
                            child: const Text('Quên mật khẩu?'),
                          ),
                        ),

                      if (isForgot) ...[
                        const SizedBox(height: AppSpacing.sm),
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () =>
                                    setState(() => _mode = AuthPageMode.login),
                          child: const Text('Quay lại Đăng nhập'),
                        ),
                      ],

                      // Quick Demo Accounts Section
                      const SizedBox(height: AppSpacing.md),
                      const Divider(),
                      const SizedBox(height: AppSpacing.sm),

                      _QuickDemoSection(
                        isLoading: _isLoading,
                        onLoginAdmin: _quickLoginAdmin,
                        onLoginStudent: _quickLoginStudent,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickDemoSection extends StatelessWidget {
  const _QuickDemoSection({
    required this.isLoading,
    required this.onLoginAdmin,
    required this.onLoginStudent,
  });

  final bool isLoading;
  final VoidCallback onLoginAdmin;
  final VoidCallback onLoginStudent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt_rounded, color: AppColors.coral, size: 20),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Tài khoản thử nghiệm nhanh',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Chọn 1-chạm để tự động đăng nhập và trải nghiệm các vai trò:',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Admin demo button
          _DemoAccountTile(
            roleLabel: 'Admin',
            roleColor: AppColors.coral,
            identity: 'admin / admin123',
            description: 'Trang quản trị & duyệt địa điểm (/admin)',
            icon: Icons.admin_panel_settings_rounded,
            isLoading: isLoading,
            onTap: onLoginAdmin,
          ),

          const SizedBox(height: AppSpacing.xs),

          // Student demo button
          _DemoAccountTile(
            roleLabel: 'Học viên',
            roleColor: AppColors.teal,
            identity: 'duong@example.com',
            description: 'Hành trình trải nghiệm văn hóa (/home)',
            icon: Icons.school_rounded,
            isLoading: isLoading,
            onTap: onLoginStudent,
          ),
        ],
      ),
    );
  }
}

class _DemoAccountTile extends StatelessWidget {
  const _DemoAccountTile({
    required this.roleLabel,
    required this.roleColor,
    required this.identity,
    required this.description,
    required this.icon,
    required this.isLoading,
    required this.onTap,
  });

  final String roleLabel;
  final Color roleColor;
  final String identity;
  final String description;
  final IconData icon;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppRadius.small),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(AppRadius.small),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: roleColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 14, color: roleColor),
                    const SizedBox(width: 4),
                    Text(
                      roleLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: roleColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      identity,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      description,
                      style: TextStyle(fontSize: 11, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: AppColors.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
