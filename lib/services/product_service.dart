import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/product.dart';
import '../models/app_user.dart';
import 'logger_service.dart';
import 'cloudinary_service.dart';

class ProductService {
  static const String _collection = 'products';
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all active products
  static Stream<List<Product>> getProducts({
    String? category,
    String? searchQuery,
    bool? isFeatured,
    String? vendorId,
  }) {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true);

      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      if (isFeatured != null) {
        query = query.where('isFeatured', isEqualTo: isFeatured);
      }

      if (vendorId != null && vendorId.isNotEmpty) {
        query = query.where('vendorId', isEqualTo: vendorId);
      }

      query = query.orderBy('createdAt', descending: true);

      return query.snapshots().map((snapshot) {
        List<Product> products = snapshot.docs
            .map((doc) => Product.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList();

        // Apply search filter if provided
        if (searchQuery != null && searchQuery.isNotEmpty) {
          final lowercaseQuery = searchQuery.toLowerCase();
          products = products.where((product) {
            return product.name.toLowerCase().contains(lowercaseQuery) ||
                   product.description.toLowerCase().contains(lowercaseQuery) ||
                   product.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
          }).toList();
        }

        return products;
      });
    } catch (e) {
      LoggerService.error('Error getting products', 'PRODUCT_SERVICE', e);
      return Stream.value([]);
    }
  }

  // Get product by ID
  static Future<Product?> getProductById(String productId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(productId).get();
      if (doc.exists) {
        return Product.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      LoggerService.error('Error getting product by ID', 'PRODUCT_SERVICE', e);
      return null;
    }
  }

  // Get categories
  static Future<List<String>> getCategories() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .get();

      final categories = <String>{};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (data['category'] != null) {
          categories.add(data['category'] as String);
        }
      }

      return categories.toList()..sort();
    } catch (e) {
      LoggerService.error('Error getting categories', 'PRODUCT_SERVICE', e);
      return [];
    }
  }

  // Add product (vendor only)
  static Future<String> addProduct(Product product, AppUser vendor) async {
    try {
      if (vendor.role != 'vendor') {
        throw Exception('Only vendors can add products');
      }

      final productData = product.toMap();
      productData['vendorId'] = vendor.uid;
      productData['vendorName'] = vendor.name;

      final docRef = await _firestore.collection(_collection).add(productData);
      
      LoggerService.info('Product added successfully: ${docRef.id}', 'PRODUCT_SERVICE');
      return docRef.id;
    } catch (e) {
      LoggerService.error('Error adding product', 'PRODUCT_SERVICE', e);
      throw Exception('Failed to add product: $e');
    }
  }

  // Update product (vendor only)
  static Future<void> updateProduct(String productId, Map<String, dynamic> updates, AppUser vendor) async {
    try {
      // Verify vendor owns the product
      final product = await getProductById(productId);
      if (product == null) {
        throw Exception('Product not found');
      }

      if (product.vendorId != vendor.uid && vendor.role != 'admin') {
        throw Exception('You can only update your own products');
      }

      updates['updatedAt'] = Timestamp.fromDate(DateTime.now());

      await _firestore.collection(_collection).doc(productId).update(updates);
      
      LoggerService.info('Product updated successfully: $productId', 'PRODUCT_SERVICE');
    } catch (e) {
      LoggerService.error('Error updating product', 'PRODUCT_SERVICE', e);
      throw Exception('Failed to update product: $e');
    }
  }

  // Delete product (vendor only)
  static Future<void> deleteProduct(String productId, AppUser vendor) async {
    try {
      // Verify vendor owns the product
      final product = await getProductById(productId);
      if (product == null) {
        throw Exception('Product not found');
      }

      if (product.vendorId != vendor.uid && vendor.role != 'admin') {
        throw Exception('You can only delete your own products');
      }

      // Soft delete by setting isActive to false
      await _firestore.collection(_collection).doc(productId).update({
        'isActive': false,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      
      LoggerService.info('Product deleted successfully: $productId', 'PRODUCT_SERVICE');
    } catch (e) {
      LoggerService.error('Error deleting product', 'PRODUCT_SERVICE', e);
      throw Exception('Failed to delete product: $e');
    }
  }

  // Upload product images
  static Future<List<String>> uploadProductImages(List<XFile> images, String vendorId) async {
    try {
      final List<String> imageUrls = [];

      for (int i = 0; i < images.length; i++) {
        final file = File(images[i].path);

        // Upload to Cloudinary instead of Firebase Storage
        final imageUrl = await CloudinaryService.uploadImage(
          file,
          folder: 'products/$vendorId',
        );

        if (imageUrl != null) {
          imageUrls.add(imageUrl);
        } else {
          throw Exception('Failed to upload image ${i + 1}');
        }
      }

      LoggerService.info('Product images uploaded successfully', 'PRODUCT_SERVICE');
      return imageUrls;
    } catch (e) {
      LoggerService.error('Error uploading product images', 'PRODUCT_SERVICE', e);
      throw Exception('Failed to upload images: $e');
    }
  }

  // Update product stock
  static Future<void> updateStock(String productId, int newStock) async {
    try {
      await _firestore.collection(_collection).doc(productId).update({
        'stock': newStock,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      
      LoggerService.info('Product stock updated: $productId', 'PRODUCT_SERVICE');
    } catch (e) {
      LoggerService.error('Error updating product stock', 'PRODUCT_SERVICE', e);
      throw Exception('Failed to update stock: $e');
    }
  }

  // Update product rating
  static Future<void> updateRating(String productId, double newRating, int reviewCount) async {
    try {
      await _firestore.collection(_collection).doc(productId).update({
        'rating': newRating,
        'reviewCount': reviewCount,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      
      LoggerService.info('Product rating updated: $productId', 'PRODUCT_SERVICE');
    } catch (e) {
      LoggerService.error('Error updating product rating', 'PRODUCT_SERVICE', e);
      throw Exception('Failed to update rating: $e');
    }
  }

  // Toggle featured status (admin only)
  static Future<void> toggleFeatured(String productId, bool isFeatured, AppUser admin) async {
    try {
      if (admin.role != 'admin') {
        throw Exception('Only admins can toggle featured status');
      }

      await _firestore.collection(_collection).doc(productId).update({
        'isFeatured': isFeatured,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      
      LoggerService.info('Product featured status updated: $productId', 'PRODUCT_SERVICE');
    } catch (e) {
      LoggerService.error('Error updating featured status', 'PRODUCT_SERVICE', e);
      throw Exception('Failed to update featured status: $e');
    }
  }
}
