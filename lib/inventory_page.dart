import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


class InventoryPage extends StatefulWidget {
  @override
  _InventoryPageState createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  List<Item> items = [];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inventory'),
      ),
      body: items.isEmpty
          ? Center(child: Text('No items in inventory'))
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Quantity')),
                  DataColumn(label: Text('Price')),
                  DataColumn(label: Text('Description')),
                ],
                rows: items
                    .map((item) => DataRow(cells: [
                          DataCell(Text(item.name)),
                          DataCell(Text(item.quantity.toString())),
                          DataCell(Text(item.price.toString())),
                          DataCell(Text(item.description)),
                        ]))
                    .toList(),
              ),
            ),
    );
  }

  // Update items list when inventory changes
  void updateInventory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('items');
    if (jsonString != null) {
      setState(() {
        List<dynamic> jsonList = json.decode(jsonString);
        items = jsonList.map((json) => Item.fromJson(json)).toList();
      });
    }
  }
}

class Item {
  String name;
  int quantity;
  double price;
  String description;
  String? dateSold;

  Item({
    required this.name,
    required this.quantity,
    required this.price,
    required this.description,
    this.dateSold,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: json['price'] ?? 0.0,
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
