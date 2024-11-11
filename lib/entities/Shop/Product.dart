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
  final String userId;

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
    required this.userId,
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
      userId: data['userId'] ?? '',
    );
  }

  factory Product.fromMap(Map<String, dynamic> data, {String? id}) {
    print('Creating Product from map: $data');
    return Product(
      id: id ?? data['id'] ?? '',
      name: data['name'] ?? '',
      price: _parseDouble(data['price']),
      artist: data['artist'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      categories: List<String>.from(data['categories'] ?? []),
      rating: _parseDouble(data['rating']),
      reviewCount: data['reviewCount'] ?? 0,
      type: _parseProductType(data['type']),
      userId: data['userId'] ?? '',
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
      'type': type.toString().split('.').last.toLowerCase(),
      'userId': userId,
    };
  }

  bool belongsToUser(String userId) {
    return this.userId == userId;
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static ProductType _parseProductType(String? value) {
    switch (value?.toLowerCase()) {
      case 'prints':
        return ProductType.prints;
      case 'marketplace':
      default:
        return ProductType.marketplace;
    }
  }
}