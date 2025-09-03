import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/admin_notification.dart';

class NotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a notification for admins
  static Future<void> createAdminNotification({
    required String title,
    required String message,
    required String type,
    String? relatedId,
    Map<String, dynamic>? metadata,
    String priority = 'medium',
  }) async {
    try {
      final notification = AdminNotification(
        id: '',
        title: title,
        message: message,
        type: type,
        relatedId: relatedId,
        metadata: metadata,
        createdAt: DateTime.now(),
        priority: priority,
      );

      await _firestore
          .collection('admin_notifications')
          .add(notification.toMap());
    } catch (e) {
      print('Error creating admin notification: $e');
      rethrow;
    }
  }

  // Notify admins about new vendor service
  static Future<void> notifyNewVendorService({
    required String vendorName,
    required String serviceName,
    required String serviceId,
  }) async {
    await createAdminNotification(
      title: 'New Vendor Service',
      message: '$vendorName has created a new service: $serviceName',
      type: 'vendor_service',
      relatedId: serviceId,
      metadata: {
        'vendorName': vendorName,
        'serviceName': serviceName,
        'action': 'created',
      },
      priority: 'medium',
    );
  }

  // Notify admins about new vendor ad
  static Future<void> notifyNewVendorAd({
    required String vendorName,
    required String adTitle,
    required String adId,
    required String duration,
    required double amount,
  }) async {
    await createAdminNotification(
      title: 'New Ad Campaign Pending Approval',
      message: '$vendorName has submitted an ad campaign "$adTitle" for $duration (₹${amount.toStringAsFixed(0)})',
      type: 'vendor_ad',
      relatedId: adId,
      metadata: {
        'vendorName': vendorName,
        'adTitle': adTitle,
        'duration': duration,
        'amount': amount,
        'action': 'pending_approval',
      },
      priority: 'high',
    );
  }

  // Notify admins about vendor service update
  static Future<void> notifyVendorServiceUpdate({
    required String vendorName,
    required String serviceName,
    required String serviceId,
  }) async {
    await createAdminNotification(
      title: 'Vendor Service Updated',
      message: '$vendorName has updated their service: $serviceName',
      type: 'vendor_service',
      relatedId: serviceId,
      metadata: {
        'vendorName': vendorName,
        'serviceName': serviceName,
        'action': 'updated',
      },
      priority: 'low',
    );
  }

  // Notify admins about new complaint
  static Future<void> notifyNewComplaint({
    required String residentName,
    required String complaintTitle,
    required String complaintId,
    required String category,
  }) async {
    await createAdminNotification(
      title: 'New Complaint Submitted',
      message: '$residentName has submitted a complaint: $complaintTitle',
      type: 'complaint',
      relatedId: complaintId,
      metadata: {
        'residentName': residentName,
        'complaintTitle': complaintTitle,
        'category': category,
        'action': 'submitted',
      },
      priority: 'high',
    );
  }

  // Notify admins about new visitor request
  static Future<void> notifyNewVisitorRequest({
    required String residentName,
    required String visitorName,
    required String visitorId,
    required String flatNo,
  }) async {
    await createAdminNotification(
      title: 'New Visitor Request',
      message: '$residentName (Flat $flatNo) has requested approval for visitor: $visitorName',
      type: 'visitor',
      relatedId: visitorId,
      metadata: {
        'residentName': residentName,
        'visitorName': visitorName,
        'flatNo': flatNo,
        'action': 'approval_requested',
      },
      priority: 'medium',
    );
  }

  // Notify admins about emergency alert
  static Future<void> notifyEmergencyAlert({
    required String guardName,
    required String alertType,
    required String alertId,
    required String location,
  }) async {
    await createAdminNotification(
      title: 'Emergency Alert',
      message: 'Emergency alert raised by $guardName: $alertType at $location',
      type: 'emergency',
      relatedId: alertId,
      metadata: {
        'guardName': guardName,
        'alertType': alertType,
        'location': location,
        'action': 'raised',
      },
      priority: 'urgent',
    );
  }

  // Get all admin notifications
  static Stream<QuerySnapshot> getAdminNotifications() {
    return _firestore
        .collection('admin_notifications')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Get unread admin notifications count
  static Stream<QuerySnapshot> getUnreadNotificationsCount() {
    return _firestore
        .collection('admin_notifications')
        .where('isRead', isEqualTo: false)
        .snapshots();
  }

  // Mark notification as read
  static Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('admin_notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      print('Error marking notification as read: $e');
      rethrow;
    }
  }

  // Mark all notifications as read
  static Future<void> markAllAsRead() async {
    try {
      final batch = _firestore.batch();
      final notifications = await _firestore
          .collection('admin_notifications')
          .where('isRead', isEqualTo: false)
          .get();

      for (final doc in notifications.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      print('Error marking all notifications as read: $e');
      rethrow;
    }
  }

  // Delete notification
  static Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore
          .collection('admin_notifications')
          .doc(notificationId)
          .delete();
    } catch (e) {
      print('Error deleting notification: $e');
      rethrow;
    }
  }

  // Delete old notifications (older than 30 days)
  static Future<void> cleanupOldNotifications() async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final oldNotifications = await _firestore
          .collection('admin_notifications')
          .where('createdAt', isLessThan: Timestamp.fromDate(thirtyDaysAgo))
          .get();

      final batch = _firestore.batch();
      for (final doc in oldNotifications.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      print('Error cleaning up old notifications: $e');
      rethrow;
    }
  }
}
