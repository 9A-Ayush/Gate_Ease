import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart.dart';

enum OrderStatus {
  placed,
  confirmed,
  packed,
  outForDelivery,
  delivered,
  cancelled,
  returned,
}

enum PaymentStatus {
  pending,
  completed,
  failed,
  refunded,
}

class DeliveryAddress {
  final String name;
  final String phone;
  final String flatNo;
  final String building;
  final String society;
  final String landmark;
  final String pincode;

  DeliveryAddress({
    required this.name,
    required this.phone,
    required this.flatNo,
    required this.building,
    required this.society,
    required this.landmark,
    required this.pincode,
  });

  String get fullAddress {
    final parts = [
      '$flatNo, $building',
      society,
      if (landmark.isNotEmpty) landmark,
      'Pincode: $pincode',
    ];
    return parts.join(', ');
  }

  factory DeliveryAddress.fromMap(Map<String, dynamic> map) {
    return DeliveryAddress(
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      flatNo: map['flatNo'] ?? '',
      building: map['building'] ?? '',
      society: map['society'] ?? '',
      landmark: map['landmark'] ?? '',
      pincode: map['pincode'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'flatNo': flatNo,
      'building': building,
      'society': society,
      'landmark': landmark,
      'pincode': pincode,
    };
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;
  final String vendorId;
  final String vendorName;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    required this.vendorId,
    required this.vendorName,
  });

  double get totalPrice => price * quantity;
  String get formattedPrice => '₹${price.toStringAsFixed(2)}';
  String get formattedTotalPrice => '₹${totalPrice.toStringAsFixed(2)}';

  factory OrderItem.fromCartItem(CartItem cartItem) {
    return OrderItem(
      productId: cartItem.productId,
      productName: cartItem.productName,
      productImage: cartItem.productImage,
      price: cartItem.price,
      quantity: cartItem.quantity,
      vendorId: cartItem.vendorId,
      vendorName: cartItem.vendorName,
    );
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      productImage: map['productImage'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 1,
      vendorId: map['vendorId'] ?? '',
      vendorName: map['vendorName'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'quantity': quantity,
      'vendorId': vendorId,
      'vendorName': vendorName,
    };
  }
}

class Order {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final List<OrderItem> items;
  final double totalAmount;
  final double deliveryFee;
  final double discount;
  final double finalAmount;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final String paymentId;
  final String paymentMethod;
  final DeliveryAddress deliveryAddress;
  final DateTime createdAt;
  final DateTime? deliveredAt;
  final Map<String, DateTime> statusHistory;
  final String? specialInstructions;
  final String? cancellationReason;

  Order({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.items,
    required this.totalAmount,
    required this.deliveryFee,
    required this.discount,
    required this.finalAmount,
    required this.status,
    required this.paymentStatus,
    required this.paymentId,
    required this.paymentMethod,
    required this.deliveryAddress,
    required this.createdAt,
    this.deliveredAt,
    required this.statusHistory,
    this.specialInstructions,
    this.cancellationReason,
  });

  // Getters for computed properties
  String get formattedTotalAmount => '₹${totalAmount.toStringAsFixed(2)}';
  String get formattedDeliveryFee => '₹${deliveryFee.toStringAsFixed(2)}';
  String get formattedDiscount => '₹${discount.toStringAsFixed(2)}';
  String get formattedFinalAmount => '₹${finalAmount.toStringAsFixed(2)}';
  
  String get statusDisplayName {
    switch (status) {
      case OrderStatus.placed:
        return 'Order Placed';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.packed:
        return 'Packed';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.returned:
        return 'Returned';
    }
  }

  bool get isActive => ![OrderStatus.delivered, OrderStatus.cancelled, OrderStatus.returned].contains(status);
  bool get canBeCancelled => [OrderStatus.placed, OrderStatus.confirmed].contains(status);
  bool get isCompleted => status == OrderStatus.delivered;

  // Get unique vendors in order
  List<String> get vendorIds => items.map((item) => item.vendorId).toSet().toList();

  factory Order.fromMap(Map<String, dynamic> map, String id) {
    return Order(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userPhone: map['userPhone'] ?? '',
      items: (map['items'] as List<dynamic>?)
          ?.map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
          .toList() ?? [],
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      deliveryFee: (map['deliveryFee'] ?? 0).toDouble(),
      discount: (map['discount'] ?? 0).toDouble(),
      finalAmount: (map['finalAmount'] ?? 0).toDouble(),
      status: _parseOrderStatus(map['status']),
      paymentStatus: _parsePaymentStatus(map['paymentStatus']),
      paymentId: map['paymentId'] ?? '',
      paymentMethod: map['paymentMethod'] ?? '',
      deliveryAddress: DeliveryAddress.fromMap(map['deliveryAddress'] ?? {}),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      deliveredAt: (map['deliveredAt'] as Timestamp?)?.toDate(),
      statusHistory: _parseStatusHistory(map['statusHistory']),
      specialInstructions: map['specialInstructions'],
      cancellationReason: map['cancellationReason'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'deliveryFee': deliveryFee,
      'discount': discount,
      'finalAmount': finalAmount,
      'status': status.toString().split('.').last,
      'paymentStatus': paymentStatus.toString().split('.').last,
      'paymentId': paymentId,
      'paymentMethod': paymentMethod,
      'deliveryAddress': deliveryAddress.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
      'deliveredAt': deliveredAt != null ? Timestamp.fromDate(deliveredAt!) : null,
      'statusHistory': statusHistory.map(
        (key, value) => MapEntry(key, Timestamp.fromDate(value)),
      ),
      'specialInstructions': specialInstructions,
      'cancellationReason': cancellationReason,
    };
  }

  Order copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userPhone,
    List<OrderItem>? items,
    double? totalAmount,
    double? deliveryFee,
    double? discount,
    double? finalAmount,
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    String? paymentId,
    String? paymentMethod,
    DeliveryAddress? deliveryAddress,
    DateTime? createdAt,
    DateTime? deliveredAt,
    Map<String, DateTime>? statusHistory,
    String? specialInstructions,
    String? cancellationReason,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      discount: discount ?? this.discount,
      finalAmount: finalAmount ?? this.finalAmount,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentId: paymentId ?? this.paymentId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      createdAt: createdAt ?? this.createdAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      statusHistory: statusHistory ?? this.statusHistory,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }

  static OrderStatus _parseOrderStatus(String? status) {
    switch (status) {
      case 'placed':
        return OrderStatus.placed;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'packed':
        return OrderStatus.packed;
      case 'outForDelivery':
        return OrderStatus.outForDelivery;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'returned':
        return OrderStatus.returned;
      default:
        return OrderStatus.placed;
    }
  }

  static PaymentStatus _parsePaymentStatus(String? status) {
    switch (status) {
      case 'pending':
        return PaymentStatus.pending;
      case 'completed':
        return PaymentStatus.completed;
      case 'failed':
        return PaymentStatus.failed;
      case 'refunded':
        return PaymentStatus.refunded;
      default:
        return PaymentStatus.pending;
    }
  }

  static Map<String, DateTime> _parseStatusHistory(Map<String, dynamic>? history) {
    if (history == null) return {};
    
    return history.map((key, value) {
      if (value is Timestamp) {
        return MapEntry(key, value.toDate());
      }
      return MapEntry(key, DateTime.now());
    });
  }

  @override
  String toString() {
    return 'Order(id: $id, status: $status, total: $formattedFinalAmount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Order && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
