import 'Product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class Cart {
  List<CartItem> items = [];

  void addItem(Product product) {
    final existingItemIndex = items.indexWhere((item) => item.product.id == product.id);

    if (existingItemIndex != -1) {
      items[existingItemIndex].quantity++;
    } else {
      items.add(CartItem(product: product, quantity: 1));
    }
  }

  void removeItem(String productId) {
    items.removeWhere((item) => item.product.id == productId);
  }

  void updateQuantity(String productId, int newQuantity) {
    final itemIndex = items.indexWhere((item) => item.product.id == productId);
    if (itemIndex != -1) {
      if (newQuantity > 0) {
        items[itemIndex].quantity = newQuantity;
      } else {
        removeItem(productId);
      }
    }
  }

  double get totalPrice {
    return items.fold(0, (total, item) => total + (item.product.price * item.quantity));
  }

  int get itemCount {
    return items.fold(0, (total, item) => total + item.quantity);
  }

  void clear() {
    items.clear();
  }
}