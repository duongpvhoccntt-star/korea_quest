import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:korea_quest/design_system/colors/app_colors.dart';
import 'package:korea_quest/design_system/components/app_buttons.dart';
import 'package:korea_quest/design_system/components/app_structure.dart';
import 'package:korea_quest/design_system/components/responsive_content.dart';
import 'package:korea_quest/design_system/radius/app_radius.dart';
import 'package:korea_quest/design_system/shadows/app_shadows.dart';
import 'package:korea_quest/design_system/spacing/app_spacing.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) => AppScaffold(
    showFooter: true,
    body: SingleChildScrollView(
      child: ResponsiveContent(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.section),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 850;
              final copy = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'KHÁM PHÁ HÀN QUỐC THEO CÁCH CỦA BẠN',
                    style: TextStyle(
                      color: AppColors.coral,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Mỗi điểm đến,\nmột chương phiêu lưu.',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: compact ? 42 : 64,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Đọc chuyện xưa, giải thử thách nhỏ và sưu tầm dấu mộc độc đáo qua từng địa danh nổi tiếng của Hàn Quốc.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: AppColors.muted),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      PrimaryButton(
                        label: 'Bắt đầu hành trình',
                        onPressed: () => context.go('/register'),
                      ),
                      SecondaryButton(
                        label: 'Xem bản mẫu',
                        onPressed: () => context.go('/home'),
                      ),
                    ],
                  ),
                ],
              );
              final map = _QuestMap(compact: compact);
              return compact
                  ? Column(
                      children: [
                        copy,
                        const SizedBox(height: AppSpacing.xxl),
                        map,
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(child: copy),
                        const SizedBox(width: AppSpacing.xxl),
                        Expanded(child: map),
                      ],
                    );
            },
          ),
        ),
      ),
    ),
  );
}

class _QuestMap extends StatelessWidget {
  const _QuestMap({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    height: compact ? 360 : 470,
    decoration: BoxDecoration(
      color: AppColors.paper,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(42),
        topRight: Radius.circular(42),
        bottomRight: Radius.circular(42),
        bottomLeft: Radius.circular(100),
      ),
      border: Border.all(color: AppColors.line),
      boxShadow: AppShadows.large,
    ),
    child: Stack(
      children: [
        const Positioned(
          left: 30,
          top: 28,
          child: Text(
            'Bản đồ phiêu lưu\nSeoul → Busan → Jeju',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const _MapNode(left: 70, top: 145, icon: '🏯', label: 'Gyeongbokgung'),
        const _MapNode(right: 70, top: 100, icon: '🏘️', label: 'Bukchon'),
        const _MapNode(right: 55, bottom: 70, icon: '🌋', label: 'Jeju'),
        Positioned(
          left: 28,
          right: 28,
          bottom: 22,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.navy,
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hành trình hiện tại',
                  style: TextStyle(color: Colors.white70),
                ),
                Text(
                  'Cung điện Gyeongbokgung · 62%',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8),
                LinearProgressIndicator(value: .62, color: AppColors.gold),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _MapNode extends StatelessWidget {
  const _MapNode({
    required this.icon,
    required this.label,
    this.left,
    this.right,
    this.top,
    this.bottom,
  });

  final String icon;
  final String label;
  final double? left;
  final double? right;
  final double? top;
  final double? bottom;

  @override
  Widget build(BuildContext context) => Positioned(
    left: left,
    right: right,
    top: top,
    bottom: bottom,
    child: Semantics(
      label: label,
      child: CircleAvatar(
        radius: 29,
        backgroundColor: AppColors.coral,
        child: Text(icon, style: const TextStyle(fontSize: 23)),
      ),
    ),
  );
}
