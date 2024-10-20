class Product {
  final String id;
  final String name;
  final double price;
  final String artist;
  final String imagePath;
  final List<String> categories;
  final double rating;
  final int reviewCount;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.artist,
    required this.imagePath,
    required this.categories,
    required this.rating,
    required this.reviewCount,
  });

  @override
  String toString() {
    return 'Product{id: $id, name: $name, price: $price, artist: $artist, imagePath: $imagePath, categories: $categories, rating: $rating, reviewCount: $reviewCount}';
  }
}