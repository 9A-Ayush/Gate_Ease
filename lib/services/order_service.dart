import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order.dart' as app_order;
import '../models/cart.dart';
import '../models/app_user.dart';
import 'logger_service.dart';

class OrderService {
  static const String _collection = 'orders';
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create new order
  static Future<String> createOrder({
    required AppUser user,
    required Cart cart,
    required app_order.DeliveryAddress deliveryAddress,
    required String paymentId,
    required String paymentMethod,
    required double deliveryFee,
    required double discount,
    String? specialInstructions,
  }) async {
    try {
      if (cart.isEmpty) {
        throw Exception('Cart is empty');
      }

      final finalAmount = cart.totalAmount + deliveryFee - discount;
      
      // Convert cart items to order items
      final orderItems = cart.items.map((cartItem) => app_order.OrderItem.fromCartItem(cartItem)).toList();

      final order = app_order.Order(
        id: '',
        userId: user.uid,
        userName: user.name,
        userPhone: user.phone,
        items: orderItems,
        totalAmount: cart.totalAmount,
        deliveryFee: deliveryFee,
        discount: discount,
        finalAmount: finalAmount,
        status: app_order.OrderStatus.placed,
        paymentStatus: app_order.PaymentStatus.completed,
        paymentId: paymentId,
        paymentMethod: paymentMethod,
        deliveryAddress: deliveryAddress,
        createdAt: DateTime.now(),
        statusHistory: {
          'placed': DateTime.now(),
        },
        specialInstructions: specialInstructions,
      );

      // Create order in Firestore
      final docRef = await _firestore.collection(_collection).add(order.toMap());
      
      // Clear user's cart after successful order
      await _firestore.collection('carts').doc(user.uid).delete();

      // Update product stock
      await _updateProductStock(orderItems);

      // Log order confirmation
      LoggerService.info('Order placed notification would be sent to user: ${user.uid}', 'ORDER_SERVICE');

      LoggerService.info('Order created successfully: ${docRef.id}', 'ORDER_SERVICE');
      return docRef.id;
    } catch (e) {
      LoggerService.error('Error creating order', 'ORDER_SERVICE', e);
      throw Exception('Failed to create order: $e');
    }
  }

  // Get order by ID
  static Future<app_order.Order?> getOrderById(String orderId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(orderId).get();
      if (doc.exists) {
        return app_order.Order.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      LoggerService.error('Error getting order by ID', 'ORDER_SERVICE', e);
      return null;
    }
  }

