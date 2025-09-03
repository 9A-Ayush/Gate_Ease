import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment.dart';
import '../models/bill.dart';
import '../models/app_user.dart';
import 'logger_service.dart';

class PaymentService {
  static const String _collection = 'payments';
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Record a successful payment
  static Future<String> recordPayment({
    required String billId,
    required String residentId,
    required String residentName,
    required String flatNo,
    required double amount,
    required String paymentId,
    required String transactionId,
    String method = 'razorpay',
    String status = 'success',
    String? signature,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      LoggerService.info('Recording payment for bill: $billId', 'PAYMENT_SERVICE');

      final payment = Payment(
        id: '', // Will be set by Firestore
        billId: billId,
        residentId: residentId,
        residentName: residentName,
        flatNo: flatNo,
        amount: amount,
        transactionId: transactionId,
        method: method,
        paymentId: paymentId,
        status: status,
        timestamp: DateTime.now(),
        signature: signature,
        metadata: metadata,
      );

      final docRef = await _firestore.collection(_collection).add(payment.toMap());
      
      LoggerService.info('Payment recorded successfully with ID: ${docRef.id}', 'PAYMENT_SERVICE');
      return docRef.id;
    } catch (e) {
      LoggerService.error('Error recording payment', 'PAYMENT_SERVICE', e);
      throw Exception('Failed to record payment: $e');
    }
  }

  /// Get payments for a specific resident
  static Future<List<Payment>> getPaymentsForResident(String residentId) async {
    try {
      LoggerService.info('Fetching payments for resident: $residentId', 'PAYMENT_SERVICE');

      final querySnapshot = await _firestore
          .collection(_collection)
          .where('resident_id', isEqualTo: residentId)
          .get();

      final payments = querySnapshot.docs
          .map((doc) => Payment.fromFirestore(doc))
          .toList();

      // Sort by timestamp (newest first)
      payments.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      LoggerService.info('Fetched ${payments.length} payments for resident', 'PAYMENT_SERVICE');
      return payments;
    } catch (e) {
      LoggerService.error('Error fetching payments for resident', 'PAYMENT_SERVICE', e);
      throw Exception('Failed to fetch payments: $e');
    }
  }

  /// Get payments for a specific flat
  static Future<List<Payment>> getPaymentsForFlat(String flatNo) async {
    try {
      LoggerService.info('Fetching payments for flat: $flatNo', 'PAYMENT_SERVICE');

      final querySnapshot = await _firestore
          .collection(_collection)
          .where('flat_no', isEqualTo: flatNo)
          .get();

      final payments = querySnapshot.docs
          .map((doc) => Payment.fromFirestore(doc))
          .toList();

      // Sort by timestamp (newest first)
      payments.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      LoggerService.info('Fetched ${payments.length} payments for flat', 'PAYMENT_SERVICE');
      return payments;
    } catch (e) {
      LoggerService.error('Error fetching payments for flat', 'PAYMENT_SERVICE', e);
      throw Exception('Failed to fetch payments: $e');
    }
  }

  /// Get all payments (for admin)
  static Future<List<Payment>> getAllPayments() async {
    try {
      LoggerService.info('Fetching all payments', 'PAYMENT_SERVICE');

      final querySnapshot = await _firestore
          .collection(_collection)
          .get();

      final payments = querySnapshot.docs
          .map((doc) => Payment.fromFirestore(doc))
          .toList();

      // Sort by timestamp (newest first)
      payments.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      LoggerService.info('Fetched ${payments.length} total payments', 'PAYMENT_SERVICE');
      return payments;
    } catch (e) {
      LoggerService.error('Error fetching all payments', 'PAYMENT_SERVICE', e);
      throw Exception('Failed to fetch payments: $e');
    }
  }

  /// Get payment by ID
  static Future<Payment?> getPaymentById(String paymentId) async {
    try {
      LoggerService.info('Fetching payment by ID: $paymentId', 'PAYMENT_SERVICE');

      final doc = await _firestore.collection(_collection).doc(paymentId).get();
      
      if (doc.exists) {
        final payment = Payment.fromFirestore(doc);
        LoggerService.info('Payment found', 'PAYMENT_SERVICE');
        return payment;
      } else {
        LoggerService.info('Payment not found', 'PAYMENT_SERVICE');
        return null;
      }
    } catch (e) {
      LoggerService.error('Error fetching payment by ID', 'PAYMENT_SERVICE', e);
      throw Exception('Failed to fetch payment: $e');
    }
  }

  /// Update payment status
  static Future<void> updatePaymentStatus(String paymentId, String status) async {
    try {
      LoggerService.info('Updating payment status: $paymentId to $status', 'PAYMENT_SERVICE');

      await _firestore.collection(_collection).doc(paymentId).update({
        'status': status,
      });

      LoggerService.info('Payment status updated successfully', 'PAYMENT_SERVICE');
    } catch (e) {
      LoggerService.error('Error updating payment status', 'PAYMENT_SERVICE', e);
      throw Exception('Failed to update payment status: $e');
    }
  }

  /// Get payment statistics
  static Future<Map<String, dynamic>> getPaymentStatistics() async {
    try {
      LoggerService.info('Fetching payment statistics', 'PAYMENT_SERVICE');

      final querySnapshot = await _firestore.collection(_collection).get();
      final payments = querySnapshot.docs.map((doc) => Payment.fromFirestore(doc)).toList();

      double totalAmount = 0;
      int successfulPayments = 0;
      int failedPayments = 0;
      int pendingPayments = 0;

      for (final payment in payments) {
        if (payment.status == 'success') {
          totalAmount += payment.amount;
          successfulPayments++;
        } else if (payment.status == 'failed') {
          failedPayments++;
        } else {
          pendingPayments++;
        }
      }

      final stats = {
        'total_amount': totalAmount,
        'total_payments': payments.length,
        'successful_payments': successfulPayments,
        'failed_payments': failedPayments,
        'pending_payments': pendingPayments,
        'success_rate': payments.isNotEmpty ? (successfulPayments / payments.length * 100) : 0.0,
      };

      LoggerService.info('Payment statistics calculated', 'PAYMENT_SERVICE');
      return stats;
    } catch (e) {
      LoggerService.error('Error fetching payment statistics', 'PAYMENT_SERVICE', e);
      throw Exception('Failed to fetch payment statistics: $e');
    }
  }

  /// Stream payments for real-time updates
  static Stream<List<Payment>> getPaymentsStream({String? residentId, String? flatNo}) {
    try {
      Query query = _firestore.collection(_collection);
      
      if (residentId != null) {
        query = query.where('resident_id', isEqualTo: residentId);
      } else if (flatNo != null) {
        query = query.where('flat_no', isEqualTo: flatNo);
      }

      return query.snapshots().map((snapshot) {
        final payments = snapshot.docs
            .map((doc) => Payment.fromFirestore(doc))
            .toList();
        
        // Sort by timestamp (newest first)
        payments.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        
        return payments;
      });
    } catch (e) {
      LoggerService.error('Error creating payments stream', 'PAYMENT_SERVICE', e);
      throw Exception('Failed to create payments stream: $e');
    }
  }
}
