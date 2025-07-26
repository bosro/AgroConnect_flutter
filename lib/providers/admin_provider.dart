// lib/providers/admin_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/admin_model.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../services/admin_notification_service.dart'; // 🆕 Add this import

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

  // 🆕 Enhanced: Add new product with optional announcement
  Future<bool> addProduct(ProductModel product, {bool sendAnnouncement = false}) async {
    try {
      // Add product to Firestore
      await _firestore.collection('products').doc(product.id).set(product.toMap());
      
      // Update local state
      _products.insert(0, product);
      notifyListeners();

      // 🔔 Send new product announcement if requested
      if (sendAnnouncement) {
        bool notificationSent = await announceNewProduct(product);
        print(notificationSent 
          ? '✅ New product announcement sent!' 
          : '⚠️ Product added but announcement failed');
      }

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

  // 🆕 Enhanced: Update order status with notifications
  Future<bool> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      print('🔄 Updating order $orderId to ${status.toString().split('.').last}');

      // Get order details before updating (for notification)
      DocumentSnapshot orderDoc = await _firestore.collection('orders').doc(orderId).get();
      
      if (!orderDoc.exists) {
        _errorMessage = 'Order not found';
        notifyListeners();
        return false;
      }

      Map<String, dynamic> orderData = orderDoc.data() as Map<String, dynamic>;

      // Update order in Firestore
      await _firestore.collection('orders').doc(orderId).update({
        'status': status.toString().split('.').last,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': _admin?.id ?? 'admin',
      });

      // Update local state
      int index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
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

      // 🔔 Send notification to customer
      bool notificationSent = await AdminNotificationService.sendOrderStatusNotification(
        userId: orderData['userId'],
        orderId: orderId,
        status: status.toString().split('.').last,
        totalAmount: orderData['totalAmount'].toDouble(),
      );

      if (notificationSent) {
        print('✅ Customer notification sent successfully');
      } else {
        print('⚠️ Order updated but notification failed');
      }

      return true;
    } catch (e) {
      _errorMessage = 'Failed to update order: $e';
      notifyListeners();
      print('❌ Error updating order: $e');
      return false;
    }
  }

  // 🆕 New method: Announce new product to interested users
  Future<bool> announceNewProduct(ProductModel product) async {
    try {
      print('📢 Announcing new product: ${product.name}');

      // Get users interested in this category
      QuerySnapshot interestedUsers = await _firestore
          .collection('users')
          .where('interests', arrayContains: product.category.toLowerCase())
          .where('fcmToken', isNotEqualTo: null)
          .get();

      List<String> userIds = interestedUsers.docs.map((doc) => doc.id).toList();
      
      // If no specific interests found, get all users with FCM tokens
      if (userIds.isEmpty) {
        print('🔍 No category-specific users found, getting all users...');
        QuerySnapshot allUsers = await _firestore
            .collection('users')
            .where('fcmToken', isNotEqualTo: null)
            .limit(50) // Limit to prevent overwhelming
            .get();
        userIds = allUsers.docs.map((doc) => doc.id).toList();
      }

      print('👥 Sending to ${userIds.length} users');

      if (userIds.isNotEmpty) {
        bool success = await AdminNotificationService.sendNewProductNotification(
          userIds: userIds,
          productName: product.name,
          productId: product.id,
          category: product.category,
        );

        // Log announcement
        await _firestore.collection('announcements').add({
          'type': 'new_product',
          'productId': product.id,
          'productName': product.name,
          'category': product.category,
          'sentTo': userIds.length,
          'success': success,
          'sentBy': _admin?.id ?? 'admin',
          'sentAt': FieldValue.serverTimestamp(),
        });

        return success;
      }

      return false;
    } catch (e) {
      print('❌ Error announcing new product: $e');
      return false;
    }
  }

  // 🆕 New method: Send promotional notifications
  Future<int> sendPromotionalNotification({
    required String title,
    required String message,
    String? category,
    String? targetAudience, // 'all', 'category', 'recent_customers'
  }) async {
    try {
      print('🎯 Sending promotional notification: $title');

      int sentCount = await AdminNotificationService.sendBulkNotification(
        title: title,
        body: message,
        category: category,
        data: {
          'type': 'promotion',
          'screen': 'home',
          'category': category ?? 'general',
        },
      );

      // Log promotional campaign
      await _firestore.collection('promotions').add({
        'title': title,
        'message': message,
        'category': category,
        'targetAudience': targetAudience ?? 'all',
        'sentTo': sentCount,
        'sentBy': _admin?.id ?? 'admin',
        'sentAt': FieldValue.serverTimestamp(),
      });

      print('📊 Promotional notification sent to $sentCount users');
      return sentCount;
    } catch (e) {
      print('❌ Error sending promotional notification: $e');
      return 0;
    }
  }

  // 🆕 New method: Send custom notification to specific user
  Future<bool> sendCustomNotification({
    required String userId,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    try {
      bool success = await AdminNotificationService.sendNotificationToUser(
        userId: userId,
        title: title,
        body: message,
        data: data,
      );

      // Log custom notification
      if (success) {
        await _firestore.collection('notifications').add({
          'type': 'custom',
          'userId': userId,
          'title': title,
          'message': message,
          'data': data ?? {},
          'sentBy': _admin?.id ?? 'admin',
          'sentAt': FieldValue.serverTimestamp(),
        });
      }

      return success;
    } catch (e) {
      print('❌ Error sending custom notification: $e');
      return false;
    }
  }

  // 🆕 New method: Get notification history
  Future<List<Map<String, dynamic>>> getNotificationHistory({int limit = 20}) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('notifications')
          .orderBy('sentAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();
    } catch (e) {
      print('❌ Error getting notification history: $e');
      return [];
    }
  }

  // 🆕 Enhanced: Load analytics with notification stats
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

      // 🆕 Get notification stats
      QuerySnapshot notificationStats = await _firestore
          .collection('notifications')
          .where('sentAt', isGreaterThan: Timestamp.fromDate(
              DateTime.now().subtract(Duration(days: 30))))
          .get();

      QuerySnapshot promotionStats = await _firestore
          .collection('promotions')
          .where('sentAt', isGreaterThan: Timestamp.fromDate(
              DateTime.now().subtract(Duration(days: 30))))
          .get();

      _analytics = {
        'totalRevenue': totalRevenue,
        'totalOrders': totalOrders,
        'pendingOrders': pendingOrders,
        'totalProducts': _products.length,
        'categoryBreakdown': categoryCount,
        'recentOrders': _orders.take(5).toList(),
        // 🆕 Notification analytics
        'notificationsSent30Days': notificationStats.docs.length,
        'promotionsSent30Days': promotionStats.docs.length,
        'lastNotificationSent': notificationStats.docs.isNotEmpty 
            ? (notificationStats.docs.first.data() as Map<String, dynamic>)['sentAt']
            : null,
      };

      notifyListeners();
    } catch (e) {
      print('Error loading analytics: $e');
    }
  }

  // 🆕 New method: Batch update order statuses
  Future<int> batchUpdateOrderStatus(List<String> orderIds, OrderStatus status) async {
    int successCount = 0;
    
    for (String orderId in orderIds) {
      bool success = await updateOrderStatus(orderId, status);
      if (success) successCount++;
      
      // Small delay to prevent overwhelming the notification service
      await Future.delayed(Duration(milliseconds: 200));
    }
    
    return successCount;
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // 🆕 New method: Get dashboard summary
  Map<String, dynamic> getDashboardSummary() {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    
    final todayOrders = _orders.where((order) => 
        order.createdAt.isAfter(todayStart)).length;
    
    final pendingCount = _orders.where((order) => 
        order.status == OrderStatus.pending).length;
    
    final lowStockProducts = _products.where((product) => 
        product.stock < 10).length;

    return {
      'todayOrders': todayOrders,
      'pendingOrders': pendingCount,
      'lowStockProducts': lowStockProducts,
      'totalRevenue': _analytics['totalRevenue'] ?? 0.0,
      'totalProducts': _products.length,
      'totalOrders': _orders.length,
    };
  }
}