  // Get user orders
  static Stream<List<app_order.Order>> getUserOrders(String userId) {
    try {
      return _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => app_order.Order.fromMap(doc.data() as Map<String, dynamic>, doc.id))
              .toList());
    } catch (e) {
      LoggerService.error('Error getting user orders', 'ORDER_SERVICE', e);
      return Stream.value([]);
    }
  }

  // Get vendor orders
  static Stream<List<app_order.Order>> getVendorOrders(String vendorId) {
    try {
      return _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => app_order.Order.fromMap(doc.data() as Map<String, dynamic>, doc.id))
              .where((order) => order.items.any((item) => item.vendorId == vendorId))
              .toList());
    } catch (e) {
      LoggerService.error('Error getting vendor orders', 'ORDER_SERVICE', e);
      return Stream.value([]);
    }
  }

  // Update order status
  static Future<void> updateOrderStatus(String orderId, app_order.OrderStatus newStatus, {String? reason}) async {
    try {
      final order = await getOrderById(orderId);
      if (order == null) {
        throw Exception('Order not found');
      }

      final updates = <String, dynamic>{
        'status': newStatus.toString().split('.').last,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      // Update status history
      final statusHistory = Map<String, dynamic>.from(order.statusHistory.map(
        (key, value) => MapEntry(key, Timestamp.fromDate(value)),
      ));
      statusHistory[newStatus.toString().split('.').last] = Timestamp.fromDate(DateTime.now());
      updates['statusHistory'] = statusHistory;

      // Handle specific status updates
      if (newStatus == app_order.OrderStatus.delivered) {
        updates['deliveredAt'] = Timestamp.fromDate(DateTime.now());
      } else if (newStatus == app_order.OrderStatus.cancelled) {
        updates['cancellationReason'] = reason ?? 'Order cancelled';
        // Restore product stock
        await _restoreProductStock(order.items);
      }

      await _firestore.collection(_collection).doc(orderId).update(updates);

      // Log status update notification
      LoggerService.info('Order status updated to ${newStatus.toString()} for order: $orderId', 'ORDER_SERVICE');

      LoggerService.info('Order status updated: $orderId -> $newStatus', 'ORDER_SERVICE');
    } catch (e) {
      LoggerService.error('Error updating order status', 'ORDER_SERVICE', e);
      throw Exception('Failed to update order status: $e');
    }
  }

  // Cancel order
  static Future<void> cancelOrder(String orderId, String reason) async {
    try {
      final order = await getOrderById(orderId);
      if (order == null) {
        throw Exception('Order not found');
      }

      if (!order.canBeCancelled) {
        throw Exception('Order cannot be cancelled at this stage');
      }

      await updateOrderStatus(orderId, app_order.OrderStatus.cancelled, reason: reason);
      
      LoggerService.info('Order cancelled: $orderId', 'ORDER_SERVICE');
    } catch (e) {
      LoggerService.error('Error cancelling order', 'ORDER_SERVICE', e);
      throw Exception('Failed to cancel order: $e');
    }
  }

  // Update product stock after order
  static Future<void> _updateProductStock(List<app_order.OrderItem> items) async {
    try {
      final batch = _firestore.batch();

      for (final item in items) {
        final productRef = _firestore.collection('products').doc(item.productId);
        final productDoc = await productRef.get();
        
        if (productDoc.exists) {
          final currentStock = productDoc.data()?['stock'] ?? 0;
          final newStock = currentStock - item.quantity;
          
          batch.update(productRef, {
            'stock': newStock >= 0 ? newStock : 0,
            'updatedAt': Timestamp.fromDate(DateTime.now()),
          });
        }
      }

      await batch.commit();
      LoggerService.info('Product stock updated after order', 'ORDER_SERVICE');
    } catch (e) {
      LoggerService.error('Error updating product stock', 'ORDER_SERVICE', e);
    }
  }

  // Restore product stock after cancellation
  static Future<void> _restoreProductStock(List<app_order.OrderItem> items) async {
    try {
      final batch = _firestore.batch();

      for (final item in items) {
        final productRef = _firestore.collection('products').doc(item.productId);
        final productDoc = await productRef.get();
        
        if (productDoc.exists) {
          final currentStock = productDoc.data()?['stock'] ?? 0;
          final newStock = currentStock + item.quantity;
          
          batch.update(productRef, {
            'stock': newStock,
            'updatedAt': Timestamp.fromDate(DateTime.now()),
          });
        }
      }

      await batch.commit();
      LoggerService.info('Product stock restored after cancellation', 'ORDER_SERVICE');
    } catch (e) {
      LoggerService.error('Error restoring product stock', 'ORDER_SERVICE', e);
    }
  }

  // Get status message for notifications
  static String _getStatusMessage(app_order.OrderStatus status) {
    switch (status) {
      case app_order.OrderStatus.placed:
        return 'Your order has been placed successfully!';
      case app_order.OrderStatus.confirmed:
        return 'Your order has been confirmed and is being prepared.';
      case app_order.OrderStatus.packed:
        return 'Your order has been packed and ready for delivery.';
      case app_order.OrderStatus.outForDelivery:
        return 'Your order is out for delivery!';
      case app_order.OrderStatus.delivered:
        return 'Your order has been delivered successfully!';
      case app_order.OrderStatus.cancelled:
        return 'Your order has been cancelled.';
      case app_order.OrderStatus.returned:
        return 'Your order has been returned.';
    }
  }
}