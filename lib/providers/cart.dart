import 'package:flutter/foundation.dart';

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItem(
      {required this.id,
      required this.title,
      required this.quantity,
      required this.price});
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemsCount {
    return _items.length;
  }

  void addItem(String productId, double price, String title) {
    if (_items.containsKey(productId)) {
      _items.update(
          productId,
          (item) => CartItem(
              id: item.id,
              title: item.title,
              quantity: item.quantity + 1,
              price: item.price));
    } else {
      _items.putIfAbsent(
          productId,
          () => CartItem(
              id: DateTime.now().toString(),
              title: title,
              quantity: 1,
              price: price));
    }
    notifyListeners();
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, item) {
      total = total + item.price * item.quantity;
    });
    return total;
  }

  void removeItem(String itemId) {
    _items.remove(itemId);
    notifyListeners();
  }

  void clearCart() {
    _items = {};
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) {
      return;
    }
    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
        (product) => CartItem(
            id: product.id,
            title: product.title,
            quantity: product.quantity - 1,
            price: product.price),
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }
}
