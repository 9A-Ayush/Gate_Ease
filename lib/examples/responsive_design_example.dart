import 'package:flutter/material.dart';
import '../utils/responsive_utils.dart';

/// Comprehensive example demonstrating the three responsive design principles:
/// 1. Scroll when needed → SingleChildScrollView
/// 2. Scale instead of hardcoding → MediaQuery
/// 3. Let text wrap → don't force it into fixed-size containers
class ResponsiveDesignExample extends StatelessWidget {
  const ResponsiveDesignExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Responsive Design Example',
          style: TextStyle(
            // PRINCIPLE 2: Scale instead of hardcoding → MediaQuery
            fontSize: ResponsiveUtils.getScaledFontSize(context, 20),
          ),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      // PRINCIPLE 1: Scroll when needed → SingleChildScrollView
      body: ResponsiveUtils.buildScrollableColumn(
        context: context,
        children: [
          _buildWelcomeSection(context),
          ResponsiveUtils.buildVerticalSpace(context, 24),
          _buildScalingExamples(context),
          ResponsiveUtils.buildVerticalSpace(context, 24),
          _buildTextWrappingExamples(context),
          ResponsiveUtils.buildVerticalSpace(context, 24),
          _buildFormExample(context),
          ResponsiveUtils.buildVerticalSpace(context, 24),
          _buildGridExample(context),
          ResponsiveUtils.buildVerticalSpace(context, 40),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return ResponsiveUtils.buildResponsiveCard(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PRINCIPLE 3: Let text wrap → flexible text
          ResponsiveUtils.buildFlexibleText(
            'Welcome to Responsive Design!',
            style: TextStyle(
              fontSize: ResponsiveUtils.getScaledFontSize(context, 24),
              fontWeight: FontWeight.bold,
              color: const Color(0xFF4CAF50),
            ),
          ),
          ResponsiveUtils.buildVerticalSpace(context, 8),
          ResponsiveUtils.buildFlexibleText(
            'This example demonstrates the three core principles of responsive design in Flutter applications.',
            style: TextStyle(
              fontSize: ResponsiveUtils.getScaledFontSize(context, 16),
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScalingExamples(BuildContext context) {
    return ResponsiveUtils.buildResponsiveCard(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveUtils.buildFlexibleText(
            'Principle 2: Scale instead of hardcoding',
            style: TextStyle(
              fontSize: ResponsiveUtils.getScaledFontSize(context, 20),
              fontWeight: FontWeight.bold,
            ),
          ),
          ResponsiveUtils.buildVerticalSpace(context, 16),
          Row(
            children: [
              Icon(
                Icons.phone_android,
                size: ResponsiveUtils.getScaledIconSize(context, 24),
                color: Colors.blue,
              ),
              ResponsiveUtils.buildHorizontalSpace(context, 8),
              ResponsiveUtils.buildFlexibleText(
                'Icons scale with screen size',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getScaledFontSize(context, 14),
                ),
              ),
            ],
          ),
          ResponsiveUtils.buildVerticalSpace(context, 12),
          Container(
            width: double.infinity,
            height: ResponsiveUtils.getButtonHeight(context),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getScaledSize(context, 8),
              ),
            ),
            child: Center(
              child: ResponsiveUtils.buildFlexibleText(
                'Button height scales responsively',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ResponsiveUtils.getScaledFontSize(context, 16),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextWrappingExamples(BuildContext context) {
    return ResponsiveUtils.buildResponsiveCard(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveUtils.buildFlexibleText(
            'Principle 3: Let text wrap',
            style: TextStyle(
              fontSize: ResponsiveUtils.getScaledFontSize(context, 20),
              fontWeight: FontWeight.bold,
            ),
          ),
          ResponsiveUtils.buildVerticalSpace(context, 16),
          // Example of flexible text in a row
          Row(
            children: [
              Icon(
                Icons.text_fields,
                size: ResponsiveUtils.getScaledIconSize(context, 20),
                color: Colors.orange,
              ),
              ResponsiveUtils.buildHorizontalSpace(context, 8),
              ResponsiveUtils.buildFlexibleText(
                'This text will wrap gracefully instead of overflowing, even on very narrow screens or when the text is quite long.',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getScaledFontSize(context, 14),
                ),
              ),
            ],
          ),
          ResponsiveUtils.buildVerticalSpace(context, 12),
          // Example of auto-sizing text
          ResponsiveUtils.buildAutoSizeText(
            'This text auto-scales to fit available space',
            context: context,
            style: TextStyle(
              fontSize: ResponsiveUtils.getScaledFontSize(context, 18),
              fontWeight: FontWeight.w500,
              color: Colors.purple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormExample(BuildContext context) {
    return ResponsiveUtils.buildResponsiveCard(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveUtils.buildFlexibleText(
            'Responsive Form Example',
            style: TextStyle(
              fontSize: ResponsiveUtils.getScaledFontSize(context, 20),
              fontWeight: FontWeight.bold,
            ),
          ),
          ResponsiveUtils.buildVerticalSpace(context, 16),
          TextFormField(
            decoration: ResponsiveUtils.getResponsiveInputDecoration(
              context: context,
              hintText: 'Enter your name',
              prefixIcon: Icon(
                Icons.person,
                size: ResponsiveUtils.getScaledIconSize(context, 20),
              ),
            ),
          ),
          ResponsiveUtils.buildVerticalSpace(context, 12),
          TextFormField(
            decoration: ResponsiveUtils.getResponsiveInputDecoration(
              context: context,
              hintText: 'Enter your email',
              prefixIcon: Icon(
                Icons.email,
                size: ResponsiveUtils.getScaledIconSize(context, 20),
              ),
            ),
          ),
          ResponsiveUtils.buildVerticalSpace(context, 16),
          SizedBox(
            width: double.infinity,
            height: ResponsiveUtils.getButtonHeight(context),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.getScaledSize(context, 8),
                  ),
                ),
              ),
              child: ResponsiveUtils.buildFlexibleText(
                'Submit',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ResponsiveUtils.getScaledFontSize(context, 16),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridExample(BuildContext context) {
    return ResponsiveUtils.buildResponsiveCard(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveUtils.buildFlexibleText(
            'Responsive Grid Layout',
            style: TextStyle(
              fontSize: ResponsiveUtils.getScaledFontSize(context, 20),
              fontWeight: FontWeight.bold,
            ),
          ),
          ResponsiveUtils.buildVerticalSpace(context, 16),
          ResponsiveUtils.buildResponsiveLayout(
            context: context,
            mobile: Column(
              children: _buildGridItems(context),
            ),
            tablet: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: ResponsiveUtils.getScaledSize(context, 12),
              mainAxisSpacing: ResponsiveUtils.getScaledSize(context, 12),
              childAspectRatio: 3,
              children: _buildGridItems(context),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildGridItems(BuildContext context) {
    final items = ['Item 1', 'Item 2', 'Item 3', 'Item 4'];
    return items.map((item) {
      return Container(
        margin: EdgeInsets.only(bottom: ResponsiveUtils.getScaledSize(context, 8)),
        padding: ResponsiveUtils.getScaledPadding(context, factor: 0.75),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.getScaledSize(context, 8),
          ),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Center(
          child: ResponsiveUtils.buildFlexibleText(
            item,
            style: TextStyle(
              fontSize: ResponsiveUtils.getScaledFontSize(context, 14),
              fontWeight: FontWeight.w500,
              color: Colors.blue.shade700,
            ),
          ),
        ),
      );
    }).toList();
  }
}
