import 'package:flutter/material.dart';
import 'package:korea_quest/design_system/colors/app_colors.dart';

abstract final class AppTypography {
  static const fontFallback = ['Arial', 'Noto Sans KR', 'sans-serif'];

  static TextTheme get textTheme =>
      const TextTheme(
        displayLarge: TextStyle(
          fontSize: 64,
          height: 1.05,
          fontWeight: FontWeight.w800,
        ),
        displaySmall: TextStyle(
          fontSize: 40,
          height: 1.12,
          fontWeight: FontWeight.w800,
        ),
        headlineMedium: TextStyle(
          fontSize: 30,
          height: 1.2,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        bodyLarge: TextStyle(fontSize: 16, height: 1.55),
        bodyMedium: TextStyle(fontSize: 14, height: 1.5),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ).apply(
        bodyColor: AppColors.ink,
        displayColor: AppColors.navy,
        fontFamilyFallback: fontFallback,
      );
}
