// ignore_for_file: argument_type_not_assignable_to_error_handler

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/models/http_exception.dart';

import 'product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    /*Product(
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
    ),*/
  ];

  String? authToken;
  String? userId;
  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((item) => item.isFavorite).toList();
  }

  Product findProductById(String ProId) {
    return _items.firstWhere((product) => product.id == ProId);
  }

  Future<void> fetchData([bool filteredByUser = false]) async {
    final filteredString =
        filteredByUser ? 'orderBy="creatorId"&equalTo=$userId' : '';

    try {
      String url =
          'https://hassan1-e78fc-default-rtdb.firebaseio.com/product.json'
          '?auth=$authToken&$filteredString';
      final http.Response res = await http.get(Uri.parse(url));

      final Map<String, dynamic> extractedData =
          json.decode(res.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      url =
          'https://hassan1-e78fc-default-rtdb.firebaseio.com/userFavorites/$userId.json'
          '?auth=$authToken';
      final http.Response favRes = await http.get(Uri.parse(url));
      final favData = json.decode(favRes.body);
      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        final productIndex =
            loadedProducts.indexWhere((element) => element.id == prodId);
        if (productIndex >= 0) {
          loadedProducts[productIndex] = Product(
              id: prodId,
              title: prodData['title'],
              description: prodData['description'],
              price: prodData['price'],
              imageUrl: prodData['imageUrl'],
              isFavorite: favData == null ? false : favData[prodId] ?? false);
        } else {
          loadedProducts.add(Product(
              id: prodId,
              title: prodData['title'],
              description: prodData['description'],
              price: prodData['price'],
              imageUrl: prodData['imageUrl'],
              isFavorite:
                  favData == null ? false : favData[prodId] ?? false)); //}
        }
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> add(Product product) async {
    try {
      String url =
          'https://hassan1-e78fc-default-rtdb.firebaseio.com/product.json?auth=$authToken';
      http.Response res = await http.post(Uri.parse(url),
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
            'creatorId': userId
          }));
      final newProduct = Product(
        id: json.decode(res.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      _items.add(newProduct);
      // ignore: avoid_print
      //print(imageUrl);

      notifyListeners();
      // ignore: empty_catches
    } catch (error) {}
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((product) => product.id == id);

    if (prodIndex >= 0) {
      try {
        String url =
            'https://hassan1-e78fc-default-rtdb.firebaseio.com/product/$id.json?auth=$authToken';
        await http.patch(Uri.parse(url),
            body: json.encode({
              'title': newProduct.title,
              'description': newProduct.description,
              'price': newProduct.price,
              'imageUrl': newProduct.imageUrl,
            }));

        _items[prodIndex] = newProduct;
        // ignore: avoid_print
        //print(imageUrl);

        notifyListeners();
        // ignore: empty_catches
      } catch (error) {
        throw error;
      }
    } else {
      print('object');
    }
  }

  Future<void> delete(String id) async {
    String url =
        'https://hassan1-e78fc-default-rtdb.firebaseio.com/product/$id.json?auth=$authToken';
    final prodIndex = _items.indexWhere((element) => element.id == id);
    Product? prodItem = _items[prodIndex];
    try {
      _items.removeAt(prodIndex);
      notifyListeners();
      var res = await http.delete(Uri.parse(url));

      if (res.statusCode >= 400) {
        _items.insert(prodIndex, prodItem);
        notifyListeners();
        throw HttpException('Could delete product');
      } else {
        print("Item Deleted");
        prodItem = null;
      }
    } catch (e) {
      throw e;
    }
  }

  void getData(String? pAuthToken, String? pUserId, List<Product> pListPro) {
    authToken = pAuthToken;
    _items = pListPro;
    userId = pUserId;
    notifyListeners();
  }

  //Products.update({required this.authToken, required this.items});

}
