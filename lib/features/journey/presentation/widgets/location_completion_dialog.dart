import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:korea_quest/core/services/celebration_sound.dart';
import 'package:korea_quest/design_system/colors/app_colors.dart';
import 'package:korea_quest/design_system/components/app_buttons.dart';
import 'package:korea_quest/design_system/radius/app_radius.dart';
import 'package:korea_quest/design_system/shadows/app_shadows.dart';
import 'package:korea_quest/design_system/spacing/app_spacing.dart';
import 'package:korea_quest/l10n/app_strings.dart';

/// A full-screen hand-off shown after a player completes every stage of a
/// location. It takes primitive reward values to remain independent from a
/// particular journey repository implementation.
Future<void> showLocationCompletionDialog(
  BuildContext context, {
  required String locationName,
  required String playerName,
  required int awardedXp,
  required bool alreadyAwarded,
  required bool stampAwarded,
  required List<String> achievementTitles,
  required bool isGuest,
  required VoidCallback onContinue,
  VoidCallback? onRegister,
  bool playSound = true,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'Location completion',
    barrierColor: AppColors.navy.withValues(alpha: 0.72),
    transitionDuration: Duration.zero,
    pageBuilder: (_, _, _) => LocationCompletionDialog(
      locationName: locationName,
      playerName: playerName,
      awardedXp: awardedXp,
      alreadyAwarded: alreadyAwarded,
      stampAwarded: stampAwarded,
      achievementTitles: achievementTitles,
      isGuest: isGuest,
      onContinue: onContinue,
      onRegister: onRegister,
      playSound: playSound,
    ),
  );
}

class LocationCompletionDialog extends StatefulWidget {
  const LocationCompletionDialog({
    required this.locationName,
    required this.playerName,
    required this.awardedXp,
    required this.alreadyAwarded,
    required this.stampAwarded,
    required this.achievementTitles,
    required this.isGuest,
    required this.onContinue,
    super.key,
    this.onRegister,
    this.playSound = true,
  });

  final String locationName;
  final String playerName;
  final int awardedXp;
  final bool alreadyAwarded;
  final bool stampAwarded;
  final List<String> achievementTitles;
  final bool isGuest;
  final VoidCallback onContinue;
  final VoidCallback? onRegister;
  final bool playSound;

  @override
  State<LocationCompletionDialog> createState() =>
      _LocationCompletionDialogState();
}

