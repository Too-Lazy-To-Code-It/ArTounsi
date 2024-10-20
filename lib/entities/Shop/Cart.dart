import 'Product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class Cart {
  List<CartItem> items = [];

  void addItem(Product product) {
    final existingItem = items.firstWhere(
          (item) => item.product.id == product.id,
      orElse: () => CartItem(product: product, quantity: 0),
    );

    if (existingItem.quantity == 0) {
      items.add(existingItem);
    }
    existingItem.quantity++;
  }

  void removeItem(String productId) {
    items.removeWhere((item) => item.product.id == productId);
  }

  void updateQuantity(String productId, int newQuantity) {
    final item = items.firstWhere((item) => item.product.id == productId);
    item.quantity = newQuantity;
    if (item.quantity <= 0) {
      removeItem(productId);
    }
  }

  double get totalPrice {
    return items.fold(0, (total, item) => total + (item.product.price * item.quantity));
  }

  int get itemCount {
    return items.fold(0, (total, item) => total + item.quantity);
  }
}