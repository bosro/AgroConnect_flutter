// lib/services/storage_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Save cart data
  static Future<void> saveCartData(List<Map<String, dynamic>> cartItems) async {
    final cartJson = jsonEncode(cartItems);
    await _prefs?.setString('cart_data', cartJson);
  }

  // Load cart data
  static List<Map<String, dynamic>> loadCartData() {
    final cartJson = _prefs?.getString('cart_data');
    if (cartJson != null) {
      final List<dynamic> cartList = jsonDecode(cartJson);
      return cartList.cast<Map<String, dynamic>>();
    }
    return [];
  }

  // Save user preferences
  static Future<void> saveUserPreferences(Map<String, dynamic> preferences) async {
    final prefsJson = jsonEncode(preferences);
    await _prefs?.setString('user_preferences', prefsJson);
  }

  // Load user preferences
  static Map<String, dynamic> loadUserPreferences() {
    final prefsJson = _prefs?.getString('user_preferences');
    if (prefsJson != null) {
      return jsonDecode(prefsJson);
    }
    return {};
  }

  // Clear all data
  static Future<void> clearAll() async {
    await _prefs?.clear();
  }
}