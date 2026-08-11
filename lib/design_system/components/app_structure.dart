import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:korea_quest/core/responsive/responsive_breakpoints.dart';
import 'package:korea_quest/design_system/colors/app_colors.dart';
import 'package:korea_quest/design_system/components/progress_components.dart';
import 'package:korea_quest/design_system/components/responsive_content.dart';
import 'package:korea_quest/design_system/spacing/app_spacing.dart';
import 'package:korea_quest/shared/providers/repository_providers.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.body,
    super.key,
    this.showHeader = true,
    this.showFooter = false,
  });

  final Widget body;
  final bool showHeader;
  final bool showFooter;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: showHeader ? const AppHeader() : null,
    body: Column(
      children: [
        Expanded(child: body),
        if (showFooter) const AppFooter(),
      ],
    ),
  );
}

class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => AppScaffold(body: child);
}

class AppHeader extends ConsumerWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  static const _destinations = [
    ('Trang chủ', '/home'),
    ('Khám phá', '/explore'),
    ('Hộ chiếu', '/passport'),
    ('Thành tích', '/achievements'),
    ('Hồ sơ', '/profile'),
  ];

  @override
  Size get preferredSize => const Size.fromHeight(78);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop =
        MediaQuery.sizeOf(context).width >= ResponsiveBreakpoints.desktop;
    final path = GoRouterState.of(context).uri.path;
    final user = ref.watch(currentUserProvider).value;
    final progress = ref.watch(userProgressProvider).value;
    return AppBar(
      toolbarHeight: 78,
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: AppColors.cream.withValues(alpha: .96),
      titleSpacing: AppSpacing.lg,
      title: InkWell(
        onTap: () => context.go('/home'),
        borderRadius: BorderRadius.circular(12),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 21,
                backgroundColor: AppColors.coral,
                foregroundColor: Colors.white,
                child: Text(
                  'KQ',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              SizedBox(width: 10),
              Text(
                'KoreaQuest',
                style: TextStyle(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: isDesktop
          ? [
              for (final destination in _destinations)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: TextButton(
                    onPressed: () => context.go(destination.$2),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.navy,
                      backgroundColor: path.startsWith(destination.$2)
                          ? Colors.white
                          : Colors.transparent,
                    ),
                    child: Text(destination.$1),
                  ),
                ),
              if (progress != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Center(
                    child: Text(
                      'LV.${progress.level} · ${progress.currentXp} XP',
                      style: const TextStyle(
                        color: AppColors.coral,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              IconButton(
                tooltip: 'Cài đặt',
                onPressed: () => context.go('/settings'),
                icon: const Icon(Icons.settings_outlined),
              ),
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.lg),
                child: UserAvatar(displayName: user?.displayName ?? 'Dương'),
              ),
            ]
          : [
              PopupMenuButton<String>(
                tooltip: 'Mở điều hướng',
                icon: const Icon(Icons.menu_rounded),
                onSelected: context.go,
                itemBuilder: (_) => [
                  for (final destination in _destinations)
                    PopupMenuItem(
                      value: destination.$2,
                      child: Text(destination.$1),
                    ),
                  const PopupMenuItem(
                    value: '/settings',
                    child: Text('Cài đặt'),
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
    );
  }
}

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AppColors.navy,
    child: ResponsiveContent(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        runSpacing: AppSpacing.md,
        children: [
          const Text(
            'KoreaQuest · Hành trình văn hóa Hàn Quốc',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          Text(
            '© 2026 · Phase 1 Foundation',
            style: TextStyle(color: Colors.white.withValues(alpha: .7)),
          ),
        ],
      ),
    ),
  );
}
