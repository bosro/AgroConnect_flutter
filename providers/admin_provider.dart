// lib/providers/admin_provider.dart
import 'package:agroconnect/models/admin_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';

class AdminProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  AdminModel? _admin;
  bool _isLoading = false;
  String? _errorMessage;
  
  List<ProductModel> _products = [];
  List<OrderModel> _orders = [];
  Map<String, dynamic> _analytics = {};

  // Getters
  AdminModel? get admin => _admin;
  bool get isLoading => _isLoading;
  bool get isAdmin => _admin != null;
  String? get errorMessage => _errorMessage;
  List<ProductModel> get products => _products;
  List<OrderModel> get orders => _orders;
  Map<String, dynamic> get analytics => _analytics;

  // Check if current user is admin
  Future<bool> checkAdminStatus() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      DocumentSnapshot adminDoc = await _firestore
          .collection('admins')
          .doc(currentUser.uid)
          .get();

      if (adminDoc.exists) {
        _admin = AdminModel.fromMap(adminDoc.data() as Map<String, dynamic>);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }

  // Load all products for admin management
  Future<void> loadAllProducts() async {
    try {
      _isLoading = true;
      notifyListeners();

      QuerySnapshot snapshot = await _firestore
          .collection('products')
          .orderBy('createdAt', descending: true)
          .get();

      _products = snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load products: $e';
      notifyListeners();
    }
  }

  // Add new product
  Future<bool> addProduct(ProductModel product) async {
    try {
      await _firestore.collection('products').doc(product.id).set(product.toMap());
      _products.insert(0, product);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add product: $e';
      notifyListeners();
      return false;
    }
  }

  // Update product
  Future<bool> updateProduct(ProductModel product) async {
    try {
      await _firestore.collection('products').doc(product.id).update(product.toMap());
      
      int index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = product;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update product: $e';
      notifyListeners();
      return false;
    }
  }

  // Delete product
  Future<bool> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
      _products.removeWhere((p) => p.id == productId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete product: $e';
      notifyListeners();
      return false;
    }
  }

  // Load all orders
  Future<void> loadAllOrders() async {
    try {
      _isLoading = true;
      notifyListeners();

      QuerySnapshot snapshot = await _firestore
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .get();

      _orders = snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load orders: $e';
      notifyListeners();
    }
  }

  // Update order status
  Future<bool> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status.toString().split('.').last,
      });

      int index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        // Create updated order (since OrderModel is immutable)
        _orders[index] = OrderModel(
          id: _orders[index].id,
          userId: _orders[index].userId,
          items: _orders[index].items,
          totalAmount: _orders[index].totalAmount,
          status: status,
          deliveryAddress: _orders[index].deliveryAddress,
          paymentMethod: _orders[index].paymentMethod,
          createdAt: _orders[index].createdAt,
          deliveryDate: _orders[index].deliveryDate,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update order: $e';
      notifyListeners();
      return false;
    }
  }

  // Load analytics data
  Future<void> loadAnalytics() async {
    try {
      // Calculate basic analytics
      double totalRevenue = _orders
          .where((order) => order.status == OrderStatus.delivered)
          .fold(0.0, (sum, order) => sum + order.totalAmount);

      int totalOrders = _orders.length;
      int pendingOrders = _orders
          .where((order) => order.status == OrderStatus.pending)
          .length;

      Map<String, int> categoryCount = {};
      for (var product in _products) {
        categoryCount[product.category] = (categoryCount[product.category] ?? 0) + 1;
      }

      _analytics = {
        'totalRevenue': totalRevenue,
        'totalOrders': totalOrders,
        'pendingOrders': pendingOrders,
        'totalProducts': _products.length,
        'categoryBreakdown': categoryCount,
        'recentOrders': _orders.take(5).toList(),
      };

      notifyListeners();
    } catch (e) {
      print('Error loading analytics: $e');
    }
  }
}