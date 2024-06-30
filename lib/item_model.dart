import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Item {
  String name;
  double price;
  int quantity;
  String description;

  Item({
    required this.name,
    required this.price,
    required this.quantity,
    required this.description,
  });

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
  }) : super(
          name: name,
          price: price,
          quantity: quantity,
          description: description,
        );

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
  List<Item> _cartItems = [];

  List<Item> get inventoryItems => _inventoryItems;
  List<SoldItem> get soldItems => _soldItems;
  List<Item> get cartItems => _cartItems;

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

  void removeFromCart(Item item) {
    // Find the item in the cart
    final cartItem = _cartItems.firstWhere((cartItem) => cartItem.name == item.name);

    if (cartItem != null) {
      // Decrease the quantity in cart
      cartItem.quantity--;

      // If cart item quantity drops to zero, remove it from cart
      if (cartItem.quantity <= 0) {
        _cartItems.remove(cartItem);
      }

      // Increase the quantity back in inventory
      final inventoryItem = _inventoryItems.firstWhere((inventoryItem) => inventoryItem.name == item.name);
      if (inventoryItem != null) {
        inventoryItem.quantity++;
      } else {
        // If the item was not found in inventory (though it should be), add it back
        _inventoryItems.add(Item(
          name: item.name,
          price: item.price,
          quantity: 1, // Default to 1 since cart should not have less than 1 quantity
          description: item.description,
        ));
      }

      notifyListeners();
    }
  }

  void resetCart() {
    _cartItems.clear();
    notifyListeners();
  }
  
  void updateItem(Item oldItem, Item updatedItem) {
    final index = _inventoryItems.indexWhere((item) => item.name == oldItem.name);
    if (index != -1) {
      _inventoryItems[index] = updatedItem;
      _saveItems();
      notifyListeners();
    }
  }

  void addItem(Item item) {
  // Check if the item already exists in inventory
  bool found = false;
  for (int i = 0; i < _inventoryItems.length; i++) {
    if (_inventoryItems[i].name == item.name) {
      // Item found, add the quantity to existing item
      _inventoryItems[i].quantity += item.quantity;
      found = true;
      break;
    }
  }

  // If item was not found, add it to inventory
  if (!found) {
    _inventoryItems.add(item);
  }

  _saveItems();
  notifyListeners();
}


  void addToCart(Item item, int quantity) {
    final existingCartItemIndex = _cartItems.indexWhere((cartItem) => cartItem.name == item.name);
    if (existingCartItemIndex >= 0) {
      _cartItems[existingCartItemIndex].quantity += quantity;
    } else {
      _cartItems.add(Item(
          name: item.name,
          price: item.price,
          quantity: quantity,
          description: item.description));
    }

    item.quantity -= quantity;
    if (item.quantity <= 0) {
      _inventoryItems.remove(item);
    }
    _saveItems();
    notifyListeners();
  }

  void finishTransaction() {
    final now = DateTime.now();
    for (final item in _cartItems) {
      final soldItem = SoldItem(
        name: item.name,
        price: item.price,
        quantity: item.quantity,
        description: item.description,
        month: now.month,
        day: now.day,
        year: now.year,
      );
      _soldItems.add(soldItem);
    }
    _cartItems.clear();
    _saveItems();
    notifyListeners();
  }

  double get totalCartPrice {
    return _cartItems.fold(0, (total, item) => total + item.price * item.quantity);
  }

  void removeItem(int index, {int quantity = 1}) {
    if (index >= 0 && index < _inventoryItems.length) {
      final item = _inventoryItems[index];
      if (quantity >= item.quantity) {
        _inventoryItems.removeAt(index);
      } else {
        item.quantity -= quantity;
      }
      _saveItems(); // Assuming _saveItems handles saving to SharedPreferences
      notifyListeners(); // Notify listeners after making changes
    }
  }

  void _saveItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String inventoryData =
        jsonEncode(_inventoryItems.map((item) => item.toJson()).toList());
    prefs.setString('inventoryItems', inventoryData);

    String soldData = jsonEncode(_soldItems.map((item) => item.toJson()).toList());
    prefs.setString('soldItems', soldData);
  }

  void returnToInventory(Item item) {
    // Increase the quantity back in inventory
    final inventoryItem = _inventoryItems.firstWhere((inventoryItem) => inventoryItem.name == item.name);
    if (inventoryItem != null) {
      inventoryItem.quantity += item.quantity;
    } else {
      // If the item was not found in inventory (though it should be), add it back
      _inventoryItems.add(Item(
        name: item.name,
        price: item.price,
        quantity: item.quantity,
        description: item.description,
      ));
    }

    // Clear the item from cart
    _cartItems.removeWhere((cartItem) => cartItem.name == item.name);

    notifyListeners();
  }
}
