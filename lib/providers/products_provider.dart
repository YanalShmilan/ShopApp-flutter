import 'package:flutter/material.dart';
import 'package:shop_app/providers/product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductsProvider with ChangeNotifier {
  List<Product> _items = [
    Product(
      id: 'p1',
      title: 'Red Shirt',
      description: 'A red shirt - it is pretty red!',
      price: 29.99,
      imageUrl:
          'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    ),
    Product(
      id: 'p2',
      title: 'Trousers',
      description: 'A nice pair of trousers.',
      price: 59.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    ),
    Product(
      id: 'p3',
      title: 'Yellow Scarf',
      description: 'Warm and cozy - exactly what you need for the winter.',
      price: 19.99,
      imageUrl:
          'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    ),
    Product(
      id: 'p4',
      title: 'A Pan',
      description: 'Prepare any meal you want.',
      price: 49.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    ),
  ];

  var showFavOnly = false;

  List<Product> get items {
    if (showFavOnly == true) {
      return _items.where((item) => item.isFavorite == true).toList();
    }
    return [..._items];
  }

  Product findById(id) => _items.firstWhere((item) => item.id == id);

  void showFavOnlyMethod() {
    showFavOnly = true;
    notifyListeners();
  }

  void showAll() {
    showFavOnly = false;
    notifyListeners();
  }

  final String authToken;
  final String userId;
  ProductsProvider(this.authToken, this._items, this.userId);
  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? '&orderBy="userId"&equalTo="$userId"' : "";
    var url = Uri.parse(
        'https://shop-app-ff040-default-rtdb.europe-west1.firebasedatabase.app/products.json?auth=$authToken$filterString');
    try {
      final response = await http.get(url);
      if (response.body == "null") {
        return;
      }
      final data = json.decode(response.body) as Map<String, dynamic>;
      url = Uri.parse(
          'https://shop-app-ff040-default-rtdb.europe-west1.firebasedatabase.app/userFavorites/$userId.json?auth=$authToken');

      final favoriteResponse = await http.get(url);
      final favData = json.decode(favoriteResponse.body);
      final List<Product> loadedProducts = [];
      data.forEach((id, prodData) {
        loadedProducts.add(Product(
            id: id,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'],
            imageUrl: prodData['imageUrl'],
            isFavorite: favData == null ? false : favData[id] ?? false));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> addProduct(Product product) async {
    var url = Uri.parse(
        'https://shop-app-ff040-default-rtdb.europe-west1.firebasedatabase.app/products.json?auth=$authToken');
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'title': product.title,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'description': product.description,
            'userId': userId
          },
        ),
      );
      final newProduct = Product(
          id: jsonDecode(response.body)['name'],
          title: product.title,
          imageUrl: product.imageUrl,
          price: product.price,
          description: product.description);
      _items.insert(0, newProduct);
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    var url = Uri.parse(
        'https://shop-app-ff040-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json?auth=$authToken');
    await http.patch(url,
        body: json.encode({
          "title": newProduct.title,
          "description": newProduct.description,
          "imageUrl": newProduct.imageUrl,
          "price": newProduct.price
        }));
    final index = _items.indexWhere((prod) => prod.id == id);
    _items[index] = newProduct;
    notifyListeners();
  }

  void deleteProduct(String id) {
    var url = Uri.parse(
        'https://shop-app-ff040-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json?auth=$authToken');
    http.delete(url);
    _items.removeWhere((prod) => prod.id == id);
    notifyListeners();
  }
}
