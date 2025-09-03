import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart.dart';
import '../models/product.dart';
import '../models/app_user.dart';
import 'logger_service.dart';

class CartService {
  static const String _collection = 'carts';
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get user's cart
  static Stream<Cart> getUserCart(String userId) {
    try {
      return _firestore
          .collection(_collection)
          .doc(userId)
          .snapshots()
          .map((doc) {
        if (doc.exists) {
          return Cart.fromMap(doc.data() as Map<String, dynamic>, userId);
        } else {
          return Cart(
            userId: userId,
            items: [],
            updatedAt: DateTime.now(),
          );
        }
      });
    } catch (e) {
      LoggerService.error('Error getting user cart', 'CART_SERVICE', e);
      return Stream.value(Cart(
        userId: userId,
        items: [],
        updatedAt: DateTime.now(),
      ));
    }
  }

  // Add item to cart
  static Future<void> addToCart(String userId, Product product, int quantity) async {
    try {
      if (quantity <= 0) {
        throw Exception('Quantity must be greater than 0');
      }

      if (quantity > product.stock) {
        throw Exception('Not enough stock available');
      }

      final cartRef = _firestore.collection(_collection).doc(userId);
      
      await _firestore.runTransaction((transaction) async {
        final cartDoc = await transaction.get(cartRef);
        
        Cart cart;
        if (cartDoc.exists) {
          cart = Cart.fromMap(cartDoc.data() as Map<String, dynamic>, userId);
        } else {
          cart = Cart(
            userId: userId,
            items: [],
            updatedAt: DateTime.now(),
          );
        }

        // Check if item already exists in cart
        final existingItemIndex = cart.items.indexWhere(
          (item) => item.productId == product.id,
        );

        List<CartItem> updatedItems = List.from(cart.items);

        if (existingItemIndex != -1) {
          // Update existing item quantity
          final existingItem = updatedItems[existingItemIndex];
          final newQuantity = existingItem.quantity + quantity;
          
          if (newQuantity > product.stock) {
            throw Exception('Total quantity exceeds available stock');
          }

          updatedItems[existingItemIndex] = existingItem.copyWith(
            quantity: newQuantity,
            maxStock: product.stock,
          );
        } else {
          // Add new item
          final cartItem = CartItem(
            productId: product.id,
            productName: product.name,
            productImage: product.imageUrls.isNotEmpty ? product.imageUrls.first : '',
            price: product.price,
            quantity: quantity,
            vendorId: product.vendorId,
            vendorName: product.vendorName,
            maxStock: product.stock,
          );
          updatedItems.add(cartItem);
        }

        final updatedCart = cart.copyWith(
          items: updatedItems,
          updatedAt: DateTime.now(),
        );

        transaction.set(cartRef, updatedCart.toMap());
      });

      LoggerService.info('Item added to cart successfully', 'CART_SERVICE');
    } catch (e) {
      LoggerService.error('Error adding item to cart', 'CART_SERVICE', e);
      throw Exception('Failed to add item to cart: $e');
    }
  }

  // Update item quantity in cart
  static Future<void> updateItemQuantity(String userId, String productId, int quantity) async {
    try {
      if (quantity <= 0) {
        await removeFromCart(userId, productId);
        return;
      }

      final cartRef = _firestore.collection(_collection).doc(userId);
      
      await _firestore.runTransaction((transaction) async {
        final cartDoc = await transaction.get(cartRef);
        
        if (!cartDoc.exists) {
          throw Exception('Cart not found');
        }

        final cart = Cart.fromMap(cartDoc.data() as Map<String, dynamic>, userId);
        
        final itemIndex = cart.items.indexWhere(
          (item) => item.productId == productId,
        );

        if (itemIndex == -1) {
          throw Exception('Item not found in cart');
        }

        final item = cart.items[itemIndex];
        
        if (quantity > item.maxStock) {
          throw Exception('Quantity exceeds available stock');
        }

        List<CartItem> updatedItems = List.from(cart.items);
        updatedItems[itemIndex] = item.copyWith(quantity: quantity);

        final updatedCart = cart.copyWith(
          items: updatedItems,
          updatedAt: DateTime.now(),
        );

        transaction.set(cartRef, updatedCart.toMap());
      });

      LoggerService.info('Cart item quantity updated successfully', 'CART_SERVICE');
    } catch (e) {
      LoggerService.error('Error updating cart item quantity', 'CART_SERVICE', e);
      throw Exception('Failed to update item quantity: $e');
    }
  }

