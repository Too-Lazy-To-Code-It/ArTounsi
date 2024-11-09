import 'package:http/http.dart' as http;
import 'dart:convert';

class UnsplashPhoto {
  final String id;
  final String description;
  final String imageUrl;
  final String photographerName;
  final String photographerUsername;

  UnsplashPhoto({
    required this.id,
    required this.description,
    required this.imageUrl,
    required this.photographerName,
    required this.photographerUsername,
  });

  factory UnsplashPhoto.fromJson(Map<String, dynamic> json) {
    return UnsplashPhoto(
      id: json['id'],
      description: json['description'] ?? json['alt_description'] ?? 'No description',
      imageUrl: json['urls']['regular'],
      photographerName: json['user']['name'],
      photographerUsername: json['user']['username'],
    );
  }
}

class UnsplashService {
  final String baseUrl = 'https://api.unsplash.com';
  final String clientId = 'si9Fs5mcDDsHcExeFqsf1NG12sdYA7X9Po4-etSxsyI'; // Replace with your actual Unsplash access key

  Future<List<UnsplashPhoto>> searchPhotos(String query) async {
    final response = await http.get(
      Uri.parse('$baseUrl/search/photos?query=$query&per_page=10'),
      headers: {'Authorization': 'Client-ID $clientId'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> results = data['results'];
      return results.map((json) => UnsplashPhoto.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load photos');
    }
  }
}

