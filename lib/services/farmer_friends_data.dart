// lib/services/farmer_friends_data.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class FarmerFriendsData {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> addSampleData() async {
    final sampleProducts = [
      // Agricultural Equipment
      {
        'id': 'eq001',
        'name': 'Hand Cultivator',
        'description': 'Professional hand cultivator for small-scale farming. Durable steel construction with comfortable grip.',
        'price': 25.99,
        'category': 'Equipment',
        'images': ['https://images.unsplash.com/photo-1625246333195-78d9c38ad449?w=500'],
        'unit': 'piece',
        'stock': 20,
        'farmerId': 'farmerfriendsstore',
        'farmerName': 'Farmer Friends Store',
        'rating': 4.7,
        'reviewCount': 15,
        'createdAt': DateTime.now().toIso8601String(),
        'isOrganic': false,
        'location': 'Madina, Ghana',
      },
      {
        'id': 'eq002',
        'name': 'Irrigation Sprinkler',
        'description': 'Efficient sprinkler system for garden and field irrigation. Adjustable spray pattern.',
        'price': 89.50,
        'category': 'Equipment',
        'images': ['https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=500'],
        'unit': 'piece',
        'stock': 12,
        'farmerId': 'farmerfriendsstore',
        'farmerName': 'Farmer Friends Store',
        'rating': 4.5,
        'reviewCount': 8,
        'createdAt': DateTime.now().toIso8601String(),
        'isOrganic': false,
        'location': 'Madina, Ghana',
      },
      // Animal Feed
      {
        'id': 'feed001',
        'name': 'Premium Poultry Feed',
        'description': 'High-quality poultry feed with balanced nutrients for optimal egg production and bird health.',
        'price': 35.00,
        'category': 'Animal Feed',
        'images': ['https://images.unsplash.com/photo-1548550023-2bdb3c5beed7?w=500'],
        'unit': '25kg bag',
        'stock': 50,
        'farmerId': 'farmerfriendsstore',
        'farmerName': 'Farmer Friends Store',
        'rating': 4.8,
        'reviewCount': 32,
        'createdAt': DateTime.now().toIso8601String(),
        'isOrganic': true,
        'location': 'Madina, Ghana',
      },
      {
        'id': 'feed002',
        'name': 'Cattle Feed Concentrate',
        'description': 'Nutritious cattle feed concentrate to supplement grazing. Improves milk production and weight gain.',
        'price': 42.00,
        'category': 'Animal Feed',
        'images': ['https://images.unsplash.com/photo-1560114928-40f1f1eb26a0?w=500'],
        'unit': '50kg bag',
        'stock': 30,
        'farmerId': 'farmerfriendsstore',
        'farmerName': 'Farmer Friends Store',
        'rating': 4.6,
        'reviewCount': 18,
        'createdAt': DateTime.now().toIso8601String(),
        'isOrganic': false,
        'location': 'Madina, Ghana',
      },
      // Poultry Products
      {
        'id': 'poultry001',
        'name': 'Chicken Feeders - Automatic',
        'description': 'Automatic chicken feeders that reduce waste and ensure continuous feeding.',
        'price': 28.75,
        'category': 'Poultry',
        'images': ['https://images.unsplash.com/photo-1548199973-03cce0bbc87b?w=500'],
        'unit': 'piece',
        'stock': 25,
        'farmerId': 'farmerfriendsstore',
        'farmerName': 'Farmer Friends Store',
        'rating': 4.4,
        'reviewCount': 12,
        'createdAt': DateTime.now().toIso8601String(),
        'isOrganic': false,
        'location': 'Madina, Ghana',
      },
      {
        'id': 'poultry002',
        'name': 'Egg Incubator - 48 Capacity',
        'description': 'Digital egg incubator with automatic turning and temperature control. Perfect for small-scale hatching.',
        'price': 156.00,
        'category': 'Poultry',
        'images': ['https://images.unsplash.com/photo-1551218808-94e220e084d2?w=500'],
        'unit': 'piece',
        'stock': 8,
        'farmerId': 'farmerfriendsstore',
        'farmerName': 'Farmer Friends Store',
        'rating': 4.9,
        'reviewCount': 6,
        'createdAt': DateTime.now().toIso8601String(),
        'isOrganic': false,
        'location': 'Madina, Ghana',
      },
    ];

    for (var product in sampleProducts) {
      await _firestore.collection('products').doc(product['id']).set(product);
    }

    print('Farmer Friends sample data added successfully!');
  }
}