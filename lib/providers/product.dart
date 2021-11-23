import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  void _setFavValue(bool newValue) {
    isFavorite = newValue;
    notifyListeners();
  }

  Future<void> toggleFavoriteStatus(String userId, String token) async {
    final oldValue = isFavorite;
    isFavorite = !isFavorite;
    final url =
        'https://hassan1-e78fc-default-rtdb.firebaseio.com/userFavorites/$userId/$id.json'
        '?auth=$token';
    try {
      http.Response res =
          await http.put(Uri.parse(url), body: json.encode(isFavorite));
      if (res.statusCode >= 400) {
        _setFavValue(oldValue);
      }
    } catch (e) {
      _setFavValue(oldValue);
    }
  }
}
