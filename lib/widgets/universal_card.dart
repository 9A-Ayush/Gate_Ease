import 'package:flutter/material.dart';

/// Universal card widget that provides consistent design across all user types
class UniversalCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool isCompact;
  final bool showBadge;
  final String? badgeText;
  final bool isEnabled;
  final Widget? customIcon;

  const UniversalCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.isCompact = false,
    this.showBadge = false,
    this.badgeText,
    this.isEnabled = true,
    this.customIcon,
  });

  @override
  State<UniversalCard> createState() => _UniversalCardState();
}

class _UniversalCardState extends State<UniversalCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.isEnabled) {
      setState(() => _isPressed = true);
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.isEnabled) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.isEnabled) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: widget.isEnabled ? widget.onTap : null,
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            child: Container(
              padding: EdgeInsets.all(widget.isCompact ? 4 : 8),
              decoration: BoxDecoration(
                color: widget.isEnabled ? Colors.white : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      _isPressed
                          ? widget.color.withValues(alpha: 0.3)
                          : (widget.isEnabled
                              ? Colors.grey.shade200
                              : Colors.grey.shade300),
                  width: _isPressed ? 2 : 1,
                ),
                boxShadow:
                    widget.isEnabled
                        ? [
                          BoxShadow(
                            color: Colors.grey.withValues(
                              alpha: _isPressed ? 0.2 : 0.1,
                            ),
                            spreadRadius: _isPressed ? 2 : 1,
                            blurRadius: _isPressed ? 8 : 4,
                            offset: Offset(0, _isPressed ? 4 : 2),
                          ),
                        ]
                        : [],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // More aggressive size reduction based on available space
                  final availableHeight = constraints.maxHeight;
                  final isVeryCompact = availableHeight < 110;
                  final isUltraCompact = availableHeight < 100;

                  final iconSize =
                      isUltraCompact
                          ? 12
                          : (isVeryCompact ? 14 : (widget.isCompact ? 16 : 18));
                  final titleSize =
                      isUltraCompact
                          ? 7
                          : (isVeryCompact ? 8 : (widget.isCompact ? 9 : 10));
                  final subtitleSize =
                      isUltraCompact
                          ? 5
                          : (isVeryCompact ? 6 : (widget.isCompact ? 7 : 8));
                  final spacing =
                      isUltraCompact
                          ? 0
                          : (isVeryCompact ? 1 : (widget.isCompact ? 2 : 3));

                  return Stack(
                    children: [
                      // Use Column with proper constraints
                      SizedBox(
                        height: 120, // Fixed height to prevent unbounded constraints
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Icon section with FittedBox and SizedBox.expand
                            Expanded(
                              flex: 4,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: widget.color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: SizedBox.expand(
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: widget.customIcon ??
                                        Icon(
                                          widget.icon,
                                          color: widget.isEnabled
                                              ? widget.color
                                              : Colors.grey,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Text section
                          Expanded(
                            flex: 2,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Title with FittedBox for responsiveness
                                Flexible(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      widget.title,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: widget.isCompact ? 11 : 13,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            widget.isEnabled
                                                ? Colors.black87
                                                : Colors.grey,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                // Subtitle with FittedBox for responsiveness
                                Flexible(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      widget.subtitle,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: widget.isCompact ? 9 : 10,
                                        color:
                                            widget.isEnabled
                                                ? Colors.grey.shade600
                                                : Colors.grey.shade400,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        ),
                      ),

                      // Badge
                      if (widget.showBadge && widget.badgeText != null)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              widget.badgeText!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Universal stat card for displaying statistics
class UniversalStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;

  const UniversalStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10), // Further reduced padding from 12 to 10
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Added to prevent overflow
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20), // Further reduced size from 22 to 20
              const Spacer(),
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 20, // Further reduced from 22 to 20
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  maxLines: 1,
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4), // Further reduced spacing from 6 to 4
          Text(
            title,
            style: const TextStyle(
              fontSize: 12, // Further reduced from 13 to 12
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1, // Further reduced from 2 to 1
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2), // Further reduced spacing from 3 to 2
            Text(
              subtitle!,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500), // Further reduced from 11 to 10
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

/// Universal grid configuration for consistent layouts
class UniversalGridConfig {
  static const double defaultAspectRatio = 1.9; // Further increased from 1.7 to 1.9
  static const double compactAspectRatio = 2.1; // Further increased from 1.9 to 2.1
  static const double crossAxisSpacing = 8.0;
  static const double mainAxisSpacing = 8.0;
  static const int crossAxisCount = 2;

  static GridView buildGrid({
    required List<Widget> children,
    bool isCompact = false,
    double? customAspectRatio,
  }) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: crossAxisSpacing,
      mainAxisSpacing: mainAxisSpacing,
      childAspectRatio:
          customAspectRatio ??
          (isCompact ? compactAspectRatio : defaultAspectRatio),
      children: children,
    );
  }
}
