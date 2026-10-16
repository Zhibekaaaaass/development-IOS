
import 'package:flutter/material.dart';

import '../models/product.dart';
import '../widgets/product_card.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

class StoreRootScreen extends StatefulWidget {
  final List<Product> products;
  final Set<int> favoriteIds;
  final int cartCount;
  final ValueChanged<int> onToggleFavorite;
  final ValueChanged<Product> onProductTap;
  final VoidCallback onOpenCart;

  const StoreRootScreen({
    super.key,
    required this.products,
    required this.favoriteIds,
    required this.cartCount,
    required this.onToggleFavorite,
    required this.onProductTap,
    required this.onOpenCart,
  });

  @override
  State<StoreRootScreen> createState() => _StoreRootScreenState();
}

class _StoreRootScreenState extends State<StoreRootScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final favoriteProducts = widget.products
        .where((product) =>
            widget.favoriteIds.contains(product.id))
        .toList();

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomeScreen(
            products: widget.products,
            favoriteIds: widget.favoriteIds,
            cartCount: widget.cartCount,
            onToggleFavorite: widget.onToggleFavorite,
            onOpenCart: widget.onOpenCart,
            onProductTap: widget.onProductTap,
          ),

          Scaffold(
            appBar: AppBar(
              title: const Text(
                'FAVORITES',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.3,
                ),
              ),
            ),
            body: favoriteProducts.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.favorite_border,
                            size: 60,
                            color: Colors.black38,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No favorites yet',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tap the heart on a sneaker to save it here.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: favoriteProducts.length,
                   
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                     crossAxisCount: 2,
                     crossAxisSpacing: 10,
                     mainAxisSpacing: 10,
                    childAspectRatio: 0.9                    ),
                    itemBuilder: (context, index) {
                      final product = favoriteProducts[index];

                      return ProductCard(
                        product: product,
                        isFavorite:
                            widget.favoriteIds.contains(product.id),
                        onToggleFavorite: () {
                          widget.onToggleFavorite(product.id);
                        },
                        onTap: () {
                          widget.onProductTap(product);
                        },
                      );
                    },
                  ),
          ),

          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFE8E8E5),
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Feed',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
