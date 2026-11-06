import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/cart_provider.dart';
import 'cart_screen.dart';

class CatalogScreen extends StatelessWidget {
  final List<Product> products;
  final ValueChanged<Product> onProductTap;

  const CatalogScreen({
    super.key,
    required this.products,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SNEAKER STORE',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.3,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Open bag',
            icon: Badge(
              label: Text('${cart.count}'),
              isLabelVisible: cart.count > 0,
              child: const Icon(Icons.shopping_bag_outlined, size: 26),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const CartScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(18),
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(height: 13),
        itemBuilder: (context, index) {
          final product = products[index];
          final inCart = cart.contains(product.id);

          return InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => onProductTap(product),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: Image.network(
                      product.imageUrl,
                      width: 85,
                      height: 85,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox(
                        width: 85,
                        height: 85,
                        child: Icon(Icons.image_not_supported_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.category.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 9,
                            letterSpacing: 1,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 34,
                          child: inCart
                              ? OutlinedButton.icon(
                                  onPressed: () => context
                                      .read<CartProvider>()
                                      .toggle(product),
                                  icon: const Icon(Icons.check, size: 16),
                                  label: const Text('IN BAG · REMOVE'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.black,
                                    textStyle: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                )
                              : ElevatedButton.icon(
                                  onPressed: () => context
                                      .read<CartProvider>()
                                      .toggle(product),
                                  icon: const Icon(
                                    Icons.add_shopping_cart,
                                    size: 16,
                                  ),
                                  label: const Text('ADD TO CART'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    textStyle: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(18, 8, 18, 14),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${cart.count} IN BAG',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      '\$${cart.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}