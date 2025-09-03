import 'package:cloud_firestore/cloud_firestore.dart';

class Payment {
  final String id;
  final String billId;
  final String residentId;
  final String residentName;
  final String flatNo;
  final double amount;
  final String transactionId;
  final String method;
  final String paymentId; // Razorpay payment ID
  final String status; // 'success', 'failed', 'pending'
  final DateTime timestamp;
  final String? receiptUrl;
  final String? signature;
  final Map<String, dynamic>? metadata;

  Payment({
    required this.id,
    required this.billId,
    required this.residentId,
    required this.residentName,
    required this.flatNo,
    required this.amount,
    required this.transactionId,
    required this.method,
    required this.paymentId,
    required this.status,
    required this.timestamp,
    this.receiptUrl,
    this.signature,
    this.metadata,
  });

  factory Payment.fromMap(Map<String, dynamic> map, String id) => Payment(
    id: id,
    billId: map['bill_id'] ?? map['billId'] ?? '',
    residentId: map['resident_id'] ?? map['residentId'] ?? '',
    residentName: map['resident_name'] ?? map['residentName'] ?? '',
    flatNo: map['flat_no'] ?? map['flatNo'] ?? '',
    amount: (map['amount'] ?? 0).toDouble(),
    transactionId: map['transaction_id'] ?? map['transactionId'] ?? '',
    method: map['method'] ?? 'razorpay',
    paymentId: map['payment_id'] ?? map['paymentId'] ?? '',
    status: map['status'] ?? 'pending',
    timestamp: (map['timestamp'] as Timestamp).toDate(),
    receiptUrl: map['receipt_url'] ?? map['receiptUrl'],
    signature: map['signature'],
    metadata: map['metadata'] as Map<String, dynamic>?,
  );

  factory Payment.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Payment.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() => {
    'bill_id': billId,
    'resident_id': residentId,
    'resident_name': residentName,
    'flat_no': flatNo,
    'amount': amount,
    'transaction_id': transactionId,
    'method': method,
    'payment_id': paymentId,
    'status': status,
    'timestamp': Timestamp.fromDate(timestamp),
    'receipt_url': receiptUrl,
    'signature': signature,
    'metadata': metadata,
  };
}