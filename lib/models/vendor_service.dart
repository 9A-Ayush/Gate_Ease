import 'package:cloud_firestore/cloud_firestore.dart';

class VendorService {
  final String id;
  final String vendorId;
  final String vendorName;
  final String serviceName;
  final String description;
  final String category;
  final String contactPhone;
  final String contactEmail;
  final double price;
  final String priceType; // 'fixed', 'hourly', 'negotiable'
  final List<String> imageUrls;
  final bool isActive;
  final double rating;
  final int reviewCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? additionalInfo;

  VendorService({
    required this.id,
    required this.vendorId,
    required this.vendorName,
    required this.serviceName,
    required this.description,
    required this.category,
    required this.contactPhone,
    required this.contactEmail,
    required this.price,
    required this.priceType,
    required this.imageUrls,
    required this.isActive,
    required this.rating,
    required this.reviewCount,
    required this.createdAt,
    required this.updatedAt,
    this.additionalInfo,
  });

  factory VendorService.fromMap(Map<String, dynamic> map, String id) {
    return VendorService(
      id: id,
      vendorId: map['vendorId'] ?? '',
      vendorName: map['vendorName'] ?? '',
      serviceName: map['serviceName'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      contactPhone: map['contactPhone'] ?? '',
      contactEmail: map['contactEmail'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      priceType: map['priceType'] ?? 'fixed',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      isActive: map['isActive'] ?? true,
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      additionalInfo: map['additionalInfo'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vendorId': vendorId,
      'vendorName': vendorName,
      'serviceName': serviceName,
      'description': description,
      'category': category,
      'contactPhone': contactPhone,
      'contactEmail': contactEmail,
      'price': price,
      'priceType': priceType,
      'imageUrls': imageUrls,
      'isActive': isActive,
      'rating': rating,
      'reviewCount': reviewCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'additionalInfo': additionalInfo,
    };
  }

  VendorService copyWith({
    String? id,
    String? vendorId,
    String? vendorName,
    String? serviceName,
    String? description,
    String? category,
    String? contactPhone,
    String? contactEmail,
    double? price,
    String? priceType,
    List<String>? imageUrls,
    bool? isActive,
    double? rating,
    int? reviewCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? additionalInfo,
  }) {
    return VendorService(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      vendorName: vendorName ?? this.vendorName,
      serviceName: serviceName ?? this.serviceName,
      description: description ?? this.description,
      category: category ?? this.category,
      contactPhone: contactPhone ?? this.contactPhone,
      contactEmail: contactEmail ?? this.contactEmail,
      price: price ?? this.price,
      priceType: priceType ?? this.priceType,
      imageUrls: imageUrls ?? this.imageUrls,
      isActive: isActive ?? this.isActive,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }
}

// Service categories enum
class ServiceCategory {
  static const String plumbing = 'Plumbing';
  static const String electrical = 'Electrical';
  static const String cleaning = 'Cleaning';
  static const String gardening = 'Gardening';
  static const String painting = 'Painting';
  static const String carpentry = 'Carpentry';
  static const String appliance = 'Appliance Repair';
  static const String pest = 'Pest Control';
  static const String security = 'Security';
  static const String delivery = 'Delivery';
  static const String catering = 'Catering';
  static const String tutoring = 'Tutoring';
  static const String fitness = 'Fitness';
  static const String beauty = 'Beauty & Wellness';
  static const String other = 'Other';

  static List<String> get allCategories => [
    plumbing,
    electrical,
    cleaning,
    gardening,
    painting,
    carpentry,
    appliance,
    pest,
    security,
    delivery,
    catering,
    tutoring,
    fitness,
    beauty,
    other,
  ];
}

// Price types enum
class PriceType {
  static const String fixed = 'fixed';
  static const String hourly = 'hourly';
  static const String negotiable = 'negotiable';

  static List<String> get allTypes => [fixed, hourly, negotiable];
  
  static String getDisplayName(String type) {
    switch (type) {
      case fixed:
        return 'Fixed Price';
      case hourly:
        return 'Per Hour';
      case negotiable:
        return 'Negotiable';
      default:
        return 'Fixed Price';
    }
  }
}
