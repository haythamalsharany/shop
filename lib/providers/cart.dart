import 'package:flutter/material.dart';


class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;


  CartItem({
    required this.id,
    required this.title,
    required this.quantity,
    required this.price,

  });
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _cartItems = {};

  Map<String, CartItem> get cartItems {
    return {...cartItems};
  }

  int get itemCount {
    return _cartItems.length;
  }

  double get totalAmount {
    var total = 0.0;
    _cartItems.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  void addCartItem(String productId, double price, String title) {
    if (_cartItems.containsKey(productId)) {
      _cartItems.update(productId, (existingCartItem) =>
          CartItem(
              id: existingCartItem.id,
              title: existingCartItem.title,
              price: existingCartItem.price,
              quantity: existingCartItem.quantity + 1
          ));
    } else {
      _cartItems.putIfAbsent(productId, () =>
          CartItem(
            id: DateTime.now().toIso8601String(),
            title: title,
            quantity: 1,
            price: price,),);
    }
    notifyListeners();
  }
  void removeItem(String productId){
    _cartItems.remove(productId);
    notifyListeners();
  }
  void removeSingleItem(productId){
    if(!_cartItems.containsKey(productId)){
      return;
    }
    if(_cartItems[productId]!.quantity>1){
      _cartItems.update(productId, (existingCartItem) =>
          CartItem(
              id: existingCartItem.id,
              title: existingCartItem.title,
              price: existingCartItem.price,
              quantity: existingCartItem.quantity - 1
          ));
    }else{
      _cartItems.remove(productId);
    }
    notifyListeners();
  }
  void clearCart(){
    _cartItems.clear();
    notifyListeners();
  }
}
