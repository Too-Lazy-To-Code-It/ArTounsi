import 'package:cloud_firestore/cloud_firestore.dart';

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
  final ProductType type;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.artist,
    required this.imagePath,
    required this.categories,
    required this.rating,
    required this.reviewCount,
    required this.type,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      artist: data['artist'] ?? '',
      imagePath: data['imagePath'] ?? '',
      categories: List<String>.from(data['categories'] ?? []),
      rating: (data['rating'] ?? 0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      type: data['type'] == 'marketplace' ? ProductType.marketplace : ProductType.prints,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'price': price,
      'artist': artist,
      'imagePath': imagePath,
      'categories': categories,
      'rating': rating,
      'reviewCount': reviewCount,
      'type': type == ProductType.marketplace ? 'marketplace' : 'prints',
    };
  }
}