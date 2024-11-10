import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../entities/Shop/Cart.dart';
import '../../entities/Shop/Product.dart';

class CartProvider extends ChangeNotifier {
  final Cart _cart = Cart();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _cartId = 'global_cart'; // You might want to replace this with a user-specific ID later

  Cart get cart => _cart;

  CartProvider() {
    _initCart();
  }

  Future<void> _initCart() async {
    await _fetchCartFromFirestore();
    _subscribeToCartUpdates();
  }

  Future<void> _fetchCartFromFirestore() async {
    try {
      DocumentSnapshot cartDoc = await _firestore.collection('carts').doc(_cartId).get();
      if (cartDoc.exists) {
        Map<String, dynamic> cartData = cartDoc.data() as Map<String, dynamic>;
        List<dynamic> items = cartData['items'] ?? [];
        for (var item in items) {
          Product product = Product.fromFirestore(
              DocumentSnapshot.fromMap(item['product'], item['product']['id'])
          );
          _cart.addItem(product, item['quantity']);
        }
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching cart from Firestore: $e');
    }
  }

  void _subscribeToCartUpdates() {
    _firestore.collection('carts').doc(_cartId).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic> cartData = snapshot.data() as Map<String, dynamic>;
        List<dynamic> items = cartData['items'] ?? [];
        _cart.clear();
        for (var item in items) {
          Product product = Product.fromFirestore(
              DocumentSnapshot.fromMap(item['product'], item['product']['id'])
          );
          _cart.addItem(product, item['quantity']);
        }
        notifyListeners();
      }
    });
  }

  Future<void> _updateFirestore() async {
    try {
      await _firestore.collection('carts').doc(_cartId).set({
        'items': _cart.items.map((item) => {
          'product': item.product.toFirestore(),
          'quantity': item.quantity,
        }).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating Firestore: $e');
    }
  }

  Future<void> addToCart(Product product, {int quantity = 1}) async {
    _cart.addItem(product, quantity);
    await _updateFirestore();
    notifyListeners();
  }

  Future<void> removeFromCart(String productId) async {
    _cart.removeItem(productId);
    await _updateFirestore();
    notifyListeners();
  }

  Future<void> updateQuantity(String productId, int newQuantity) async {
    _cart.updateQuantity(productId, newQuantity);
    await _updateFirestore();
    notifyListeners();
  }

  Future<void> clearCart() async {
    _cart.clear();
    await _updateFirestore();
    notifyListeners();
  }

  double get totalPrice => _cart.totalPrice;
  int get itemCount => _cart.itemCount;
}