  // Remove item from cart
  static Future<void> removeFromCart(String userId, String productId) async {
    try {
      final cartRef = _firestore.collection(_collection).doc(userId);
      
      await _firestore.runTransaction((transaction) async {
        final cartDoc = await transaction.get(cartRef);
        
        if (!cartDoc.exists) {
          throw Exception('Cart not found');
        }

        final cart = Cart.fromMap(cartDoc.data() as Map<String, dynamic>, userId);
        
        final updatedItems = cart.items.where(
          (item) => item.productId != productId,
        ).toList();

        final updatedCart = cart.copyWith(
          items: updatedItems,
          updatedAt: DateTime.now(),
        );

        transaction.set(cartRef, updatedCart.toMap());
      });

      LoggerService.info('Item removed from cart successfully', 'CART_SERVICE');
    } catch (e) {
      LoggerService.error('Error removing item from cart', 'CART_SERVICE', e);
      throw Exception('Failed to remove item from cart: $e');
    }
  }

  // Clear entire cart
  static Future<void> clearCart(String userId) async {
    try {
      final cartRef = _firestore.collection(_collection).doc(userId);
      
      final emptyCart = Cart(
        userId: userId,
        items: [],
        updatedAt: DateTime.now(),
      );

      await cartRef.set(emptyCart.toMap());

      LoggerService.info('Cart cleared successfully', 'CART_SERVICE');
    } catch (e) {
      LoggerService.error('Error clearing cart', 'CART_SERVICE', e);
      throw Exception('Failed to clear cart: $e');
    }
  }

  // Get cart item count
  static Future<int> getCartItemCount(String userId) async {
    try {
      final cartDoc = await _firestore.collection(_collection).doc(userId).get();
      
      if (cartDoc.exists) {
        final cart = Cart.fromMap(cartDoc.data() as Map<String, dynamic>, userId);
        return cart.totalItems;
      }
      
      return 0;
    } catch (e) {
      LoggerService.error('Error getting cart item count', 'CART_SERVICE', e);
      return 0;
    }
  }

  // Validate cart items (check stock availability)
  static Future<Map<String, dynamic>> validateCart(String userId) async {
    try {
      final cartDoc = await _firestore.collection(_collection).doc(userId).get();
      
      if (!cartDoc.exists) {
        return {
          'isValid': true,
          'issues': <String>[],
          'updatedCart': null,
        };
      }

      final cart = Cart.fromMap(cartDoc.data() as Map<String, dynamic>, userId);
      final List<String> issues = [];
      final List<CartItem> validItems = [];
      bool hasChanges = false;

      for (final cartItem in cart.items) {
        // Get current product data
        final productDoc = await _firestore
            .collection('products')
            .doc(cartItem.productId)
            .get();

        if (!productDoc.exists) {
          issues.add('${cartItem.productName} is no longer available');
          hasChanges = true;
          continue;
        }

        final productData = productDoc.data() as Map<String, dynamic>;
        final currentStock = productData['stock'] ?? 0;
        final isActive = productData['isActive'] ?? false;

        if (!isActive) {
          issues.add('${cartItem.productName} is no longer available');
          hasChanges = true;
          continue;
        }

        if (currentStock <= 0) {
          issues.add('${cartItem.productName} is out of stock');
          hasChanges = true;
          continue;
        }

        if (cartItem.quantity > currentStock) {
          issues.add('${cartItem.productName} quantity reduced to $currentStock (was ${cartItem.quantity})');
          validItems.add(cartItem.copyWith(
            quantity: currentStock,
            maxStock: currentStock,
          ));
          hasChanges = true;
        } else {
          validItems.add(cartItem.copyWith(maxStock: currentStock));
        }
      }

      Cart? updatedCart;
      if (hasChanges) {
        updatedCart = cart.copyWith(
          items: validItems,
          updatedAt: DateTime.now(),
        );
        
        // Update cart in Firestore
        await _firestore.collection(_collection).doc(userId).set(updatedCart.toMap());
      }

      return {
        'isValid': issues.isEmpty,
        'issues': issues,
        'updatedCart': updatedCart,
      };
    } catch (e) {
      LoggerService.error('Error validating cart', 'CART_SERVICE', e);
      return {
        'isValid': false,
        'issues': ['Failed to validate cart'],
        'updatedCart': null,
      };
    }
  }
}
