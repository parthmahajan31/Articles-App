import 'dart:convert';

import 'package:http/http.dart' as http;

import '../data/post_data.dart';

class ApiService {
  static const _baseUrl = 'https://jsonplaceholder.typicode.com';

  Future<List<Post>> fetchPosts() async {
    final uri = Uri.parse('$_baseUrl/posts');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body) as List;
      return data.map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }
}
