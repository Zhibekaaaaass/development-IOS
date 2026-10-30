import 'package:flutter/material.dart';

class Product {
  final String id;
  final String title;
  final String category;
  final double price;
  final double rating;
  final int reviewsCount;
  final IconData icon;
  final Color badgeColor;

  const Product({
    required this.id,
    required this.title,
    required this.category,
    required this.price,
    required this.rating,
    required this.reviewsCount,
    required this.icon,
    required this.badgeColor,
  });
}

List<Product> seedProducts() {
  return const [
    Product(
      id: 'p1',
      title: 'MacBook Pro 16" M3 Max',
      category: 'Laptops',
      price: 3499,
      rating: 4.9,
      reviewsCount: 142,
      icon: Icons.laptop_mac,
      badgeColor: Colors.blueAccent,
    ),
    Product(
      id: 'p2',
      title: 'iPhone 16 Pro Max 512GB',
      category: 'Smartphones',
      price: 1399,
      rating: 4.8,
      reviewsCount: 320,
      icon: Icons.smartphone,
      badgeColor: Colors.deepPurple,
    ),
    Product(
      id: 'p3',
      title: 'Sony WH-1000XM5 Wireless',
      category: 'Audio',
      price: 399,
      rating: 4.7,
      reviewsCount: 89,
      icon: Icons.headphones,
      badgeColor: Colors.teal,
    ),
    Product(
      id: 'p4',
      title: 'iPad Pro 13" M4',
      category: 'Tablets',
      price: 1299,
      rating: 4.9,
      reviewsCount: 95,
      icon: Icons.tablet_mac,
      badgeColor: Colors.indigo,
    ),
    Product(
      id: 'p5',
      title: 'Apple Watch Ultra 2',
      category: 'Wearables',
      price: 799,
      rating: 4.8,
      reviewsCount: 210,
      icon: Icons.watch,
      badgeColor: Colors.orange,
    ),
    Product(
      id: 'p6',
      title: 'Keychron Q1 Pro Keyboard',
      category: 'Peripherals',
      price: 199,
      rating: 4.6,
      reviewsCount: 54,
      icon: Icons.keyboard,
      badgeColor: Colors.brown,
    ),
    Product(
      id: 'p7',
      title: 'Logitech MX Master 3S',
      category: 'Peripherals',
      price: 99,
      rating: 4.8,
      reviewsCount: 412,
      icon: Icons.mouse,
      badgeColor: Colors.blueGrey,
    ),
    Product(
      id: 'p8',
      title: 'Dell UltraSharp 32" 4K',
      category: 'Monitors',
      price: 899,
      rating: 4.7,
      reviewsCount: 78,
      icon: Icons.tv,
      badgeColor: Colors.cyan,
    ),
  ];
}
