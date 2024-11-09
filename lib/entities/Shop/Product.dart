import 'package:cloud_firestore/cloud_firestore.dart';

enum ProductType { marketplace, prints }

class Product {
  final String id;
  final String name;
  final double price;
  final String artist;
  final String imageUrl;
  final List<String> categories;
  final double rating;
  final int reviewCount;
  final ProductType type;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.artist,
    required this.imageUrl,
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
      price: _parseDouble(data['price']),
      artist: data['artist'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      categories: List<String>.from(data['categories'] ?? []),
      rating: _parseDouble(data['rating']),
      reviewCount: data['reviewCount'] ?? 0,
      type: _parseProductType(data['type']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'price': price,
      'artist': artist,
      'imageUrl': imageUrl,
      'categories': categories,
      'rating': rating,
      'reviewCount': reviewCount,
      'type': type.toString().split('.').last,
    };
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static ProductType _parseProductType(dynamic value) {
    if (value is String) {
      return ProductType.values.firstWhere(
        (type) =>
            type.toString().split('.').last.toLowerCase() ==
            value.toLowerCase(),
        orElse: () => ProductType.marketplace,
      );
    }
    return ProductType.marketplace;
  }
}
