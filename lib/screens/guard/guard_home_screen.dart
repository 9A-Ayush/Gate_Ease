import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_provider.dart';
import '../../widgets/communication_fab.dart';
import '../../widgets/universal_card.dart';
import '../../constants/app_strings.dart';
import '../../services/error_handler_service.dart';
import '../../services/notification_service.dart';
import 'package:provider/provider.dart';

class GuardHomeScreen extends StatelessWidget {
  const GuardHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.appUser;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      floatingActionButton: const CommunicationFAB(),
      appBar: AppBar(
        title: const Text('GateEase Guard'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () => _showLanguageSelector(context),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/profile_edit'),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey.shade300,
                backgroundImage:
                    authProvider.appUser?.profileImageUrl != null
                        ? NetworkImage(authProvider.appUser!.profileImageUrl!)
                        : null,
                child:
                    authProvider.appUser?.profileImageUrl == null
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
        padding: const EdgeInsets.all(16.0),
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
                    'Welcome, ${user?.name ?? 'Guard'}!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Gate Security • ${DateTime.now().hour < 12
                        ? 'Morning'
                        : DateTime.now().hour < 17
                        ? 'Afternoon'
                        : 'Evening'} Shift',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quick Stats
            Row(
              children: [
                Expanded(
                  child: UniversalStatCard(
                    title: 'Today\'s Visitors',
                    value: '0',
                    icon: Icons.people_outline,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: UniversalStatCard(
                    title: 'Pre-approved',
                    value: '0',
                    icon: Icons.check_circle_outline,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Emergency SOS Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                children: [
                  Icon(Icons.emergency, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  const Text(
                    'Emergency SOS',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap to send emergency alert to admin and residents',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _sendSOSAlert(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'SEND SOS ALERT',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Main Features
            const Text(
              'Guard Services',
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
                  icon: Icons.person_add,
                  title: 'Log\nVisitor',
                  subtitle: 'Manual visitor\nentry',
                  color: Colors.blue,
                  isCompact: true,
                  onTap:
                      () => Navigator.pushNamed(context, '/guard_visitor_log'),
                ),
                UniversalCard(
                  icon: Icons.list_alt,
                  title: 'Pre-approved\nVisitors',
                  subtitle: 'View approved\nvisitors',
                  color: Colors.green,
                  isCompact: true,
                  onTap:
                      () => Navigator.pushNamed(
                        context,
                        '/guard_preapproved_visitors',
                      ),
                ),
                UniversalCard(
                  icon: Icons.people_alt,
                  title: 'All\nVisitors',
                  subtitle: 'View approval\nstatus',
                  color: Colors.purple,
                  isCompact: true,
                  onTap:
                      () => Navigator.pushNamed(context, '/guard_all_visitors'),
                ),
                UniversalCard(
                  icon: Icons.chat_bubble_outline,
                  title: 'Communication\nHub',
                  subtitle: 'Chat with\nadmin',
                  color: Colors.teal,
                  isCompact: true,
                  onTap: () => Navigator.pushNamed(context, '/guard_chat'),
                ),
                UniversalCard(
                  icon: Icons.people_alt,
                  title: 'Social\nFeed',
                  subtitle: 'Connect with\ncommunity',
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

  void _sendSOSAlert(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.warning, color: Colors.red),
                SizedBox(width: 8),
                Text('Emergency SOS'),
              ],
            ),
            content: const Text(
              'Are you sure you want to send an emergency alert? This will notify all admins and residents immediately.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _sendEmergencyAlert(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('SEND ALERT'),
              ),
            ],
          ),
    );
  }

  void _showLanguageSelector(BuildContext context) {
    final languages = [
      {'name': 'English', 'code': 'en', 'flag': '🇺🇸'},
      {'name': 'हिंदी', 'code': 'hi', 'flag': '🇮🇳'},
      {'name': 'मराठी', 'code': 'mr', 'flag': '🇮🇳'},
      {'name': 'ગુજરાતી', 'code': 'gu', 'flag': '🇮🇳'},
      {'name': 'தமிழ்', 'code': 'ta', 'flag': '🇮🇳'},
      {'name': 'తెలుగు', 'code': 'te', 'flag': '🇮🇳'},
    ];

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Select Language'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: languages.length,
                itemBuilder: (context, index) {
                  final language = languages[index];
                  return ListTile(
                    leading: Text(
                      language['flag']!,
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(language['name']!),
                    onTap: () {
                      Navigator.pop(context);
                      ErrorHandlerService.showInfoSnackBar(
                        context,
                        'Language changed to ${language['name']}. Full localization coming soon!',
                      );
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  Future<void> _sendEmergencyAlert(BuildContext context) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final guardName = authProvider.appUser?.name ?? 'Security Guard';

      // Create emergency alert in Firestore
      final alertDoc = await FirebaseFirestore.instance.collection('emergency_alerts').add({
        'type': 'SOS',
        'message': 'Emergency SOS alert from gate security',
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'active',
        'location': 'Main Gate',
        'guardId': authProvider.firebaseUser?.uid,
        'guardName': guardName,
      });

      // Notify all admins about the emergency alert
      await NotificationService.notifyEmergencyAlert(
        guardName: guardName,
        alertType: 'SOS',
        alertId: alertDoc.id,
        location: 'Main Gate',
      );

      if (context.mounted) {
        ErrorHandlerService.showSuccessSnackBar(
          context,
          AppStrings.emergencyAlertSent,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ErrorHandlerService.handleError(
          context,
          e,
          customMessage: 'Failed to send emergency alert. Please try again.',
        );
      }
    }
  }
}
