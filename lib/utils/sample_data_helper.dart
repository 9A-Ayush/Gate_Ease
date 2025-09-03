import 'package:cloud_firestore/cloud_firestore.dart';

class SampleDataHelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Add sample complaints for testing
  static Future<void> addSampleComplaints() async {
    try {
      final sampleComplaints = [
        {
          'raised_by': 'sample_user_1',
          'raised_by_name': 'John Doe',
          'flat_no': 'A-101',
          'category': 'Plumbing',
          'description': 'Water leakage in the bathroom. The tap is continuously dripping and causing water wastage.',
          'status': 'Open',
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        },
        {
          'raised_by': 'sample_user_2',
          'raised_by_name': 'Jane Smith',
          'flat_no': 'B-205',
          'category': 'Electrical',
          'description': 'Power outage in the living room. Multiple switches are not working properly.',
          'status': 'In Progress',
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        },
        {
          'raised_by': 'sample_user_3',
          'raised_by_name': 'Mike Johnson',
          'flat_no': 'C-302',
          'category': 'Maintenance',
          'description': 'Elevator is making strange noises and sometimes gets stuck between floors.',
          'status': 'Open',
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        },
        {
          'raised_by': 'sample_user_4',
          'raised_by_name': 'Sarah Wilson',
          'flat_no': 'A-104',
          'category': 'Security',
          'description': 'Main gate security camera is not working. Need immediate attention for safety.',
          'status': 'Resolved',
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        },
        {
          'raised_by': 'sample_user_5',
          'raised_by_name': 'David Brown',
          'flat_no': 'B-201',
          'category': 'Noise',
          'description': 'Loud music from neighboring flat during night hours. Disturbing sleep.',
          'status': 'In Progress',
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        },
        {
          'raised_by': 'sample_user_6',
          'raised_by_name': 'Lisa Davis',
          'flat_no': 'C-401',
          'category': 'Parking',
          'description': 'Unauthorized vehicles are parking in my designated parking spot.',
          'status': 'Open',
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        },
        {
          'raised_by': 'sample_user_7',
          'raised_by_name': 'Robert Miller',
          'flat_no': 'A-203',
          'category': 'Cleanliness',
          'description': 'Garbage disposal area is not being cleaned regularly. Bad smell and hygiene issues.',
          'status': 'Resolved',
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        },
        {
          'raised_by': 'sample_user_8',
          'raised_by_name': 'Emily Garcia',
          'flat_no': 'B-301',
          'category': 'Other',
          'description': 'Internet connectivity issues in common areas. WiFi is very slow.',
          'status': 'Open',
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        },
      ];

      // Add each complaint to Firestore
      for (final complaint in sampleComplaints) {
        await _firestore.collection('complaints').add(complaint);
      }

      print('✅ Sample complaints added successfully!');
    } catch (e) {
      print('❌ Error adding sample complaints: $e');
    }
  }

  /// Clear all sample complaints (for testing purposes)
  static Future<void> clearSampleComplaints() async {
    try {
      final querySnapshot = await _firestore
          .collection('complaints')
          .where('raised_by', whereIn: [
            'sample_user_1',
            'sample_user_2',
            'sample_user_3',
            'sample_user_4',
            'sample_user_5',
            'sample_user_6',
            'sample_user_7',
            'sample_user_8',
          ])
          .get();

      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('✅ Sample complaints cleared successfully!');
    } catch (e) {
      print('❌ Error clearing sample complaints: $e');
    }
  }
}
