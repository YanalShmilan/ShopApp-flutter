import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product(
      {required this.id,
      required this.title,
      required this.description,
      required this.price,
      required this.imageUrl,
      this.isFavorite = false});

  Future<void> toggleFavStatus(String token) async {
    var url = Uri.parse(
        'https://shop-app-ff040-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json?auth=$token');
    await http.patch(url, body: json.encode({"isFavorite": !isFavorite}));

    isFavorite = !isFavorite;
    notifyListeners();
  }
}
