import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<ProductModel> _products = [];
  List<ProductModel> _filteredProducts = [];
  List<String> _categories = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  List<ProductModel> get products => _filteredProducts;
  List<String> get categories => _categories;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  bool _organicFilter = false;
  bool _inStockFilter = false;
  double _minPrice = 0;
  double _maxPrice = 1000;
  String _sortBy = 'name';

  // Add these getter methods
  bool get organicFilter => _organicFilter;
  bool get inStockFilter => _inStockFilter;
  double get minPrice => _minPrice;
  double get maxPrice => _maxPrice;
  String get sortBy => _sortBy;

  Future<void> loadProducts() async {
    try {
      _isLoading = true;
      notifyListeners();

      QuerySnapshot snapshot = await _firestore
          .collection('products')
          .orderBy('createdAt', descending: true)
          .get();

      _products = snapshot.docs
          .map(
              (doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      _categories = ['All'];
      Set<String> categorySet = _products.map((p) => p.category).toSet();
      _categories.addAll(categorySet.toList());

      _filteredProducts = _products;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error loading products: $e');
    }
  }

  void searchProducts(String query) {
    _searchQuery = query;
    _filterProducts();
  }

  void filterByCategory(String category) {
    _selectedCategory = category;
    _filterProducts();
  }

  void _filterProducts() {
    _filteredProducts = _products.where((product) {
      // Search filter
      bool matchesSearch = _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.description
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());

      // Category filter
      bool matchesCategory =
          _selectedCategory == 'All' || product.category == _selectedCategory;

      // Price filter
      bool matchesPrice =
          product.price >= _minPrice && product.price <= _maxPrice;

      // Organic filter
      bool matchesOrganic = !_organicFilter || product.isOrganic;

      // Stock filter
      bool matchesStock = !_inStockFilter || product.stock > 0;

      return matchesSearch &&
          matchesCategory &&
          matchesPrice &&
          matchesOrganic &&
          matchesStock;
    }).toList();

    // Apply sorting
    switch (_sortBy) {
      case 'price_low':
        _filteredProducts.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high':
        _filteredProducts.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'rating':
        _filteredProducts.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'newest':
        _filteredProducts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'name':
      default:
        _filteredProducts.sort((a, b) => a.name.compareTo(b.name));
        break;
    }

    notifyListeners();
  }

  void applyFilters({
    double? minPrice,
    double? maxPrice,
    bool organicOnly = false,
    bool inStockOnly = false,
    String sortBy = 'name',
  }) {
    _minPrice = minPrice ?? 0;
    _maxPrice = maxPrice ?? 1000;
    _organicFilter = organicOnly;
    _inStockFilter = inStockOnly;
    _sortBy = sortBy;

    _filterProducts();
  }

  void clearFilters() {
    _minPrice = 0;
    _maxPrice = 1000;
    _organicFilter = false;
    _inStockFilter = false;
    _sortBy = 'name';
    _searchQuery = '';
    _selectedCategory = 'All';

    _filterProducts();
  }

  ProductModel? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }
}
