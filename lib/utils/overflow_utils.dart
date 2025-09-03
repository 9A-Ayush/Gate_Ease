import 'package:flutter/material.dart';

/// Utility class to prevent overflow issues across the app
class OverflowUtils {
  
  /// Creates a safe Row that prevents horizontal overflow
  static Widget safeRow({
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    MainAxisSize mainAxisSize = MainAxisSize.max,
  }) {
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: children.map((child) {
        // Wrap non-Expanded widgets in Flexible to prevent overflow
        if (child is Expanded || child is Flexible) {
          return child;
        }
        return Flexible(child: child);
      }).toList(),
    );
  }

  /// Creates a safe Column that prevents vertical overflow
  static Widget safeColumn({
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    MainAxisSize mainAxisSize = MainAxisSize.min,
  }) {
    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: children,
    );
  }

  /// Creates a safe dialog that prevents overflow
  static Widget safeDialog({
    required BuildContext context,
    required Widget child,
    double maxHeightFactor = 0.8,
    double maxWidthFactor = 0.9,
  }) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * maxHeightFactor,
          maxWidth: MediaQuery.of(context).size.width * maxWidthFactor,
        ),
        child: SingleChildScrollView(
          child: child,
        ),
      ),
    );
  }

  /// Creates safe text that prevents overflow
  static Widget safeText(
    String text, {
    TextStyle? style,
    int? maxLines,
    TextOverflow overflow = TextOverflow.ellipsis,
    TextAlign textAlign = TextAlign.start,
  }) {
    return Text(
      text,
      style: style,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }

  /// Creates a safe button row that prevents overflow
  static Widget safeButtonRow({
    required List<Widget> buttons,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.end,
    double spacing = 12.0,
  }) {
    final List<Widget> children = [];
    for (int i = 0; i < buttons.length; i++) {
      if (i > 0) {
        children.add(SizedBox(width: spacing));
      }
      children.add(Flexible(child: buttons[i]));
    }
    
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      children: children,
    );
  }

  /// Creates a safe form field that prevents overflow
  static Widget safeFormField({
    required Widget child,
    String? label,
    double spacing = 8.0,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          safeText(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: spacing),
        ],
        child,
      ],
    );
  }

  /// Creates a safe grid that prevents overflow
  static Widget safeGrid({
    required List<Widget> children,
    int crossAxisCount = 2,
    double crossAxisSpacing = 12.0,
    double mainAxisSpacing = 12.0,
    double childAspectRatio = 1.1,
  }) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: crossAxisSpacing,
      mainAxisSpacing: mainAxisSpacing,
      childAspectRatio: childAspectRatio,
      children: children,
    );
  }

  /// Creates safe padding that adapts to screen size
  static EdgeInsets safePadding(BuildContext context, {
    double factor = 1.0,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final basePadding = screenWidth < 400 ? 12.0 : 16.0;
    return EdgeInsets.all(basePadding * factor);
  }

  /// Creates safe spacing that adapts to screen size
  static double safeSpacing(BuildContext context, {
    String size = 'md',
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final baseSpacing = screenWidth < 400 ? 8.0 : 12.0;
    
    switch (size) {
      case 'xs':
        return baseSpacing * 0.5;
      case 'sm':
        return baseSpacing * 0.75;
      case 'md':
        return baseSpacing;
      case 'lg':
        return baseSpacing * 1.5;
      case 'xl':
        return baseSpacing * 2.0;
      default:
        return baseSpacing;
    }
  }

  /// Creates a safe container with responsive constraints
  static Widget safeContainer({
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

  /// Wraps content in a safe scrollable area
  static Widget safeScrollable({
    required Widget child,
    EdgeInsets? padding,
    ScrollPhysics? physics,
  }) {
    return SingleChildScrollView(
      padding: padding,
      physics: physics,
      child: child,
    );
  }

  /// Creates a safe modal bottom sheet
  static Widget safeBottomSheet({
    required BuildContext context,
    required Widget child,
    double maxHeightFactor = 0.9,
  }) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * maxHeightFactor,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: child,
      ),
    );
  }

  /// Creates safe responsive font sizes
  static double safeFontSize(BuildContext context, {
    required double baseSize,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 400) {
      return baseSize * 0.9;
    } else if (screenWidth > 600) {
      return baseSize * 1.1;
    }
    return baseSize;
  }

  /// Creates safe responsive icon sizes
  static double safeIconSize(BuildContext context, {
    required double baseSize,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 400) {
      return baseSize * 0.9;
    } else if (screenWidth > 600) {
      return baseSize * 1.1;
    }
    return baseSize;
  }
}
