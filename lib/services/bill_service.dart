import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bill.dart';
import '../models/app_user.dart';
import 'logger_service.dart';

class BillService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'bills';

  // Create a new bill
  static Future<String> createBill({
    required String title,
    required String description,
    required double amount,
    required String residentId,
    required String residentName,
    required String residentEmail,
    required String flatNumber,
    required String billType,
    required DateTime dueDate,
    required String createdBy,
    String? notes,
  }) async {
    try {
      LoggerService.info('Creating bill for resident: $residentId', 'BILL_SERVICE');

      final bill = Bill(
        id: '', // Will be set by Firestore
        title: title,
        description: description,
        amount: amount,
        residentId: residentId,
        residentName: residentName,
        residentEmail: residentEmail,
        flatNumber: flatNumber,
        billType: billType,
        dueDate: dueDate,
        createdAt: DateTime.now(),
        status: 'pending',
        createdBy: createdBy,
        notes: notes,
      );

      final docRef = await _firestore.collection(_collection).add(bill.toMap());
      
      LoggerService.info('Bill created successfully with ID: ${docRef.id}', 'BILL_SERVICE');
      return docRef.id;
    } catch (e) {
      LoggerService.error('Error creating bill', 'BILL_SERVICE', e);
      throw Exception('Failed to create bill: $e');
    }
  }

  // Get all bills (for admin)
  static Future<List<Bill>> getAllBills() async {
    try {
      LoggerService.info('Fetching all bills', 'BILL_SERVICE');

      final querySnapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();

      final bills = querySnapshot.docs
          .map((doc) => Bill.fromFirestore(doc))
          .toList();

      LoggerService.info('Fetched ${bills.length} bills', 'BILL_SERVICE');
      return bills;
    } catch (e) {
      LoggerService.error('Error fetching all bills', 'BILL_SERVICE', e);
      throw Exception('Failed to fetch bills: $e');
    }
  }

  // Get bills for a specific resident
  static Future<List<Bill>> getBillsForResident(String residentId) async {
    try {
      LoggerService.info('Fetching bills for resident: $residentId', 'BILL_SERVICE');

      // Use simple query without orderBy to avoid index requirement
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('residentId', isEqualTo: residentId)
          .get();

      final bills = querySnapshot.docs
          .map((doc) => Bill.fromFirestore(doc))
          .toList();

      // Sort in memory by due date (ascending - earliest first)
      bills.sort((a, b) => a.dueDate.compareTo(b.dueDate));

      LoggerService.info('Fetched ${bills.length} bills for resident', 'BILL_SERVICE');
      return bills;
    } catch (e) {
      LoggerService.error('Error fetching bills for resident', 'BILL_SERVICE', e);
      throw Exception('Failed to fetch bills: $e');
    }
  }

  // Get bills stream for real-time updates
  static Stream<List<Bill>> getBillsStream() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Bill.fromFirestore(doc))
            .toList());
  }

  // Get bills stream for a specific resident
  static Stream<List<Bill>> getBillsStreamForResident(String residentId) {
    return _firestore
        .collection(_collection)
        .where('residentId', isEqualTo: residentId)
        .orderBy('dueDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Bill.fromFirestore(doc))
            .toList());
  }

  // Update bill status (for payments)
  static Future<void> markBillAsPaid({
    required String billId,
    required String paymentId,
    required String paymentMethod,
  }) async {
    try {
      LoggerService.info('Marking bill as paid: $billId', 'BILL_SERVICE');

      await _firestore.collection(_collection).doc(billId).update({
        'status': 'paid',
        'paidAt': FieldValue.serverTimestamp(),
        'paymentId': paymentId,
        'paymentMethod': paymentMethod,
      });

      LoggerService.info('Bill marked as paid successfully', 'BILL_SERVICE');
    } catch (e) {
      LoggerService.error('Error marking bill as paid', 'BILL_SERVICE', e);
      throw Exception('Failed to update bill status: $e');
    }
  }

  // Update bill
  static Future<void> updateBill(String billId, Map<String, dynamic> updates) async {
    try {
      LoggerService.info('Updating bill: $billId', 'BILL_SERVICE');

      await _firestore.collection(_collection).doc(billId).update(updates);

      LoggerService.info('Bill updated successfully', 'BILL_SERVICE');
    } catch (e) {
      LoggerService.error('Error updating bill', 'BILL_SERVICE', e);
      throw Exception('Failed to update bill: $e');
    }
  }

  // Delete bill
  static Future<void> deleteBill(String billId) async {
    try {
      LoggerService.info('Deleting bill: $billId', 'BILL_SERVICE');

      await _firestore.collection(_collection).doc(billId).delete();

      LoggerService.info('Bill deleted successfully', 'BILL_SERVICE');
    } catch (e) {
      LoggerService.error('Error deleting bill', 'BILL_SERVICE', e);
      throw Exception('Failed to delete bill: $e');
    }
  }

  // Get bill by ID
  static Future<Bill?> getBillById(String billId) async {
    try {
      LoggerService.info('Fetching bill by ID: $billId', 'BILL_SERVICE');

      final doc = await _firestore.collection(_collection).doc(billId).get();
      
      if (doc.exists) {
        return Bill.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      LoggerService.error('Error fetching bill by ID', 'BILL_SERVICE', e);
      throw Exception('Failed to fetch bill: $e');
    }
  }

  // Get pending bills count for a resident
  static Future<int> getPendingBillsCount(String residentId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('residentId', isEqualTo: residentId)
          .where('status', isEqualTo: 'pending')
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      LoggerService.error('Error getting pending bills count', 'BILL_SERVICE', e);
      return 0;
    }
  }

  // Get total pending amount for a resident
  static Future<double> getTotalPendingAmount(String residentId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('residentId', isEqualTo: residentId)
          .where('status', isEqualTo: 'pending')
          .get();

      double total = 0;
      for (final doc in querySnapshot.docs) {
        final bill = Bill.fromFirestore(doc);
        total += bill.amount;
      }

      return total;
    } catch (e) {
      LoggerService.error('Error getting total pending amount', 'BILL_SERVICE', e);
      return 0;
    }
  }

  // Update overdue bills (should be called periodically)
  static Future<void> updateOverdueBills() async {
    try {
      LoggerService.info('Updating overdue bills', 'BILL_SERVICE');

      final now = DateTime.now();
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: 'pending')
          .where('dueDate', isLessThan: Timestamp.fromDate(now))
          .get();

      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.update(doc.reference, {'status': 'overdue'});
      }

      await batch.commit();
      LoggerService.info('Updated ${querySnapshot.docs.length} overdue bills', 'BILL_SERVICE');
    } catch (e) {
      LoggerService.error('Error updating overdue bills', 'BILL_SERVICE', e);
    }
  }

  // Get bills statistics for admin dashboard
  static Future<Map<String, dynamic>> getBillsStatistics() async {
    try {
      final allBillsSnapshot = await _firestore.collection(_collection).get();
      final pendingBillsSnapshot = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: 'pending')
          .get();
      final paidBillsSnapshot = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: 'paid')
          .get();
      final overdueBillsSnapshot = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: 'overdue')
          .get();

      double totalAmount = 0;
      double pendingAmount = 0;
      double paidAmount = 0;

      for (final doc in allBillsSnapshot.docs) {
        final bill = Bill.fromFirestore(doc);
        totalAmount += bill.amount;
      }

      for (final doc in pendingBillsSnapshot.docs) {
        final bill = Bill.fromFirestore(doc);
        pendingAmount += bill.amount;
      }

      for (final doc in paidBillsSnapshot.docs) {
        final bill = Bill.fromFirestore(doc);
        paidAmount += bill.amount;
      }

      return {
        'totalBills': allBillsSnapshot.docs.length,
        'pendingBills': pendingBillsSnapshot.docs.length,
        'paidBills': paidBillsSnapshot.docs.length,
        'overdueBills': overdueBillsSnapshot.docs.length,
        'totalAmount': totalAmount,
        'pendingAmount': pendingAmount,
        'paidAmount': paidAmount,
      };
    } catch (e) {
      LoggerService.error('Error getting bills statistics', 'BILL_SERVICE', e);
      return {};
    }
  }
}
