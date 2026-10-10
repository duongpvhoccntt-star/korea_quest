import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:korea_quest/app/app_config.dart';
import 'package:korea_quest/design_system/colors/app_colors.dart';
import 'package:korea_quest/design_system/components/app_buttons.dart';
import 'package:korea_quest/design_system/components/app_feedback.dart';
import 'package:korea_quest/design_system/components/app_fields.dart';
import 'package:korea_quest/design_system/components/app_scroll_view.dart';
import 'package:korea_quest/design_system/components/app_structure.dart';
import 'package:korea_quest/design_system/components/responsive_content.dart';
import 'package:korea_quest/design_system/radius/app_radius.dart';
import 'package:korea_quest/design_system/shadows/app_shadows.dart';
import 'package:korea_quest/design_system/spacing/app_spacing.dart';
import 'package:korea_quest/features/admin/presentation/providers/admin_providers.dart';
import 'package:korea_quest/features/auth/domain/auth_models.dart';
import 'package:korea_quest/features/auth/presentation/providers/auth_providers.dart';
import 'package:korea_quest/l10n/app_strings.dart';

enum AuthPageMode { register, login, forgotPassword }

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({required this.mode, this.redirectTo, super.key});

  final AuthPageMode mode;
  final String? redirectTo;

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  late AuthPageMode _mode;
  final _identityController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

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
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final strings = appStrings(context);
    final identity = _identityController.text.trim();
    final password = _passwordController.text;

    final validationError = _validate(identity: identity, password: password);
    if (validationError != null) {
      setState(() => _errorMessage = validationError);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final repository = ref.read(authRepositoryProvider);
      if (_mode == AuthPageMode.forgotPassword) {
        await repository.sendPasswordResetEmail(email: identity);
        if (mounted) {
          AppToast.show(context, strings.resetEmailSent);
          setState(() => _mode = AuthPageMode.login);
        }
      } else if (_mode == AuthPageMode.register) {
        final fullName = _fullNameController.text.trim();
        final displayName = _displayNameController.text.trim();
        await repository.register(
          fullName: fullName,
          displayName: displayName,
          email: identity,
          password: password,
        );
        if (mounted) {
          if (repository.currentUser == null) {
            AppToast.show(context, strings.accountCreatedVerify);
            setState(() => _mode = AuthPageMode.login);
          } else {
            AppToast.show(context, strings.accountCreated);
            context.go(widget.redirectTo ?? '/explore');
          }
        }
      } else {
        final user = await repository.signIn(
          identity: identity,
          password: password,
        );
        if (user.isAdmin && _usesDemoAuth) {
          await _startDemoAdminSession(identity, password);
        }
        if (user.isAdmin) {
          ref.invalidate(adminAccessProvider);
          ref.invalidate(adminLocationsProvider);
        }
        if (mounted) {
          AppToast.show(
            context,
            user.isAdmin ? strings.adminSignedIn : strings.signedIn,
          );
          context.go(
            user.isAdmin ? '/admin' : (widget.redirectTo ?? '/explore'),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        setState(() => _errorMessage = error.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String? _validate({required String identity, required String password}) {
    final strings = appStrings(context);
    if (identity.isEmpty) return strings.emailRequired;
    if (_mode != AuthPageMode.login || AppConfig.hasSupabaseConfiguration) {
      final at = identity.indexOf('@');
      if (at <= 0 || identity.indexOf('.', at) <= at + 1) {
        return strings.invalidEmail;
      }
    }
    if (_mode == AuthPageMode.forgotPassword) return null;
    if (password.isEmpty) return strings.passwordRequired;
    if (_mode == AuthPageMode.register) {
      if (_fullNameController.text.trim().isEmpty) {
        return strings.fullNameRequired;
      }
      if (password.length < 8) return strings.passwordAtLeast8;
      if (_confirmPasswordController.text != password) {
        return strings.confirmationMismatch;
      }
    }
    return null;
  }

  bool get _usesDemoAuth =>
      !AppConfig.hasSupabaseConfiguration || AppConfig.adminDemoMode;

  Future<void> _startDemoAdminSession(String identity, String password) async {
    ref.read(adminDemoOverrideProvider.notifier).enable();
    await ref
        .read(adminRepositoryProvider)
        .signIn(email: identity, password: password);
  }

  Future<void> _quickLoginAdmin() async {
    final strings = appStrings(context);
    const identity = 'admin';
    const password = 'admin123';
    _identityController.text = identity;
    _passwordController.text = password;
    setState(() => _isLoading = true);

    try {
      final user = await ref
          .read(authRepositoryProvider)
          .signIn(identity: identity, password: password);
      if (!user.isAdmin) {
        throw AuthException(strings.adminNoAccess);
      }
      await _startDemoAdminSession(identity, password);
      ref.invalidate(adminAccessProvider);
      ref.invalidate(adminLocationsProvider);
      if (mounted) {
        AppToast.show(context, strings.adminSignedIn);
        context.go('/admin');
      }
    } catch (error) {
      if (mounted) setState(() => _errorMessage = error.toString());
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
        AppToast.show(context, appStrings(context).studentQuickSignedIn);
        context.go(widget.redirectTo ?? '/explore');
      }
    } catch (error) {
      if (mounted) setState(() => _errorMessage = error.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = appStrings(context);
    final isRegister = _mode == AuthPageMode.register;
    final isForgot = _mode == AuthPageMode.forgotPassword;

    final title = switch (_mode) {
      AuthPageMode.register => strings.openPassport,
      AuthPageMode.login => strings.signIn,
      AuthPageMode.forgotPassword => strings.recoverPassword,
    };

    final description = switch (_mode) {
      AuthPageMode.register => strings.registerDescription,
      AuthPageMode.login => strings.loginDescription,
      AuthPageMode.forgotPassword => strings.forgotDescription,
    };

    return AppScaffold(
      showFooter: false,
      body: AppScrollView(
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
                      confirmPasswordController: _confirmPasswordController,
                      fullNameController: _fullNameController,
                      displayNameController: _displayNameController,
                      errorMessage: _errorMessage,
                      showDemoAccounts: _usesDemoAuth,
                      onSubmit: _submit,
                      onModeChanged: (mode) => setState(() {
                        _mode = mode;
                        _errorMessage = null;
                      }),
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
          final visual = _TravelVisualPanel(compact: !wide);
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
  const _TravelVisualPanel({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) => Container(
    height: compact ? 210 : 640,
    decoration: BoxDecoration(
      image: DecorationImage(
        image: const AssetImage('assets/images/auth_gyeongbokgung_mist.jpg'),
        fit: BoxFit.cover,
        alignment: compact ? Alignment.center : Alignment.centerRight,
      ),
    ),
    child: Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          key: ValueKey('auth-korea-scenery'),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x0DEF646B), Color(0x4DEF646B), Color(0xD9A83238)],
              stops: [0, .52, 1],
            ),
          ),
        ),
        if (!compact)
          const Positioned(
            right: -12,
            top: 18,
            child: _StampBadge(label: 'SEOUL', icon: Icons.local_florist),
          ),
        if (!compact)
          const Positioned(
            left: -8,
            bottom: 12,
            child: _StampBadge(label: 'PASS', icon: Icons.confirmation_num),
          ),
        Padding(
          padding: EdgeInsets.all(compact ? AppSpacing.md : AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _PillLabel(label: appStrings(context).travelTagline),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appStrings(context).continueKoreaJourney,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style:
                        (compact
                                ? Theme.of(context).textTheme.headlineSmall
                                : Theme.of(context).textTheme.headlineMedium)
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              shadows: const [
                                Shadow(
                                  color: Color(0x66000000),
                                  blurRadius: 12,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                  ),
                  if (!compact) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      appStrings(context).travelVisualDescription,
                      style: const TextStyle(
                        color: Colors.white,
                        height: 1.6,
                        shadows: [
                          Shadow(color: Color(0x66000000), blurRadius: 8),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const _AchievementPreview(),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _AuthFormPanel extends ConsumerWidget {
  const _AuthFormPanel({
    required this.mode,
    required this.title,
    required this.description,
    required this.isLoading,
    required this.isRegister,
    required this.isForgot,
    required this.identityController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.fullNameController,
    required this.displayNameController,
    required this.errorMessage,
    required this.showDemoAccounts,
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
  final TextEditingController confirmPasswordController;
  final TextEditingController fullNameController;
  final TextEditingController displayNameController;
  final String? errorMessage;
  final bool showDemoAccounts;
  final VoidCallback onSubmit;
  final ValueChanged<AuthPageMode> onModeChanged;
  final VoidCallback onQuickLoginAdmin;
  final VoidCallback onQuickLoginStudent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = appStrings(context);
    final compact = MediaQuery.sizeOf(context).width < 600;
    return Padding(
      padding: EdgeInsets.all(compact ? AppSpacing.md : AppSpacing.xl),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _AuthBrand(),
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
                compact
                    ? Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isLoading
                                  ? null
                                  : () => onModeChanged(AuthPageMode.login),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: mode == AuthPageMode.login
                                    ? AppColors.palePink
                                    : Colors.white,
                                foregroundColor: AppColors.koreanRed,
                                side: const BorderSide(
                                  color: AppColors.borderSoft,
                                ),
                              ),
                              child: Text(strings.signIn),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isLoading
                                  ? null
                                  : () => onModeChanged(AuthPageMode.register),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: mode == AuthPageMode.register
                                    ? AppColors.palePink
                                    : Colors.white,
                                foregroundColor: AppColors.koreanRed,
                                side: const BorderSide(
                                  color: AppColors.borderSoft,
                                ),
                              ),
                              child: Text(strings.register),
                            ),
                          ),
                        ],
                      )
                    : SegmentedButton<AuthPageMode>(
                        segments: [
                          ButtonSegment(
                            value: AuthPageMode.login,
                            icon: const Icon(Icons.login_rounded),
                            label: Text(strings.signIn),
                          ),
                          ButtonSegment(
                            value: AuthPageMode.register,
                            icon: const Icon(Icons.person_add_alt_1_rounded),
                            label: Text(strings.register),
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
                  label: strings.fullName,
                  hint: 'Phạm Văn Dương',
                  controller: fullNameController,
                  prefixIcon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: strings.displayName,
                  hint: 'Dương',
                  controller: displayNameController,
                  prefixIcon: Icons.badge_outlined,
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              AppTextField(
                label: strings.email,
                hint: showDemoAccounts && !isRegister
                    ? strings.demoEmailHint
                    : 'ban@example.com',
                controller: identityController,
                prefixIcon: Icons.email_outlined,
              ),
              if (!isForgot) ...[
                const SizedBox(height: AppSpacing.md),
                PasswordField(
                  label: strings.password,
                  controller: passwordController,
                ),
              ],
              if (isRegister) ...[
                const SizedBox(height: AppSpacing.md),
                PasswordField(
                  label: strings.confirmPassword,
                  controller: confirmPasswordController,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  strings.passwordHelp,
                  style: const TextStyle(
                    color: AppColors.stitchMuted,
                    fontSize: 12,
                  ),
                ),
              ],
              if (errorMessage != null) ...[
                const SizedBox(height: AppSpacing.md),
                _AuthErrorMessage(message: errorMessage!),
              ],
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: switch (mode) {
                  AuthPageMode.register => strings.createAccount,
                  AuthPageMode.login => strings.signInJourney,
                  AuthPageMode.forgotPassword => strings.sendInstructions,
                },
                isLoading: isLoading,
                onPressed: onSubmit,
              ),
              if (!isForgot) ...[
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () {
                            ref
                                .read(guestModeProvider.notifier)
                                .enableGuestMode();
                            context.go('/explore');
                          },
                    icon: const Icon(
                      Icons.explore_outlined,
                      color: AppColors.teal,
                    ),
                    label: const Text(
                      'Khám phá với tư cách Khách',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                        horizontal: AppSpacing.md,
                      ),
                      side: const BorderSide(color: AppColors.teal),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                      ),
                    ),
                  ),
                ),
              ],
              if (mode == AuthPageMode.login)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: isLoading
                        ? null
                        : () => onModeChanged(AuthPageMode.forgotPassword),
                    child: Text(strings.forgotPassword),
                  ),
                ),
              if (isForgot)
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () => onModeChanged(AuthPageMode.login),
                  child: Text(strings.backToSignIn),
                ),
              if (showDemoAccounts && mode == AuthPageMode.login) ...[
                const SizedBox(height: AppSpacing.md),
                _QuickDemoSection(
                  isLoading: isLoading,
                  onLoginAdmin: onQuickLoginAdmin,
                  onLoginStudent: onQuickLoginStudent,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthBrand extends StatelessWidget {
  const _AuthBrand();

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Image.asset(
        'assets/images/koreaquest_logo_mark.png',
        key: const ValueKey('auth-koreaquest-logo'),
        width: 64,
        height: 64,
        filterQuality: FilterQuality.high,
      ),
      const SizedBox(width: AppSpacing.sm),
      const Flexible(child: _PillLabel(label: 'KoreaQuest Passport')),
    ],
  );
}

class _AuthErrorMessage extends StatelessWidget {
  const _AuthErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.palePink,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.koreanRed),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.danger),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(message)),
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
              Expanded(
                child: Text(
                  appStrings(context).quickDemoAccounts,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            appStrings(context).quickDemoDescription,
            style: const TextStyle(color: AppColors.stitchMuted),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Admin button — dùng tài khoản thật Supabase
          _DemoAccountTile(
            roleLabel: 'Admin',
            roleColor: AppColors.koreanRed,
            identity: 'admin / admin123',
            description: appStrings(context).adminDemoDescription,
            icon: Icons.admin_panel_settings_rounded,
            isLoading: isLoading,
            onTap: onLoginAdmin,
          ),
          const SizedBox(height: AppSpacing.xs),
          _DemoAccountTile(
            roleLabel: appStrings(context).student,
            roleColor: AppColors.koreanBlue,
            identity: 'duong@example.com',
            description: appStrings(context).studentDemoDescription,
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
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.butter,
            child: Icon(
              Icons.military_tech_rounded,
              color: AppColors.stitchText,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appStrings(context).earnedBadgesMessage,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                Text(
                  appStrings(context).quizWaiting,
                  style: const TextStyle(
                    color: AppColors.stitchMuted,
                    fontSize: 12,
                  ),
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
