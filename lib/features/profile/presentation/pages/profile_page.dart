import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:korea_quest/design_system/components/app_feedback.dart';
import 'package:korea_quest/design_system/components/app_fields.dart';
import 'package:korea_quest/design_system/components/progress_components.dart';
import 'package:korea_quest/design_system/spacing/app_spacing.dart';
import 'package:korea_quest/shared/providers/repository_providers.dart';
import 'package:korea_quest/shared/widgets/module_page.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key, this.isEditing = false});

  final bool isEditing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final progress = ref.watch(userProgressProvider);
    if (user.isLoading || progress.isLoading) return const LoadingIndicator();
    if (user.hasError || progress.hasError) {
      return const ErrorState(message: 'Không thể tải hồ sơ mock.');
    }
    final profile = user.requireValue;
    final xp = progress.requireValue;
    return ModulePage(
      eyebrow: isEditing ? 'Chỉnh sửa' : 'Nhà thám hiểm',
      title: isEditing ? 'Chỉnh sửa hồ sơ' : 'Hồ sơ của ${profile.displayName}',
      description: isEditing
          ? 'Form khung sẵn sàng nối với feature state ở giai đoạn sau.'
          : 'Tổng kết những gì bạn đã học, đã đi và đã chinh phục.',
      actionLabel: isEditing ? 'Lưu thay đổi' : 'Chỉnh sửa hồ sơ',
      onAction: () {
        if (isEditing) {
          AppToast.show(context, 'Đã lưu thay đổi bản mẫu.');
          context.go('/profile');
        } else {
          context.go('/profile/edit');
        }
      },
      child: isEditing
          ? const _EditProfileForm()
          : LayoutBuilder(
              builder: (context, constraints) {
                final identity = Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      children: [
                        UserAvatar(
                          displayName: profile.displayName,
                          radius: 52,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          profile.fullName,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text('@${profile.handle} · Hà Nội, Việt Nam'),
                        const SizedBox(height: AppSpacing.md),
                        LevelBadge(level: xp.level),
                        const SizedBox(height: AppSpacing.lg),
                        XPProgressBar(progress: xp),
                      ],
                    ),
                  ),
                );
                final summary = Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Thông tin cá nhân',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        ListTile(
                          leading: const Icon(Icons.email_outlined),
                          title: const Text('duong@example.com'),
                          subtitle: const Text('Email'),
                        ),
                        const ListTile(
                          leading: Icon(Icons.language_rounded),
                          title: Text('Tiếng Việt'),
                          subtitle: Text('Ngôn ngữ'),
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.local_fire_department_outlined,
                          ),
                          title: Text('${xp.streakDays} ngày'),
                          subtitle: const Text('Chuỗi hiện tại'),
                        ),
                      ],
                    ),
                  ),
                );
                if (constraints.maxWidth < 760) {
                  return Column(
                    children: [
                      identity,
                      const SizedBox(height: AppSpacing.lg),
                      summary,
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: identity),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(flex: 2, child: summary),
                  ],
                );
              },
            ),
    );
  }
}

class _EditProfileForm extends StatelessWidget {
  const _EditProfileForm();

  @override
  Widget build(BuildContext context) => const Card(
    child: Padding(
      padding: EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          AppTextField(label: 'Họ và tên', hint: 'Phạm Văn Dương'),
          SizedBox(height: AppSpacing.md),
          AppTextField(label: 'Tên hiển thị', hint: 'Dương'),
          SizedBox(height: AppSpacing.md),
          AppTextField(label: 'Giới thiệu', hint: 'Câu chuyện của bạn…'),
        ],
      ),
    ),
  );
}
