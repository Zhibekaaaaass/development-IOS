import 'package:flutter/foundation.dart';

import '../models/product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem(this.product, this.quantity);
}

class CartProvider extends ChangeNotifier {
  final Map<int, CartItem> _items = <int, CartItem>{};

  List<CartItem> get items => _items.values.toList();

  bool get isEmpty => _items.isEmpty;

  int get count => _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => _items.values
      .fold(0.0, (sum, item) => sum + item.product.price * item.quantity);

  bool contains(int productId) => _items.containsKey(productId);

  void add(Product product) {
    final existing = _items[product.id];
    if (existing == null) {
      _items[product.id] = CartItem(product, 1);
    } else {
      existing.quantity++;
    }
    notifyListeners();
  }

  void toggle(Product product) {
    if (_items.containsKey(product.id)) {
      _items.remove(product.id);
    } else {
      _items[product.id] = CartItem(product, 1);
    }
    notifyListeners();
  }

  void changeQuantity(int productId, int change) {
    final item = _items[productId];
    if (item == null) return;
    item.quantity += change;
    if (item.quantity <= 0) {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void remove(int productId) {
    if (_items.remove(productId) != null) {
      notifyListeners();
    }
  }

  void restore(Product product, int quantity) {
    _items[product.id] = CartItem(product, quantity);
    notifyListeners();
  }

  void clear() {
    if (_items.isEmpty) return;
    _items.clear();
    notifyListeners();
  }
}