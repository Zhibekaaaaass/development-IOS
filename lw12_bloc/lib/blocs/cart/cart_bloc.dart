import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/cart_item.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState()) {
    on<AddProductEvent>((event, emit) {
      final existingIndex = state.items.indexWhere(
        (item) => item.product.id == event.product.id,
      );

      List<CartItem> updatedItems = List.from(state.items);

      if (existingIndex >= 0) {
        final current = updatedItems[existingIndex];
        updatedItems[existingIndex] = current.copyWith(quantity: current.quantity + 1);
      } else {
        updatedItems.add(CartItem(product: event.product, quantity: 1));
      }

      emit(CartState(items: updatedItems));
    });

    on<DecrementProductEvent>((event, emit) {
      final existingIndex = state.items.indexWhere(
        (item) => item.product.id == event.productId,
      );

      if (existingIndex >= 0) {
        List<CartItem> updatedItems = List.from(state.items);
        final current = updatedItems[existingIndex];

        if (current.quantity > 1) {
          updatedItems[existingIndex] = current.copyWith(quantity: current.quantity - 1);
        } else {
          updatedItems.removeAt(existingIndex);
        }

        emit(CartState(items: updatedItems));
      }
    });

    on<RemoveProductEvent>((event, emit) {
      final updatedItems = state.items.where(
        (item) => item.product.id != event.productId,
      ).toList();

      emit(CartState(items: updatedItems));
    });

    on<ClearCartEvent>((event, emit) {
      emit(const CartState(items: []));
    });
  }
}
