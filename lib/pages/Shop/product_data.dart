enum ProductType { marketplace, prints }

class Product {
  final String name;
  final double price;
  final String artist;
  final String imagePath;
  final List<String> categories;
  final double rating;
  final int reviewCount;

  Product({
    required this.name,
    required this.price,
    required this.artist,
    required this.imagePath,
    required this.categories,
    required this.rating,
    required this.reviewCount,
  });
}

class ProductData {
  static List<Product> getProducts(ProductType type) {
    if (type == ProductType.marketplace) {
      return [
        Product(
          name: 'Digital Artwork 1',
          price: 29.99,
          artist: 'John Doe',
          imagePath: 'assets/images/Shop/1.jpg',
          categories: ['Digital', 'Abstract'],
          rating: 4.5,
          reviewCount: 120,
        ),
        Product(
          name: '3D Model Pack',
          price: 49.99,
          artist: 'Jane Smith',
          imagePath: 'assets/images/Shop/2.jpg',
          categories: ['3D', 'Characters'],
          rating: 4.2,
          reviewCount: 85,
        ),
        // Add more marketplace products...
      ];
    } else {
      return [
        Product(
          name: 'Landscape Print',
          price: 24.99,
          artist: 'Emma Wilson',
          imagePath: 'assets/images/Shop/1.jpg',
          categories: ['Landscape', 'Nature'],
          rating: 4.7,
          reviewCount: 180,
        ),
        Product(
          name: 'Portrait Print',
          price: 29.99,
          artist: 'Michael Lee',
          imagePath: 'assets/images/Shop/2.jpg',
          categories: ['Portrait', 'People'],
          rating: 4.5,
          reviewCount: 130,
        ),
        // Add more print products...
      ];
    }
  }
}