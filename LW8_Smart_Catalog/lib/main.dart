import 'package:flutter/material.dart';
import 'screens/catalog_feed_screen.dart';

void main() {
  runApp(const NarxozStoreApp());
}

class NarxozStoreApp extends StatelessWidget {
  const NarxozStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Catalog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF02569B)),
      ),
      home: const CatalogFeedScreen(),
    );
  }
}
