import 'package:flutter/material.dart';

import '../../entities/Shop/Cart.dart';
import '../../entities/Shop/Product.dart';

class CartProvider extends ChangeNotifier {
  final Cart _cart = Cart();

  Cart get cart => _cart;

  void addToCart(Product product) {
    _cart.addItem(product);
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _cart.removeItem(productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int newQuantity) {
    _cart.updateQuantity(productId, newQuantity);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }
}
