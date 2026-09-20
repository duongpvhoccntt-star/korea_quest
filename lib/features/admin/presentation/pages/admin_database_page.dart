import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:korea_quest/app/app_config.dart';
import 'package:korea_quest/design_system/colors/app_colors.dart';
import 'package:korea_quest/design_system/components/app_buttons.dart';
import 'package:korea_quest/design_system/components/app_feedback.dart';
import 'package:korea_quest/design_system/components/responsive_content.dart';
import 'package:korea_quest/design_system/spacing/app_spacing.dart';
import 'package:korea_quest/features/admin/presentation/providers/admin_providers.dart';
import 'package:korea_quest/features/admin/presentation/widgets/admin_dashboard.dart';
import 'package:korea_quest/features/admin/presentation/widgets/admin_sign_in.dart';

class AdminDatabasePage extends ConsumerWidget {
  const AdminDatabasePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demoOverride = ref.watch(adminDemoOverrideProvider);
    final hasBackend = AppConfig.hasAdminBackend || demoOverride;
    if (!hasBackend) {
      return const Scaffold(body: _MissingConfiguration());
    }

    final isDemo = AppConfig.adminDemoMode || demoOverride;
    final session = ref.watch(adminSessionProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(isDemo ? 'KoreaQuest Admin · Demo' : 'KoreaQuest Admin'),
        backgroundColor: AppColors.paper,
        actions: [
          if (session.value?.isSignedIn ?? false)
            TextButton.icon(
              onPressed: () async {
                await ref.read(adminRepositoryProvider).signOut();
                ref.invalidate(adminAccessProvider);
                ref.invalidate(adminLocationsProvider);
                ref.invalidate(adminGameConfigProvider);
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Đăng xuất'),
            ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: session.when(
        loading: () => const LoadingIndicator(label: 'Đang kiểm tra phiên…'),
        error: (error, _) => ErrorState(message: error.toString()),
        data: (current) {
          if (!current.isSignedIn) return const AdminSignIn();
          final access = ref.watch(adminAccessProvider);
          return access.when(
            loading: () => const LoadingIndicator(
              label: 'Đang kiểm tra quyền Quản trị viên…',
            ),
            error: (error, _) => ErrorState(message: error.toString()),
            data: (isAdmin) =>
                isAdmin ? const AdminDashboard() : const _ForbiddenAdmin(),
          );
        },
      ),
    );
  }
}

class _MissingConfiguration extends ConsumerWidget {
  const _MissingConfiguration();

  @override
  Widget build(BuildContext context, WidgetRef ref) => ResponsiveContent(
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.settings_suggest_outlined,
                  size: 48,
                  color: AppColors.coral,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Chưa cấu hình Supabase',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Khởi động Supabase local, lấy URL/publishable key từ '
                  '`supabase status`, rồi chạy Flutter với hai dart-define: '
                  'SUPABASE_URL và SUPABASE_PUBLISHABLE_KEY.',
                ),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'Hoặc chạy nhanh bản demo không cần email/Supabase bằng '
                  '`--dart-define=ADMIN_DEMO_MODE=true`.',
                ),
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: 'Bật chế độ Demo để kiểm thử ngay',
                  icon: Icons.play_arrow_rounded,
                  onPressed: () {
                    ref.read(adminDemoOverrideProvider.notifier).enable();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _ForbiddenAdmin extends StatelessWidget {
  const _ForbiddenAdmin();

  @override
  Widget build(BuildContext context) => const ErrorState(
    title: 'Không có quyền truy cập',
    message: 'Tài khoản hiện tại không thuộc danh sách admin_users.',
  );
}
