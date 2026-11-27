import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/cart/cart_bloc.dart';
import '../blocs/cart/cart_event.dart';
import '../blocs/cart/cart_state.dart';
import '../models/product.dart';

class ProductTile extends StatelessWidget {
  final Product product;

  const ProductTile({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        final quantity = state.getProductQuantity(product.id);
        final inCart = quantity > 0;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: inCart ? Colors.blue.shade100 : Colors.blue.shade50,
                  child: Icon(product.icon, color: Colors.blueAccent),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${product.price.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                if (inCart)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 18, color: Colors.blueAccent),
                          onPressed: () {
                            context.read<CartBloc>().add(DecrementProductEvent(product.id));
                          },
                        ),
                        Text(
                          '$quantity',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, size: 18, color: Colors.blueAccent),
                          onPressed: () {
                            context.read<CartBloc>().add(AddProductEvent(product));
                          },
                        ),
                      ],
                    ),
                  )
                else
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF02569B),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      context.read<CartBloc>().add(AddProductEvent(product));
                    },
                    icon: const Icon(Icons.add_shopping_cart, size: 16),
                    label: const Text('Add'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
