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
import 'package:korea_quest/design_system/shadows/app_shadows.dart';
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
    if (oldWidget.mode != widget.mode) _mode = widget.mode;
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
      } else if (identity.toLowerCase() == 'admin' && password == 'admin123') {
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
        // Login mode — nếu là email admin thì đăng nhập qua Supabase Admin
        final isAdminEmail = identity.toLowerCase() == 'admin@koreaquest.com';
        if (isAdminEmail) {
          await ref
              .read(adminRepositoryProvider)
              .signIn(email: identity, password: password);
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
      if (mounted) AppToast.show(context, error.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _quickLoginAdmin() async {
    const identity = 'admin';
    const password = 'admin123';
    _identityController.text = identity;
    _passwordController.text = password;
    setState(() => _isLoading = true);

    try {
      ref.read(adminDemoOverrideProvider.notifier).enable();
      await ref
          .read(adminRepositoryProvider)
          .signIn(email: identity, password: password);
      await ref
          .read(authRepositoryProvider)
          .signIn(identity: identity, password: password);
      ref.invalidate(adminAccessProvider);
      ref.invalidate(adminLocationsProvider);
      if (mounted) {
        AppToast.show(context, 'Đăng nhập Quản trị viên thành công.');
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
      AuthPageMode.register => 'Mở hộ chiếu KoreaQuest',
      AuthPageMode.login => 'Đăng nhập',
      AuthPageMode.forgotPassword => 'Khôi phục mật khẩu',
    };

    final description = switch (_mode) {
      AuthPageMode.register =>
        'Tạo hồ sơ du hành để nhận XP, huy hiệu và dấu mộc sau mỗi địa điểm.',
      AuthPageMode.login =>
        'Chào mừng bạn quay lại với cuốn nhật ký khám phá văn hóa Hàn Quốc.',
      AuthPageMode.forgotPassword =>
        'Nhập email của bạn để nhận hướng dẫn khôi phục mật khẩu.',
    };

    return AppScaffold(
      showFooter: false,
      body: SingleChildScrollView(
        primary: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ColoredBox(
              color: AppColors.pageBg,
              child: ResponsiveContent(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                  child: _AuthPostcard(
                    form: _AuthFormPanel(
                      mode: _mode,
                      title: title,
                      description: description,
                      isLoading: _isLoading,
                      isRegister: isRegister,
                      isForgot: isForgot,
                      identityController: _identityController,
                      passwordController: _passwordController,
                      fullNameController: _fullNameController,
                      displayNameController: _displayNameController,
                      onSubmit: _submit,
                      onModeChanged: (mode) => setState(() => _mode = mode),
                      onQuickLoginAdmin: _quickLoginAdmin,
                      onQuickLoginStudent: _quickLoginStudent,
                    ),
                  ),
                ),
              ),
            ),
            const AppFooter(),
          ],
        ),
      ),
    );
  }
}

class _AuthPostcard extends StatelessWidget {
  const _AuthPostcard({required this.form});

  final Widget form;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      border: Border.all(color: AppColors.borderSoft),
      boxShadow: AppShadows.large,
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 900;
          final visual = const _TravelVisualPanel();
          if (!wide) {
            return Column(children: [visual, form]);
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(flex: 5, child: _TravelVisualPanel()),
              Expanded(flex: 7, child: form),
            ],
          );
        },
      ),
    ),
  );
}

