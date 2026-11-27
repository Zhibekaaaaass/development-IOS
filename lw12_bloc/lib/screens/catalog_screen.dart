import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_cubit.dart';
import '../blocs/auth/auth_state.dart';
import '../models/product.dart';
import '../widgets/product_tile.dart';
import '../widgets/cart_badge_button.dart';
import 'cart_screen.dart';
import 'login_screen.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  static const List<Product> _catalogProducts = [
    Product(id: '1', title: 'MacBook Pro M3 Max 16"', price: 3499, icon: Icons.laptop_mac),
    Product(id: '2', title: 'iPhone 16 Pro Titanium', price: 1299, icon: Icons.smartphone),
    Product(id: '3', title: 'Sony WH-1000XM5 ANC', price: 399, icon: Icons.headphones),
    Product(id: '4', title: 'Apple Watch Ultra 2 GPS', price: 799, icon: Icons.watch),
    Product(id: '5', title: 'iPad Pro 13" M4 OLED', price: 1299, icon: Icons.tablet_mac),
  ];

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final username = authState is AuthSuccess ? authState.username : 'User';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enterprise Store', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Welcome, $username', style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          CartBadgeButton(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              context.read<AuthCubit>().logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _catalogProducts.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          return ProductTile(product: _catalogProducts[index]);
        },
      ),
    );
  }
}
