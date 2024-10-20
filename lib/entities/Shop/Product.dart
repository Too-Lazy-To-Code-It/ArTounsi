enum ProductType { marketplace, prints }

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

  static List<Product> getProducts(ProductType type) {
    if (type == ProductType.marketplace) {
      return [
        Product(
          id: 'm1',
          name: 'Digital Artwork 1',
          price: 29.99,
          artist: 'John Doe',
          imagePath: 'assets/images/Shop/1.jpg',
          categories: ['Digital', 'Abstract'],
          rating: 4.5,
          reviewCount: 120,
        ),
        Product(
          id: 'm2',
          name: '3D Model Pack',
          price: 49.99,
          artist: 'Jane Smith',
          imagePath: 'assets/images/Shop/2.jpg',
          categories: ['3D', 'Characters'],
          rating: 4.2,
          reviewCount: 85,
        ),
      ];
    } else {
      return [
        Product(
          id: 'p1',
          name: 'Landscape Print',
          price: 24.99,
          artist: 'Emma Wilson',
          imagePath: 'assets/images/Shop/3.jpg',
          categories: ['Landscape', 'Nature'],
          rating: 4.7,
          reviewCount: 180,
        ),
        Product(
          id: 'p2',
          name: 'Portrait Print',
          price: 29.99,
          artist: 'Michael Lee',
          imagePath: 'assets/images/Shop/4.jpg',
          categories: ['Portrait', 'People'],
          rating: 4.5,
          reviewCount: 130,
        ),
      ];
    }
  }
}
