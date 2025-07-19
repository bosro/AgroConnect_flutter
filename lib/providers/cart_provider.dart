import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';

class CartProvider with ChangeNotifier {
  List<CartItemModel> _items = [];

  List<CartItemModel> get items => _items;
  int get itemCount => _items.length;
  
  double get totalAmount {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  void addToCart(ProductModel product, int quantity) {
    final existingIndex = _items.indexWhere(
      (item) => item.productId == product.id,
    );

    if (existingIndex >= 0) {
      _items[existingIndex] = CartItemModel(
        id: _items[existingIndex].id,
        productId: product.id,
        productName: product.name,
        productImage: product.images.isNotEmpty ? product.images.first : '',
        price: product.price,
        quantity: _items[existingIndex].quantity + quantity,
        unit: product.unit,
      );
    } else {
      _items.add(CartItemModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: product.id,
        productName: product.name,
        productImage: product.images.isNotEmpty ? product.images.first : '',
        price: product.price,
        quantity: quantity,
        unit: product.unit,
      ));
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _items.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    final index = _items.indexWhere((item) => item.productId == productId);
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index] = CartItemModel(
          id: _items[index].id,
          productId: _items[index].productId,
          productName: _items[index].productName,
          productImage: _items[index].productImage,
          price: _items[index].price,
          quantity: quantity,
          unit: _items[index].unit,
        );
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  int getQuantity(String productId) {
    final item = _items.firstWhere(
      (item) => item.productId == productId,
      orElse: () => CartItemModel(
        id: '',
        productId: '',
        productName: '',
        productImage: '',
        price: 0,
        quantity: 0,
        unit: '',
      ),
    );
    return item.quantity;
  }
}