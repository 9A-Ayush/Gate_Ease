import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/admin_notification.dart';
import '../../services/notification_service.dart';

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() =>
      _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  String selectedFilter = 'all';
  final List<String> filters = [
    'all',
    'unread',
    'vendor_service',
    'vendor_ad',
    'complaint',
    'visitor',
    'emergency',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) => setState(() => selectedFilter = value),
            itemBuilder:
                (context) =>
                    filters.map((filter) {
                      return PopupMenuItem(
                        value: filter,
                        child: Row(
                          children: [
                            Icon(
                              selectedFilter == filter
                                  ? Icons.check
                                  : Icons.circle_outlined,
                              size: 20,
                              color:
                                  selectedFilter == filter
                                      ? Colors.green
                                      : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(_getFilterDisplayName(filter)),
                          ],
                        ),
                      );
                    }).toList(),
          ),
          IconButton(
            icon: const Icon(Icons.mark_email_read),
            onPressed: _markAllAsRead,
            tooltip: 'Mark all as read',
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Card
          _buildStatsCard(),

          // Notifications List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getNotificationsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, size: 64, color: Colors.red.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading notifications',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No notifications found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You\'ll see notifications here when vendors create services or ads',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                final notifications =
                    snapshot.data!.docs
                        .map(
                          (doc) => AdminNotification.fromMap(
                            doc.data() as Map<String, dynamic>,
                            doc.id,
                          ),
                        )
                        .toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return _buildNotificationCard(notification);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.all(16),
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
      child: StreamBuilder<QuerySnapshot>(
        stream: NotificationService.getUnreadNotificationsCount(),
        builder: (context, snapshot) {
          final unreadCount = snapshot.hasData ? snapshot.data!.docs.length : 0;

          return Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unread Notifications',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$unreadCount',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.notifications_active,
                  color: const Color(0xFF4CAF50),
                  size: 24,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(AdminNotification notification) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: notification.isRead ? 1 : 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _handleNotificationTap(notification),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border:
                notification.isRead
                    ? null
                    : Border.all(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                      width: 1,
                    ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _getNotificationIcon(notification.type),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                notification.isRead
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(notification.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _getPriorityBadge(notification.priority),
                  if (!notification.isRead) ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Text(
                notification.message,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
              if (notification.relatedId != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _navigateToRelated(notification),
                        icon: const Icon(Icons.open_in_new, size: 16),
                        label: Text(
                          _getActionText(notification.type),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF4CAF50),
                          side: const BorderSide(color: Color(0xFF4CAF50)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () => _deleteNotification(notification.id),
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.red.shade400,
                      tooltip: 'Delete',
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _getNotificationIcon(String type) {
    IconData iconData;
    Color color;

    switch (type) {
      case 'vendor_service':
        iconData = Icons.build;
        color = Colors.blue;
        break;
      case 'vendor_ad':
        iconData = Icons.campaign;
        color = Colors.orange;
        break;
      case 'complaint':
        iconData = Icons.report_problem;
        color = Colors.red;
        break;
      case 'visitor':
        iconData = Icons.people;
        color = Colors.purple;
        break;
      case 'emergency':
        iconData = Icons.emergency;
        color = Colors.red.shade700;
        break;
      default:
        iconData = Icons.notifications;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(iconData, color: color, size: 20),
    );
  }

  Widget _getPriorityBadge(String priority) {
    Color color;
    String text;

    switch (priority) {
      case 'urgent':
        color = Colors.red;
        text = 'URGENT';
        break;
      case 'high':
        color = Colors.orange;
        text = 'HIGH';
        break;
      case 'medium':
        color = Colors.blue;
        text = 'MED';
        break;
      case 'low':
        color = Colors.green;
        text = 'LOW';
        break;
      default:
        color = Colors.grey;
        text = 'MED';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Stream<QuerySnapshot> _getNotificationsStream() {
    Query query = FirebaseFirestore.instance
        .collection('admin_notifications')
        .orderBy('createdAt', descending: true);

    switch (selectedFilter) {
      case 'unread':
        query = query.where('isRead', isEqualTo: false);
        break;
      case 'vendor_service':
      case 'vendor_ad':
      case 'complaint':
      case 'visitor':
      case 'emergency':
        query = query.where('type', isEqualTo: selectedFilter);
        break;
    }

    return query.snapshots();
  }

  String _getFilterDisplayName(String filter) {
    switch (filter) {
      case 'all':
        return 'All Notifications';
      case 'unread':
        return 'Unread Only';
      case 'vendor_service':
        return 'Vendor Services';
      case 'vendor_ad':
        return 'Vendor Ads';
      case 'complaint':
        return 'Complaints';
      case 'visitor':
        return 'Visitors';
      case 'emergency':
        return 'Emergency';
      default:
        return filter;
    }
  }

  String _getActionText(String type) {
    switch (type) {
      case 'vendor_service':
        return 'View Service';
      case 'vendor_ad':
        return 'Review Ad';
      case 'complaint':
        return 'View Complaint';
      case 'visitor':
        return 'View Visitor';
      case 'emergency':
        return 'View Alert';
      default:
        return 'View Details';
    }
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Future<void> _handleNotificationTap(AdminNotification notification) async {
    if (!notification.isRead) {
      await NotificationService.markAsRead(notification.id);
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await NotificationService.markAllAsRead();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All notifications marked as read'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark notifications as read: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteNotification(String notificationId) async {
    try {
      await NotificationService.deleteNotification(notificationId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification deleted'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete notification: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToRelated(AdminNotification notification) {
    switch (notification.type) {
      case 'vendor_ad':
        Navigator.pushNamed(context, '/admin_vendors');
        break;
      case 'vendor_service':
        Navigator.pushNamed(context, '/admin_vendors');
        break;
      case 'complaint':
        Navigator.pushNamed(context, '/admin_complaints');
        break;
      case 'visitor':
        Navigator.pushNamed(context, '/admin_visitor_management');
        break;
      default:
        // Handle other types or show a message
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Feature coming soon!')));
    }
  }
}
