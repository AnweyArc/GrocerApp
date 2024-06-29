import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ItemModel extends ChangeNotifier {
  List<Map<String, dynamic>> inventoryItems = [];
  List<Map<String, dynamic>> soldItems = [];
  List<Map<String, dynamic>> cartItems = [];

  // Initialize SharedPreferences instance
  static SharedPreferences? _prefs; // Change to nullable SharedPreferences

  // Constructor to initialize SharedPreferences
  ItemModel() {
    _initSharedPreferences(); // Initiate the initialization process
  }

  // Initialize SharedPreferences
  void _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _loadData(); // Load data after SharedPreferences is initialized
  }

  // Save inventoryItems and soldItems to SharedPreferences
  void _saveData() {
    _prefs?.setString('inventoryItems', json.encode(inventoryItems));
    _prefs?.setString('soldItems', json.encode(soldItems));
  }

  // Load inventoryItems and soldItems from SharedPreferences
  void _loadData() {
    var inventoryData = _prefs?.getString('inventoryItems');
    var soldData = _prefs?.getString('soldItems');

    if (inventoryData != null) {
      Iterable decoded = json.decode(inventoryData);
      inventoryItems = decoded.map((item) => Map<String, dynamic>.from(item)).toList();
    }

    if (soldData != null) {
      Iterable decoded = json.decode(soldData);
      soldItems = decoded.map((item) => Map<String, dynamic>.from(item)).toList();
    }
  }

  // Add item to inventoryItems
  void addItem(String name, double price, int quantity, String description) {
    inventoryItems.add({
      'name': name,
      'price': price,
      'quantity': quantity,
      'description': description
    });
    _saveData();
    notifyListeners();
  }

  // Add item to cartItems
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
      _saveData();
      notifyListeners();
    }
  }

  // Finish transaction, update inventoryItems and add to soldItems
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
    _saveData();
    notifyListeners();
  }

  // Delete sold item from soldItems list
  void deleteSoldItem(int index) {
    if (index >= 0 && index < soldItems.length) {
      soldItems.removeAt(index);
      _saveData(); // Save changes after deleting item
      notifyListeners();
    }
  }
}
