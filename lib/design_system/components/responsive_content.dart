import 'package:flutter/material.dart';
import 'package:korea_quest/core/responsive/responsive_breakpoints.dart';
import 'package:korea_quest/design_system/spacing/app_spacing.dart';

class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent({
    required this.child,
    super.key,
    this.padding,
    this.maxWidth,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth ?? ResponsiveBreakpoints.maxContent,
      ),
      child: Padding(
        padding:
            padding ??
            EdgeInsets.symmetric(
              horizontal:
                  MediaQuery.sizeOf(context).width <
                      ResponsiveBreakpoints.mobile
                  ? AppSpacing.md
                  : AppSpacing.lg,
            ),
        child: child,
      ),
    ),
  );
}