class _TravelVisualPanel extends StatelessWidget {
  const _TravelVisualPanel();

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 420),
    padding: const EdgeInsets.all(AppSpacing.xl),
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.skyLight, AppColors.palePink],
      ),
    ),
    child: Stack(
      children: [
        const Positioned(
          right: -12,
          top: 18,
          child: _StampBadge(label: 'SEOUL', icon: Icons.local_florist),
        ),
        const Positioned(
          left: -8,
          bottom: 12,
          child: _StampBadge(label: 'PASS', icon: Icons.confirmation_num),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const _PillLabel(label: '한국 여행 · Khám phá xứ Kim Chi'),
            const SizedBox(height: AppSpacing.xxl),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tiếp tục hành trình Hàn Quốc của bạn',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.stitchText,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Lưu từng bước chân qua các vùng đất kỳ thú, tích lũy tem du hành và chinh phục kho tàng văn hóa rực rỡ.',
                  style: TextStyle(color: AppColors.stitchMuted, height: 1.6),
                ),
                const SizedBox(height: AppSpacing.lg),
                const _AchievementPreview(),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}

class _AuthFormPanel extends StatelessWidget {
  const _AuthFormPanel({
    required this.mode,
    required this.title,
    required this.description,
    required this.isLoading,
    required this.isRegister,
    required this.isForgot,
    required this.identityController,
    required this.passwordController,
    required this.fullNameController,
    required this.displayNameController,
    required this.onSubmit,
    required this.onModeChanged,
    required this.onQuickLoginAdmin,
    required this.onQuickLoginStudent,
  });

  final AuthPageMode mode;
  final String title;
  final String description;
  final bool isLoading;
  final bool isRegister;
  final bool isForgot;
  final TextEditingController identityController;
  final TextEditingController passwordController;
  final TextEditingController fullNameController;
  final TextEditingController displayNameController;
  final VoidCallback onSubmit;
  final ValueChanged<AuthPageMode> onModeChanged;
  final VoidCallback onQuickLoginAdmin;
  final VoidCallback onQuickLoginStudent;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(AppSpacing.xl),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _PillLabel(label: 'KoreaQuest Passport'),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.stitchText,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              description,
              style: const TextStyle(color: AppColors.stitchMuted),
            ),
            const SizedBox(height: AppSpacing.lg),
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
                selected: {mode},
                onSelectionChanged: isLoading
                    ? null
                    : (selection) => onModeChanged(selection.first),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            if (isRegister) ...[
              AppTextField(
                label: 'Họ và tên',
                hint: 'Phạm Văn Dương',
                controller: fullNameController,
                prefixIcon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Tên hiển thị',
                hint: 'Dương',
                controller: displayNameController,
                prefixIcon: Icons.badge_outlined,
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            AppTextField(
              label: isRegister ? 'Email' : 'Email hoặc tên đăng nhập',
              hint: isRegister ? 'duong@example.com' : 'Nhập admin hoặc email',
              controller: identityController,
              prefixIcon: Icons.email_outlined,
            ),
            if (!isForgot) ...[
              const SizedBox(height: AppSpacing.md),
              PasswordField(label: 'Mật khẩu', controller: passwordController),
            ],
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: switch (mode) {
                AuthPageMode.register => 'Tạo tài khoản',
                AuthPageMode.login => 'Đăng nhập vào hành trình',
                AuthPageMode.forgotPassword => 'Gửi hướng dẫn',
              },
              isLoading: isLoading,
              onPressed: onSubmit,
            ),
            if (mode == AuthPageMode.login)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: isLoading
                      ? null
                      : () => onModeChanged(AuthPageMode.forgotPassword),
                  child: const Text('Quên mật khẩu?'),
                ),
              ),
            if (isForgot)
              TextButton(
                onPressed: isLoading
                    ? null
                    : () => onModeChanged(AuthPageMode.login),
                child: const Text('Quay lại đăng nhập'),
              ),
            const SizedBox(height: AppSpacing.md),
            _QuickDemoSection(
              isLoading: isLoading,
              onLoginAdmin: onQuickLoginAdmin,
              onLoginStudent: onQuickLoginStudent,
            ),
          ],
        ),
      ),
    ),
  );
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
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: AppColors.skyLight.withValues(alpha: .45),
      borderRadius: BorderRadius.circular(AppRadius.large),
      border: Border.all(color: AppColors.borderSoft),
    ),
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.bolt_rounded,
                color: AppColors.koreanRed,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Tài khoản thử nghiệm nhanh',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'Chọn một vai trò để vào nhanh bản demo.',
            style: TextStyle(color: AppColors.stitchMuted),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Admin button — dùng tài khoản thật Supabase
          _DemoAccountTile(
            roleLabel: 'Admin',
            roleColor: AppColors.koreanRed,
            identity: 'admin / admin123',
            description: 'Quản trị và duyệt địa điểm',
            icon: Icons.admin_panel_settings_rounded,
            isLoading: isLoading,
            onTap: onLoginAdmin,
          ),
          const SizedBox(height: AppSpacing.xs),
          _DemoAccountTile(
            roleLabel: 'Học viên',
            roleColor: AppColors.koreanBlue,
            identity: 'duong@example.com',
            description: 'Trải nghiệm hành trình văn hóa',
            icon: Icons.school_rounded,
            isLoading: isLoading,
            onTap: onLoginStudent,
          ),
        ],
      ),
    ),
  );
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
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(AppRadius.medium),
    child: InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(AppRadius.medium),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: roleColor.withValues(alpha: .12),
              child: Icon(icon, color: roleColor, size: 20),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    roleLabel,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  Text(identity, style: const TextStyle(fontSize: 12)),
                  Text(
                    description,
                    style: const TextStyle(
                      color: AppColors.stitchMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    ),
  );
}

class _AchievementPreview extends StatelessWidget {
  const _AchievementPreview();

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .92),
      borderRadius: BorderRadius.circular(AppRadius.large),
      boxShadow: AppShadows.small,
    ),
    child: const Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.butter,
            child: Icon(
              Icons.military_tech_rounded,
              color: AppColors.stitchText,
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '3/12 huy hiệu đã mở',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                Text(
                  '50+ câu đố văn hóa đang chờ bạn',
                  style: TextStyle(color: AppColors.stitchMuted, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _PillLabel extends StatelessWidget {
  const _PillLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .86),
      borderRadius: BorderRadius.circular(AppRadius.round),
      border: Border.all(color: AppColors.borderSoft),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.koreanRed,
          fontWeight: FontWeight.w900,
          letterSpacing: .4,
          fontSize: 12,
        ),
      ),
    ),
  );
}

class _StampBadge extends StatelessWidget {
  const _StampBadge({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Transform.rotate(
    angle: -.18,
    child: Container(
      width: 74,
      height: 74,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .72),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.koreanRed, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.koreanRed, size: 22),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
          ),
        ],
      ),
    ),
  );
}
