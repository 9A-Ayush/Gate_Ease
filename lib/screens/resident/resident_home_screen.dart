import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_provider.dart';
import '../../widgets/ad_carousel_widget.dart';
import '../../widgets/communication_fab.dart';
import '../../widgets/universal_card.dart';
import '../../services/error_handler_service.dart';
import '../../utils/text_utils.dart';
import '../../utils/overflow_prevention.dart';
import '../../utils/responsive_utils.dart';
import 'package:provider/provider.dart';

class ResidentHomeScreen extends StatelessWidget {
  const ResidentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.appUser;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      floatingActionButton: const CommunicationFAB(),
      appBar: AppBar(
        title: const Text('GateEase Resident'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => _showNotifications(context),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/profile_edit'),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey.shade300,
                backgroundImage:
                    user?.profileImageUrl != null
                        ? NetworkImage(user!.profileImageUrl!)
                        : null,
                child:
                    user?.profileImageUrl == null
                        ? Icon(
                          Icons.person,
                          size: 20,
                          color: Colors.grey.shade600,
                        )
                        : null,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(12.0, 16.0, 12.0, 80.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${user?.name ?? 'Resident'}!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Flat ${user?.flatNo ?? 'N/A'} • ${user?.societyId ?? 'Society'}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Sponsored Ads Carousel
            const AdCarouselWidget(),
            const SizedBox(height: 24),

            // Quick Stats
            Row(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream:
                        FirebaseFirestore.instance
                            .collection('visitors')
                            .where('visiting_flat', isEqualTo: user?.flatNo)
                            .where('status', isEqualTo: 'pending')
                            .snapshots(),
                    builder: (context, snapshot) {
                      final count =
                          snapshot.hasData ? snapshot.data!.docs.length : 0;
                      return UniversalStatCard(
                        title: 'Pending Visitors',
                        value: count.toString(),
                        icon: Icons.people_outline,
                        color: Colors.orange,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream:
                        FirebaseFirestore.instance
                            .collection('complaints')
                            .where('raised_by', isEqualTo: user?.uid)
                            .where('status', isEqualTo: 'Open')
                            .snapshots(),
                    builder: (context, snapshot) {
                      final count =
                          snapshot.hasData ? snapshot.data!.docs.length : 0;
                      return UniversalStatCard(
                        title: 'Open Complaints',
                        value: count.toString(),
                        icon: Icons.report_problem_outlined,
                        color: Colors.red,
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Main Features
            const Text(
              'Resident Services',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            UniversalGridConfig.buildGrid(
              isCompact: true,
              children: [
                UniversalCard(
                  icon: Icons.people_outline,
                  title: 'Visitor Management',
                  subtitle: 'Approve & track\nvisitors',
                  color: Colors.blue,
                  isCompact: true,
                  onTap:
                      () => Navigator.pushNamed(context, '/visitor_management'),
                ),
                UniversalCard(
                  icon: Icons.report_problem,
                  title: 'Raise Complaints',
                  subtitle: 'Report & track Issues',
                  color: Colors.red,
                  isCompact: true,
                  onTap: () => Navigator.pushNamed(context, '/complaints'),
                ),
                UniversalCard(
                  icon: Icons.pool,
                  title: 'Amenity Booking',
                  subtitle: 'Book community & facilities',
                  color: Colors.purple,
                  isCompact: true,
                  onTap: () => Navigator.pushNamed(context, '/amenities'),
                ),
                UniversalCard(
                  icon: Icons.payment,
                  title: 'Payment History',
                  subtitle: 'View maintenance & fees',
                  color: Colors.green,
                  isCompact: true,
                  onTap: () => Navigator.pushNamed(context, '/payments'),
                ),
                UniversalCard(
                  icon: Icons.chat_bubble_outline,
                  title: 'Community Chat',
                  subtitle: 'Connect with neighbors',
                  color: Colors.teal,
                  isCompact: true,
                  onTap: () => Navigator.pushNamed(context, '/chat'),
                ),
                UniversalCard(
                  icon: Icons.announcement,
                  title: 'Society Announcements',
                  subtitle: 'View updates & alerts',
                  color: Colors.orange,
                  isCompact: true,
                  onTap: () => Navigator.pushNamed(context, '/announcements'),
                ),
                UniversalCard(
                  icon: Icons.people_alt,
                  title: 'Social Feed',
                  subtitle: 'Connect with community',
                  color: Colors.indigo,
                  isCompact: true,
                  onTap: () => Navigator.pushNamed(context, '/social_feed'),
                ),
                UniversalCard(
                  icon: Icons.shopping_bag,
                  title: 'Shop',
                  subtitle: 'Buy products from vendors',
                  color: Colors.deepOrange,
                  isCompact: true,
                  onTap: () => Navigator.pushNamed(context, '/products'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recent Activity Section
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                'No recent activity',
                style: TextStyle(color: Colors.grey, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => OverflowPrevention.safeAlertDialog(
            context: context,
            title: const Row(
              children: [
                Icon(Icons.notifications, color: Color(0xFF4CAF50)),
                SizedBox(width: 8),
                Flexible(child: Text('Notifications')),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildNotificationItem(
                  'Welcome to GateEase!',
                  'Your account has been successfully activated.',
                  Icons.check_circle,
                  Colors.green,
                  '2 hours ago',
                ),
                _buildNotificationItem(
                  'Visitor Approved',
                  'Your visitor John Doe has been approved by security.',
                  Icons.person_add_alt_1,
                  Colors.blue,
                  '1 day ago',
                ),
                _buildNotificationItem(
                  'Maintenance Payment Due',
                  'Your monthly maintenance payment is due on 30th.',
                  Icons.payment,
                  Colors.orange,
                  '3 days ago',
                ),
                _buildNotificationItem(
                  'Society Announcement',
                  'New parking rules will be effective from next month.',
                  Icons.announcement,
                  Colors.purple,
                  '1 week ago',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: TextUtils.buttonText('Close'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ErrorHandlerService.showInfoSnackBar(
                    context,
                    'Full notification system coming soon!',
                  );
                },
                child: const Text('View All'),
              ),
            ],
          ),
    );
  }

  Widget _buildNotificationItem(
    String title,
    String message,
    IconData icon,
    Color color,
    String time,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
