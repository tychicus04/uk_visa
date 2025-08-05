import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';
import '../constants/app_colors.dart';

class AppTheme {
  // ==========================================================================
  // LIGHT THEME
  // ==========================================================================

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(AppColors.primaryColor),
        brightness: Brightness.light,
        primary: const Color(AppColors.primaryColor),
        secondary: const Color(AppColors.secondaryColor),
        tertiary: const Color(AppColors.accentColor),
        surface: const Color(AppColors.surfaceColor),
        background: const Color(AppColors.backgroundColor),
        error: const Color(AppColors.errorColor),
      ),

      // Typography
      textTheme: _textTheme,

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(AppColors.primaryColor),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actionsIconTheme: const IconThemeData(color: Colors.white),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: const Color(AppColors.cardColor),
        elevation: AppConstants.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: AppConstants.smallPadding,
          vertical: AppConstants.smallPadding / 2,
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(AppColors.primaryColor),
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(AppColors.primaryColor),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(AppColors.primaryColor),
          side: const BorderSide(
            color: Color(AppColors.primaryColor),
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Filled Button Theme
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(AppColors.primaryColor),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(
            color: Color(AppColors.borderColor),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(
            color: Color(AppColors.borderColor),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(
            color: Color(AppColors.primaryColor),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(
            color: Color(AppColors.errorColor),
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(
            color: Color(AppColors.errorColor),
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: const Color(AppColors.textHint),
        ),
        labelStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: const Color(AppColors.textSecondary),
        ),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const Color(AppColors.primaryColor);
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const Color(AppColors.primaryColor);
          }
          return const Color(AppColors.textSecondary);
        }),
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const Color(AppColors.primaryColor);
          }
          return Colors.grey[300];
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const Color(AppColors.primaryColor).withOpacity(0.5);
          }
          return Colors.grey[400];
        }),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Color(AppColors.primaryColor),
        linearTrackColor: Color(AppColors.borderColor),
        circularTrackColor: Color(AppColors.borderColor),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(AppColors.primaryColor),
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: const Color(AppColors.primaryColor),
        unselectedItemColor: const Color(AppColors.textSecondary),
        selectedLabelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Navigation Bar Theme
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: const Color(AppColors.primaryColor).withOpacity(0.2),
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(AppColors.primaryColor),
            );
          }
          return GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: const Color(AppColors.textSecondary),
          );
        }),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(
              color: Color(AppColors.primaryColor),
              size: 24,
            );
          }
          return const IconThemeData(
            color: Color(AppColors.textSecondary),
            size: 24,
          );
        }),
      ),

      // Tab Bar Theme
      tabBarTheme: TabBarThemeData(
        labelColor: const Color(AppColors.primaryColor),
        unselectedLabelColor: const Color(AppColors.textSecondary),
        labelStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(
            color: Color(AppColors.primaryColor),
            width: 3,
          ),
        ),
        indicatorSize: TabBarIndicatorSize.label,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: Color(AppColors.dividerColor),
        thickness: 1,
        space: 1,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey[100],
        disabledColor: Colors.grey[300],
        selectedColor: const Color(AppColors.primaryColor),
        secondarySelectedColor: const Color(AppColors.primaryLight),
        labelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        brightness: Brightness.light,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // List Tile Theme
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: const Color(AppColors.textPrimary),
        ),
        subtitleTextStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: const Color(AppColors.textSecondary),
        ),
        iconColor: const Color(AppColors.primaryColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: const Color(AppColors.textPrimary),
        ),
        contentTextStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: const Color(AppColors.textSecondary),
        ),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConstants.borderRadius),
          ),
        ),
        modalBackgroundColor: Colors.white,
        modalElevation: 8,
      ),

      // Snack Bar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(AppColors.textPrimary),
        contentTextStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
        actionTextColor: const Color(AppColors.primaryLight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 6,
      ),

      // Tooltip Theme
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: const Color(AppColors.textPrimary),
          borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      // Slider Theme
      sliderTheme: SliderThemeData(
        activeTrackColor: const Color(AppColors.primaryColor),
        inactiveTrackColor: const Color(AppColors.primaryColor).withOpacity(0.3),
        thumbColor: const Color(AppColors.primaryColor),
        overlayColor: const Color(AppColors.primaryColor).withOpacity(0.2),
        valueIndicatorColor: const Color(AppColors.primaryColor),
        valueIndicatorTextStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }

  // ==========================================================================
  // DARK THEME
  // ==========================================================================

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(AppColors.primaryColor),
        brightness: Brightness.dark,
        primary: const Color(AppColors.primaryLight),
        secondary: const Color(AppColors.secondaryLight),
        tertiary: const Color(AppColors.accentLight),
        surface: const Color(0xFF1E1E1E),
        background: const Color(0xFF121212),
        error: const Color(AppColors.errorColor),
        onSurface: Colors.white,
        onBackground: Colors.white,
      ),

      // Typography
      textTheme: _textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actionsIconTheme: const IconThemeData(color: Colors.white),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: const Color(0xFF2D2D2D),
        elevation: AppConstants.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: AppConstants.smallPadding,
          vertical: AppConstants.smallPadding / 2,
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(AppColors.primaryLight),
          foregroundColor: Colors.black,
          elevation: 2,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2D2D2D),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(
            color: Color(0xFF424242),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(
            color: Color(0xFF424242),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(
            color: Color(AppColors.primaryLight),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(
            color: Color(AppColors.errorColor),
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(
            color: Color(AppColors.errorColor),
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.grey[400],
        ),
        labelStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.grey[300],
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: const Color(AppColors.primaryLight),
        unselectedItemColor: Colors.grey[400],
        selectedLabelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  // ==========================================================================
  // TEXT THEME
  // ==========================================================================

  static TextTheme get _textTheme {
    return TextTheme(
      // Display styles
      displayLarge: GoogleFonts.poppins(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 45,
        fontWeight: FontWeight.w400,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 36,
        fontWeight: FontWeight.w400,
      ),

      // Headline styles
      headlineLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),

      // Title styles
      titleLarge: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),

      // Label styles
      labelLarge: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      labelMedium: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
      labelSmall: GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),

      // Body styles
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
      ),
    );
  }

  // ==========================================================================
  // CUSTOM STYLES
  // ==========================================================================

  static TextStyle get appBarTitle => GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle get cardTitle => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: const Color(AppColors.textPrimary),
  );

  static TextStyle get cardSubtitle => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: const Color(AppColors.textSecondary),
  );

  static TextStyle get buttonText => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get captionText => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: const Color(AppColors.textHint),
  );

  static TextStyle get scoreText => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: const Color(AppColors.primaryColor),
  );

  static TextStyle get percentageText => GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  // Premium styles
  static TextStyle get premiumText => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: const Color(AppColors.premiumGold),
  );

  static BoxDecoration get premiumGradient => const BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Color(AppColors.premiumGradientStart),
        Color(AppColors.premiumGradientEnd),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.all(Radius.circular(AppConstants.borderRadius)),
  );

  // ==========================================================================
  // CUSTOM DECORATIONS
  // ==========================================================================

  static BoxDecoration get cardDecoration => BoxDecoration(
    color: const Color(AppColors.cardColor),
    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration get primaryGradient => const BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Color(AppColors.primaryColor),
        Color(AppColors.primaryDark),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.all(Radius.circular(AppConstants.borderRadius)),
  );

  static BoxDecoration get successGradient => const BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Color(AppColors.successColor),
        Color(0xFF388E3C),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.all(Radius.circular(AppConstants.borderRadius)),
  );

  static BoxDecoration get errorGradient => const BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Color(AppColors.errorColor),
        Color(0xFFD32F2F),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.all(Radius.circular(AppConstants.borderRadius)),
  );

  // ==========================================================================
  // ANIMATION CURVES
  // ==========================================================================

  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve slideInCurve = Curves.easeOut;
  static const Curve slideOutCurve = Curves.easeIn;

  // ==========================================================================
  // SHADOWS
  // ==========================================================================

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: const Color(AppColors.primaryColor).withOpacity(0.3),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get premiumShadow => [
    BoxShadow(
      color: const Color(AppColors.premiumGold).withOpacity(0.3),
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
  ];

  // ==========================================================================
  // RESPONSIVE BREAKPOINTS
  // ==========================================================================

  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint &&
          MediaQuery.of(context).size.width < desktopBreakpoint;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktopBreakpoint;

  // ==========================================================================
  // UTILITY METHODS
  // ==========================================================================

  static EdgeInsets responsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(AppConstants.defaultPadding);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(AppConstants.largePadding);
    } else {
      return const EdgeInsets.all(AppConstants.extraLargePadding);
    }
  }

  static double responsiveFontSize(BuildContext context, double baseFontSize) {
    if (isMobile(context)) {
      return baseFontSize;
    } else if (isTablet(context)) {
      return baseFontSize * 1.1;
    } else {
      return baseFontSize * 1.2;
    }
  }

  static BorderRadius get defaultBorderRadius =>
      BorderRadius.circular(AppConstants.borderRadius);

  static BorderRadius get largeBorderRadius =>
      BorderRadius.circular(AppConstants.largeBorderRadius);

  static BorderRadius get smallBorderRadius =>
      BorderRadius.circular(AppConstants.smallBorderRadius);
}