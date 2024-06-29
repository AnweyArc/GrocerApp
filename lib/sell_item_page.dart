import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'items_sold_page.dart';

class SellItemPage extends StatefulWidget {
  @override
  _SellItemPageState createState() => _SellItemPageState();
}

class _SellItemPageState extends State<SellItemPage> {
  List<Item> items = [];
  List<Item> cart = []; // Temporary cart to store sold items
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
      Item? selectedItem = items.firstWhere(
        (item) => item.name == _selectedItem,
        orElse: () => Item(name: '', quantity: 0, price: 0.0, description: ''),
      );

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
              content: Text(
                'There\'s only ${selectedItem.quantity} of ${selectedItem.name} in the inventory.',
              ),
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

      // Add item to cart
      Item soldItem = Item(
        name: selectedItem.name,
        quantity: _quantityToSell,
        price: selectedItem.price,
        description: selectedItem.description,
        dateSold:
            '${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year}',
      );
      setState(() {
        cart.add(soldItem);
        _selectedItem = null;
        _quantityToSell = 0;
      });
    }
  }

  _navigateToCart() async {
    // Navigate to CartPage and wait for result
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CartPage(cart: cart)),
    );

    // Handle result if needed, e.g., update inventory after transaction
    if (result == true) {
      _updateInventory(); // Update inventory after transaction
    }
  }

  void _updateInventory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Item> updatedItems = List.from(items);

    for (var cartItem in cart) {
      Item? existingItem = updatedItems.firstWhere(
        (item) => item.name == cartItem.name,
        orElse: () => Item(name: '', quantity: 0, price: 0.0, description: ''),
      );

      if (existingItem.name.isNotEmpty) {
        // Update quantity in the existing item
        existingItem.quantity -= cartItem.quantity;
        if (existingItem.quantity <= 0) {
          // Remove items with zero or negative quantity
          updatedItems.remove(existingItem);
        }
      }
    }

    // Save updated inventory
    prefs.setString(
      'items',
      json.encode(updatedItems.map((item) => item.toJson()).toList()),
    );

    // Update state with the new items list
    setState(() {
      items = updatedItems;
    });
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
                  child: Text(item.name), // Removed the null-aware operator
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _sellItem,
                  child: Text('Add to Cart'),
                ),
                ElevatedButton(
                  onPressed: _navigateToCart,
                  child: Text('Cart'),
                ),
              ],
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

class CartPage extends StatefulWidget {
  final List<Item> cart;

  const CartPage({Key? key, required this.cart}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  double _moneyReceived = 0.0;
  double _change = 0.0;

  void _calculateChange() {
    setState(() {
      _change = _moneyReceived - _totalAmount();
    });
  }

  double _totalAmount() {
    double totalAmount = 0;
    for (var item in widget.cart) {
      totalAmount += item.quantity * item.price;
    }
    return totalAmount;
  }

  _finishTransaction() async {
    try {
      // Save sold items to SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Load existing sold items
      List<String>? soldItemsJsonList = prefs.getStringList('sold_items');
      List<Item> soldItems = soldItemsJsonList?.map((itemJson) {
        Map<String, dynamic> itemMap = json.decode(itemJson);
        return Item.fromJson(itemMap);
      }).toList() ?? [];

      // Add current cart items to sold items
      soldItems.addAll(widget.cart);

      // Convert sold items to JSON and save to SharedPreferences
      List<String> updatedSoldItemsJsonList =
          soldItems.map((item) => json.encode(item.toJson())).toList();
      await prefs.setStringList('sold_items', updatedSoldItemsJsonList);

      // Clear cart
      setState(() {
        widget.cart.clear();
        _moneyReceived = 0.0;
        _change = 0.0;
      });

      // Optionally navigate or show confirmation
      Navigator.pop(context, true);
    } catch (e) {
      print('Error in _finishTransaction: $e');
      // Handle error as needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Quantity')),
                  DataColumn(label: Text('Price')),
                  DataColumn(label: Text('Total Price')),
                  DataColumn(label: Text('Date Sold')),
                ],
                rows: widget.cart
                    .map((item) => DataRow(cells: [
                          DataCell(Text(item.name)),
                          DataCell(Text(item.quantity.toString())),
                          DataCell(Text(item.price.toString())),
                          DataCell(Text(
                              (item.quantity * item.price).toStringAsFixed(2))),
                          DataCell(Text(item.dateSold ?? '')),
                        ]))
                    .toList(),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              decoration: InputDecoration(labelText: 'Money Received'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _moneyReceived = double.tryParse(value) ?? 0.0;
                  _calculateChange();
                });
              },
            ),
            SizedBox(height: 20),
            Text(
              'Total Amount: \₱${_totalAmount().toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Change: \₱${_change.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _finishTransaction,
              child: Text('Finish Transaction'),
            ),
          ],
        ),
      ),
    );
  }
}
