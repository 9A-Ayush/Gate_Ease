import 'package:flutter/material.dart';

/// Comprehensive overflow prevention utilities for the entire app
class OverflowPrevention {
  
  /// Creates a safe scrollable column that prevents bottom overflow
  static Widget safeScrollableColumn({
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    EdgeInsets? padding,
    bool shrinkWrap = true,
    ScrollPhysics? physics,
  }) {
    return SingleChildScrollView(
      padding: padding,
      physics: physics,
      child: Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  /// Creates a safe flexible column that adapts to available space
  static Widget safeFlexibleColumn({
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    int flex = 1,
  }) {
    return Flexible(
      flex: flex,
      child: Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  /// Creates a safe expanded column that fills available space
  static Widget safeExpandedColumn({
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    int flex = 1,
  }) {
    return Expanded(
      flex: flex,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }

  /// Creates a safe dialog that prevents overflow
  static Widget safeDialog({
    required BuildContext context,
    required Widget title,
    required Widget content,
    List<Widget>? actions,
    double maxHeightFactor = 0.8,
    double maxWidthFactor = 0.9,
    bool scrollableContent = true,
  }) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * maxHeightFactor,
          maxWidth: MediaQuery.of(context).size.width * maxWidthFactor,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: title,
            ),
            
            // Content
            Flexible(
              child: scrollableContent
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: content,
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: content,
                    ),
            ),
            
            // Actions
            if (actions != null && actions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions
                      .map((action) => Flexible(child: action))
                      .expand((widget) => [widget, const SizedBox(width: 8)])
                      .take(actions.length * 2 - 1)
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Creates a safe alert dialog with overflow prevention
  static Widget safeAlertDialog({
    required BuildContext context,
    required Widget title,
    required Widget content,
    List<Widget>? actions,
    double maxHeightFactor = 0.8,
  }) {
    return AlertDialog(
      title: title,
      content: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * maxHeightFactor,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: SingleChildScrollView(
          child: content,
        ),
      ),
      actions: actions,
    );
  }

  /// Creates a safe bottom sheet that prevents overflow
  static Widget safeBottomSheet({
    required BuildContext context,
    required Widget child,
    double maxHeightFactor = 0.9,
    bool isScrollControlled = true,
  }) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * maxHeightFactor,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  /// Creates a safe form that prevents overflow
  static Widget safeForm({
    required List<Widget> children,
    EdgeInsets? padding,
    double? spacing,
  }) {
    final spacingValue = spacing ?? 16.0;
    
    return SingleChildScrollView(
      padding: padding ?? const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children
            .expand((widget) => [widget, SizedBox(height: spacingValue)])
            .take(children.length * 2 - 1)
            .toList(),
      ),
    );
  }

  /// Creates a safe card content that prevents overflow
  static Widget safeCardContent({
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.center,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    EdgeInsets? padding,
    double? spacing,
  }) {
    final spacingValue = spacing ?? 8.0;
    
    return Padding(
      padding: padding ?? const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: MainAxisSize.min,
        children: children
            .expand((widget) => [widget, SizedBox(height: spacingValue)])
            .take(children.length * 2 - 1)
            .toList(),
      ),
    );
  }

  /// Creates a safe list view that prevents overflow
  static Widget safeListView({
    required List<Widget> children,
    EdgeInsets? padding,
    bool shrinkWrap = true,
    ScrollPhysics? physics,
  }) {
    return ListView(
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics ?? const NeverScrollableScrollPhysics(),
      children: children,
    );
  }

  /// Creates a safe grid view that prevents overflow
  static Widget safeGridView({
    required List<Widget> children,
    int crossAxisCount = 2,
    double crossAxisSpacing = 8.0,
    double mainAxisSpacing = 8.0,
    double childAspectRatio = 1.0,
    EdgeInsets? padding,
    bool shrinkWrap = true,
    ScrollPhysics? physics,
  }) {
    return GridView.count(
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics ?? const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: crossAxisSpacing,
      mainAxisSpacing: mainAxisSpacing,
      childAspectRatio: childAspectRatio,
      children: children,
    );
  }

  /// Creates safe responsive spacing based on screen size
  static double safeSpacing(BuildContext context, {String size = 'md'}) {
    final screenHeight = MediaQuery.of(context).size.height;
    final baseSpacing = screenHeight < 600 ? 8.0 : 12.0;
    
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

  /// Creates safe responsive padding based on screen size
  static EdgeInsets safePadding(BuildContext context, {String size = 'md'}) {
    final spacing = safeSpacing(context, size: size);
    return EdgeInsets.all(spacing);
  }
}
