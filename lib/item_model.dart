import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Item {
  String name;
  double price;
  int quantity;
  String description;

  Item({required this.name, required this.price, required this.quantity, required this.description});

  Map<String, dynamic> toJson() => {
    'name': name,
    'price': price,
    'quantity': quantity,
    'description': description,
  };

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      name: json['name'],
      price: json['price'],
      quantity: json['quantity'],
      description: json['description'],
    );
  }
}

class SoldItem extends Item {
  int month;
  int day;
  int year;

  SoldItem({
    required String name,
    required double price,
    required int quantity,
    required String description,
    required this.month,
    required this.day,
    required this.year,
  }) : super(name: name, price: price, quantity: quantity, description: description);

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'month': month,
    'day': day,
    'year': year,
  };

  factory SoldItem.fromJson(Map<String, dynamic> json) {
    return SoldItem(
      name: json['name'],
      price: json['price'],
      quantity: json['quantity'],
      description: json['description'],
      month: json['month'],
      day: json['day'],
      year: json['year'],
    );
  }
}

class ItemModel with ChangeNotifier {
  List<Item> _inventoryItems = [];
  List<SoldItem> _soldItems = [];

  List<Item> get inventoryItems => _inventoryItems;
  List<SoldItem> get soldItems => _soldItems;

  ItemModel() {
    _loadItems();
  }

  void _loadItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? inventoryData = prefs.getString('inventoryItems');
    if (inventoryData != null) {
      List<dynamic> inventoryJson = jsonDecode(inventoryData);
      _inventoryItems = inventoryJson.map((json) => Item.fromJson(json)).toList();
    }

    String? soldData = prefs.getString('soldItems');
    if (soldData != null) {
      List<dynamic> soldJson = jsonDecode(soldData);
      _soldItems = soldJson.map((json) => SoldItem.fromJson(json)).toList();
    }

    notifyListeners();
  }

  void addItem(Item item) {
    _inventoryItems.add(item);
    _saveItems();
    notifyListeners();
  }

  void sellItem(SoldItem soldItem) {
    _soldItems.add(soldItem);
    _saveItems();
    notifyListeners();
  }

  void removeItem(int index) {
    _inventoryItems.removeAt(index);
    _saveItems();
    notifyListeners();
  }

  void _saveItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String inventoryData = jsonEncode(_inventoryItems.map((item) => item.toJson()).toList());
    prefs.setString('inventoryItems', inventoryData);

    String soldData = jsonEncode(_soldItems.map((item) => item.toJson()).toList());
    prefs.setString('soldItems', soldData);
  }
}
