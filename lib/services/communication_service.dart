import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';
import 'logger_service.dart';

class CommunicationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get available users to chat with based on current user role
  static Future<List<AppUser>> getAvailableContacts(
    String currentUserRole,
  ) async {
    try {
      List<String> allowedRoles = [];

      switch (currentUserRole) {
        case 'admin':
          // Admin can chat with vendors, residents, guards
          allowedRoles = ['vendor', 'resident', 'guard'];
          break;
        case 'resident':
          // Residents can chat with vendors, admin, guards
          allowedRoles = ['vendor', 'admin', 'guard'];
          break;
        case 'guard':
          // Guards can chat with residents, admins
          allowedRoles = ['resident', 'admin'];
          break;
        case 'vendor':
          // Vendors can chat with admin, residents (who interact with their ads/campaigns)
          allowedRoles = ['admin', 'resident'];
          break;
        default:
          return [];
      }

      final querySnapshot =
          await _firestore
              .collection('users')
              .where('role', whereIn: allowedRoles)
              .where('status', isEqualTo: 'approved')
              .get();

      return querySnapshot.docs
          .map((doc) => AppUser.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      LoggerService.error(
        'Error getting available contacts',
        'COMMUNICATION',
        e,
      );
      return [];
    }
  }

  // Get or create chat room between two users
  static Future<String> getOrCreateChatRoom(
    String userId1,
    String userId2,
  ) async {
    try {
      LoggerService.communication(
        'Creating chat room between $userId1 and $userId2',
      );

      // Create consistent chat room ID
      final List<String> userIds = [userId1, userId2]..sort();
      final chatRoomId = '${userIds[0]}_${userIds[1]}';

      LoggerService.communication('Chat room ID: $chatRoomId');

      // Check if chat room exists
      final chatRoomDoc =
          await _firestore.collection('chat_rooms').doc(chatRoomId).get();

      if (!chatRoomDoc.exists) {
        LoggerService.communication('Creating new chat room...');
        // Create new chat room
        await _firestore.collection('chat_rooms').doc(chatRoomId).set({
          'participants': userIds,
          'createdAt': FieldValue.serverTimestamp(),
          'lastMessage': '',
          'lastMessageTime': FieldValue.serverTimestamp(),
          'lastMessageSender': '',
        });
        LoggerService.communication('Chat room created successfully');
      } else {
        LoggerService.communication('Chat room already exists');
      }

      return chatRoomId;
    } catch (e) {
      LoggerService.error('Error creating chat room', 'COMMUNICATION', e);
      throw Exception('Failed to create chat room: $e');
    }
  }

  // Send message
  static Future<void> sendMessage({
    required String chatRoomId,
    required String message,
    required String senderName,
    required String receiverId,
  }) async {
    try {
      LoggerService.communication(
        'Sending message: "$message" to chat room: $chatRoomId',
      );

      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('No user logged in');

      LoggerService.communication('Current user: ${currentUser.uid}');

      // Add message to messages subcollection
      await _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .add({
            'senderId': currentUser.uid,
            'senderName': senderName,
            'receiverId': receiverId,
            'message': message,
            'timestamp': FieldValue.serverTimestamp(),
            'isRead': false,
          });

      LoggerService.communication('Message added to subcollection');

      // Update chat room with last message info
      await _firestore.collection('chat_rooms').doc(chatRoomId).update({
        'lastMessage': message,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageSender': senderName,
      });

      LoggerService.communication('Chat room updated with last message');
    } catch (e) {
      LoggerService.error('Error sending message', 'COMMUNICATION', e);
      throw Exception('Failed to send message: $e');
    }
  }

  // Get messages stream
  static Stream<QuerySnapshot> getMessages(String chatRoomId) {
    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Get user's chat rooms
  static Stream<QuerySnapshot> getUserChatRooms(String userId) {
    return _firestore
        .collection('chat_rooms')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }

  // Mark messages as read
  static Future<void> markMessagesAsRead(
    String chatRoomId,
    String userId,
  ) async {
    try {
      final unreadMessages =
          await _firestore
              .collection('chat_rooms')
              .doc(chatRoomId)
              .collection('messages')
              .where('receiverId', isEqualTo: userId)
              .where('isRead', isEqualTo: false)
              .get();

      final batch = _firestore.batch();
      for (final doc in unreadMessages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      LoggerService.error('Error marking messages as read', 'COMMUNICATION', e);
    }
  }

  // Get unread message count for user
  static Stream<int> getUnreadMessageCount(String userId) {
    return _firestore
        .collectionGroup('messages')
        .where('receiverId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Get user info by ID
  static Future<AppUser?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return AppUser.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      LoggerService.error('Error getting user by ID', 'COMMUNICATION', e);
      return null;
    }
  }

  // Get vendors that a resident has interacted with (through ads/campaigns)
  static Future<List<AppUser>> getInteractedVendors(String residentId) async {
    try {
      // Get all vendor ads that are currently approved and active
      final vendorAdsSnapshot =
          await _firestore
              .collection('vendor_ads')
              .where('status', isEqualTo: 'approved')
              .get();

      final Set<String> vendorIds = {};
      for (final doc in vendorAdsSnapshot.docs) {
        final vendorId = doc.data()['vendorId'] as String?;
        if (vendorId != null) {
          vendorIds.add(vendorId);
        }
      }

      // Get vendor services that are active
      final vendorServicesSnapshot =
          await _firestore
              .collection('vendor_services')
              .where('isActive', isEqualTo: true)
              .get();

      for (final doc in vendorServicesSnapshot.docs) {
        final vendorId = doc.data()['vendorId'] as String?;
        if (vendorId != null) {
          vendorIds.add(vendorId);
        }
      }

      // Get vendor user details
      final List<AppUser> vendors = [];
      for (final vendorId in vendorIds) {
        final vendorDoc =
            await _firestore.collection('users').doc(vendorId).get();
        if (vendorDoc.exists) {
          final vendorData = vendorDoc.data()!;
          if (vendorData['role'] == 'vendor' &&
              vendorData['status'] == 'approved') {
            vendors.add(AppUser.fromMap(vendorData, vendorDoc.id));
          }
        }
      }

      return vendors;
    } catch (e) {
      LoggerService.error(
        'Error getting interacted vendors',
        'COMMUNICATION',
        e,
      );
      return [];
    }
  }

  // Get residents who have interacted with vendor's ads/campaigns
  static Future<List<AppUser>> getInteractedResidents(String vendorId) async {
    try {
      // For now, return all approved residents since we don't track specific interactions
      // In a real app, you'd track ad views, service inquiries, etc.
      final querySnapshot =
          await _firestore
              .collection('users')
              .where('role', isEqualTo: 'resident')
              .where('status', isEqualTo: 'approved')
              .get();

      return querySnapshot.docs
          .map((doc) => AppUser.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      LoggerService.error(
        'Error getting interacted residents',
        'COMMUNICATION',
        e,
      );
      return [];
    }
  }

  // Get role-specific contact groups
  static Future<Map<String, List<AppUser>>> getContactGroups(
    String currentUserRole, [
    String? userId,
  ]) async {
    try {
      List<AppUser> contacts;

      if (currentUserRole == 'resident' && userId != null) {
        // For residents, get regular contacts plus interacted vendors
        final regularContacts = await getAvailableContacts(currentUserRole);
        final interactedVendors = await getInteractedVendors(userId);

        // Combine and deduplicate
        final allContacts = <String, AppUser>{};
        for (final contact in regularContacts) {
          allContacts[contact.uid] = contact;
        }
        for (final vendor in interactedVendors) {
          allContacts[vendor.uid] = vendor;
        }
        contacts = allContacts.values.toList();
      } else if (currentUserRole == 'vendor' && userId != null) {
        // For vendors, get regular contacts plus interacted residents
        final regularContacts = await getAvailableContacts(currentUserRole);
        final interactedResidents = await getInteractedResidents(userId);

        // Combine and deduplicate
        final allContacts = <String, AppUser>{};
        for (final contact in regularContacts) {
          allContacts[contact.uid] = contact;
        }
        for (final resident in interactedResidents) {
          allContacts[resident.uid] = resident;
        }
        contacts = allContacts.values.toList();
      } else {
        contacts = await getAvailableContacts(currentUserRole);
      }

      final Map<String, List<AppUser>> groups = {};

      for (final contact in contacts) {
        final role = contact.role;
        if (!groups.containsKey(role)) {
          groups[role] = [];
        }
        groups[role]!.add(contact);
      }

      return groups;
    } catch (e) {
      LoggerService.error('Error getting contact groups', 'COMMUNICATION', e);
      return {};
    }
  }

  // Get role display name
  static String getRoleDisplayName(String role) {
    switch (role) {
      case 'admin':
        return 'Administrators';
      case 'resident':
        return 'Residents';
      case 'guard':
        return 'Security Guards';
      case 'vendor':
        return 'Vendors';
      default:
        return role;
    }
  }

  // Get role icon
  static String getRoleIcon(String role) {
    switch (role) {
      case 'admin':
        return '👨‍💼';
      case 'resident':
        return '🏠';
      case 'guard':
        return '🛡️';
      case 'vendor':
        return '🏪';
      default:
        return '👤';
    }
  }

  // Create emergency broadcast (admin only)
  static Future<void> sendEmergencyBroadcast({
    required String message,
    required String senderName,
    required List<String> targetRoles,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('No user logged in');

      // Get all users with target roles
      final querySnapshot =
          await _firestore
              .collection('users')
              .where('role', whereIn: targetRoles)
              .where('status', isEqualTo: 'approved')
              .get();

      final batch = _firestore.batch();

      // Create emergency broadcast document
      final broadcastRef = _firestore.collection('emergency_broadcasts').doc();
      batch.set(broadcastRef, {
        'senderId': currentUser.uid,
        'senderName': senderName,
        'message': message,
        'targetRoles': targetRoles,
        'timestamp': FieldValue.serverTimestamp(),
        'recipients': querySnapshot.docs.map((doc) => doc.id).toList(),
      });

      // Send individual messages to each user
      for (final userDoc in querySnapshot.docs) {
        final chatRoomId = await getOrCreateChatRoom(
          currentUser.uid,
          userDoc.id,
        );

        final messageRef =
            _firestore
                .collection('chat_rooms')
                .doc(chatRoomId)
                .collection('messages')
                .doc();

        batch.set(messageRef, {
          'senderId': currentUser.uid,
          'senderName': senderName,
          'receiverId': userDoc.id,
          'message': '🚨 EMERGENCY BROADCAST: $message',
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
          'isEmergency': true,
        });

        // Update chat room
        final chatRoomRef = _firestore.collection('chat_rooms').doc(chatRoomId);
        batch.update(chatRoomRef, {
          'lastMessage': '🚨 EMERGENCY BROADCAST: $message',
          'lastMessageTime': FieldValue.serverTimestamp(),
          'lastMessageSender': senderName,
        });
      }

      await batch.commit();
    } catch (e) {
      LoggerService.error(
        'Error sending emergency broadcast',
        'COMMUNICATION',
        e,
      );
      throw Exception('Failed to send emergency broadcast');
    }
  }
}
