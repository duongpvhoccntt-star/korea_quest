import 'package:flutter/material.dart';
import 'package:korea_quest/design_system/colors/app_colors.dart';
import 'package:korea_quest/design_system/radius/app_radius.dart';
import 'package:korea_quest/shared/models/domain_models.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({required this.displayName, super.key, this.radius = 22});

  final String displayName;
  final double radius;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Ảnh đại diện của $displayName',
    child: CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.coral,
      foregroundColor: Colors.white,
      child: Text(
        displayName.characters.first.toUpperCase(),
        style: TextStyle(fontWeight: FontWeight.w800, fontSize: radius * .8),
      ),
    ),
  );
}

class StatusChip extends StatelessWidget {
  const StatusChip({required this.status, super.key});

  final LocationStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, icon, color) = switch (status) {
      LocationStatus.completed => (
        'Hoàn thành',
        Icons.check_circle,
        AppColors.green,
      ),
      LocationStatus.inProgress => (
        'Đang thực hiện',
        Icons.directions_walk,
        AppColors.coral,
      ),
      LocationStatus.available => (
        'Có thể khám phá',
        Icons.explore,
        AppColors.teal,
      ),
      LocationStatus.locked => ('Chưa mở khóa', Icons.lock, AppColors.disabled),
    };
    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label),
      backgroundColor: color.withValues(alpha: .1),
      side: BorderSide(color: color.withValues(alpha: .25)),
    );
  }
}

class XPProgressBar extends StatelessWidget {
  const XPProgressBar({
    required this.progress,
    super.key,
    this.showLabel = true,
  });

  final UserProgress progress;
  final bool showLabel;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '${progress.currentXp} trên ${progress.nextLevelXp} XP',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showLabel)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Text(
                  '${progress.currentXp} XP',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                Text('${progress.nextLevelXp} XP · Cấp ${progress.level + 1}'),
              ],
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.round),
          child: LinearProgressIndicator(
            value: progress.xpPercentage,
            minHeight: 10,
            backgroundColor: AppColors.line,
            color: AppColors.gold,
          ),
        ),
      ],
    ),
  );
}

class LevelBadge extends StatelessWidget {
  const LevelBadge({required this.level, super.key});

  final int level;

  @override
  Widget build(BuildContext context) => Chip(
    avatar: const Icon(Icons.star_rounded, size: 17, color: AppColors.gold),
    label: Text('LEVEL $level · NHÀ THÁM HIỂM'),
    backgroundColor: AppColors.navy,
    labelStyle: const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w700,
    ),
    side: BorderSide.none,
  );
}
