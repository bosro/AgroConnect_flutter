import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add sample data to Firestore
  static Future<void> addSampleData() async {
    final sampleProducts = [
      {
        'id': 'prod1',
        'name': 'Fresh Organic Tomatoes',
        'description': 'Premium quality organic tomatoes, freshly harvested from our local farms. Perfect for cooking and salads.',
        'price': 5.99,
        'category': 'Vegetables',
        'images': ['https://images.unsplash.com/photo-1546470427-e97d5b8c0463?w=500'],
        'unit': 'kg',
        'stock': 50,
        'farmerId': 'farmer1',
        'farmerName': 'Green Valley Farm',
        'rating': 4.5,
        'reviewCount': 23,
        'createdAt': DateTime.now().toIso8601String(),
        'isOrganic': true,
        'location': 'Yogyakarta, Indonesia',
      },
      {
        'id': 'prod2',
        'name': 'Fresh Bananas',
        'description': 'Sweet and ripe bananas, rich in potassium and perfect for a healthy snack.',
        'price': 3.50,
        'category': 'Fruits',
        'images': ['https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=500'],
        'unit': 'kg',
        'stock': 75,
        'farmerId': 'farmer2',
        'farmerName': 'Tropical Fruits Co.',
        'rating': 4.2,
        'reviewCount': 18,
        'createdAt': DateTime.now().toIso8601String(),
        'isOrganic': false,
        'location': 'Bandung, Indonesia',
      },
      {
        'id': 'prod3',
        'name': 'Premium Rice',
        'description': 'High-quality jasmine rice, perfect for daily meals. Grown using sustainable farming practices.',
        'price': 12.99,
        'category': 'Grains',
        'images': ['https://images.unsplash.com/photo-1586201375761-83865001e31c?w=500'],
        'unit': 'kg',
        'stock': 100,
        'farmerId': 'farmer3',
        'farmerName': 'Rice Masters Farm',
        'rating': 4.8,
        'reviewCount': 45,
        'createdAt': DateTime.now().toIso8601String(),
        'isOrganic': true,
        'location': 'Bali, Indonesia',
      },
      {
        'id': 'prod4',
        'name': 'Farm Equipment - Hand Plow',
        'description': 'Durable hand plow for small-scale farming. Made from high-quality steel.',
        'price': 45.00,
        'category': 'Equipment',
        'images': ['https://images.unsplash.com/photo-1625246333195-78d9c38ad449?w=500'],
        'unit': 'piece',
        'stock': 15,
        'farmerId': 'supplier1',
        'farmerName': 'AgriTools Supply',
        'rating': 4.3,
        'reviewCount': 8,
        'createdAt': DateTime.now().toIso8601String(),
        'isOrganic': false,
        'location': 'Jakarta, Indonesia',
      },
      {
        'id': 'prod5',
        'name': 'Fresh Carrots',
        'description': 'Crispy and sweet carrots, rich in vitamins. Perfect for cooking and juicing.',
        'price': 4.25,
        'category': 'Vegetables',
        'images': ['https://images.unsplash.com/photo-1445282768818-728615cc910a?w=500'],
        'unit': 'kg',
        'stock': 40,
        'farmerId': 'farmer1',
        'farmerName': 'Green Valley Farm',
        'rating': 4.4,
        'reviewCount': 12,
        'createdAt': DateTime.now().toIso8601String(),
        'isOrganic': true,
        'location': 'Yogyakarta, Indonesia',
      },
    ];

    for (var product in sampleProducts) {
      await _firestore.collection('products').doc(product['id']).set(product);
    }
  }
}