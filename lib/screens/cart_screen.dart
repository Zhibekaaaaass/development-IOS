import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Future<void> _confirmClear(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear bag?'),
        content: const Text('All items will be removed from your bag.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('CLEAR ALL'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      context.read<CartProvider>().clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final items = cart.items;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text(
          'YOUR BAG',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.3,
          ),
        ),
        actions: [
          if (items.isNotEmpty)
            TextButton.icon(
              onPressed: () => _confirmClear(context),
              icon: const Icon(Icons.delete_sweep_outlined),
              label: const Text('CLEAR ALL'),
              style: TextButton.styleFrom(foregroundColor: Colors.black),
            ),
        ],
      ),
      body: items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.shopping_bag_outlined,
                      size: 58,
                      color: Colors.black38,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Your bag is empty',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Add a sneaker from the store to see it here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54, height: 1.5),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('CONTINUE SHOPPING'),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(18),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 13),
              itemBuilder: (context, index) {
                final item = items[index];
                final product = item.product;

                return Container(
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
                            Row(
                              children: [
                                _QuantityButton(
                                  icon: Icons.remove,
                                  onTap: () => context
                                      .read<CartProvider>()
                                      .changeQuantity(product.id, -1),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 13,
                                  ),
                                  child: Text(
                                    '${item.quantity}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                _QuantityButton(
                                  icon: Icons.add,
                                  onTap: () => context
                                      .read<CartProvider>()
                                      .changeQuantity(product.id, 1),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 5),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${(product.price * item.quantity).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          IconButton(
                            tooltip: 'Remove',
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              final provider = context.read<CartProvider>();
                              final quantity = item.quantity;
                              provider.remove(product.id);
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  SnackBar(
                                    content: Text('${product.name} removed'),
                                    action: SnackBarAction(
                                      label: 'UNDO',
                                      onPressed: () =>
                                          provider.restore(product, quantity),
                                    ),
                                  ),
                                );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: items.isEmpty
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(18, 12, 18, 16),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'ITEMS',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 11,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        Text(
                          '${cart.count}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'TOTAL',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Text(
                          '\$${cart.totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          showDialog<void>(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              title: const Text('Demo checkout'),
                              content: const Text(
                                'Your bag is ready. Real payment '
                                'is not connected in this milestone.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(dialogContext),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                        child: const Text(
                          'CONTINUE TO CHECKOUT',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 29,
      height: 29,
      child: Material(
        color: const Color(0xFFF0F0ED),
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(9),
          child: Icon(icon, size: 16),
        ),
      ),
    );
  }
}