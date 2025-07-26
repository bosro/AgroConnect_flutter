import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class WishlistProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<ProductModel> _wishlistItems = [];
  List<String> _wishlistProductIds = [];

  List<ProductModel> get wishlistItems => _wishlistItems;
  List<String> get wishlistProductIds => _wishlistProductIds;
  int get itemCount => _wishlistItems.length;

  bool isInWishlist(String productId) {
    return _wishlistProductIds.contains(productId);
  }

  Future<void> loadWishlist(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore
          .collection('wishlists')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        _wishlistProductIds = List<String>.from(data['productIds'] ?? []);
        
        // Load full product details
        if (_wishlistProductIds.isNotEmpty) {
          QuerySnapshot productsSnapshot = await _firestore
              .collection('products')
              .where(FieldPath.documentId, whereIn: _wishlistProductIds)
              .get();
          
          _wishlistItems = productsSnapshot.docs
              .map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>))
              .toList();
        } else {
          _wishlistItems = [];
        }
      }
      notifyListeners();
    } catch (e) {
      print('Error loading wishlist: $e');
    }
  }

  Future<void> toggleWishlist(ProductModel product, String userId) async {
    try {
      if (isInWishlist(product.id)) {
        // Remove from wishlist
        _wishlistProductIds.remove(product.id);
        _wishlistItems.removeWhere((item) => item.id == product.id);
      } else {
        // Add to wishlist
        _wishlistProductIds.add(product.id);
        _wishlistItems.add(product);
      }

      // Update in Firestore
      await _firestore.collection('wishlists').doc(userId).set({
        'productIds': _wishlistProductIds,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      notifyListeners();
    } catch (e) {
      print('Error updating wishlist: $e');
    }
  }

  void clearWishlist() {
    _wishlistItems.clear();
    _wishlistProductIds.clear();
    notifyListeners();
  }
}