import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF121212);
  static const card = Color(0xFF1E1E1E);
  static const primary = Color(0xFF0A84FF);
  static const secondary = Color(0xFF5AC8FA);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFA1A1A1);
  static const success = Color(0xFF30D158);
  static const error = Color(0xFFFF453A);
  static const grey = Color(0xFF2C2C2E);
}

class AppTextStyles {
  static var heading = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const subHeading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static const small = TextStyle(
    fontSize: 14,
    color: AppColors.grey,
  );
}

class AppSizes {
  static const padding = 16.0;
  static const smallPadding = 8.0;
  static const radius = 12.0;
  static const iconSize = 28.0;
}
