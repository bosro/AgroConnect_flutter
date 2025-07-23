// lib/providers/search_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class SearchProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<ProductModel> _searchResults = [];
  bool _isSearching = false;
  String _currentQuery = '';
  Map<String, dynamic> _filters = {
    'category': null,
    'minPrice': null,
    'maxPrice': null,
    'isOrganic': null,
    'inStock': true,
  };

  // Getters
  List<ProductModel> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  String get currentQuery => _currentQuery;
  Map<String, dynamic> get filters => _filters;

  // Search products with advanced filters
  Future<void> searchProducts(String query) async {
    _currentQuery = query;
    _isSearching = true;
    notifyListeners();

    try {
      Query baseQuery = _firestore.collection('products');
      
      // Apply filters
      if (_filters['category'] != null) {
        baseQuery = baseQuery.where('category', isEqualTo: _filters['category']);
      }
      
      if (_filters['isOrganic'] != null) {
        baseQuery = baseQuery.where('isOrganic', isEqualTo: _filters['isOrganic']);
      }
      
      if (_filters['inStock'] == true) {
        baseQuery = baseQuery.where('stock', isGreaterThan: 0);
      }

      QuerySnapshot snapshot = await baseQuery.get();
      
      List<ProductModel> allProducts = snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      // Filter by search query (client-side for better flexibility)
      if (query.isNotEmpty) {
        _searchResults = allProducts.where((product) {
          final searchLower = query.toLowerCase();
          return product.name.toLowerCase().contains(searchLower) ||
                 product.description.toLowerCase().contains(searchLower) ||
                 product.category.toLowerCase().contains(searchLower) ||
                 product.farmerName.toLowerCase().contains(searchLower);
        }).toList();
      } else {
        _searchResults = allProducts;
      }

      // Apply price filters
      if (_filters['minPrice'] != null) {
        _searchResults = _searchResults
            .where((product) => product.price >= _filters['minPrice'])
            .toList();
      }
      
      if (_filters['maxPrice'] != null) {
        _searchResults = _searchResults
            .where((product) => product.price <= _filters['maxPrice'])
            .toList();
      }

      // Sort results by relevance/rating
      _searchResults.sort((a, b) {
        // Prioritize exact matches in name
        if (query.isNotEmpty) {
          bool aExact = a.name.toLowerCase().startsWith(query.toLowerCase());
          bool bExact = b.name.toLowerCase().startsWith(query.toLowerCase());
          if (aExact && !bExact) return -1;
          if (!aExact && bExact) return 1;
        }
        
        // Then sort by rating
        return b.rating.compareTo(a.rating);
      });

    } catch (e) {
      print('Search error: $e');
      _searchResults = [];
    }

    _isSearching = false;
    notifyListeners();
  }

  // Update filters
  void updateFilter(String key, dynamic value) {
    _filters[key] = value;
    notifyListeners();
    
    // Re-search with new filters
    if (_currentQuery.isNotEmpty || _hasActiveFilters()) {
      searchProducts(_currentQuery);
    }
  }

  // Clear all filters
  void clearFilters() {
    _filters = {
      'category': null,
      'minPrice': null,
      'maxPrice': null,
      'isOrganic': null,
      'inStock': true,
    };
    notifyListeners();
    searchProducts(_currentQuery);
  }

  // Check if any filters are active
  bool _hasActiveFilters() {
    return _filters['category'] != null ||
           _filters['minPrice'] != null ||
           _filters['maxPrice'] != null ||
           _filters['isOrganic'] != null ||
           _filters['inStock'] != true;
  }

  // Get search suggestions
  Future<List<String>> getSearchSuggestions(String query) async {
    if (query.length < 2) return [];

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('products')
          .get();

      Set<String> suggestions = {};
      
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        String name = data['name'] ?? '';
        String category = data['category'] ?? '';
        String description = data['description'] ?? '';
        
        // Add matching product names
        if (name.toLowerCase().contains(query.toLowerCase())) {
          suggestions.add(name);
        }
        
        // Add matching categories
        if (category.toLowerCase().contains(query.toLowerCase())) {
          suggestions.add(category);
        }
        
        // Add relevant words from description
        List<String> words = description.toLowerCase().split(' ');
        for (String word in words) {
          if (word.length > 3 && word.contains(query.toLowerCase())) {
            suggestions.add(word.toLowerCase());
          }
        }
      }

      return suggestions.take(5).toList();
    } catch (e) {
      print('Error getting suggestions: $e');
      return [];
    }
  }
}