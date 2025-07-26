// lib/services/admin_notification_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminNotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // ⚠️ IMPORTANT: Replace with your actual Firebase Server Key
  static const String _serverKey = 'YOUR_FIREBASE_SERVER_KEY_HERE';
  
  // Send notification to specific user
  static Future<bool> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      print('🔔 Sending notification to user: $userId');
      
      // Get user's FCM token
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (!userDoc.exists) {
        print('❌ User not found');
        return false;
      }
      
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      String? fcmToken = userData['fcmToken'] as String?;
      
      if (fcmToken == null || fcmToken.isEmpty) {
        print('❌ No FCM token found for user');
        return false;
      }

      print('📱 Sending to FCM token: ${fcmToken.substring(0, 20)}...');

      // Send notification using HTTP request to FCM
      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$_serverKey',
        },
        body: jsonEncode({
          'to': fcmToken,
          'notification': {
            'title': title,
            'body': body,
            'sound': 'default',
            'android_channel_id': 'farmer_friends_channel',
          },
          'data': {
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            ...?data,
          },
          'priority': 'high',
        }),
      );

      print('📤 FCM Response: ${response.statusCode}');
      print('📤 FCM Body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Notification sent successfully');
        
        // Log notification in Firestore for tracking
        await _firestore.collection('notifications').add({
          'userId': userId,
          'title': title,
          'body': body,
          'data': data ?? {},
          'sentAt': FieldValue.serverTimestamp(),
          'status': 'sent',
          'fcmResponse': json.decode(response.body),
        });
        
        return true;
      } else {
        print('❌ Failed to send notification: ${response.body}');
        return false;
      }
    } catch (e) {
      print('💥 Error sending notification: $e');
      return false;
    }
  }

  // Send order status notification
  static Future<bool> sendOrderStatusNotification({
    required String userId,
    required String orderId,
    required String status,
    required double totalAmount,
  }) async {
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
  }

  // Send new product notification
  static Future<bool> sendNewProductNotification({
    required List<String> userIds,
    required String productName,
    required String productId,
    required String category,
  }) async {
    bool allSuccess = true;
    
    for (String userId in userIds) {
      bool success = await sendNotificationToUser(
        userId: userId,
        title: 'New ${category} Available! 🌾',
        body: 'Check out $productName now available in your area',
        data: {
          'type': 'new_product',
          'productId': productId,
          'category': category,
          'screen': 'product_details',
        },
      );
      
      if (!success) allSuccess = false;
      
      // Add small delay to avoid rate limiting
      await Future.delayed(Duration(milliseconds: 100));
    }
    
    return allSuccess;
  }

  // Send bulk notification to all users
  static Future<int> sendBulkNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? category, // Optional: filter by user interests
  }) async {
    try {
      Query query = _firestore.collection('users').where('fcmToken', isNotEqualTo: null);
      
      // Optional: filter by category interest
      if (category != null) {
        query = query.where('interests', arrayContains: category);
      }
      
      QuerySnapshot usersSnapshot = await query.get();
      
      int successCount = 0;
      List<Future<bool>> sendTasks = [];
      
      // Send to batches of 10 to avoid overwhelming the server
      for (int i = 0; i < usersSnapshot.docs.length; i += 10) {
        List<QueryDocumentSnapshot> batch = usersSnapshot.docs
            .skip(i)
            .take(10)
            .toList();
        
        for (QueryDocumentSnapshot userDoc in batch) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          String? fcmToken = userData['fcmToken'] as String?;
          
          if (fcmToken != null && fcmToken.isNotEmpty) {
            sendTasks.add(sendNotificationToUser(
              userId: userDoc.id,
              title: title,
              body: body,
              data: data,
            ));
          }
        }
        
        // Process batch
        List<bool> batchResults = await Future.wait(sendTasks);
        successCount += batchResults.where((result) => result).length;
        sendTasks.clear();
        
        // Delay between batches
        if (i + 10 < usersSnapshot.docs.length) {
          await Future.delayed(Duration(seconds: 1));
        }
      }
      
      print('📊 Sent $successCount/${usersSnapshot.docs.length} notifications successfully');
      return successCount;
    } catch (e) {
      print('💥 Error sending bulk notifications: $e');
      return 0;
    }
  }

  // Helper methods
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
      default:
        return 'Order Update';
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
      default:
        return 'Your order #$orderShort status has been updated to $status';
    }
  }
}