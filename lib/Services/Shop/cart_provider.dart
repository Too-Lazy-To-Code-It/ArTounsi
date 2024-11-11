import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../entities/Shop/Cart.dart';
import '../../entities/Shop/Product.dart';

class CartProvider extends ChangeNotifier {
  final Cart _cart = Cart();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = true;

  CartProvider() {
    _initCart();
  }

  Cart get cart => _cart;
  bool get isLoading => _isLoading;

  Future<void> _initCart() async {
    await _fetchCartFromFirestore();
    _subscribeToCartUpdates();
  }

  Future<void> _fetchCartFromFirestore() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        print('No user logged in');
        _isLoading = false;
        notifyListeners();
        return;
      }

      print('Fetching cart for user: ${user.uid}');
      DocumentSnapshot<Map<String, dynamic>> cartDoc = await _firestore.collection('carts').doc(user.uid).get();
      if (cartDoc.exists && cartDoc.data() != null) {
        print('Cart document exists in Firestore');
        _updateCartFromData(cartDoc.data()!);
      } else {
        print('Cart document does not exist in Firestore');
        await _createCartInFirestore(user.uid);
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error fetching cart from Firestore: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _createCartInFirestore(String userId) async {
    try {
      await _firestore.collection('carts').doc(userId).set({
        'items': [],
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('Created new cart in Firestore for user: $userId');
    } catch (e) {
      print('Error creating cart in Firestore: $e');
    }
  }

  void _subscribeToCartUpdates() {
    User? user = _auth.currentUser;
    if (user == null) return;

    print('Subscribing to cart updates for user: ${user.uid}');
    _firestore.collection('carts').doc(user.uid).snapshots().listen((DocumentSnapshot<Map<String, dynamic>> snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        print('Received cart update from Firestore');
        _updateCartFromData(snapshot.data()!);
        notifyListeners();
      }
    }, onError: (error) {
      print('Error in cart subscription: $error');
    });
  }

  void _updateCartFromData(Map<String, dynamic> cartData) {
    List<dynamic> items = cartData['items'] ?? [];
    _cart.clear();
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
  }

  Future<void> _updateFirestore() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return;

      print('Updating cart in Firestore for user: ${user.uid}');
      await _firestore.collection('carts').doc(user.uid).set({
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

  Future<void> addToCart(Product product, {int quantity = 1}) async {
    print('Adding product to cart: ${product.id}, quantity: $quantity');
    _cart.addItem(product, quantity);
    await _updateFirestore();
    notifyListeners();
  }

  Future<void> removeFromCart(String productId) async {
    print('Removing product from cart: $productId');
    _cart.removeItem(productId);
    await _updateFirestore();
    notifyListeners();
  }

  Future<void> updateQuantity(String productId, int newQuantity) async {
    print('Updating quantity for product: $productId, new quantity: $newQuantity');
    _cart.updateQuantity(productId, newQuantity);
    await _updateFirestore();
    notifyListeners();
  }

  Future<void> clearCart() async {
    print('Clearing cart');
    _cart.clear();
    await _updateFirestore();
    notifyListeners();
  }

  double get totalPrice => _cart.totalPrice;
  int get itemCount => _cart.itemCount;
}