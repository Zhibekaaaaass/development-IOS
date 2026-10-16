
class Product {
  final int id;
  final String name;
  final String imageUrl;
  final double price;
  final double oldPrice;
  final double rating;
  final String category;
  final String description;

  const Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.oldPrice,
    required this.rating,
    required this.category,
    required this.description,
  });
}
