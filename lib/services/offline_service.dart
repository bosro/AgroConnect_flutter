// lib/services/offline_service.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/product_model.dart';

class OfflineService {
  static Box? _productsBox;
  static Box? _ordersBox;
  static ValueNotifier<bool> isOnline = ValueNotifier(true);

  static Future<void> initialize() async {
    _productsBox = await Hive.openBox('products');
    _ordersBox = await Hive.openBox('orders');
    
    // Monitor connectivity
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      isOnline.value = result != ConnectivityResult.none;
    } as void Function(List<ConnectivityResult> event)?);
  }

  // Cache products for offline access
  static Future<void> cacheProducts(List<ProductModel> products) async {
    final productMaps = products.map((p) => p.toMap()).toList();
    await _productsBox?.put('cached_products', productMaps);
  }

  // Get cached products
  static List<ProductModel> getCachedProducts() {
    final cached = _productsBox?.get('cached_products');
    if (cached != null) {
      return (cached as List).map((p) => ProductModel.fromMap(p)).toList();
    }
    return [];
  }

  // Queue orders for when online
  static Future<void> queueOrder(Map<String, dynamic> orderData) async {
    final List<dynamic> queuedOrders = _ordersBox?.get('queued_orders', defaultValue: []) ?? [];
    queuedOrders.add(orderData);
    await _ordersBox?.put('queued_orders', queuedOrders);
  }

  // Process queued orders when online
  static Future<void> processQueuedOrders() async {
    if (!isOnline.value) return;
    
    final List<dynamic> queuedOrders = _ordersBox?.get('queued_orders', defaultValue: []) ?? [];
    
    for (var orderData in queuedOrders) {
      try {
        // Process order (implement your order processing logic)
        await _processOrder(orderData);
      } catch (e) {
        print('Failed to process queued order: $e');
      }
    }
    
    // Clear processed orders
    await _ordersBox?.delete('queued_orders');
  }

  static Future<void> _processOrder(Map<String, dynamic> orderData) async {
    // Implement actual order processing
  }
}