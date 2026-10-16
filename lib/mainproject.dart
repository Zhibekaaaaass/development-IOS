
import 'package:flutter/material.dart';

import 'models/product.dart';
import 'screens/root_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/cart_screen.dart';

final GlobalKey<NavigatorState> navigatorKey =
    GlobalKey<NavigatorState>();

void main() {
  runApp(const SneakerStoreApp());
}

class SneakerStoreApp extends StatefulWidget {
  const SneakerStoreApp({super.key});

  @override
  State<SneakerStoreApp> createState() =>
      _SneakerStoreAppState();
}

class _SneakerStoreAppState extends State<SneakerStoreApp> {
  // Products saved to Favorites.
  final Set<int> _favoriteIds = <int>{};

  // Product ID -> quantity in cart.
  final Map<int, int> _cart = <int, int>{};

  // Products available in the store.
  final List<Product> _products = const [
    Product(
      id: 1,
      name: 'Air Max',
      imageUrl:
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=1000',
      price: 129.99,
      oldPrice: 159.99,
      rating: 4.8,
      category: 'Running',
      description:
          'A bold everyday running sneaker with a cushioned feel '
          'and a confident sporty look. Designed for everyday '
          'movement and comfort.',
    ),
    Product(
      id: 2,
      name: 'Classic White',
      imageUrl:
          'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=1000',
      price: 89.99,
      oldPrice: 109.99,
      rating: 4.7,
      category: 'Lifestyle',
      description:
          'A clean classic sneaker that fits naturally into your '
          'everyday wardrobe. Easy to style, comfortable to wear, '
          'and timeless in design.',
    ),
    Product(
      id: 3,
      name: 'Sport Runner',
      imageUrl:
          'https://images.unsplash.com/photo-1460353581641-37baddab0fa2?w=1000',
      price: 99.99,
      oldPrice: 119.99,
      rating: 4.6,
      category: 'Sportswear',
      description:
          'A sporty lightweight silhouette for active days. '
          'Pair it with casual clothes or your training essentials.',
    ),
    Product(
      id: 4,
      name: 'Street Style',
      imageUrl:
          'https://images.unsplash.com/photo-1552346154-21d32810aba3?w=1000',
      price: 119.99,
      oldPrice: 139.99,
      rating: 4.9,
      category: 'Streetwear',
      description:
          'Modern streetwear sneakers with a distinctive profile. '
          'Made to stand out while staying versatile enough '
          'for daily wear.',
    ),
    Product(
      id: 5,
      name: 'Mono Low',
      imageUrl:
          'https://images.unsplash.com/photo-1525966222134-fcfa99b8ae77?w=1000',
      price: 114.99,
      oldPrice: 134.99,
      rating: 4.8,
      category: 'Lifestyle',
      description:
          'Minimal low-top sneakers with understated details '
          'and a monochrome finish. An easy everyday essential.',
    ),
    Product(
      id: 6,
      name: 'Cloud Step',
      imageUrl:
          'https://images.unsplash.com/photo-1495555961986-6d4c1ecb7be3?w=1000',
      price: 94.99,
      oldPrice: 114.99,
      rating: 4.5,
      category: 'Running',
      description:
          'Comfort-first sneakers with a sporty look, ideal for '
          'busy days and relaxed weekend plans.',
    ),
  ];

  // Total quantity of all products in the cart.
  int get _cartCount {
    return _cart.values.fold(
      0,
      (sum, quantity) => sum + quantity,
    );
  }

  // Add a product to Favorites or remove it.
  void _toggleFavorite(int id) {
    setState(() {
      if (!_favoriteIds.add(id)) {
        _favoriteIds.remove(id);
      }
    });
  }

  // Add a product to the cart.
  void _addToCart(Product product) {
    setState(() {
      _cart.update(
        product.id,
        (quantity) => quantity + 1,
        ifAbsent: () => 1,
      );
    });

    ScaffoldMessenger.of(
      navigatorKey.currentContext!,
    ).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to bag'),
        action: SnackBarAction(
          label: 'VIEW BAG',
          onPressed: _openCart,
        ),
      ),
    );
  }

  // Increase or decrease product quantity in the cart.
  void _changeQuantity(int productId, int change) {
    setState(() {
      final current = _cart[productId] ?? 0;
      final next = current + change;

      if (next <= 0) {
        _cart.remove(productId);
      } else {
        _cart[productId] = next;
      }
    });
  }

  // Open the cart screen.
  void _openCart() {
    navigatorKey.currentState?.push(
      MaterialPageRoute<void>(
        builder: (_) => CartScreen(
          products: _products,
          quantities: Map<int, int>.from(_cart),
          onChangeQuantity: _changeQuantity,
        ),
      ),
    );
  }

  // Open product details and pass the complete Product object.
  void _openProduct(Product product) {
    navigatorKey.currentState?.push(
      MaterialPageRoute<void>(
        builder: (_) => ProductDetailScreen(
          product: product,
          initiallyFavorite: _favoriteIds.contains(product.id),
          onToggleFavorite: () => _toggleFavorite(product.id),
          onAddToCart: () => _addToCart(product),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Sneaker Store',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F7F5),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF7F7F5),
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      home: StoreRootScreen(
        products: _products,
        favoriteIds: _favoriteIds,
        cartCount: _cartCount,
        onToggleFavorite: _toggleFavorite,
        onOpenCart: _openCart,
        onProductTap: _openProduct,
      ),
    );
  }
}
