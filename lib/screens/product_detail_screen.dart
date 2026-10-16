
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/category_badge.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final bool initiallyFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onAddToCart;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.initiallyFavorite,
    required this.onToggleFavorite,
    required this.onAddToCart,
  });

  @override
  State<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState
    extends State<ProductDetailScreen> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.initiallyFavorite;
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final wide = MediaQuery.sizeOf(context).width >= 850;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text(
          'PRODUCT DETAILS',
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: _isFavorite
                ? 'Remove favorite'
                : 'Add favorite',
            onPressed: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
              widget.onToggleFavorite();
            },
            icon: Icon(
              _isFavorite
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: _isFavorite ? Colors.red : Colors.black,
            ),
          ),
        ],
      ),
      body: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _productImage(product)),
                Expanded(
                  child: SingleChildScrollView(
                    child: _details(product, true),
                  ),
                ),
              ],
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _productImage(product),
                  const SizedBox(height: 22),
                  _details(product, false),
                ],
              ),
            ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(18, 8, 18, 13),
        child: SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: widget.onAddToCart,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.shopping_bag_outlined,
                  size: 19,
                ),
                const SizedBox(width: 9),
                const Text(
                  'ADD TO BAG',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '· \$${product.price.toStringAsFixed(2)}',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _productImage(Product product) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child: AspectRatio(
          aspectRatio: 1.05,
          child: Hero(
            tag: 'product-${product.id}',
            child: Image.network(
              product.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const ColoredBox(
                  color: Color(0xFFECECE9),
                  child: Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      size: 54,
                    ),
                  ),
                );
              },
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const ColoredBox(
                  color: Color(0xFFECECE9),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Colors.black,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _details(Product product, bool wide) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        wide ? 28 : 2,
        12,
        wide ? 28 : 2,
        28,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CategoryBadge(
            label: product.category.toUpperCase(),
          ),
          const SizedBox(height: 14),
          Text(
            product.name,
            style: TextStyle(
              fontSize: wide ? 34 : 30,
              height: 1.1,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.star_rounded, size: 19),
              const SizedBox(width: 5),
              Text(
                '${product.rating.toStringAsFixed(1)} / 5.0',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '· Customer rating',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '\$${product.oldPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black45,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'ABOUT THIS PAIR',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            product.description,
            style: const TextStyle(
              fontSize: 14,
              height: 1.7,
              color: Color(0xFF555550),
            ),
          ),
          const SizedBox(height: 23),
          const Divider(color: Color(0xFFE4E4E0)),
          const SizedBox(height: 15),
          const Row(
            children: [
              Icon(Icons.local_shipping_outlined, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Standard delivery available',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Row(
            children: [
              Icon(Icons.replay_rounded, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Easy returns within 14 days',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          // Новая кнопка возврата
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('BACK TO STORE'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