class _LocationCompletionDialogState extends State<LocationCompletionDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  var _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    );
    if (widget.playSound) unawaited(CelebrationSound.play());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
      return;
    }
    if (!_started) {
      _started = true;
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return PopScope(
      canPop: false,
      child: Material(
        color: Colors.transparent,
        child: SafeArea(
          minimum: const EdgeInsets.all(AppSpacing.md),
          child: Stack(
            fit: StackFit.expand,
            children: [
              IgnorePointer(
                child: CustomPaint(
                  key: ValueKey(
                    reduceMotion
                        ? 'celebration-static-backdrop'
                        : 'celebration-animated-backdrop',
                  ),
                  painter: _KoreanCelebrationPainter(
                    progress: _controller,
                    reduceMotion: reduceMotion,
                  ),
                ),
              ),
              Center(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final progress = _cardProgress(_controller.value);
                    return Opacity(
                      opacity: progress,
                      child: Transform.scale(
                        scale: .9 + (.1 * progress),
                        child: child,
                      ),
                    );
                  },
                  child: _RewardCard(
                    locationName: widget.locationName,
                    playerName: widget.playerName,
                    awardedXp: widget.awardedXp,
                    alreadyAwarded: widget.alreadyAwarded,
                    stampAwarded: widget.stampAwarded,
                    achievementTitles: widget.achievementTitles,
                    isGuest: widget.isGuest,
                    onContinue: () => _closeAndRun(widget.onContinue),
                    onRegister: widget.onRegister == null
                        ? null
                        : () => _closeAndRun(widget.onRegister!),
                  ),
                ),
              ),
              Positioned(
                top: AppSpacing.xs,
                right: AppSpacing.xs,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    color: AppColors.paper,
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.small,
                  ),
                  child: IconButton(
                    key: const ValueKey('close-location-completion'),
                    onPressed: () => _closeAndRun(widget.onContinue),
                    icon: const Icon(Icons.close_rounded),
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _cardProgress(double value) {
    if (MediaQuery.disableAnimationsOf(context)) return 1;
    return Curves.easeOutBack
        .transform(((value - .14) / .34).clamp(0, 1).toDouble())
        .clamp(0, 1)
        .toDouble();
  }

  void _closeAndRun(VoidCallback action) {
    Navigator.of(context, rootNavigator: true).pop();
    action();
  }
}

class _RewardCard extends StatelessWidget {
  const _RewardCard({
    required this.locationName,
    required this.playerName,
    required this.awardedXp,
    required this.alreadyAwarded,
    required this.stampAwarded,
    required this.achievementTitles,
    required this.isGuest,
    required this.onContinue,
    this.onRegister,
  });

  final String locationName;
  final String playerName;
  final int awardedXp;
  final bool alreadyAwarded;
  final bool stampAwarded;
  final List<String> achievementTitles;
  final bool isGuest;
  final VoidCallback onContinue;
  final VoidCallback? onRegister;

  @override
  Widget build(BuildContext context) {
    final strings = appStrings(context);
    final rewardChips = <Widget>[
      if (awardedXp > 0)
        _RewardChip(
          icon: Icons.bolt_rounded,
          label: '+$awardedXp XP',
          color: AppColors.gold,
        ),
      if (stampAwarded)
        _RewardChip(
          icon: Icons.verified_rounded,
          label: strings.passport,
          color: AppColors.coral,
        ),
      for (final title in achievementTitles)
        _RewardChip(
          icon: Icons.emoji_events_rounded,
          label: title,
          color: AppColors.teal,
        ),
    ];

    return Semantics(
      liveRegion: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Container(
          key: const ValueKey('location-completion-card'),
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.paper,
            borderRadius: BorderRadius.circular(AppRadius.large),
            border: Border.all(color: AppColors.line),
            boxShadow: AppShadows.large,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: AppSpacing.section,
                    height: AppSpacing.section,
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.gold, width: 2),
                    ),
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      color: AppColors.gold,
                      size: AppSpacing.xl,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  strings.guestCelebrationTitle(playerName, locationName),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.stitchText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (rewardChips.isNotEmpty) ...[
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: rewardChips,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ] else if (alreadyAwarded) ...[
                  Text(
                    strings.rewardsAlreadyReceived,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.stitchMuted),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
                if (isGuest && onRegister != null) ...[
                  PrimaryButton(
                    label: strings.registerAndSaveProgress,
                    icon: Icons.card_membership_rounded,
                    onPressed: onRegister,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Center(
                    child: TextButton(
                      onPressed: onContinue,
                      child: Text(strings.continueAsGuest),
                    ),
                  ),
                ] else
                  PrimaryButton(
                    label: strings.backToKoreaMap,
                    icon: Icons.map_outlined,
                    onPressed: onContinue,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RewardChip extends StatelessWidget {
  const _RewardChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.sm,
      vertical: AppSpacing.xs,
    ),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(AppRadius.round),
      border: Border.all(color: color.withValues(alpha: 0.35)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: AppSpacing.lg),
        const SizedBox(width: AppSpacing.xs),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSpacing.section * 2.5),
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: AppColors.stitchText),
          ),
        ),
      ],
    ),
  );
}

class _KoreanCelebrationPainter extends CustomPainter {
  const _KoreanCelebrationPainter({
    required this.progress,
    required this.reduceMotion,
  }) : super(repaint: progress);

  final Animation<double> progress;
  final bool reduceMotion;

  static const _petals = <Offset>[
    Offset(.08, .16),
    Offset(.22, .72),
    Offset(.4, .08),
    Offset(.61, .82),
    Offset(.76, .14),
    Offset(.92, .64),
    Offset(.12, .46),
    Offset(.87, .42),
  ];

  static const _fireworkOrigins = <Offset>[
    Offset(.16, .28),
    Offset(.84, .24),
    Offset(.12, .72),
    Offset(.88, .7),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final value = reduceMotion ? 1.0 : progress.value;
    final burst = Curves.easeOutCubic.transform(
      (value / .46).clamp(0, 1).toDouble(),
    );
    final fall = ((value - .12) / .88).clamp(0, 1).toDouble();
    final center = Offset(size.width / 2, size.height / 2);

    _paintTaegeukgi(canvas, size, burst);
    _paintDancheongRibbons(canvas, size, burst);
    _paintTaegeuk(canvas, size, burst);
    _paintFireworks(canvas, size, burst, fall);
    _paintPetals(canvas, size, center, burst, fall);
  }

  void _paintTaegeukgi(Canvas canvas, Size size, double progress) {
    final flagWidth = (size.width * .22)
        .clamp(AppSpacing.section * 2, AppSpacing.section * 3)
        .toDouble();
    final flagHeight = flagWidth * .66;
    final flagRect = Rect.fromLTWH(
      AppSpacing.lg,
      AppSpacing.lg,
      flagWidth,
      flagHeight,
    );
    final paint = Paint()
      ..color = AppColors.paper.withValues(alpha: .92 * progress);
    canvas.drawRRect(
      RRect.fromRectAndRadius(flagRect, const Radius.circular(AppRadius.small)),
      paint,
    );
    _paintTaegeukSymbol(
      canvas,
      flagRect.center,
      flagHeight * .24,
      opacity: progress,
    );

    final trigramPaint = Paint()
      ..color = AppColors.ink.withValues(alpha: .85 * progress)
      ..strokeWidth = AppSpacing.xxs / 2
      ..strokeCap = StrokeCap.round;
    _paintTrigram(
      canvas,
      Offset(flagRect.left + AppSpacing.sm, flagRect.top + AppSpacing.sm),
      trigramPaint,
      splitMiddle: false,
    );
    _paintTrigram(
      canvas,
      Offset(flagRect.right - AppSpacing.lg, flagRect.top + AppSpacing.sm),
      trigramPaint,
      splitMiddle: true,
    );
    _paintTrigram(
      canvas,
      Offset(flagRect.left + AppSpacing.sm, flagRect.bottom - AppSpacing.md),
      trigramPaint,
      splitMiddle: true,
    );
    _paintTrigram(
      canvas,
      Offset(flagRect.right - AppSpacing.lg, flagRect.bottom - AppSpacing.md),
      trigramPaint,
      splitMiddle: false,
    );
  }

  void _paintTrigram(
    Canvas canvas,
    Offset origin,
    Paint paint, {
    required bool splitMiddle,
  }) {
    for (var index = 0; index < 3; index++) {
      final y = origin.dy + (index * AppSpacing.xxs);
      if (splitMiddle && index.isOdd) {
        canvas
          ..drawLine(
            origin.translate(0, y - origin.dy),
            Offset(origin.dx + AppSpacing.xxs, y),
            paint,
          )
          ..drawLine(
            Offset(origin.dx + AppSpacing.sm, y),
            Offset(origin.dx + AppSpacing.md, y),
            paint,
          );
      } else {
        canvas.drawLine(
          Offset(origin.dx, y),
          Offset(origin.dx + AppSpacing.md, y),
          paint,
        );
      }
    }
  }

  void _paintDancheongRibbons(Canvas canvas, Size size, double progress) {
    final ribbonPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = AppSpacing.xs
      ..strokeCap = StrokeCap.round;
    final radius = math.min(size.width, size.height) * .7 * progress;
    final bounds = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: radius,
    );
    final colors = [AppColors.coral, AppColors.teal, AppColors.gold];
    for (var index = 0; index < colors.length; index++) {
      ribbonPaint.color = colors[index].withValues(alpha: .5 * progress);
      canvas.drawArc(
        bounds.inflate(index * AppSpacing.sm),
        math.pi * (.14 + (index * .22)),
        math.pi * .42,
        false,
        ribbonPaint,
      );
    }
  }

  void _paintTaegeuk(Canvas canvas, Size size, double progress) {
    final radius = AppSpacing.xxl * progress;
    final center = Offset(size.width - AppSpacing.xxl, AppSpacing.xxl);
    _paintTaegeukSymbol(canvas, center, radius, opacity: .72 * progress);
  }

  void _paintTaegeukSymbol(
    Canvas canvas,
    Offset center,
    double radius, {
    required double opacity,
  }) {
    if (radius == 0) return;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..color = AppColors.koreanRed.withValues(alpha: opacity);
    canvas.drawArc(rect, -math.pi / 2, math.pi, true, paint);
    paint.color = AppColors.koreanBlue.withValues(alpha: opacity);
    canvas.drawArc(rect, math.pi / 2, math.pi, true, paint);
    canvas.drawCircle(
      Offset(center.dx, center.dy - (radius / 2)),
      radius / 2,
      paint..color = AppColors.koreanBlue.withValues(alpha: opacity),
    );
    canvas.drawCircle(
      Offset(center.dx, center.dy + (radius / 2)),
      radius / 2,
      paint..color = AppColors.koreanRed.withValues(alpha: opacity),
    );
  }

  void _paintFireworks(Canvas canvas, Size size, double burst, double fall) {
    final progress = Curves.easeOut.transform(
      ((fall - .08) / .58).clamp(0, 1).toDouble(),
    );
    final colors = [
      AppColors.paper,
      AppColors.koreanRed,
      AppColors.koreanBlue,
      AppColors.gold,
    ];
    for (var index = 0; index < _fireworkOrigins.length; index++) {
      final center = Offset(
        _fireworkOrigins[index].dx * size.width,
        _fireworkOrigins[index].dy * size.height,
      );
      final rayPaint = Paint()
        ..color = colors[index].withValues(alpha: (1 - progress) * .9)
        ..strokeWidth = AppSpacing.xxs / 2
        ..strokeCap = StrokeCap.round;
      final distance = AppSpacing.xxl * (1 + (burst * 2));
      for (var ray = 0; ray < 12; ray++) {
        final angle = (math.pi * 2 * ray) / 12;
        final start = Offset(
          center.dx + (math.cos(angle) * AppSpacing.xs),
          center.dy + (math.sin(angle) * AppSpacing.xs),
        );
        final end = Offset(
          center.dx + (math.cos(angle) * distance * progress),
          center.dy + (math.sin(angle) * distance * progress),
        );
        canvas
          ..drawLine(start, end, rayPaint)
          ..drawCircle(end, AppSpacing.xxs / 2, rayPaint);
      }
    }
  }

  void _paintPetals(
    Canvas canvas,
    Size size,
    Offset center,
    double burst,
    double fall,
  ) {
    for (var index = 0; index < _petals.length; index++) {
      final destination = Offset(
        _petals[index].dx * size.width,
        _petals[index].dy * size.height + (fall * AppSpacing.xl),
      );
      final position = Offset.lerp(center, destination, burst)!;
      final sizeFactor = AppSpacing.sm + (index % 3) * AppSpacing.xxs;
      _paintMugunghwa(canvas, position, sizeFactor, fall);
    }
  }

  void _paintMugunghwa(
    Canvas canvas,
    Offset center,
    double size,
    double rotation,
  ) {
    final petalPaint = Paint()..color = AppColors.blossom.withValues(alpha: .9);
    final corePaint = Paint()
      ..color = AppColors.koreanRed.withValues(alpha: .9);
    canvas
      ..save()
      ..translate(center.dx, center.dy)
      ..rotate(rotation * math.pi);
    for (var petal = 0; petal < 5; petal++) {
      canvas
        ..save()
        ..rotate((math.pi * 2 * petal) / 5)
        ..drawOval(
          Rect.fromCenter(
            center: Offset(0, -size * .32),
            width: size * .62,
            height: size,
          ),
          petalPaint,
        )
        ..restore();
    }
    canvas
      ..drawCircle(Offset.zero, size * .2, corePaint)
      ..drawCircle(Offset.zero, size * .08, Paint()..color = AppColors.gold)
      ..restore();
  }

  @override
  bool shouldRepaint(_KoreanCelebrationPainter oldDelegate) =>
      oldDelegate.reduceMotion != reduceMotion ||
      oldDelegate.progress != progress;
}
