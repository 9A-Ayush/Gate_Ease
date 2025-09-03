import 'package:flutter/material.dart';

class ResponsiveUtils {
  // Enhanced breakpoints for better mobile support
  static const double smallMobileBreakpoint =
      320; // Very small phones (iPhone SE)
  static const double mobileBreakpoint = 480; // Regular phones
  static const double largeMobileBreakpoint = 600; // Large phones/small tablets
  static const double tabletBreakpoint = 900; // Tablets
  static const double desktopBreakpoint = 1200; // Desktop

  // Screen type detection with enhanced mobile categories
  static bool isSmallMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < smallMobileBreakpoint;
  }

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < largeMobileBreakpoint;
  }

  static bool isLargeMobile(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < largeMobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= largeMobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  // Device category helper
  static String getDeviceCategory(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < smallMobileBreakpoint) return 'small_mobile';
    if (width < mobileBreakpoint) return 'mobile';
    if (width < largeMobileBreakpoint) return 'large_mobile';
    if (width < tabletBreakpoint) return 'tablet';
    return 'desktop';
  }

  // Enhanced responsive values with mobile variants
  static double getResponsiveValue(
    BuildContext context, {
    required double mobile,
    double? largeMobile,
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? tablet ?? largeMobile ?? mobile;
    if (isTablet(context)) return tablet ?? largeMobile ?? mobile;
    if (isLargeMobile(context)) return largeMobile ?? mobile;
    return mobile;
  }

  // Enhanced responsive values with all device categories
  static double getEnhancedResponsiveValue(
    BuildContext context, {
    required double smallMobile,
    required double mobile,
    required double largeMobile,
    required double tablet,
    required double desktop,
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width < smallMobileBreakpoint) return smallMobile;
    if (width < mobileBreakpoint) return mobile;
    if (width < largeMobileBreakpoint) return largeMobile;
    if (width < tabletBreakpoint) return tablet;
    return desktop;
  }

  // Enhanced grid columns for better mobile support
  static int getGridColumns(BuildContext context, {int? maxColumns}) {
    final width = MediaQuery.of(context).size.width;
    int columns;

    if (width < smallMobileBreakpoint) {
      columns = 1; // Very small phones: 1 column
    } else if (width < mobileBreakpoint) {
      columns = 2; // Small phones: 2 columns
    } else if (width < largeMobileBreakpoint) {
      columns = 2; // Regular phones: 2 columns
    } else if (width < tabletBreakpoint) {
      columns = 3; // Large phones/small tablets: 3 columns
    } else if (width < desktopBreakpoint) {
      columns = 4; // Tablets: 4 columns
    } else {
      columns = 5; // Desktop: 5 columns
    }

    return maxColumns != null
        ? (columns > maxColumns ? maxColumns : columns)
        : columns;
  }

  // Adaptive grid columns based on content type
  static int getAdaptiveGridColumns(
    BuildContext context, {
    required String contentType,
    int? maxColumns,
  }) {
    final width = MediaQuery.of(context).size.width;
    int columns;

    switch (contentType) {
      case 'feature_cards':
        if (width < smallMobileBreakpoint) {
          columns = 1;
        } else if (width < largeMobileBreakpoint) {
          columns = 2;
        } else if (width < tabletBreakpoint) {
          columns = 3;
        } else {
          columns = 4;
        }
        break;
      case 'stat_cards':
        if (width < mobileBreakpoint) {
          columns = 2;
        } else if (width < tabletBreakpoint) {
          columns = 3;
        } else {
          columns = 4;
        }
        break;
      case 'list_items':
        if (width < largeMobileBreakpoint) {
          columns = 1;
        } else if (width < tabletBreakpoint) {
          columns = 2;
        } else {
          columns = 3;
        }
        break;
      default:
        columns = getGridColumns(context, maxColumns: maxColumns);
    }

    return maxColumns != null
        ? (columns > maxColumns ? maxColumns : columns)
        : columns;
  }

  // Padding
  static EdgeInsets getResponsivePadding(BuildContext context) {
    return EdgeInsets.all(
      getResponsiveValue(context, mobile: 16.0, tablet: 24.0, desktop: 32.0),
    );
  }

  static EdgeInsets getResponsiveHorizontalPadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: getResponsiveValue(
        context,
        mobile: 16.0,
        tablet: 32.0,
        desktop: 64.0,
      ),
    );
  }

  // Font sizes
  static double getResponsiveFontSize(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    return getResponsiveValue(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  // Card dimensions
  static double getCardAspectRatio(BuildContext context) {
    return getResponsiveValue(context, mobile: 0.9, tablet: 1.0, desktop: 1.1);
  }

  // Maximum content width for large screens
  static double getMaxContentWidth(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: double.infinity,
      tablet: 800,
      desktop: 1200,
    );
  }

  // Safe area padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return EdgeInsets.only(
      top: mediaQuery.padding.top,
      bottom: mediaQuery.padding.bottom,
      left: mediaQuery.padding.left,
      right: mediaQuery.padding.right,
    );
  }

  // Responsive spacing
  static double getSpacing(BuildContext context, {required String size}) {
    final multiplier = getResponsiveValue(
      context,
      mobile: 1.0,
      tablet: 1.2,
      desktop: 1.4,
    );

    switch (size) {
      case 'xs':
        return 4.0 * multiplier;
      case 'sm':
        return 8.0 * multiplier;
      case 'md':
        return 16.0 * multiplier;
      case 'lg':
        return 24.0 * multiplier;
      case 'xl':
        return 32.0 * multiplier;
      case 'xxl':
        return 48.0 * multiplier;
      default:
        return 16.0 * multiplier;
    }
  }

  // Responsive icon size
  static double getIconSize(BuildContext context, {required String size}) {
    final multiplier = getResponsiveValue(
      context,
      mobile: 1.0,
      tablet: 1.1,
      desktop: 1.2,
    );

    switch (size) {
      case 'sm':
        return 16.0 * multiplier;
      case 'md':
        return 24.0 * multiplier;
      case 'lg':
        return 32.0 * multiplier;
      case 'xl':
        return 48.0 * multiplier;
      default:
        return 24.0 * multiplier;
    }
  }

  // Responsive button height
  static double getButtonHeight(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: 48.0,
      tablet: 52.0,
      desktop: 56.0,
    );
  }

  // Responsive app bar height
  static double getAppBarHeight(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: kToolbarHeight,
      tablet: kToolbarHeight + 8,
      desktop: kToolbarHeight + 16,
    );
  }

  // Layout helpers
  static Widget buildResponsiveLayout({
    required BuildContext context,
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? tablet ?? mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return mobile;
  }

  // Responsive container
  static Widget buildResponsiveContainer({
    required BuildContext context,
    required Widget child,
    bool centerContent = true,
  }) {
    final maxWidth = getMaxContentWidth(context);

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: maxWidth),
      child:
          centerContent && maxWidth != double.infinity
              ? Center(child: child)
              : child,
    );
  }

  // Responsive grid view
  static Widget buildResponsiveGrid({
    required BuildContext context,
    required List<Widget> children,
    int? maxColumns,
    double? childAspectRatio,
    double? crossAxisSpacing,
    double? mainAxisSpacing,
  }) {
    final columns = getGridColumns(context, maxColumns: maxColumns);

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: columns,
      crossAxisSpacing: crossAxisSpacing ?? getSpacing(context, size: 'md'),
      mainAxisSpacing: mainAxisSpacing ?? getSpacing(context, size: 'md'),
      childAspectRatio: childAspectRatio ?? getCardAspectRatio(context),
      children: children,
    );
  }

  // Responsive text styles
  static TextStyle getHeadingStyle(BuildContext context, {int level = 1}) {
    final baseSizes = [32.0, 28.0, 24.0, 20.0, 18.0, 16.0];
    final clampedLevel = level.clamp(1, baseSizes.length);
    final size = baseSizes[clampedLevel - 1];

    return TextStyle(
      fontSize: getResponsiveFontSize(
        context,
        mobile: size,
        tablet: size + 2,
        desktop: size + 4,
      ),
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle getBodyStyle(BuildContext context) {
    return TextStyle(
      fontSize: getResponsiveFontSize(
        context,
        mobile: 14.0,
        tablet: 15.0,
        desktop: 16.0,
      ),
    );
  }

  static TextStyle getCaptionStyle(BuildContext context) {
    return TextStyle(
      fontSize: getResponsiveFontSize(
        context,
        mobile: 12.0,
        tablet: 13.0,
        desktop: 14.0,
      ),
      color: Colors.grey.shade600,
    );
  }

  // PRINCIPLE 1: Scroll when needed → SingleChildScrollView
  static Widget buildScrollableColumn({
    required BuildContext context,
    required List<Widget> children,
    EdgeInsets? padding,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    ScrollPhysics? physics,
  }) {
    return SingleChildScrollView(
      padding: padding ?? getScaledPadding(context),
      physics: physics,
      child: Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: children,
      ),
    );
  }

  static Widget buildScrollableRow({
    required BuildContext context,
    required List<Widget> children,
    EdgeInsets? padding,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    ScrollPhysics? physics,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding ?? getScaledPadding(context),
      physics: physics,
      child: Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: children,
      ),
    );
  }

  // PRINCIPLE 2: Scale instead of hardcoding → MediaQuery
  static double getScaledSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / 375.0; // Base width (iPhone 6/7/8)
    return baseSize * scaleFactor.clamp(0.8, 1.5);
  }

  static double getScaledFontSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / 375.0;
    return baseSize * scaleFactor.clamp(0.9, 1.3);
  }

  static double getScaledIconSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / 375.0;
    return baseSize * scaleFactor.clamp(0.8, 1.4);
  }

  static EdgeInsets getScaledPadding(BuildContext context, {double factor = 1.0}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final basePadding = screenWidth < 400 ? 12.0 : 16.0;
    return EdgeInsets.all(basePadding * factor);
  }

  static EdgeInsets getScaledSymmetricPadding(
    BuildContext context, {
    double horizontal = 1.0,
    double vertical = 1.0,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final basePadding = screenWidth < 400 ? 12.0 : 16.0;
    return EdgeInsets.symmetric(
      horizontal: basePadding * horizontal,
      vertical: basePadding * vertical,
    );
  }

  // PRINCIPLE 3: Let text wrap → don't force it into fixed-size containers
  static Widget buildFlexibleText(
    String text, {
    TextStyle? style,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return Flexible(
      child: Text(
        text,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow ?? TextOverflow.visible,
        softWrap: true,
      ),
    );
  }

  static Widget buildExpandedText(
    String text, {
    TextStyle? style,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    int flex = 1,
  }) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow ?? TextOverflow.visible,
        softWrap: true,
      ),
    );
  }

  static Widget buildAutoSizeText(
    String text, {
    required BuildContext context,
    TextStyle? style,
    TextAlign? textAlign,
    int? maxLines,
  }) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        text,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines ?? 1,
        overflow: TextOverflow.visible,
      ),
    );
  }





  // Responsive dialog with scrolling
  static Widget buildResponsiveDialog({
    required BuildContext context,
    required Widget title,
    required Widget content,
    List<Widget>? actions,
  }) {
    final screenSize = MediaQuery.of(context).size;

    return AlertDialog(
      title: title,
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: screenSize.width * 0.9,
          maxHeight: screenSize.height * 0.7,
        ),
        child: SingleChildScrollView(
          child: content,
        ),
      ),
      actions: actions,
    );
  }

  // Safe containers that adapt to content
  static Widget buildFlexibleContainer({
    required Widget child,
    EdgeInsets? padding,
    EdgeInsets? margin,
    Decoration? decoration,
    double? width,
    double? height,
    BoxConstraints? constraints,
  }) {
    return Container(
      padding: padding,
      margin: margin,
      decoration: decoration,
      width: width,
      height: height,
      constraints: constraints,
      child: child,
    );
  }

  // Responsive safe areas
  static Widget buildSafeScrollableScreen({
    required BuildContext context,
    required List<Widget> children,
    EdgeInsets? padding,
    ScrollPhysics? physics,
    Color? backgroundColor,
  }) {
    return Scaffold(
      backgroundColor: backgroundColor ?? Colors.grey.shade50,
      body: SafeArea(
        child: buildScrollableColumn(
          context: context,
          children: children,
          padding: padding,
          physics: physics,
        ),
      ),
    );
  }

  // Responsive card with proper constraints
  static Widget buildResponsiveCard({
    required BuildContext context,
    required Widget child,
    EdgeInsets? padding,
    EdgeInsets? margin,
    Color? color,
    double? elevation,
    BorderRadius? borderRadius,
  }) {
    return Container(
      margin: margin ?? EdgeInsets.symmetric(
        horizontal: getScaledSize(context, 8.0),
        vertical: getScaledSize(context, 4.0),
      ),
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: borderRadius ?? BorderRadius.circular(getScaledSize(context, 12.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: getScaledSize(context, 4.0),
            offset: Offset(0, getScaledSize(context, 2.0)),
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? getScaledPadding(context),
        child: child,
      ),
    );
  }



  // Responsive spacing helpers
  static SizedBox buildVerticalSpace(BuildContext context, double baseSize) {
    return SizedBox(height: getScaledSize(context, baseSize));
  }

  static SizedBox buildHorizontalSpace(BuildContext context, double baseSize) {
    return SizedBox(width: getScaledSize(context, baseSize));
  }

  // Responsive form field decoration
  static InputDecoration getResponsiveInputDecoration({
    required BuildContext context,
    String? hintText,
    String? labelText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    Color? fillColor,
  }) {
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: fillColor ?? const Color(0xFFF5F5F5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(getScaledSize(context, 12.0)),
        borderSide: BorderSide.none,
      ),
      contentPadding: getScaledSymmetricPadding(
        context,
        horizontal: 1.0,
        vertical: 1.0,
      ),
      hintStyle: TextStyle(
        color: Colors.grey,
        fontSize: getScaledFontSize(context, 14.0),
      ),
      labelStyle: TextStyle(
        color: Colors.grey.shade700,
        fontSize: getScaledFontSize(context, 14.0),
      ),
    );
  }
}
