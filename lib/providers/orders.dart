import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shop/providers/cart.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;


  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,

  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  String? authToken;
  String? userId;

  List<OrderItem> get orders {
    return [..._orders];
  }

  void getData(String? pAuthToken, String? pUserId,
      List<OrderItem> pListOrders) {
    authToken = pAuthToken;
    _orders = pListOrders;
    userId = pUserId;
    notifyListeners();
  }

  Future<void> fetchOrders() async {
    try {

      String url =
          'https://hassan1-e78fc-default-rtdb.firebaseio.com/orders/$userId.json'
          '?auth=$authToken';
      final http.Response res = await http.get(Uri.parse(url));

      final Map<String, dynamic> extractedData =
      json.decode(res.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }

      final List<OrderItem> loadedOrders = [];
      extractedData.forEach((orderId, orderData) {
        loadedOrders.add(OrderItem(
          id: orderId,
          amount: orderData['amount'],
          products:(orderData['products'] as List<dynamic>).map((item) => CartItem(
              id: item.id,
              title: item.title,
              quantity: item.quantity,
              price: item.price)
          ).toList(),
          dateTime:  DateTime.parse(orderData['dateTime'])),);
         //}

      });
      _orders = loadedOrders.reversed.toList();

      notifyListeners();
    } catch (error) {
      throw error;
    }
  }
  Future<void> addOrder(List<CartItem> cartProduct,double total) async {
    try {
      String url =
          'https://hassan1-e78fc-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken';
      final timeStamp=DateTime.now();
      http.Response res = await http.post(Uri.parse(url),
          body: json.encode({
            'amount': total,
            'dateTime':timeStamp.toIso8601String(),
            'products':cartProduct.map((cp) => {
              'id': cp.id,
              'title': cp.title,
              'quantity': cp.quantity,
              'price': cp.price
            }).toList()

          }));

      _orders.insert(0, OrderItem(
          id: json.decode(res.body)['name'],
          amount: total,
          products: cartProduct,
          dateTime: timeStamp));


      notifyListeners();

    } catch (error) {
      throw error;
    }
  }
}
