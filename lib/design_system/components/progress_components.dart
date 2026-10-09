import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:korea_quest/design_system/colors/app_colors.dart';
import 'package:korea_quest/design_system/radius/app_radius.dart';
import 'package:korea_quest/shared/models/domain_models.dart';
import 'package:korea_quest/l10n/app_strings.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    required this.displayName,
    super.key,
    this.radius = 22,
    this.avatarPreset,
    this.avatarBytes,
  });

  final String displayName;
  final double radius;
  final String? avatarPreset;
  final Uint8List? avatarBytes;

  static const culturalPresets = <String, String>{
    'hanbok': '🎎',
    'seoul': '🗼',
    'haechi': '🦁',
    'scholar': '📜',
    'foodie': '🍲',
    'kpop': '🎵',
  };

  @override
  Widget build(BuildContext context) {
    if (avatarBytes != null && avatarBytes!.isNotEmpty) {
      return Semantics(
        label: appStrings(context).avatarOf(displayName),
        child: CircleAvatar(
          radius: radius,
          backgroundColor: AppColors.skyLight,
          backgroundImage: MemoryImage(avatarBytes!),
        ),
      );
    }

    if (avatarPreset != null && culturalPresets.containsKey(avatarPreset)) {
      final emoji = culturalPresets[avatarPreset]!;
      return Semantics(
        label: appStrings(context).avatarOf(displayName),
        child: CircleAvatar(
          radius: radius,
          backgroundColor: AppColors.skyLight,
          child: Text(emoji, style: TextStyle(fontSize: radius * 1.05)),
        ),
      );
    }

    return Semantics(
      label: appStrings(context).avatarOf(displayName),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.coral,
        foregroundColor: Colors.white,
        child: Text(
          displayName.isNotEmpty
              ? displayName.characters.first.toUpperCase()
              : '?',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: radius * .8),
        ),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({
    required this.status,
    required this.releaseStatus,
    super.key,
  });

  final LocationStatus status;
  final LocationReleaseStatus releaseStatus;

  @override
  Widget build(BuildContext context) {
    final (label, icon, color) = !releaseStatus.isReleased
        ? ('Sắp ra mắt', Icons.schedule_rounded, AppColors.disabled)
        : switch (status) {
            LocationStatus.completed => (
              appStrings(context).completed,
              Icons.check_circle,
              AppColors.completedGreen,
            ),
            LocationStatus.inProgress => (
              appStrings(context).inProgress,
              Icons.directions_walk,
              AppColors.koreanRed,
            ),
            LocationStatus.available => (
              appStrings(context).availableToExplore,
              Icons.explore,
              AppColors.koreanBlue,
            ),
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
    label: appStrings(
      context,
    ).xpProgress(progress.currentXp, progress.nextLevelXp),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showLabel)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${progress.currentXp} XP',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    appStrings(
                      context,
                    ).nextLevel(progress.nextLevelXp, progress.level + 1),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.round),
          child: LinearProgressIndicator(
            value: progress.xpPercentage,
            minHeight: 10,
            backgroundColor: AppColors.line,
            color: AppColors.butter,
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
    avatar: const Icon(Icons.star_rounded, size: 17, color: AppColors.butter),
    label: Text(appStrings(context).levelExplorer(level)),
    backgroundColor: AppColors.stitchText,
    labelStyle: const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w700,
    ),
    side: BorderSide.none,
  );
}
