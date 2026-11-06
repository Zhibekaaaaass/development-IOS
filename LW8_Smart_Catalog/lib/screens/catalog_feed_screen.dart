import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/dismiss_background.dart';
import '../widgets/empty_state.dart';
import '../widgets/product_grid_card.dart';
import '../widgets/product_list_tile.dart';

class CatalogFeedScreen extends StatefulWidget {
  const CatalogFeedScreen({super.key});

  @override
  State<CatalogFeedScreen> createState() => _CatalogFeedScreenState();
}

class _CatalogFeedScreenState extends State<CatalogFeedScreen> {
  late List<Product> _products;
  int _currentViewIndex = 0;
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    _products = seedProducts();
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    _counter++;
    final newProduct = Product(
      id: 'new_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Fresh Gadget #$_counter',
      category: 'New Arrivals',
      price: 149.0 + _counter * 10,
      rating: 5.0,
      reviewsCount: 1,
      icon: Icons.fiber_new,
      badgeColor: Colors.green,
    );
    setState(() {
      _products.insert(0, newProduct);
    });
  }

  void _removeProduct(Product product) {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index == -1) return;
    setState(() {
      _products.removeAt(index);
    });

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text('Removed "${product.title}"'),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () {
              final safeIndex = index > _products.length ? _products.length : index;
              setState(() {
                _products.insert(safeIndex, product);
              });
            },
          ),
        ),
      );
  }

  void _resetCatalog() {
    setState(() {
      _products = seedProducts();
    });
  }

  Widget _dismissible(Product product, Widget child) {
    return Dismissible(
      key: ValueKey(product.id),
      direction: DismissDirection.endToStart,
      background: const DismissBackground(),
      onDismissed: (_) => _removeProduct(product),
      child: child,
    );
  }

  Widget _buildList() {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _products.length,
      separatorBuilder: (context, index) => const Divider(height: 1, thickness: 0.5),
      itemBuilder: (context, index) {
        final product = _products[index];
        return _dismissible(product, ProductListTile(product: product));
      },
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return _dismissible(product, ProductGridCard(product: product));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isList = _currentViewIndex == 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Smart Catalog (${_products.length})'),
        actions: [
          IconButton(
            tooltip: isList ? 'Switch to Grid' : 'Switch to List',
            icon: Icon(isList ? Icons.grid_view : Icons.view_list),
            onPressed: () => setState(() => _currentViewIndex = isList ? 1 : 0),
          ),
        ],
      ),
      body: _products.isEmpty
          ? EmptyState(onReset: _resetCatalog)
          : RefreshIndicator(
              onRefresh: _onRefresh,
              child: isList ? _buildList() : _buildGrid(),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentViewIndex,
        onDestinationSelected: (i) => setState(() => _currentViewIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.list_alt), label: 'List Feed'),
          NavigationDestination(icon: Icon(Icons.grid_on), label: 'Grid Catalog'),
        ],
      ),
    );
  }
}
