// lib/services/analytics_service.dart
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  // Initialize analytics
  static Future<void> initialize() async {
    await _analytics.setAnalyticsCollectionEnabled(true);
    FlutterError.onError = _crashlytics.recordFlutterFatalError;
  }

  // Track screen views
  static Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenName,
    );
  }

  // Track user events
  static Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    await _analytics.logEvent(
      name: name,
      parameters: parameters,
    );
  }

  // Track product views
  static Future<void> logProductView(String productId, String productName) async {
    await _analytics.logEvent(
      name: 'view_item',
      parameters: {
        'item_id': productId,
        'item_name': productName,
        'content_type': 'product',
      },
    );
  }

  // Track add to cart
  static Future<void> logAddToCart(String productId, String productName, double price) async {
    await _analytics.logEvent(
      name: 'add_to_cart',
      parameters: {
        'item_id': productId,
        'item_name': productName,
        'price': price,
        'currency': 'GHS',
      },
    );
  }

  // Track purchases
  static Future<void> logPurchase({
    required String orderId,
    required double amount,
    required List<Map<String, dynamic>> items,
  }) async {
    await _analytics.logEvent(
      name: 'purchase',
      parameters: {
        'transaction_id': orderId,
        'value': amount,
        'currency': 'GHS',
        'items': items,
      },
    );
  }

  // Track user registration
  static Future<void> logSignUp(String method) async {
    await _analytics.logEvent(
      name: 'sign_up',
      parameters: {
        'method': method,
      },
    );
  }

  // Track user login
  static Future<void> logLogin(String method) async {
    await _analytics.logEvent(
      name: 'login',
      parameters: {
        'method': method,
      },
    );
  }

  // Set user properties
  static Future<void> setUserProperties({
    String? userId,
    String? userType,
    String? location,
  }) async {
    if (userId != null) {
      await _analytics.setUserId(id: userId);
    }
    
    if (userType != null) {
      await _analytics.setUserProperty(name: 'user_type', value: userType);
    }
    
    if (location != null) {
      await _analytics.setUserProperty(name: 'location', value: location);
    }
  }

  // Log custom errors
  static Future<void> logError(dynamic error, StackTrace? stackTrace) async {
    await _crashlytics.recordError(error, stackTrace);
  }
}