import 'package:equatable/equatable.dart';
import '../../models/cart_item.dart';

class CartState extends Equatable {
  final List<CartItem> items;

  const CartState({this.items = const []});

  int get count => items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => items.fold(0.0, (sum, item) => sum + item.subtotal);

  int getProductQuantity(String productId) {
    final found = items.where((i) => i.product.id == productId).toList();
    return found.isNotEmpty ? found.first.quantity : 0;
  }

  @override
  List<Object?> get props => [items];
}
