import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const heading = TextStyle(
    fontSize: 38, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary, height: 1.15, letterSpacing: -1.0,
  );
  static const body = TextStyle(
    fontSize: 14, color: AppColors.textMuted, height: 1.6,
  );
  static const label = TextStyle(
    fontSize: 11, fontWeight: FontWeight.w600,
    color: AppColors.textHint, letterSpacing: 0.8,
  );
}