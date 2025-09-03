class Vendor {
  final String id;
  final String name;
  final String serviceType;
  final String contact;
  final double rating;
  final String? bannerUrl;

  Vendor({
    required this.id,
    required this.name,
    required this.serviceType,
    required this.contact,
    required this.rating,
    this.bannerUrl,
  });

  factory Vendor.fromMap(Map<String, dynamic> map, String id) => Vendor(
    id: id,
    name: map['name'] ?? '',
    serviceType: map['service_type'] ?? '',
    contact: map['contact'] ?? '',
    rating: (map['rating'] ?? 0).toDouble(),
    bannerUrl: map['banner_url'],
  );

  Map<String, dynamic> toMap() => {
    'name': name,
    'service_type': serviceType,
    'contact': contact,
    'rating': rating,
    'banner_url': bannerUrl,
  };
}
