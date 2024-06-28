import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AddItemPage extends StatefulWidget {
  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  int _quantity = 0;
  double _price = 0.0;
  String _description = '';

  _saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<Item> items = [];
      String? jsonString = prefs.getString('items');
      if (jsonString != null) {
        List<dynamic> jsonList = json.decode(jsonString);
        items = jsonList.map((json) => Item.fromJson(json)).toList();
      }
      items.add(Item(
          name: _name, quantity: _quantity, price: _price, description: _description));
      prefs.setString('items', json.encode(items.map((item) => item.toJson()).toList()));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Item'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                onSaved: (value) {
                  _name = value!;
                },
                validator: (value) {
                  return value!.isEmpty ? 'Please enter a name' : null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  _quantity = int.parse(value!);
                },
                validator: (value) {
                  return value!.isEmpty ? 'Please enter a quantity' : null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  _price = double.parse(value!);
                },
                validator: (value) {
                  return value!.isEmpty ? 'Please enter a price' : null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                onSaved: (value) {
                  _description = value!;
                },
                validator: (value) {
                  return value!.isEmpty ? 'Please enter a description' : null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveItem,
                child: Text('Save Item'),
              ),
            ],
          ),
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
