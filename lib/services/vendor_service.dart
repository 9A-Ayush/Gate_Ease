import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/vendor_service.dart';
import '../models/vendor_ad.dart';
import 'cloudinary_service.dart';

class VendorBusinessService {
  static final VendorBusinessService _instance = VendorBusinessService._internal();
  factory VendorBusinessService() => _instance;
  VendorBusinessService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Service Management
  Future<String> createService(VendorService service, List<File> images) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    try {
      // Upload images to Cloudinary
      List<String> imageUrls = [];
      for (File image in images) {
        final url = await CloudinaryService.uploadImage(
          image,
          folder: 'vendor_services',
        );
        if (url != null) imageUrls.add(url);
      }

      // Create service document
      final serviceData = service.copyWith(
        vendorId: user.uid,
        imageUrls: imageUrls,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final docRef = await _db.collection('vendor_services').add(serviceData.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create service: $e');
    }
  }

  Future<void> updateService(String serviceId, VendorService service, List<File>? newImages) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    try {
      List<String> imageUrls = service.imageUrls;

      // Upload new images if provided
      if (newImages != null && newImages.isNotEmpty) {
        for (File image in newImages) {
          final url = await CloudinaryService.uploadImage(
            image,
            folder: 'vendor_services',
          );
          if (url != null) imageUrls.add(url);
        }
      }

      final updatedService = service.copyWith(
        imageUrls: imageUrls,
        updatedAt: DateTime.now(),
      );

      await _db.collection('vendor_services').doc(serviceId).update(updatedService.toMap());
    } catch (e) {
      throw Exception('Failed to update service: $e');
    }
  }

  Future<void> deleteService(String serviceId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    try {
      await _db.collection('vendor_services').doc(serviceId).delete();
    } catch (e) {
      throw Exception('Failed to delete service: $e');
    }
  }

  Stream<List<VendorService>> getVendorServices(String vendorId) {
    return _db
        .collection('vendor_services')
        .where('vendorId', isEqualTo: vendorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => VendorService.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<VendorService>> getAllActiveServices() {
    return _db
        .collection('vendor_services')
        .where('isActive', isEqualTo: true)
        .orderBy('rating', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => VendorService.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Ad Management
  Future<String> createAd(VendorAd ad, File bannerImage) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    try {
      // Upload banner to Cloudinary
      final bannerUrl = await CloudinaryService.uploadImage(
        bannerImage,
        folder: 'vendor_ads',
      );

      if (bannerUrl == null) throw Exception('Failed to upload banner image');

      // Create ad document
      final adData = ad.copyWith(
        vendorId: user.uid,
        bannerUrl: bannerUrl,
        createdAt: DateTime.now(),
        status: 'pending', // Ads need admin approval
      );

      final docRef = await _db.collection('vendor_ads').add(adData.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create ad: $e');
    }
  }

  Future<void> updateAd(String adId, VendorAd ad, File? newBanner) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    try {
      String bannerUrl = ad.bannerUrl;

      // Upload new banner if provided
      if (newBanner != null) {
        final url = await CloudinaryService.uploadImage(
          newBanner,
          folder: 'vendor_ads',
        );
        if (url != null) bannerUrl = url;
      }

      final updatedAd = ad.copyWith(bannerUrl: bannerUrl);
      await _db.collection('vendor_ads').doc(adId).update(updatedAd.toMap());
    } catch (e) {
      throw Exception('Failed to update ad: $e');
    }
  }

  Future<void> deleteAd(String adId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    try {
      await _db.collection('vendor_ads').doc(adId).delete();
    } catch (e) {
      throw Exception('Failed to delete ad: $e');
    }
  }

  Stream<List<VendorAd>> getVendorAds(String vendorId) {
    return _db
        .collection('vendor_ads')
        .where('vendorId', isEqualTo: vendorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => VendorAd.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<VendorAd>> getActiveAds() {
    return _db
        .collection('vendor_ads')
        .where('status', isEqualTo: 'active')
        .where('endDate', isGreaterThan: Timestamp.now())
        .orderBy('endDate')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => VendorAd.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Analytics
  Future<Map<String, dynamic>> getVendorAnalytics(String vendorId) async {
    try {
      // Get services count
      final servicesSnapshot = await _db
          .collection('vendor_services')
          .where('vendorId', isEqualTo: vendorId)
          .get();

      // Get ads count and stats
      final adsSnapshot = await _db
          .collection('vendor_ads')
          .where('vendorId', isEqualTo: vendorId)
          .get();

      int totalViews = 0;
      int totalClicks = 0;
      double totalSpent = 0;

      for (var doc in adsSnapshot.docs) {
        final ad = VendorAd.fromMap(doc.data(), doc.id);
        totalViews += ad.views;
        totalClicks += ad.clicks;
        if (ad.status == 'active' || ad.status == 'expired') {
          totalSpent += ad.amount;
        }
      }

      return {
        'totalServices': servicesSnapshot.docs.length,
        'activeServices': servicesSnapshot.docs.where((doc) => doc.data()['isActive'] == true).length,
        'totalAds': adsSnapshot.docs.length,
        'activeAds': adsSnapshot.docs.where((doc) => VendorAd.fromMap(doc.data(), doc.id).isActive).length,
        'totalViews': totalViews,
        'totalClicks': totalClicks,
        'totalSpent': totalSpent,
        'ctr': totalViews > 0 ? (totalClicks / totalViews) * 100 : 0.0,
      };
    } catch (e) {
      throw Exception('Failed to get analytics: $e');
    }
  }

  // Utility methods
  Future<void> incrementAdViews(String adId) async {
    try {
      await _db.collection('vendor_ads').doc(adId).update({
        'views': FieldValue.increment(1),
      });
    } catch (e) {
      // Silently fail for analytics
    }
  }

  Future<void> incrementAdClicks(String adId) async {
    try {
      await _db.collection('vendor_ads').doc(adId).update({
        'clicks': FieldValue.increment(1),
      });
    } catch (e) {
      // Silently fail for analytics
    }
  }
}
