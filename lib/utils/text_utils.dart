import 'package:flutter/material.dart';

/// Universal text utilities for consistent overflow handling across the app
class TextUtils {
  /// Creates a responsive text widget that automatically sizes to fit
  static Widget responsiveText(
    String text, {
    TextStyle? style,
    int maxLines = 1,
    TextAlign textAlign = TextAlign.start,
    TextOverflow overflow = TextOverflow.ellipsis,
  }) {
    return Text(
      text,
      style: style,
      maxLines: maxLines,
      textAlign: textAlign,
      overflow: overflow,
    );
  }

  /// Creates a flexible text widget that shrinks gracefully
  static Widget flexibleText(
    String text, {
    TextStyle? style,
    int maxLines = 1,
    TextAlign textAlign = TextAlign.start,
    TextOverflow overflow = TextOverflow.ellipsis,
    int flex = 1,
  }) {
    return Flexible(
      flex: flex,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: _getAlignmentFromTextAlign(textAlign),
        child: Text(
          text,
          style: style,
          maxLines: maxLines,
          overflow: overflow,
          textAlign: textAlign,
        ),
      ),
    );
  }

  /// Creates a text widget for buttons that handles long text gracefully
  static Widget buttonText(
    String text, {
    TextStyle? style,
    int maxLines = 1,
    TextAlign textAlign = TextAlign.center,
  }) {
    return Flexible(
      child: Text(
        text,
        style: style,
        maxLines: maxLines,
        textAlign: textAlign,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// Creates a text widget for list tiles that handles overflow
  static Widget listTileText(
    String text, {
    TextStyle? style,
    int maxLines = 1,
    bool isTitle = false,
  }) {
    return Text(
      text,
      style: style,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Creates a text widget for cards that adapts to available space
  static Widget cardText(
    String text, {
    TextStyle? style,
    int maxLines = 1,
    TextAlign textAlign = TextAlign.center,
    bool isTitle = false,
  }) {
    return Text(
      text,
      style: style,
      maxLines: maxLines,
      textAlign: textAlign,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Creates a text widget for headers that scales appropriately
  static Widget headerText(
    String text, {
    TextStyle? style,
    int maxLines = 2,
    TextAlign textAlign = TextAlign.start,
  }) {
    return Text(
      text,
      style: style,
      maxLines: maxLines,
      textAlign: textAlign,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Creates a text widget for app bar titles
  static Widget appBarText(String text, {TextStyle? style}) {
    return Text(
      text,
      style: style,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Creates a text widget for form labels
  static Widget labelText(String text, {TextStyle? style, int maxLines = 1}) {
    return Text(
      text,
      style: style,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Creates a text widget for body content
  static Widget bodyText(
    String text, {
    TextStyle? style,
    int maxLines = 3,
    TextAlign textAlign = TextAlign.start,
  }) {
    return Text(
      text,
      style: style,
      maxLines: maxLines,
      textAlign: textAlign,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Creates a text widget for status chips/badges
  static Widget statusText(String text, {TextStyle? style}) {
    return Text(
      text,
      style: style,
      maxLines: 1,
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Helper method to convert TextAlign to Alignment
  static Alignment _getAlignmentFromTextAlign(TextAlign textAlign) {
    switch (textAlign) {
      case TextAlign.left:
      case TextAlign.start:
        return Alignment.centerLeft;
      case TextAlign.right:
      case TextAlign.end:
        return Alignment.centerRight;
      case TextAlign.center:
        return Alignment.center;
      case TextAlign.justify:
        return Alignment.centerLeft;
    }
  }

  /// Creates a safe row with flexible text elements
  static Widget safeTextRow({
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
  }) {
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children:
          children.map((child) {
            if (child is Text) {
              return Flexible(
                child: Text(
                  child.data ?? '',
                  style: child.style,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }
            return child;
          }).toList(),
    );
  }

  /// Creates a safe column with flexible text elements
  static Widget safeTextColumn({
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
  }) {
    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: children,
    );
  }
}
