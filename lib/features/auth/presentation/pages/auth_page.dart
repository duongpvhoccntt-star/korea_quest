import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:korea_quest/design_system/colors/app_colors.dart';
import 'package:korea_quest/design_system/components/app_buttons.dart';
import 'package:korea_quest/design_system/components/app_feedback.dart';
import 'package:korea_quest/design_system/components/app_fields.dart';
import 'package:korea_quest/design_system/components/app_structure.dart';
import 'package:korea_quest/design_system/components/responsive_content.dart';
import 'package:korea_quest/design_system/spacing/app_spacing.dart';

enum AuthPageMode { register, login, forgotPassword }

class AuthPage extends StatelessWidget {
  const AuthPage({required this.mode, super.key});

  final AuthPageMode mode;

  @override
  Widget build(BuildContext context) {
    final title = switch (mode) {
      AuthPageMode.register => 'Chào mừng nhà thám hiểm!',
      AuthPageMode.login => 'Tiếp tục hành trình',
      AuthPageMode.forgotPassword => 'Khôi phục mật khẩu',
    };
    final description = switch (mode) {
      AuthPageMode.register =>
        'Tạo hồ sơ để nhận hộ chiếu KoreaQuest đầu tiên.',
      AuthPageMode.login => 'Đăng nhập bản mẫu để xem tiến độ dùng chung.',
      AuthPageMode.forgotPassword => 'Nhập email để nhận hướng dẫn khôi phục.',
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
                        'HỘ CHIẾU CỦA BẠN ĐANG CHỜ',
                        style: TextStyle(
                          color: AppColors.coral,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(description),
                      const SizedBox(height: AppSpacing.lg),
                      if (mode == AuthPageMode.register) ...[
                        const AppTextField(
                          label: 'Họ và tên',
                          hint: 'Phạm Văn Dương',
                          prefixIcon: Icons.person_outline,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        const AppTextField(
                          label: 'Tên hiển thị',
                          hint: 'Dương',
                          prefixIcon: Icons.badge_outlined,
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                      const AppTextField(
                        label: 'Email',
                        hint: 'duong@example.com',
                        prefixIcon: Icons.email_outlined,
                      ),
                      if (mode != AuthPageMode.forgotPassword) ...[
                        const SizedBox(height: AppSpacing.md),
                        const PasswordField(label: 'Mật khẩu'),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      PrimaryButton(
                        label: switch (mode) {
                          AuthPageMode.register => 'Tạo tài khoản',
                          AuthPageMode.login => 'Đăng nhập',
                          AuthPageMode.forgotPassword => 'Gửi hướng dẫn',
                        },
                        onPressed: () {
                          AppToast.show(
                            context,
                            'Đã mô phỏng thao tác thành công.',
                          );
                          if (mode != AuthPageMode.forgotPassword) {
                            context.go('/home');
                          }
                        },
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextButton(
                        onPressed: () => context.go(
                          mode == AuthPageMode.login ? '/register' : '/login',
                        ),
                        child: Text(
                          mode == AuthPageMode.login
                              ? 'Chưa có tài khoản? Đăng ký'
                              : 'Đã có tài khoản? Đăng nhập',
                        ),
                      ),
                      if (mode == AuthPageMode.login)
                        TextButton(
                          onPressed: () => context.go('/forgot-password'),
                          child: const Text('Quên mật khẩu?'),
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
