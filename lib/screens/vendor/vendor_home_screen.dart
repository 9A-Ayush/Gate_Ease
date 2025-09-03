import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_provider.dart';
import '../../services/vendor_service.dart';
import '../../models/vendor_service.dart';
import '../../models/vendor_ad.dart';
import '../../widgets/communication_fab.dart';
import '../../widgets/universal_card.dart';

class VendorHomeScreen extends StatefulWidget {
  const VendorHomeScreen({super.key});

  @override
  State<VendorHomeScreen> createState() => _VendorHomeScreenState();
}

class _VendorHomeScreenState extends State<VendorHomeScreen> {
  final VendorBusinessService _vendorService = VendorBusinessService();
  Map<String, dynamic>? _analytics;
  bool _isLoadingAnalytics = true;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.appUser?.uid != null) {
      try {
        final analytics = await _vendorService.getVendorAnalytics(
          authProvider.appUser!.uid,
        );
        setState(() {
          _analytics = analytics;
          _isLoadingAnalytics = false;
        });
      } catch (e) {
        setState(() => _isLoadingAnalytics = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.appUser;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Vendor Dashboard'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/profile_edit'),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
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
      body: RefreshIndicator(
        onRefresh: _loadAnalytics,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
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
                      'Welcome, ${user?.name ?? 'Vendor'}!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Manage your services and grow your business',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Analytics Cards
              if (_isLoadingAnalytics)
                const Center(child: CircularProgressIndicator())
              else if (_analytics != null)
                _buildAnalyticsSection(),

              const SizedBox(height: 24),

              // Quick Actions
              _buildQuickActions(),

              const SizedBox(height: 24),

              // Recent Services
              _buildRecentServices(),

              const SizedBox(height: 24),

              // Recent Ads
              _buildRecentAds(),
            ],
          ),
        ),
      ),
      floatingActionButton: const CommunicationFAB(),
    );
  }

  Widget _buildAnalyticsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // Added to prevent overflow
      children: [
        const Text(
          'Analytics Overview',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12), // Reduced spacing from 16 to 12
        UniversalGridConfig.buildGrid(
          customAspectRatio: 2.0, // Increased custom aspect ratio for better fit
          children: [
            UniversalStatCard(
              title: 'Services',
              value: '${_analytics!['totalServices']}',
              subtitle: '${_analytics!['activeServices']} active',
              icon: Icons.build,
              color: Colors.blue,
            ),
            UniversalStatCard(
              title: 'Ads',
              value: '${_analytics!['totalAds']}',
              subtitle: '${_analytics!['activeAds']} active',
              icon: Icons.campaign,
              color: Colors.orange,
            ),
            UniversalStatCard(
              title: 'Views',
              value: '${_analytics!['totalViews']}',
              subtitle: '${_analytics!['ctr'].toStringAsFixed(1)}% CTR',
              icon: Icons.visibility,
              color: Colors.green,
            ),
            UniversalStatCard(
              title: 'Spent',
              value: '₹${_analytics!['totalSpent'].toStringAsFixed(0)}',
              subtitle: 'Total investment',
              icon: Icons.currency_rupee,
              color: Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnalyticsCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Add Service',
                'Create new service listing',
                Icons.add_business,
                Colors.blue,
                () => Navigator.pushNamed(context, '/vendor_add_service'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                'Create Ad',
                'Promote your business',
                Icons.campaign,
                Colors.orange,
                () => Navigator.pushNamed(context, '/vendor_create_ad'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'My Services',
                'Manage your listings',
                Icons.list_alt,
                Colors.green,
                () => Navigator.pushNamed(context, '/vendor_services'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                'My Ads',
                'Track ad performance',
                Icons.analytics,
                Colors.purple,
                () => Navigator.pushNamed(context, '/vendor_ads'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Shopping Management Row
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'My Products',
                'Manage your products',
                Icons.inventory,
                Colors.teal,
                () => Navigator.pushNamed(context, '/vendor_products'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                'Orders',
                'Manage your orders',
                Icons.receipt_long,
                Colors.orange,
                () => Navigator.pushNamed(context, '/vendor_orders'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Social Media Row
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Social Feed',
                'Connect with community',
                Icons.people_alt,
                Colors.indigo,
                () => Navigator.pushNamed(context, '/social_feed'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentServices() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.appUser?.uid == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Services',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/vendor_services'),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<VendorService>>(
          stream: _vendorService.getVendorServices(authProvider.appUser!.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(Icons.build, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'No services yet',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed:
                          () => Navigator.pushNamed(
                            context,
                            '/vendor_add_service',
                          ),
                      child: const Text('Create Your First Service'),
                    ),
                  ],
                ),
              );
            }

            final services = snapshot.data!.take(3).toList();
            return Column(
              children:
                  services
                      .map((service) => _buildServiceCard(service))
                      .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildServiceCard(VendorService service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child:
                service.imageUrls.isNotEmpty
                    ? Image.network(
                      service.imageUrls.first,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey.shade200,
                            child: Icon(
                              Icons.build,
                              color: Colors.grey.shade400,
                            ),
                          ),
                    )
                    : Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey.shade200,
                      child: Icon(Icons.build, color: Colors.grey.shade400),
                    ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.serviceName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  service.category,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      '${service.rating.toStringAsFixed(1)} (${service.reviewCount})',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color:
                  service.isActive
                      ? Colors.green.shade100
                      : Colors.red.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              service.isActive ? 'Active' : 'Inactive',
              style: TextStyle(
                fontSize: 12,
                color:
                    service.isActive
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAds() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.appUser?.uid == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Ads',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/vendor_ads'),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<VendorAd>>(
          stream: _vendorService.getVendorAds(authProvider.appUser!.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(Icons.campaign, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'No ads yet',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed:
                          () =>
                              Navigator.pushNamed(context, '/vendor_create_ad'),
                      child: const Text('Create Your First Ad'),
                    ),
                  ],
                ),
              );
            }

            final ads = snapshot.data!.take(3).toList();
            return Column(children: ads.map((ad) => _buildAdCard(ad)).toList());
          },
        ),
      ],
    );
  }

  Widget _buildAdCard(VendorAd ad) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              ad.bannerUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) => Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey.shade200,
                    child: Icon(Icons.campaign, color: Colors.grey.shade400),
                  ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ad.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${ad.views} views • ${ad.clicks} clicks',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ends: ${ad.endDate.day}/${ad.endDate.month}/${ad.endDate.year}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(ad.status).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              AdStatus.getDisplayName(ad.status),
              style: TextStyle(
                fontSize: 12,
                color: _getStatusColor(ad.status),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'expired':
        return Colors.grey;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showQuickActionMenu() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.add_business, color: Colors.blue),
                  title: const Text('Add Service'),
                  subtitle: const Text('Create a new service listing'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/vendor_add_service');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.campaign, color: Colors.orange),
                  title: const Text('Create Ad'),
                  subtitle: const Text('Promote your business'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/vendor_create_ad');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.chat, color: Colors.green),
                  title: const Text('Chat'),
                  subtitle: const Text('Message residents and admins'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/vendor_chat');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.people_alt, color: Colors.indigo),
                  title: const Text('Social Feed'),
                  subtitle: const Text('Connect with community'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/social_feed');
                  },
                ),
              ],
            ),
          ),
    );
  }
}
