import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/responsive_utils.dart';
import '../../widgets/responsive_widgets.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  Map<String, dynamic> _analytics = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    try {
      // Get user counts by role
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();

      int totalUsers = usersSnapshot.docs.length;
      int residents = 0;
      int vendors = 0;
      int guards = 0;
      int pendingApprovals = 0;

      for (var doc in usersSnapshot.docs) {
        final data = doc.data();
        final role = data['role'] ?? '';
        final status = data['status'] ?? '';

        switch (role) {
          case 'resident':
            residents++;
            if (status == 'pending') pendingApprovals++;
            break;
          case 'vendor':
            vendors++;
            break;
          case 'guard':
            guards++;
            break;
        }
      }

      // Get visitor statistics
      final visitorsSnapshot = await FirebaseFirestore.instance
          .collection('visitors')
          .get();

      int totalVisitors = visitorsSnapshot.docs.length;
      int approvedVisitors = 0;
      int pendingVisitors = 0;

      for (var doc in visitorsSnapshot.docs) {
        final data = doc.data();
        final status = data['status'] ?? '';
        if (status == 'approved') approvedVisitors++;
        if (status == 'pending') pendingVisitors++;
      }

      // Get complaint statistics
      final complaintsSnapshot = await FirebaseFirestore.instance
          .collection('complaints')
          .get();

      int totalComplaints = complaintsSnapshot.docs.length;
      int resolvedComplaints = 0;
      int pendingComplaints = 0;

      for (var doc in complaintsSnapshot.docs) {
        final data = doc.data();
        final status = data['status'] ?? '';
        if (status == 'resolved') resolvedComplaints++;
        if (status == 'pending') pendingComplaints++;
      }

      // Get vendor statistics
      final servicesSnapshot = await FirebaseFirestore.instance
          .collection('vendor_services')
          .get();

      final adsSnapshot = await FirebaseFirestore.instance
          .collection('vendor_ads')
          .get();

      int totalServices = servicesSnapshot.docs.length;
      int activeServices = 0;
      int totalAds = adsSnapshot.docs.length;
      int activeAds = 0;

      for (var doc in servicesSnapshot.docs) {
        final data = doc.data();
        if (data['isActive'] == true) activeServices++;
      }

      for (var doc in adsSnapshot.docs) {
        final data = doc.data();
        if (data['status'] == 'active') activeAds++;
      }

      setState(() {
        _analytics = {
          'totalUsers': totalUsers,
          'residents': residents,
          'vendors': vendors,
          'guards': guards,
          'pendingApprovals': pendingApprovals,
          'totalVisitors': totalVisitors,
          'approvedVisitors': approvedVisitors,
          'pendingVisitors': pendingVisitors,
          'totalComplaints': totalComplaints,
          'resolvedComplaints': resolvedComplaints,
          'pendingComplaints': pendingComplaints,
          'totalServices': totalServices,
          'activeServices': activeServices,
          'totalAds': totalAds,
          'activeAds': activeAds,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading analytics: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'Analytics Dashboard',
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: ResponsiveUtils.getResponsivePadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Statistics
                  _buildSectionTitle('User Statistics'),
                  ResponsiveGrid(
                    maxColumns: 2,
                    children: [
                      _buildStatCard(
                        'Total Users',
                        '${_analytics['totalUsers'] ?? 0}',
                        Icons.people,
                        Colors.blue,
                      ),
                      _buildStatCard(
                        'Residents',
                        '${_analytics['residents'] ?? 0}',
                        Icons.home,
                        Colors.green,
                      ),
                      _buildStatCard(
                        'Vendors',
                        '${_analytics['vendors'] ?? 0}',
                        Icons.business,
                        Colors.orange,
                      ),
                      _buildStatCard(
                        'Guards',
                        '${_analytics['guards'] ?? 0}',
                        Icons.security,
                        Colors.purple,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Pending Approvals
                  _buildSectionTitle('Pending Approvals'),
                  ResponsiveGrid(
                    maxColumns: 2,
                    children: [
                      _buildStatCard(
                        'Pending Residents',
                        '${_analytics['pendingApprovals'] ?? 0}',
                        Icons.pending_actions,
                        Colors.red,
                      ),
                      _buildStatCard(
                        'Pending Visitors',
                        '${_analytics['pendingVisitors'] ?? 0}',
                        Icons.people_outline,
                        Colors.orange,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Visitor Statistics
                  _buildSectionTitle('Visitor Management'),
                  ResponsiveGrid(
                    maxColumns: 2,
                    children: [
                      _buildStatCard(
                        'Total Visitors',
                        '${_analytics['totalVisitors'] ?? 0}',
                        Icons.people_alt,
                        Colors.indigo,
                      ),
                      _buildStatCard(
                        'Approved Visitors',
                        '${_analytics['approvedVisitors'] ?? 0}',
                        Icons.check_circle,
                        Colors.green,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Complaint Statistics
                  _buildSectionTitle('Complaint Management'),
                  ResponsiveGrid(
                    maxColumns: 2,
                    children: [
                      _buildStatCard(
                        'Total Complaints',
                        '${_analytics['totalComplaints'] ?? 0}',
                        Icons.report_problem,
                        Colors.red,
                      ),
                      _buildStatCard(
                        'Resolved',
                        '${_analytics['resolvedComplaints'] ?? 0}',
                        Icons.check_circle_outline,
                        Colors.green,
                      ),
                      _buildStatCard(
                        'Pending',
                        '${_analytics['pendingComplaints'] ?? 0}',
                        Icons.pending,
                        Colors.orange,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Vendor Statistics
                  _buildSectionTitle('Vendor Management'),
                  ResponsiveGrid(
                    maxColumns: 2,
                    children: [
                      _buildStatCard(
                        'Total Services',
                        '${_analytics['totalServices'] ?? 0}',
                        Icons.build,
                        Colors.teal,
                      ),
                      _buildStatCard(
                        'Active Services',
                        '${_analytics['activeServices'] ?? 0}',
                        Icons.verified,
                        Colors.green,
                      ),
                      _buildStatCard(
                        'Total Ads',
                        '${_analytics['totalAds'] ?? 0}',
                        Icons.campaign,
                        Colors.purple,
                      ),
                      _buildStatCard(
                        'Active Ads',
                        '${_analytics['activeAds'] ?? 0}',
                        Icons.ads_click,
                        Colors.orange,
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: ResponsiveUtils.getHeadingStyle(context, level: 2),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return ResponsiveCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: ResponsiveUtils.getBodyStyle(context).copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: ResponsiveUtils.getHeadingStyle(context, level: 1).copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
