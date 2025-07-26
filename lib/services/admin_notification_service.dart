// lib/services/admin_notification_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminNotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🆕 Send notification to specific user via Cloud Function
  static Future<bool> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      print('🔔 Creating notification request for user: $userId');

      // Create notification request - Cloud Function will process it
      DocumentReference requestRef = await _firestore.collection('notificationRequests').add({
        'type': 'single',
        'userId': userId,
        'title': title,
        'body': body,
        'data': data ?? {},
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      print('📝 Notification request created: ${requestRef.id}');
      
      // Wait briefly for Cloud Function to process
      await Future.delayed(Duration(seconds: 2));
      
      // Check if processed successfully
      DocumentSnapshot requestDoc = await requestRef.get();
      if (requestDoc.exists) {
        Map<String, dynamic> requestData = requestDoc.data() as Map<String, dynamic>;
        bool success = requestData['status'] == 'sent';
        
        if (success) {
          print('✅ Notification sent successfully via Cloud Function');
        } else {
          print('❌ Notification failed: ${requestData['error'] ?? 'Unknown error'}');
        }
        
        return success;
      }
      
      return false;
    } catch (e) {
      print('💥 Error creating notification request: $e');
      return false;
    }
  }

  // 🆕 Send order status notification via Cloud Function
  static Future<bool> sendOrderStatusNotification({
    required String userId,
    required String orderId,
    required String status,
    required double totalAmount,
  }) async {
    try {
      print('📦 Sending order status notification: $orderId → $status');

      // Note: The Cloud Function automatically handles order status changes
      // This method is for manual/additional notifications only
      String title = _getStatusTitle(status);
      String body = _getStatusBody(orderId, status, totalAmount);

      return await sendNotificationToUser(
        userId: userId,
        title: title,
        body: body,
        data: {
          'type': 'order_update',
          'orderId': orderId,
          'status': status,
          'screen': 'order_details',
        },
      );
    } catch (e) {
      print('💥 Error sending order status notification: $e');
      return false;
    }
  }

  // 🆕 Send new product notification via Cloud Function
  static Future<bool> sendNewProductNotification({
    required List<String> userIds,
    required String productName,
    required String productId,
    required String category,
  }) async {
    try {
      print('🆕 Announcing new product: $productName to ${userIds.length} users');

      // Create bulk notification request for new product
      DocumentReference requestRef = await _firestore.collection('notificationRequests').add({
        'type': 'new_product',
        'productName': productName,
        'productId': productId,
        'category': category,
        'targetUserIds': userIds,
        'title': 'New $category Available! 🌾',
        'body': 'Check out $productName now available in your area',
        'data': {
          'type': 'new_product',
          'productId': productId,
          'category': category,
          'screen': 'product_details',
        },
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      print('📝 New product notification request created: ${requestRef.id}');
      
      // Wait for Cloud Function to process
      await Future.delayed(Duration(seconds: 3));
      
      // Check results
      DocumentSnapshot requestDoc = await requestRef.get();
      if (requestDoc.exists) {
        Map<String, dynamic> requestData = requestDoc.data() as Map<String, dynamic>;
        bool success = requestData['status'] == 'completed';
        
        if (success) {
          int sentCount = requestData['totalSent'] ?? 0;
          print('✅ New product notification sent to $sentCount users');
        }
        
        return success;
      }
      
      return false;
    } catch (e) {
      print('💥 Error sending new product notification: $e');
      return false;
    }
  }

  // 🆕 Send bulk notification via Cloud Function
  static Future<int> sendBulkNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? category,
  }) async {
    try {
      print('📢 Creating bulk notification request: $title');

      // Create bulk notification request - Cloud Function will process it
      DocumentReference requestRef = await _firestore.collection('notificationRequests').add({
        'type': 'bulk',
        'title': title,
        'body': body,
        'category': category ?? 'all',
        'data': data ?? {
          'type': 'promotion',
          'screen': 'home',
        },
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      print('📝 Bulk notification request created: ${requestRef.id}');
      
      // Wait for Cloud Function to process
      await Future.delayed(Duration(seconds: 5));
      
      // Check results
      DocumentSnapshot requestDoc = await requestRef.get();
      if (requestDoc.exists) {
        Map<String, dynamic> requestData = requestDoc.data() as Map<String, dynamic>;
        
        if (requestData['status'] == 'completed') {
          int sentCount = requestData['totalSent'] ?? 0;
          int targetedCount = requestData['totalTargeted'] ?? 0;
          print('📊 Bulk notification completed: $sentCount/$targetedCount sent');
          return sentCount;
        } else if (requestData['status'] == 'failed') {
          print('❌ Bulk notification failed: ${requestData['error']}');
          return 0;
        } else {
          print('⏳ Bulk notification still processing...');
          return 0;
        }
      }
      
      return 0;
    } catch (e) {
      print('💥 Error creating bulk notification request: $e');
      return 0;
    }
  }

  // 🆕 Send custom notification to specific user
  static Future<bool> sendCustomNotification({
    required String userId,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    try {
      print('👤 Sending custom notification to user: $userId');

      return await sendNotificationToUser(
        userId: userId,
        title: title,
        body: message,
        data: {
          'type': 'custom',
          'screen': 'home',
          ...?data,
        },
      );
    } catch (e) {
      print('💥 Error sending custom notification: $e');
      return false;
    }
  }

  // 🆕 Send welcome notification for new users
  static Future<bool> sendWelcomeNotification({
    required String userId,
    required String userName,
  }) async {
    try {
      print('👋 Sending welcome notification to: $userName');

      return await sendNotificationToUser(
        userId: userId,
        title: 'Welcome to Farmer Friends! 🌾',
        body: 'Hi $userName! Discover fresh produce and farming supplies in your area.',
        data: {
          'type': 'welcome',
          'screen': 'home',
        },
      );
    } catch (e) {
      print('💥 Error sending welcome notification: $e');
      return false;
    }
  }

  // 🆕 Send promotional notification with targeting
  static Future<int> sendPromotionalNotification({
    required String title,
    required String message,
    String? category,
    String? targetAudience, // 'all', 'category', 'recent_customers'
  }) async {
    try {
      print('🎯 Sending promotional notification: $title');

      return await sendBulkNotification(
        title: title,
        body: message,
        category: category,
        data: {
          'type': 'promotion',
          'category': category ?? 'general',
          'targetAudience': targetAudience ?? 'all',
          'screen': 'home',
        },
      );
    } catch (e) {
      print('💥 Error sending promotional notification: $e');
      return 0;
    }
  }

  // 🆕 Send notification for low stock alert (admin internal)
  static Future<bool> sendLowStockAlert({
    required String adminUserId,
    required String productName,
    required String productId,
    required int stockLevel,
  }) async {
    try {
      return await sendNotificationToUser(
        userId: adminUserId,
        title: 'Low Stock Alert! ⚠️',
        body: '$productName is running low (${stockLevel} remaining)',
        data: {
          'type': 'low_stock',
          'productId': productId,
          'stockLevel': stockLevel.toString(),
          'screen': 'admin_products',
        },
      );
    } catch (e) {
      print('💥 Error sending low stock alert: $e');
      return false;
    }
  }

  // 🆕 Get notification request status
  static Future<Map<String, dynamic>?> getNotificationRequestStatus(String requestId) async {
    try {
      DocumentSnapshot requestDoc = await _firestore
          .collection('notificationRequests')
          .doc(requestId)
          .get();

      if (requestDoc.exists) {
        return requestDoc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('💥 Error getting notification request status: $e');
      return null;
    }
  }

  // 🆕 Get notification history for admin dashboard
  static Future<List<Map<String, dynamic>>> getNotificationHistory({
    int limit = 20,
    String? type,
  }) async {
    try {
      Query query = _firestore
          .collection('notificationRequests')
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (type != null) {
        query = query.where('type', isEqualTo: type);
      }

      QuerySnapshot snapshot = await query.get();

      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();
    } catch (e) {
      print('💥 Error getting notification history: $e');
      return [];
    }
  }

  // 🆕 Get notification analytics
  static Future<Map<String, dynamic>> getNotificationAnalytics() async {
    try {
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(Duration(days: 30));
      final sevenDaysAgo = now.subtract(Duration(days: 7));

      // Get counts for different time periods
      final last30DaysQuery = await _firestore
          .collection('notificationRequests')
          .where('createdAt', isGreaterThan: Timestamp.fromDate(thirtyDaysAgo))
          .get();

      final last7DaysQuery = await _firestore
          .collection('notificationRequests')
          .where('createdAt', isGreaterThan: Timestamp.fromDate(sevenDaysAgo))
          .get();

      // Calculate success rates
      int totalSent30Days = 0;
      int totalFailed30Days = 0;
      Map<String, int> typeBreakdown = {};

      for (var doc in last30DaysQuery.docs) {
        Map<String, dynamic> data = doc.data();
        String status = data['status'] ?? 'pending';
        String type = data['type'] ?? 'unknown';

        typeBreakdown[type] = (typeBreakdown[type] ?? 0) + 1;

        if (status == 'sent' || status == 'completed') {
          totalSent30Days += (data['totalSent'] ?? 1) as int;
        } else if (status == 'failed') {
          totalFailed30Days += 1;
        }
      }

      return {
        'totalRequests30Days': last30DaysQuery.docs.length,
        'totalRequests7Days': last7DaysQuery.docs.length,
        'totalSent30Days': totalSent30Days,
        'totalFailed30Days': totalFailed30Days,
        'successRate': totalSent30Days + totalFailed30Days > 0 
            ? (totalSent30Days / (totalSent30Days + totalFailed30Days) * 100).round()
            : 0,
        'typeBreakdown': typeBreakdown,
        'lastCalculated': FieldValue.serverTimestamp(),
      };
    } catch (e) {
      print('💥 Error getting notification analytics: $e');
      return {};
    }
  }

  // 🆕 Cancel pending notification request
  static Future<bool> cancelNotificationRequest(String requestId) async {
    try {
      await _firestore
          .collection('notificationRequests')
          .doc(requestId)
          .update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      });

      print('🚫 Notification request cancelled: $requestId');
      return true;
    } catch (e) {
      print('💥 Error cancelling notification request: $e');
      return false;
    }
  }

  // Helper methods for message formatting
  static String _getStatusTitle(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 'Order Confirmed! ✅';
      case 'shipped':
        return 'Order Shipped! 🚚';
      case 'delivered':
        return 'Order Delivered! 📦';
      case 'cancelled':
        return 'Order Cancelled ❌';
      case 'processing':
        return 'Order Processing 🔄';
      case 'packed':
        return 'Order Packed 📦';
      default:
        return 'Order Update 📋';
    }
  }

  static String _getStatusBody(String orderId, String status, double totalAmount) {
    String orderShort = orderId.substring(0, 8);
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 'Your order #$orderShort (GH₵${totalAmount.toStringAsFixed(2)}) has been confirmed and is being prepared.';
      case 'shipped':
        return 'Your order #$orderShort is on its way! Track your delivery in the app.';
      case 'delivered':
        return 'Your order #$orderShort has been delivered! Thank you for choosing Farmer Friends.';
      case 'cancelled':
        return 'Your order #$orderShort has been cancelled. Refund will be processed within 3-5 business days.';
      case 'processing':
        return 'Your order #$orderShort is being processed and will be ready soon.';
      case 'packed':
        return 'Your order #$orderShort has been packed and is ready for shipping.';
      default:
        return 'Your order #$orderShort status has been updated to $status.';
    }
  }

  // 🆕 Test notification system
  static Future<bool> sendTestNotification(String userId) async {
    try {
      return await sendNotificationToUser(
        userId: userId,
        title: 'Test Notification 🧪',
        body: 'This is a test notification from Farmer Friends admin panel.',
        data: {
          'type': 'test',
          'screen': 'home',
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        },
      );
    } catch (e) {
      print('💥 Error sending test notification: $e');
      return false;
    }
  }
}