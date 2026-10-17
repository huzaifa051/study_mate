import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppTheme {
  static TextStyle serif (double size, {Color color = AppColors.charcoal}) {
    return TextStyle(
      fontFamily: 'serif',
      fontSize: size,
      color: color,
      height: 1.2,
    );
  }

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.stone,
      colorScheme: const ColorScheme.light(
        primary: AppColors.forest,
        onPrimary: AppColors.stone,
        secondary: AppColors.clay,
        surface: AppColors.stone,
        onSurface: AppColors.charcoal,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.stone,
        foregroundColor: AppColors.charcoal,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.forest,
          foregroundColor: AppColors.stone,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)
          ),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.hairline),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.forest, width: 1.5),
        ),
        labelStyle: TextStyle(color: AppColors.muted),
      ),
    );
  }
}