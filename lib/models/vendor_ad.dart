import 'package:cloud_firestore/cloud_firestore.dart';

class VendorAd {
  final String id;
  final String vendorId;
  final String vendorName;
  final String title;
  final String description;
  final String bannerUrl;
  final String status; // 'pending', 'active', 'expired', 'rejected'
  final int duration; // in days (1, 7, 30)
  final double amount; // payment amount
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final int views;
  final int clicks;
  final String? rejectionReason;
  final Map<String, dynamic>? additionalInfo;

  VendorAd({
    required this.id,
    required this.vendorId,
    required this.vendorName,
    required this.title,
    required this.description,
    required this.bannerUrl,
    required this.status,
    required this.duration,
    required this.amount,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.views,
    required this.clicks,
    this.rejectionReason,
    this.additionalInfo,
  });

  factory VendorAd.fromMap(Map<String, dynamic> map, String id) {
    return VendorAd(
      id: id,
      vendorId: map['vendorId'] ?? '',
      vendorName: map['vendorName'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      bannerUrl: map['bannerUrl'] ?? '',
      status: map['status'] ?? 'pending',
      duration: map['duration'] ?? 1,
      amount: (map['amount'] ?? 0.0).toDouble(),
      startDate: (map['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (map['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      views: map['views'] ?? 0,
      clicks: map['clicks'] ?? 0,
      rejectionReason: map['rejectionReason'],
      additionalInfo: map['additionalInfo'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vendorId': vendorId,
      'vendorName': vendorName,
      'title': title,
      'description': description,
      'bannerUrl': bannerUrl,
      'status': status,
      'duration': duration,
      'amount': amount,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'views': views,
      'clicks': clicks,
      'rejectionReason': rejectionReason,
      'additionalInfo': additionalInfo,
    };
  }

  VendorAd copyWith({
    String? id,
    String? vendorId,
    String? vendorName,
    String? title,
    String? description,
    String? bannerUrl,
    String? status,
    int? duration,
    double? amount,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    int? views,
    int? clicks,
    String? rejectionReason,
    Map<String, dynamic>? additionalInfo,
  }) {
    return VendorAd(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      vendorName: vendorName ?? this.vendorName,
      title: title ?? this.title,
      description: description ?? this.description,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      status: status ?? this.status,
      duration: duration ?? this.duration,
      amount: amount ?? this.amount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      views: views ?? this.views,
      clicks: clicks ?? this.clicks,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }

  bool get isActive => status == 'active' && DateTime.now().isBefore(endDate);
  bool get isExpired => DateTime.now().isAfter(endDate);
  bool get isPending => status == 'pending';
  bool get isRejected => status == 'rejected';

  double get ctr => views > 0 ? (clicks / views) * 100 : 0.0; // Click-through rate
}

// Ad status enum
class AdStatus {
  static const String pending = 'pending';
  static const String active = 'active';
  static const String expired = 'expired';
  static const String rejected = 'rejected';

  static List<String> get allStatuses => [pending, active, expired, rejected];
  
  static String getDisplayName(String status) {
    switch (status) {
      case pending:
        return 'Pending Approval';
      case active:
        return 'Active';
      case expired:
        return 'Expired';
      case rejected:
        return 'Rejected';
      default:
        return 'Unknown';
    }
  }
}

// Ad duration and pricing
class AdDuration {
  static const int oneDay = 1;
  static const int oneWeek = 7;
  static const int oneMonth = 30;

  static List<int> get allDurations => [oneDay, oneWeek, oneMonth];
  
  static String getDisplayName(int duration) {
    switch (duration) {
      case oneDay:
        return '1 Day';
      case oneWeek:
        return '1 Week';
      case oneMonth:
        return '1 Month';
      default:
        return '$duration Days';
    }
  }

  static double getPrice(int duration) {
    switch (duration) {
      case oneDay:
        return 50.0; // ₹50 for 1 day
      case oneWeek:
        return 300.0; // ₹300 for 1 week
      case oneMonth:
        return 1000.0; // ₹1000 for 1 month
      default:
        return 50.0 * duration; // ₹50 per day for custom durations
    }
  }
}
