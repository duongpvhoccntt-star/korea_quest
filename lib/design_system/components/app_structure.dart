import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:korea_quest/core/responsive/responsive_breakpoints.dart';
import 'package:korea_quest/design_system/colors/app_colors.dart';
import 'package:korea_quest/design_system/components/app_buttons.dart';
import 'package:korea_quest/design_system/components/progress_components.dart';
import 'package:korea_quest/design_system/components/responsive_content.dart';
import 'package:korea_quest/design_system/radius/app_radius.dart';
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

  static const _guestDestinations = [
    ('Trang chủ', '/'),
    ('Hành trình', '/home'),
    ('Hộ chiếu', '/passport'),
    ('Hồ sơ', '/profile'),
  ];

  static const _memberDestinations = [
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
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= ResponsiveBreakpoints.desktop;
    final showXp = width >= ResponsiveBreakpoints.wide;
    final path = GoRouterState.of(context).uri.path;
    final isGuest =
        path == '/' ||
        path == '/register' ||
        path == '/login' ||
        path == '/forgot-password';
    final destinations = isGuest ? _guestDestinations : _memberDestinations;
    final user = isGuest ? null : ref.watch(currentUserProvider).value;
    final progress = isGuest ? null : ref.watch(userProgressProvider).value;

    return Material(
      color: AppColors.cream.withValues(alpha: .96),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.line)),
        ),
        child: ResponsiveContent(
          child: SizedBox(
            height: preferredSize.height,
            child: Row(
              children: [
                _BrandLockup(onTap: () => context.go('/')),
                const Spacer(),
                if (isDesktop) ...[
                  for (final destination in destinations)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xxs,
                      ),
                      child: _HeaderLink(
                        label: destination.$1,
                        selected: _isSelected(path, destination.$2),
                        onPressed: () => context.go(destination.$2),
                      ),
                    ),
                  const SizedBox(width: AppSpacing.sm),
                  if (isGuest) ...[
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('Đăng nhập'),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    PrimaryButton(
                      label: 'Bắt đầu',
                      onPressed: () => context.go('/register'),
                    ),
                  ] else ...[
                    if (showXp && progress != null)
                      Container(
                        margin: const EdgeInsets.only(right: AppSpacing.sm),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AppColors.line),
                          borderRadius: BorderRadius.circular(AppRadius.round),
                        ),
                        child: Text(
                          'LV.${progress.level}  ${progress.currentXp} XP',
                          style: const TextStyle(
                            color: AppColors.coral,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    IconButton(
                      tooltip: 'Cài đặt',
                      onPressed: () => context.go('/settings'),
                      icon: const Icon(Icons.settings_outlined),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    UserAvatar(displayName: user?.displayName ?? 'Dương'),
                  ],
                ] else
                  PopupMenuButton<String>(
                    tooltip: 'Mở điều hướng',
                    icon: const Icon(Icons.menu_rounded),
                    onSelected: context.go,
                    itemBuilder: (_) => [
                      for (final destination in destinations)
                        PopupMenuItem(
                          value: destination.$2,
                          child: Text(destination.$1),
                        ),
                      if (isGuest) ...[
                        const PopupMenuDivider(),
                        const PopupMenuItem(
                          value: '/login',
                          child: Text('Đăng nhập'),
                        ),
                        const PopupMenuItem(
                          value: '/register',
                          child: Text('Bắt đầu hành trình'),
                        ),
                      ] else
                        const PopupMenuItem(
                          value: '/settings',
                          child: Text('Cài đặt'),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static bool _isSelected(String currentPath, String destination) =>
      destination == '/'
      ? currentPath == '/'
      : currentPath.startsWith(destination);
}

class _BrandLockup extends StatelessWidget {
  const _BrandLockup({this.onTap, this.light = false});

  final VoidCallback? onTap;
  final bool light;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(AppRadius.medium),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.coral,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.paper, width: 3),
              boxShadow: const [
                BoxShadow(color: AppColors.coral, spreadRadius: 2),
              ],
            ),
            child: const Text(
              'KQ',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Georgia',
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'KoreaQuest',
                style: TextStyle(
                  color: light ? Colors.white : AppColors.navy,
                  fontSize: 19,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.4,
                ),
              ),
              Text(
                'CULTURE ADVENTURE',
                style: TextStyle(
                  color: light
                      ? Colors.white.withValues(alpha: .64)
                      : AppColors.teal,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _HeaderLink extends StatelessWidget {
  const _HeaderLink({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: onPressed,
    style: TextButton.styleFrom(
      foregroundColor: selected ? AppColors.navy : AppColors.muted,
      backgroundColor: selected ? Colors.white : Colors.transparent,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      shadowColor: AppColors.ink,
      elevation: selected ? 1 : 0,
    ),
    child: Text(label),
  );
}

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AppColors.footer,
    child: ResponsiveContent(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xxl,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final mobile = constraints.maxWidth < ResponsiveBreakpoints.mobile;
          final columns = [
            _FooterColumn(
              title: 'Khám phá',
              links: const [
                ('Địa điểm', '/explore'),
                ('Hành trình', '/home'),
                ('Huy hiệu', '/achievements'),
              ],
            ),
            _FooterColumn(
              title: 'Hỗ trợ',
              links: const [
                ('Cách hoạt động', '/'),
                ('Câu hỏi thường gặp', '/'),
                ('Liên hệ', '/'),
              ],
            ),
            _FooterColumn(
              title: 'Pháp lý',
              links: const [('Quyền riêng tư', '/'), ('Điều khoản', '/')],
            ),
          ];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: AppSpacing.xxl,
                runSpacing: AppSpacing.xl,
                children: [
                  SizedBox(
                    width: mobile
                        ? constraints.maxWidth
                        : constraints.maxWidth * .34,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _BrandLockup(light: true),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Hành trình khám phá văn hóa Hàn Quốc qua thử thách, câu chuyện và những dấu mộc đáng nhớ.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: .64),
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  for (final column in columns)
                    SizedBox(
                      width: mobile
                          ? (constraints.maxWidth - AppSpacing.xxl) / 2
                          : constraints.maxWidth * .14,
                      child: column,
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Divider(color: Colors.white.withValues(alpha: .12)),
              const SizedBox(height: AppSpacing.md),
              Text(
                '© 2026 KoreaQuest · Dự án khám phá văn hóa Hàn Quốc.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .52),
                  fontSize: 12,
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}

class _FooterColumn extends StatelessWidget {
  const _FooterColumn({required this.title, required this.links});

  final String title;
  final List<(String, String)> links;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: AppSpacing.xs),
      for (final link in links)
        TextButton(
          onPressed: () => context.go(link.$2),
          style: TextButton.styleFrom(
            foregroundColor: Colors.white.withValues(alpha: .62),
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(link.$1),
        ),
    ],
  );
}
