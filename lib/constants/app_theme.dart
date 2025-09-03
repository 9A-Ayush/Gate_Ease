import 'package:flutter/material.dart';
import '../utils/responsive_utils.dart';

/// Application theme constants for consistent styling
class AppTheme {
  // Primary Colors
  static const Color primaryColor = Color(0xFF4CAF50);
  static const Color primaryColorLight = Color(0xFF81C784);
  static const Color primaryColorDark = Color(0xFF388E3C);

  // Secondary Colors
  static const Color secondaryColor = Color(0xFF2196F3);
  static const Color secondaryColorLight = Color(0xFF64B5F6);
  static const Color secondaryColorDark = Color(0xFF1976D2);

  // Status Colors
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFF44336);
  static const Color infoColor = Color(0xFF2196F3);

  // Neutral Colors
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Colors.white;
  static const Color cardColor = Colors.white;

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color textOnPrimary = Colors.white;

  // Border Colors
  static const Color borderColor = Color(0xFFE0E0E0);
  static const Color dividerColor = Color(0xFFBDBDBD);

  // Shadow Colors
  static const Color shadowColor = Color(0x1A000000);
  static const Color shadowColorLight = Color(0x0D000000);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, primaryColorDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondaryColor, secondaryColorDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Spacing Constants
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Border Radius
  static const double radiusS = 4.0;
  static const double radiusM = 8.0;
  static const double radiusL = 12.0;
  static const double radiusXL = 16.0;
  static const double radiusXXL = 24.0;
  static const double radiusCircular = 50.0;

  // Elevation
  static const double elevationS = 2.0;
  static const double elevationM = 4.0;
  static const double elevationL = 8.0;
  static const double elevationXL = 16.0;

  // Icon Sizes
  static const double iconSizeS = 16.0;
  static const double iconSizeM = 24.0;
  static const double iconSizeL = 32.0;
  static const double iconSizeXL = 48.0;

  // Base Font Sizes (use ResponsiveUtils.getScaledFontSize for actual implementation)
  static const double fontSizeXS = 10.0;
  static const double fontSizeS = 12.0;
  static const double fontSizeM = 14.0;
  static const double fontSizeL = 16.0;
  static const double fontSizeXL = 18.0;
  static const double fontSizeXXL = 20.0;
  static const double fontSizeTitle = 24.0;
  static const double fontSizeHeading = 28.0;

  // Responsive Text Style Builders
  static TextStyle getHeadingStyle(BuildContext context) {
    return TextStyle(
      fontSize: ResponsiveUtils.getScaledFontSize(context, fontSizeHeading),
      fontWeight: FontWeight.bold,
      color: textPrimary,
    );
  }

  static TextStyle getTitleStyle(BuildContext context) {
    return TextStyle(
      fontSize: ResponsiveUtils.getScaledFontSize(context, fontSizeTitle),
      fontWeight: FontWeight.w600,
      color: textPrimary,
    );
  }

  static TextStyle getSubtitleStyle(BuildContext context) {
    return TextStyle(
      fontSize: ResponsiveUtils.getScaledFontSize(context, fontSizeXL),
      fontWeight: FontWeight.w500,
      color: textPrimary,
    );
  }

  static TextStyle getBodyStyle(BuildContext context) {
    return TextStyle(
      fontSize: ResponsiveUtils.getScaledFontSize(context, fontSizeL),
      fontWeight: FontWeight.normal,
      color: textPrimary,
    );
  }

  static TextStyle getCaptionStyle(BuildContext context) {
    return TextStyle(
      fontSize: ResponsiveUtils.getScaledFontSize(context, fontSizeM),
      fontWeight: FontWeight.normal,
      color: textSecondary,
    );
  }

  static TextStyle getLabelStyle(BuildContext context) {
    return TextStyle(
      fontSize: ResponsiveUtils.getScaledFontSize(context, fontSizeS),
      fontWeight: FontWeight.w500,
      color: textSecondary,
    );
  }

  // Legacy static styles (deprecated - use responsive versions above)
  @deprecated
  static const TextStyle headingStyle = TextStyle(
    fontSize: fontSizeHeading,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  @deprecated
  static const TextStyle titleStyle = TextStyle(
    fontSize: fontSizeTitle,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  @deprecated
  static const TextStyle subtitleStyle = TextStyle(
    fontSize: fontSizeXL,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );

  @deprecated
  static const TextStyle bodyStyle = TextStyle(
    fontSize: fontSizeL,
    fontWeight: FontWeight.normal,
    color: textPrimary,
  );

  @deprecated
  static const TextStyle captionStyle = TextStyle(
    fontSize: fontSizeM,
    fontWeight: FontWeight.normal,
    color: textSecondary,
  );

  @deprecated
  static const TextStyle labelStyle = TextStyle(
    fontSize: fontSizeS,
    fontWeight: FontWeight.w500,
    color: textSecondary,
  );

  // Button Styles
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: textOnPrimary,
    elevation: elevationS,
    padding: const EdgeInsets.symmetric(
      horizontal: spacingL,
      vertical: spacingM,
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusM)),
  );

  static ButtonStyle secondaryButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: primaryColor,
    side: const BorderSide(color: primaryColor),
    padding: const EdgeInsets.symmetric(
      horizontal: spacingL,
      vertical: spacingM,
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusM)),
  );

  static ButtonStyle textButtonStyle = TextButton.styleFrom(
    foregroundColor: primaryColor,
    padding: const EdgeInsets.symmetric(
      horizontal: spacingM,
      vertical: spacingS,
    ),
  );

  // Card Styles
  static BoxDecoration cardDecoration = BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(radiusL),
    boxShadow: [
      BoxShadow(
        color: shadowColor,
        spreadRadius: 1,
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration elevatedCardDecoration = BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(radiusL),
    boxShadow: [
      BoxShadow(
        color: shadowColor,
        spreadRadius: 2,
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );

  // Input Decoration
  static InputDecoration inputDecoration({
    String? labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: const BorderSide(color: errorColor),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacingM,
        vertical: spacingM,
      ),
    );
  }

  // App Bar Theme
  static AppBarTheme appBarTheme = const AppBarTheme(
    backgroundColor: primaryColor,
    foregroundColor: textOnPrimary,
    elevation: elevationS,
    centerTitle: false,
    titleTextStyle: TextStyle(
      fontSize: fontSizeXXL,
      fontWeight: FontWeight.w600,
      color: textOnPrimary,
    ),
  );

  // Bottom Navigation Bar Theme
  static BottomNavigationBarThemeData bottomNavTheme =
      const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: elevationM,
      );

  // Floating Action Button Theme
  static FloatingActionButtonThemeData fabTheme =
      const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: textOnPrimary,
        elevation: elevationM,
      );

  // Snackbar Theme
  static SnackBarThemeData snackBarTheme = const SnackBarThemeData(
    backgroundColor: textPrimary,
    contentTextStyle: TextStyle(color: textOnPrimary),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(radiusM)),
    ),
  );

  // Complete Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.green,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      appBarTheme: appBarTheme,
      bottomNavigationBarTheme: bottomNavTheme,
      floatingActionButtonTheme: fabTheme,
      snackBarTheme: snackBarTheme,
      elevatedButtonTheme: ElevatedButtonThemeData(style: primaryButtonStyle),
      outlinedButtonTheme: OutlinedButtonThemeData(style: secondaryButtonStyle),
      textButtonTheme: TextButtonThemeData(style: textButtonStyle),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: elevationS,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusL),
        ),
      ),
    );
  }
}
