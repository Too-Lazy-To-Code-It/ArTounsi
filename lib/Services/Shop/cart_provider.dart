import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../entities/Shop/Cart.dart';
import '../../entities/Shop/Product.dart';

class CartProvider extends ChangeNotifier {
  Cart _cart = Cart();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = true;
  String? _userId;

  CartProvider() {
    _initCart();
  }

  Cart get cart => _cart;
  bool get isLoading => _isLoading;

  Future<void> _initCart() async {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _userId = user.uid;
        _fetchCartFromFirestore();
      } else {
        _userId = null;
        _clearLocalCart();
      }
    });
  }

  Future<void> _fetchCartFromFirestore() async {
    if (_userId == null) {
      print('No user logged in');
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      print('Fetching cart for user: $_userId');
      DocumentSnapshot<Map<String, dynamic>> cartDoc = await _firestore.collection('carts').doc(_userId).get();
      if (cartDoc.exists && cartDoc.data() != null) {
        print('Cart document exists in Firestore');
        _updateCartFromData(cartDoc.data()!);
      } else {
        print('Cart document does not exist in Firestore');
        await _createCartInFirestore();
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error fetching cart from Firestore: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _createCartInFirestore() async {
    if (_userId == null) return;

    try {
      await _firestore.collection('carts').doc(_userId).set({
        'items': [],
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('Created new cart in Firestore for user: $_userId');
    } catch (e) {
      print('Error creating cart in Firestore: $e');
    }
  }

  void _updateCartFromData(Map<String, dynamic> cartData) {
    List<dynamic> items = cartData['items'] ?? [];
    _cart = Cart(); // Create a new Cart instance
    print('Updating cart from Firestore data...');
    print('Number of items in Firestore: ${items.length}');
    for (var item in items) {
      if (item is Map<String, dynamic> && item.containsKey('product') && item.containsKey('quantity')) {
        print('Processing item: $item');
        Product product = Product.fromMap(item['product']);
        int quantity = item['quantity'];
        print('Adding to cart: ${product.name}, quantity: $quantity');
        _cart.addItem(product, quantity);
      } else {
        print('Invalid item format: $item');
      }
    }
    print('Updated cart items: ${_cart.itemCount}');
    notifyListeners();
  }

  Future<void> _updateFirestore() async {
    if (_userId == null) return;

    try {
      print('Updating cart in Firestore for user: $_userId');
      await _firestore.collection('carts').doc(_userId).set({
        'items': _cart.items.map((item) => {
          'product': item.product.toFirestore(),
          'quantity': item.quantity,
        }).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('Cart updated in Firestore');
    } catch (e) {
      print('Error updating Firestore: $e');
    }
  }

  void _clearLocalCart() {
    _cart = Cart(); // Create a new empty Cart instance
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addToCart(Product product, {int quantity = 1}) async {
    if (_userId == null) {
      print('Cannot add product to cart: User not logged in');
      return;
    }

    print('Adding product to cart: ${product.id}, quantity: $quantity');
    _cart.addItem(product, quantity);
    await _updateFirestore();
    notifyListeners();
  }

  Future<void> removeFromCart(String productId) async {
    if (_userId == null) {
      print('Cannot remove product from cart: User not logged in');
      return;
    }

    print('Removing product from cart: $productId');
    _cart.removeItem(productId);
    await _updateFirestore();
    notifyListeners();
  }

  Future<void> updateQuantity(String productId, int newQuantity) async {
    if (_userId == null) {
      print('Cannot update quantity: User not logged in');
      return;
    }

    print('Updating quantity for product: $productId, new quantity: $newQuantity');
    _cart.updateQuantity(productId, newQuantity);
    await _updateFirestore();
    notifyListeners();
  }

  Future<void> clearCart() async {
    if (_userId == null) {
      print('Cannot clear cart: User not logged in');
      return;
    }

    print('Clearing cart');
    _cart.clear();
    await _updateFirestore();
    notifyListeners();
  }

  double get totalPrice => _cart.totalPrice;
  int get itemCount => _cart.itemCount;
}