import 'package:flutter/foundation.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem(
      {required this.id,
      required this.amount,
      required this.products,
      required this.dateTime});
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  final String token;
  Orders(this.token, this._orders);
  Future<void> fetchAndSetOrders() async {
    var url = Uri.parse(
        'https://shop-app-ff040-default-rtdb.europe-west1.firebasedatabase.app/orders.json?auth=$token');
    try {
      final response = await http.get(url);
      if (response.body == "null") {
        return;
      }
      final data = json.decode(response.body) as Map<String, dynamic>;
      final List<OrderItem> loadedOrders = [];
      data.forEach((id, orderData) {
        loadedOrders.add(OrderItem(
            id: id,
            dateTime: DateTime.parse(orderData['dateTime']),
            amount: orderData['amount'],
            products: (orderData['products'] as List<dynamic>)
                .map((item) => CartItem(
                    id: item['id'],
                    quantity: item['quantity'],
                    price: item['price'],
                    title: item['title']))
                .toList()));
      });
      _orders = loadedOrders;
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    var url = Uri.parse(
        'https://shop-app-ff040-default-rtdb.europe-west1.firebasedatabase.app/orders.json?auth=$token');
    final timeStamp = DateTime.now();
    final response = await http.post(url,
        body: json.encode({
          "amount": total,
          "products": cartProducts
              .map((cp) => {
                    "id": cp.id,
                    "title": cp.title,
                    "quantity": cp.quantity,
                    "price": cp.price
                  })
              .toList(),
          "dateTime": timeStamp.toIso8601String()
        }));
    _orders.insert(
        0,
        OrderItem(
            id: json.decode(response.body)['name'],
            amount: total,
            products: cartProducts,
            dateTime: timeStamp));
    notifyListeners();
  }
}
