import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_provider.dart';
import '../../services/notification_service.dart';
import '../../widgets/communication_fab.dart';
import '../../widgets/universal_card.dart';
import 'package:provider/provider.dart';
import '../../utils/responsive_utils.dart';
import '../../widgets/responsive_widgets.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return ResponsiveScaffold(
      title: 'Admin Dashboard',
      floatingActionButton: const CommunicationFAB(),
      actions: [
        // Notifications Button with Badge (moved to left)
        StreamBuilder<QuerySnapshot>(
          stream: NotificationService.getUnreadNotificationsCount(),
          builder: (context, snapshot) {
            final unreadCount =
                snapshot.hasData ? snapshot.data!.docs.length : 0;
            return Stack(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.notifications,
                    size: ResponsiveUtils.getIconSize(context, size: 'md'),
                  ),
                  onPressed:
                      () =>
                          Navigator.pushNamed(context, '/admin_notifications'),
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        unreadCount > 99 ? '99+' : '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        // Profile Avatar (moved to right)
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/profile_edit'),
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            child: CircleAvatar(
              radius: ResponsiveUtils.getIconSize(context, size: 'md') / 2,
              backgroundColor: Colors.grey.shade300,
              backgroundImage:
                  authProvider.appUser?.profileImageUrl != null
                      ? NetworkImage(authProvider.appUser!.profileImageUrl!)
                      : null,
              child:
                  authProvider.appUser?.profileImageUrl == null
                      ? Icon(
                        Icons.person,
                        size: ResponsiveUtils.getIconSize(context, size: 'sm'),
                        color: Colors.grey.shade600,
                      )
                      : null,
            ),
          ),
        ),
      ],
      body: SingleChildScrollView(
        padding: ResponsiveUtils.getResponsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              width: double.infinity,
              padding: ResponsiveUtils.getResponsivePadding(context),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, Admin!',
                    style: ResponsiveUtils.getHeadingStyle(
                      context,
                      level: 2,
                    ).copyWith(color: Colors.white),
                  ),
                  SizedBox(
                    height: ResponsiveUtils.getSpacing(context, size: 'sm'),
                  ),
                  Text(
                    'Manage your society efficiently',
                    style: ResponsiveUtils.getBodyStyle(
                      context,
                    ).copyWith(color: Colors.white.withOpacity(0.9)),
                  ),
                ],
              ),
            ),
            SizedBox(height: ResponsiveUtils.getSpacing(context, size: 'lg')),

            // Pending Requests Summary
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('users')
                      .where('role', isEqualTo: 'resident')
                      .where('status', isEqualTo: 'pending')
                      .snapshots(),
              builder: (context, snapshot) {
                final pendingCount =
                    snapshot.hasData ? snapshot.data!.docs.length : 0;

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        pendingCount > 0
                            ? Colors.orange.shade50
                            : Colors.green.shade50,
                    border: Border.all(
                      color: pendingCount > 0 ? Colors.orange : Colors.green,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        pendingCount > 0
                            ? Icons.pending_actions
                            : Icons.check_circle,
                        color: pendingCount > 0 ? Colors.orange : Colors.green,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pendingCount > 0
                                  ? '$pendingCount Pending Requests'
                                  : 'No Pending Requests',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color:
                                    pendingCount > 0
                                        ? Colors.orange.shade800
                                        : Colors.green.shade800,
                              ),
                            ),
                            Text(
                              pendingCount > 0
                                  ? 'Residents waiting for approval'
                                  : 'All requests processed',
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    pendingCount > 0
                                        ? Colors.orange.shade600
                                        : Colors.green.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (pendingCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$pendingCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Management Options
            const Text(
              'Management',
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
                // Priority 1: Most urgent/important tasks
                UniversalCard(
                  icon: Icons.people_outline,
                  title: 'Pending Requests',
                  subtitle: 'Review resident applications',
                  color: Colors.orange,
                  isCompact: true,
                  onTap:
                      () => Navigator.pushNamed(
                        context,
                        '/admin_pending_requests',
                      ),
                ),
                UniversalCard(
                  icon: Icons.receipt_long,
                  title: 'Bill Management',
                  subtitle: 'Create & manage bills',
                  color: Colors.teal,
                  isCompact: true,
                  onTap: () => Navigator.pushNamed(context, '/admin_bills'),
                ),

                // Priority 2: User management
                UniversalCard(
                  icon: Icons.group,
                  title: 'Manage Users',
                  subtitle: 'Residents, Guards & Vendors',
                  color: Colors.blue,
                  isCompact: true,
                  onTap:
                      () => Navigator.pushNamed(
                        context,
                        '/admin_user_management',
                      ),
                ),
                UniversalCard(
                  icon: Icons.people_alt,
                  title: 'Visitor Management',
                  subtitle: 'Monitor & approve visitors',
                  color: Colors.indigo,
                  isCompact: true,
                  onTap:
                      () => Navigator.pushNamed(
                        context,
                        '/admin_visitor_management',
                      ),
                ),

                // Priority 3: Communication & issues
                UniversalCard(
                  icon: Icons.announcement,
                  title: 'Post Announcements',
                  subtitle: 'Society updates & alerts',
                  color: Colors.orange,
                  isCompact: true,
                  onTap:
                      () =>
                          Navigator.pushNamed(context, '/admin_announcements'),
                ),
                UniversalCard(
                  icon: Icons.report_problem,
                  title: 'Manage Complaints',
                  subtitle: 'Handle & resolve issues',
                  color: Colors.red,
                  isCompact: true,
                  onTap:
                      () => Navigator.pushNamed(context, '/admin_complaints'),
                ),

                // Priority 4: Business & analytics
                UniversalCard(
                  icon: Icons.business,
                  title: 'Vendor Management',
                  subtitle: 'Approve ads & listings',
                  color: Colors.teal,
                  isCompact: true,
                  onTap: () => Navigator.pushNamed(context, '/admin_vendors'),
                ),
                UniversalCard(
                  icon: Icons.analytics,
                  title: 'Analytics',
                  subtitle: 'Statistics & reports',
                  color: Colors.purple,
                  isCompact: true,
                  onTap: () => Navigator.pushNamed(context, '/admin_analytics'),
                ),
                UniversalCard(
                  icon: Icons.people_alt,
                  title: 'Social Feed',
                  subtitle: 'Connect with community',
                  color: Colors.indigo,
                  isCompact: true,
                  onTap: () => Navigator.pushNamed(context, '/social_feed'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
