import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'sell_item_page.dart';

class ItemsSoldPage extends StatefulWidget {
  @override
  _ItemsSoldPageState createState() => _ItemsSoldPageState();
}

class _ItemsSoldPageState extends State<ItemsSoldPage> {
  List<Item> soldItems = [];

  @override
  void initState() {
    super.initState();
    _loadSoldItems();
  }

  _loadSoldItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? jsonStringList = prefs.getStringList('sold_items');
    if (jsonStringList != null) {
      setState(() {
        soldItems = jsonStringList
            .map((jsonString) => Item.fromJson(json.decode(jsonString)))
            .toList();
      });
    }
  }

  _deleteItem(Item item) async {
    setState(() {
      soldItems.remove(item);
    });
    _saveSoldItems();
  }

  _deleteAllItems() async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Items'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  _deleteAllSoldItems();
                  Navigator.of(context).pop();
                },
                child: Text('Delete All Sold Items'),
              ),
              SizedBox(height: 8),
              ...soldItems.map((item) {
                return ElevatedButton(
                  onPressed: () {
                    _deleteItem(item);
                    Navigator.of(context).pop();
                  },
                  child: Text('Delete ${item.name}'),
                );
              }).toList(),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  _deleteAllSoldItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('sold_items');
    setState(() {
      soldItems.clear();
    });
  }

  _saveSoldItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> jsonItems =
        soldItems.map((item) => json.encode(item.toJson())).toList();
    await prefs.setStringList('sold_items', jsonItems);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Items Sold'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _deleteAllItems,
            tooltip: 'Delete Items',
          ),
        ],
      ),
      body: soldItems.isEmpty
          ? Center(child: Text('No items sold'))
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Quantity')),
                  DataColumn(label: Text('Price')),
                  DataColumn(label: Text('Total Price')), // New column for total price
                  DataColumn(label: Text('Description')),
                  DataColumn(label: Text('Date Sold')),
                ],
                rows: soldItems
                    .map((item) => DataRow(cells: [
                          DataCell(Text(item.name)),
                          DataCell(Text(item.quantity.toString())),
                          DataCell(Text(item.price.toString())),
                          DataCell(Text((item.quantity * item.price).toString())), // Calculate total price
                          DataCell(Text(item.description)),
                          DataCell(Text(item.dateSold ?? '')),
                        ]))
                    .toList(),
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

  Item({
    required this.name,
    required this.quantity,
    required this.price,
    required this.description,
    this.dateSold,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      name: json['name'],
      quantity: json['quantity'],
      price: json['price'],
      description: json['description'],
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
