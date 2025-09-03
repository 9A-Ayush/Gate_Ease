import 'package:cloud_firestore/cloud_firestore.dart';

class Bill {
  final String id;
  final String title;
  final String description;
  final double amount;
  final String residentId;
  final String residentName;
  final String residentEmail;
  final String flatNumber;
  final String billType; // 'maintenance', 'utility', 'penalty', 'other'
  final DateTime dueDate;
  final DateTime createdAt;
  final String status; // 'pending', 'paid', 'overdue'
  final DateTime? paidAt;
  final String? paymentId;
  final String? paymentMethod;
  final String createdBy; // Admin ID who created the bill
  final String? notes;

  Bill({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.residentId,
    required this.residentName,
    required this.residentEmail,
    required this.flatNumber,
    required this.billType,
    required this.dueDate,
    required this.createdAt,
    required this.status,
    this.paidAt,
    this.paymentId,
    this.paymentMethod,
    required this.createdBy,
    this.notes,
  });

  // Getter for backward compatibility
  String get type => billType;

  // Create Bill from Firestore document
  factory Bill.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Bill(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      residentId: data['residentId'] ?? '',
      residentName: data['residentName'] ?? '',
      residentEmail: data['residentEmail'] ?? '',
      flatNumber: data['flatNumber'] ?? '',
      billType: data['billType'] ?? 'other',
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      status: data['status'] ?? 'pending',
      paidAt: data['paidAt'] != null ? (data['paidAt'] as Timestamp).toDate() : null,
      paymentId: data['paymentId'],
      paymentMethod: data['paymentMethod'],
      createdBy: data['createdBy'] ?? '',
      notes: data['notes'],
    );
  }

  // Create Bill from Map
  factory Bill.fromMap(Map<String, dynamic> data, String id) {
    return Bill(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      residentId: data['residentId'] ?? '',
      residentName: data['residentName'] ?? '',
      residentEmail: data['residentEmail'] ?? '',
      flatNumber: data['flatNumber'] ?? '',
      billType: data['billType'] ?? 'other',
      dueDate: data['dueDate'] is Timestamp 
          ? (data['dueDate'] as Timestamp).toDate()
          : DateTime.parse(data['dueDate']),
      createdAt: data['createdAt'] is Timestamp 
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.parse(data['createdAt']),
      status: data['status'] ?? 'pending',
      paidAt: data['paidAt'] != null 
          ? (data['paidAt'] is Timestamp 
              ? (data['paidAt'] as Timestamp).toDate()
              : DateTime.parse(data['paidAt']))
          : null,
      paymentId: data['paymentId'],
      paymentMethod: data['paymentMethod'],
      createdBy: data['createdBy'] ?? '',
      notes: data['notes'],
    );
  }

  // Convert Bill to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'amount': amount,
      'residentId': residentId,
      'residentName': residentName,
      'residentEmail': residentEmail,
      'flatNumber': flatNumber,
      'billType': billType,
      'dueDate': Timestamp.fromDate(dueDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
      'paidAt': paidAt != null ? Timestamp.fromDate(paidAt!) : null,
      'paymentId': paymentId,
      'paymentMethod': paymentMethod,
      'createdBy': createdBy,
      'notes': notes,
    };
  }

  // Copy with method for updating bill
  Bill copyWith({
    String? id,
    String? title,
    String? description,
    double? amount,
    String? residentId,
    String? residentName,
    String? residentEmail,
    String? flatNumber,
    String? billType,
    DateTime? dueDate,
    DateTime? createdAt,
    String? status,
    DateTime? paidAt,
    String? paymentId,
    String? paymentMethod,
    String? createdBy,
    String? notes,
  }) {
    return Bill(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      residentId: residentId ?? this.residentId,
      residentName: residentName ?? this.residentName,
      residentEmail: residentEmail ?? this.residentEmail,
      flatNumber: flatNumber ?? this.flatNumber,
      billType: billType ?? this.billType,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      paidAt: paidAt ?? this.paidAt,
      paymentId: paymentId ?? this.paymentId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdBy: createdBy ?? this.createdBy,
      notes: notes ?? this.notes,
    );
  }

  // Helper methods
  bool get isPaid => status == 'paid';
  bool get isPending => status == 'pending';
  bool get isOverdue => status == 'overdue' || (isPending && DateTime.now().isAfter(dueDate));
  
  String get formattedAmount => '₹${amount.toStringAsFixed(2)}';
  
  String get billTypeDisplayName {
    switch (billType) {
      case 'maintenance':
        return 'Maintenance';
      case 'utility':
        return 'Utility';
      case 'penalty':
        return 'Penalty';
      case 'other':
        return 'Other';
      default:
        return 'Other';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case 'paid':
        return 'Paid';
      case 'pending':
        return 'Pending';
      case 'overdue':
        return 'Overdue';
      default:
        return 'Unknown';
    }
  }

  @override
  String toString() {
    return 'Bill(id: $id, title: $title, amount: $amount, status: $status, dueDate: $dueDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Bill && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
