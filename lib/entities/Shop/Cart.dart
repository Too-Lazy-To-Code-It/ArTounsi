import 'Product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class Cart {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  void addItem(Product product, [int quantity = 1]) {
    final existingItemIndex = _items.indexWhere((item) => item.product.id == product.id);

    if (existingItemIndex != -1) {
      _items[existingItemIndex].quantity += quantity;
    } else {
      _items.add(CartItem(product: product, quantity: quantity));
    }
  }

  void removeItem(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
  }

  void updateQuantity(String productId, int newQuantity) {
    final itemIndex = _items.indexWhere((item) => item.product.id == productId);
    if (itemIndex != -1) {
      if (newQuantity > 0) {
        _items[itemIndex].quantity = newQuantity;
      } else {
        removeItem(productId);
      }
    }
  }

  double get totalPrice {
    return _items.fold(0, (total, item) => total + (item.product.price * item.quantity));
  }

  int get itemCount {
    return _items.fold(0, (total, item) => total + item.quantity);
  }

  void clear() {
    _items.clear();
  }
}