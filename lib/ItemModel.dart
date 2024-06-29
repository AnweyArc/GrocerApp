import 'package:flutter/material.dart';

class ItemModel extends ChangeNotifier {
  List<Map<String, dynamic>> inventoryItems = [];
  List<Map<String, dynamic>> soldItems = [];
  List<Map<String, dynamic>> cartItems = [];

  void addItem(String name, double price, int quantity, String description) {
    inventoryItems.add({
      'name': name,
      'price': price,
      'quantity': quantity,
      'description': description
    });
    notifyListeners();
  }

  void addToCart(String name, int quantity) {
    var item = inventoryItems.firstWhere(
      (item) => item['name'] == name,
      orElse: () => {},
    );

    if (item.isNotEmpty && item['quantity'] >= quantity) {
      var cartItem = cartItems.firstWhere(
        (cartItem) => cartItem['name'] == name,
        orElse: () => {},
      );

      if (cartItem.isNotEmpty) {
        cartItem['quantity'] += quantity;
      } else {
        cartItems.add({
          'name': name,
          'price': item['price'],
          'quantity': quantity,
          'description': item['description']
        });
      }
      notifyListeners();
    }
  }

  void finishTransaction() {
    var date = DateTime.now();
    cartItems.forEach((cartItem) {
      var inventoryItem = inventoryItems.firstWhere(
        (item) => item['name'] == cartItem['name'],
        orElse: () => {},
      );

      if (inventoryItem.isNotEmpty) {
        inventoryItem['quantity'] -= cartItem['quantity'];
        soldItems.add({
          'name': cartItem['name'],
          'price': cartItem['price'],
          'quantity': cartItem['quantity'],
          'description': cartItem['description'],
          'date': date,
        });
      }
    });
    cartItems.clear();
    notifyListeners();
  }
}
