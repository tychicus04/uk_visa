import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors (Blue from the design)
  static const Color primary = Color(0xFF2B7CE9);
  static const Color primaryLight = Color(0xFF4A94FF);
  static const Color primaryDark = Color(0xFF1E5AA8);

  // Secondary Colors
  static const Color secondary = Color(0xFF00C896);
  static const Color secondaryLight = Color(0xFF26E5B8);
  static const Color secondaryDark = Color(0xFF009974);

  // Accent Colors
  static const Color accent = Color(0xFFFF6B35);
  static const Color accentLight = Color(0xFFFF8A5B);
  static const Color accentDark = Color(0xFFE55A2B);

  // Background Colors
  static const Color backgroundLight = Color(0xFFFAFBFF);
  static const Color backgroundDark = Color(0xFF0D1117);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF161B22);

  // Card Colors
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF21262D);

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF1F2937);
  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  static const Color textTertiaryLight = Color(0xFF9CA3AF);
  static const Color textTertiaryDark = Color(0xFF6B7280);

  // Border Colors
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderDark = Color(0xFF30363D);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFF6B6B);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFFBF47);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF60A5FA);

  // Progress Colors
  static const Color progressGreen = Color(0xFF10B981);
  static const Color progressBlue = Color(0xFF3B82F6);
  static const Color progressOrange = Color(0xFFF59E0B);
  static const Color progressRed = Color(0xFFEF4444);

  // Answer Colors (for quiz)
  static const Color answerCorrect = Color(0xFF10B981);
  static const Color answerIncorrect = Color(0xFFEF4444);
  static const Color answerSelected = Color(0xFF3B82F6);
  static const Color answerDefault = Color(0xFFF3F4F6);
  static const Color answerDefaultDark = Color(0xFF374151);

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF2B7CE9),
    Color(0xFF1E5AA8),
  ];

  static const List<Color> successGradient = [
    Color(0xFF10B981),
    Color(0xFF059669),
  ];

  static const List<Color> backgroundGradient = [
    Color(0xFF2B7CE9),
    Color(0xFF4A94FF),
  ];

  // UK Flag Colors
  static const Color ukRed = Color(0xFFCF142B);
  static const Color ukBlue = Color(0xFF00247D);
  static const Color ukWhite = Color(0xFFFFFFFF);

  // Shimmer Colors
  static const Color shimmerBase = Color(0xFFE5E7EB);
  static const Color shimmerHighlight = Color(0xFFF3F4F6);
  static const Color shimmerBaseDark = Color(0xFF374151);
  static const Color shimmerHighlightDark = Color(0xFF4B5563);

  // Shadow Colors
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowDark = Color(0x40000000);

  // Overlay Colors
  static const Color overlayLight = Color(0x80FFFFFF);
  static const Color overlayDark = Color(0x80000000);

  // Icon Colors
  static const Color iconLight = Color(0xFF6B7280);
  static const Color iconDark = Color(0xFF9CA3AF);
  static const Color iconActive = Color(0xFF2B7CE9);

  // Input Colors
  static const Color inputFillLight = Color(0xFFF9FAFB);
  static const Color inputFillDark = Color(0xFF374151);
  static const Color inputBorderLight = Color(0xFFD1D5DB);
  static const Color inputBorderDark = Color(0xFF4B5563);

  // Disabled Colors
  static const Color disabledLight = Color(0xFFE5E7EB);
  static const Color disabledDark = Color(0xFF374151);
  static const Color disabledTextLight = Color(0xFF9CA3AF);
  static const Color disabledTextDark = Color(0xFF6B7280);
}