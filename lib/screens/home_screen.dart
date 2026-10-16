
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/category_badge.dart';
import '../widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  final List<Product> products;
  final Set<int> favoriteIds;
  final int cartCount;
  final ValueChanged<int> onToggleFavorite;
  final ValueChanged<Product> onProductTap;
  final VoidCallback onOpenCart;

  const HomeScreen({
    super.key,
    required this.products,
    required this.favoriteIds,
    required this.cartCount,
    required this.onToggleFavorite,
    required this.onProductTap,
    required this.onOpenCart,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  String _selectedCategory = 'All';
  bool _favoritesOnly = false;

  List<String> get _categories => [
        'All',
        ...widget.products.map((p) => p.category).toSet(),
      ];

  List<Product> get _filteredProducts {
    final query = _searchController.text.trim().toLowerCase();

    return widget.products.where((product) {
      final categoryMatches = _selectedCategory == 'All' ||
          product.category == _selectedCategory;

      final searchMatches =
          product.name.toLowerCase().contains(query) ||
          product.category.toLowerCase().contains(query);

      final favoriteMatches =
          !_favoritesOnly || widget.favoriteIds.contains(product.id);

      return categoryMatches && searchMatches && favoriteMatches;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 1150
        ? 4
        : width >= 760
            ? 3
            : 2;

    final items = _filteredProducts;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SNEAKER STORE',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.3,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            tooltip: _favoritesOnly
                ? 'Show all products'
                : 'Show favorites',
            onPressed: () {
              setState(() {
                _favoritesOnly = !_favoritesOnly;
              });
            },
            icon: Icon(
              _favoritesOnly
                  ? Icons.favorite
                  : Icons.favorite_border,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 17),
            child: Center(
              child: Material(
                color: Colors.black,
                borderRadius: BorderRadius.circular(30),
                child: InkWell(
                  onTap: widget.onOpenCart,
                  borderRadius: BorderRadius.circular(30),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.shopping_bag_outlined,
                          color: Colors.white,
                          size: 17,
                        ),
                        const SizedBox(width: 7),
                        Text(
                          '${widget.cartCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'STEP INTO STYLE',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 2.2,
                        fontWeight: FontWeight.w800,
                        color: Colors.black45,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Find your next\nfavorite sneakers.',
                      style: TextStyle(
                        fontSize: 32,
                        height: 1.08,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.2,
                      ),
                    ),
                    const SizedBox(height: 19),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(21),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'NEW COLLECTION',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                    letterSpacing: 1.6,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 9),
                                Text(
                                  'Move your way.',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 23,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.directions_run_rounded,
                            color: Colors.white,
                            size: 38,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Popular sneakers',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        Text(
                          '${items.length} PRODUCTS',
                          style: const TextStyle(
                            fontSize: 10,
                            letterSpacing: 1,
                            color: Colors.black54,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Search sneakers...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isEmpty
                            ? null
                            : IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                                icon: const Icon(Icons.close),
                              ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 13),
                    SizedBox(
                      height: 42,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: _categories.map((category) {
                          return CategoryBadge(
                            label: category,
                            selected:
                                _selectedCategory == category,
                            onTap: () {
                              setState(() {
                                _selectedCategory = category;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 17),
                  ],
                ),
              ),
            ),
            if (items.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No products found. Try another search or filter.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = items[index];

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
                    childCount: items.length,
                  ),
                  gridDelegate:
                      SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 13,
                    mainAxisSpacing: 13,
                    childAspectRatio:
                        width < 420 ? 0.62 : width < 760 ? 0.68 : 0.78,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
