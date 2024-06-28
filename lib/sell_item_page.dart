import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SellItemPage extends StatefulWidget {
  @override
  _SellItemPageState createState() => _SellItemPageState();
}

class _SellItemPageState extends State<SellItemPage> {
  List<Item> items = [];
  String? _selectedItem;
  int _quantityToSell = 0;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  _loadItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('items');
    if (jsonString != null) {
      setState(() {
        List<dynamic> jsonList = json.decode(jsonString);
        items = jsonList.map((json) => Item.fromJson(json)).toList();
      });
    }
  }

  _sellItem() async {
    if (_selectedItem != null && _quantityToSell > 0) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<Item> updatedItems = [];
      List<Item> soldItems = [];

      // Find the selected item
      Item? selectedItem = items.firstWhere((item) => item.name == _selectedItem, orElse: () => Item(name: '', quantity: 0, price: 0.0, description: ''));

      // Validate if item was found
      if (selectedItem.name.isEmpty) {
        return; // Handle case where selected item is not found
      }

      // Validate quantity to sell
      if (_quantityToSell > selectedItem.quantity) {
        // Show error message if trying to sell more than available
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('There\'s only ${selectedItem.quantity} of ${selectedItem.name} in the inventory.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
        return;
      }

      // Update items and sold items lists
      for (Item item in items) {
        if (item.name == _selectedItem) {
          int remainingQuantity = item.quantity - _quantityToSell;
          if (remainingQuantity > 0) {
            updatedItems.add(Item(
                name: item.name,
                quantity: remainingQuantity,
                price: item.price,
                description: item.description));
          }
          String dateSold = '${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year}';
          soldItems.add(Item(
              name: item.name,
              quantity: _quantityToSell,
              price: item.price,
              description: item.description,
              dateSold: dateSold));
        } else {
          updatedItems.add(item);
        }
      }

      // Save updated inventory and sold items
      prefs.setString('items', json.encode(updatedItems.map((item) => item.toJson()).toList()));
      prefs.setString('sold_items', json.encode(soldItems.map((item) => item.toJson()).toList()));

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sell Item'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Select Item'),
              value: _selectedItem,
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item.name,
                  child: Text(item.name ?? ''), // Handle null name
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedItem = value;
                });
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Quantity to Sell'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _quantityToSell = int.tryParse(value) ?? 0;
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sellItem,
              child: Text('Sell Item'),
            ),
          ],
        ),
      ),
    );
  }
}

class Item {
  String name;
  int quantity;
  double price;
  String description;
  String? dateSold;

  Item({required this.name, required this.quantity, required this.price, required this.description, this.dateSold});

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 0, // Handle null or missing quantity
      price: json['price'] ?? 0.0, // Handle null or missing price
      description: json['description'] ?? '',
      dateSold: json['dateSold'],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'quantity': quantity,
        'price': price,
        'description': description,
        'dateSold': dateSold,
      };
}
