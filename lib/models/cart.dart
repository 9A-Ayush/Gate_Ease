import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;
  final String vendorId;
  final String vendorName;
  final int maxStock;

  CartItem({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    required this.vendorId,
    required this.vendorName,
    required this.maxStock,
  });

  // Getters for computed properties
  double get totalPrice => price * quantity;
  String get formattedPrice => '₹${price.toStringAsFixed(2)}';
  String get formattedTotalPrice => '₹${totalPrice.toStringAsFixed(2)}';
  bool get canIncreaseQuantity => quantity < maxStock;
  bool get canDecreaseQuantity => quantity > 1;

  // Create from map
  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      productImage: map['productImage'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 1,
      vendorId: map['vendorId'] ?? '',
      vendorName: map['vendorName'] ?? '',
      maxStock: map['maxStock'] ?? 0,
    );
  }

  // Convert to map
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'quantity': quantity,
      'vendorId': vendorId,
      'vendorName': vendorName,
      'maxStock': maxStock,
    };
  }

  // Copy with method
  CartItem copyWith({
    String? productId,
    String? productName,
    String? productImage,
    double? price,
    int? quantity,
    String? vendorId,
    String? vendorName,
    int? maxStock,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      vendorId: vendorId ?? this.vendorId,
      vendorName: vendorName ?? this.vendorName,
      maxStock: maxStock ?? this.maxStock,
    );
  }

  @override
  String toString() {
    return 'CartItem(productId: $productId, quantity: $quantity, price: $price)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem && other.productId == productId;
  }

  @override
  int get hashCode => productId.hashCode;
}

class Cart {
  final String userId;
  final List<CartItem> items;
  final DateTime updatedAt;

  Cart({
    required this.userId,
    required this.items,
    required this.updatedAt,
  });

  // Getters for computed properties
  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
  double get totalAmount => items.fold(0.0, (sum, item) => sum + item.totalPrice);
  String get formattedTotalAmount => '₹${totalAmount.toStringAsFixed(2)}';

  // Get unique vendors in cart
  List<String> get vendorIds => items.map((item) => item.vendorId).toSet().toList();
  
  // Get items by vendor
  List<CartItem> getItemsByVendor(String vendorId) {
    return items.where((item) => item.vendorId == vendorId).toList();
  }

  // Create from Firestore document
  factory Cart.fromMap(Map<String, dynamic> map, String userId) {
    return Cart(
      userId: userId,
      items: (map['items'] as List<dynamic>?)
          ?.map((item) => CartItem.fromMap(item as Map<String, dynamic>))
          .toList() ?? [],
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Copy with method
  Cart copyWith({
    String? userId,
    List<CartItem>? items,
    DateTime? updatedAt,
  }) {
    return Cart(
      userId: userId ?? this.userId,
      items: items ?? this.items,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Cart(userId: $userId, items: ${items.length}, total: $formattedTotalAmount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Cart && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;
}
