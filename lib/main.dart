import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Inventory.dart';
import 'SoldItems.dart';
import 'item_model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ItemModel(),
      child: MaterialApp(
        title: 'Inventory App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Inventory Management'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Inventory'),
              Tab(text: 'Sold Items'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            InventoryScreen(),
            SoldItemsScreen(),
          ],
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AddItemDialog();
                  },
                );
              },
              tooltip: 'Add Item',
              child: Icon(Icons.add),
            ),
            SizedBox(height: 10),
            FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return SellItemDialog();
                  },
                );
              },
              tooltip: 'Sell Item',
              child: Icon(Icons.shopping_cart),
            ),
          ],
        ),
      ),
    );
  }
}

class AddItemDialog extends StatefulWidget {
  @override
  _AddItemDialogState createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Item'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the item name';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _priceController,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the price';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _quantityController,
              decoration: InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the quantity';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          child: Text('Add'),
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              final name = _nameController.text;
              final price = double.tryParse(_priceController.text) ?? 0;
              final quantity = int.tryParse(_quantityController.text) ?? 0;
              final description = _descriptionController.text;

              final newItem = Item(
                name: name,
                price: price,
                quantity: quantity,
                description: description,
              );

              Provider.of<ItemModel>(context, listen: false).addItem(newItem);
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

class SellItemDialog extends StatefulWidget {
  @override
  _SellItemDialogState createState() => _SellItemDialogState();
}

class _SellItemDialogState extends State<SellItemDialog> {
  final _itemNameController = TextEditingController();
  final _quantityController = TextEditingController();

  @override
  void dispose() {
    _itemNameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Sell Item'),
      content: Consumer<ItemModel>(
        builder: (context, itemModel, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: _itemNameController,
                decoration: InputDecoration(labelText: 'Item Name'),
              ),
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the quantity';
                  }
                  return null;
                },
              ),
            ],
          );
        },
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
            Provider.of<ItemModel>(context, listen: false).resetCart();
          },
        ),
        ElevatedButton(
          child: Text('Add to Cart'),
          onPressed: () {
            final itemName = _itemNameController.text.trim();
            final quantity = int.tryParse(_quantityController.text) ?? 0;

            if (itemName.isNotEmpty && quantity > 0) {
              final item = Provider.of<ItemModel>(context, listen: false)
                  .findItemByName(itemName);

              if (item != null && quantity <= item.quantity) {
                Provider.of<ItemModel>(context, listen: false)
                    .addToCart(item, quantity);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$quantity ${item.name} added to cart')),
                );
                _itemNameController.clear();
                _quantityController.clear();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Item not found or quantity exceeds stock')),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please enter valid item name and quantity')),
              );
            }
          },
        ),
        TextButton(
          child: Text('Go to Cart'),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => CartScreen()),
            );
          },
        ),
      ],
    );
  }
}

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: Consumer<ItemModel>(
        builder: (context, itemModel, child) {
          final cartItems = itemModel.cartItems;
          final totalPrice = itemModel.totalCartPrice;
          return Column(
            children: <Widget>[
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return ListTile(
                      title: Text(item.name),
                      subtitle: Text('Quantity: ${item.quantity}\nPrice: ${item.price * item.quantity}'),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    Text('Total Price: \$${totalPrice.toStringAsFixed(2)}'),
                    SizedBox(height: 10),
                    ElevatedButton(
                      child: Text('Finish Transaction'),
                      onPressed: () {
                        Provider.of<ItemModel>(context, listen: false).finishTransaction();
                        Provider.of<ItemModel>(context, listen: false).resetCart();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

extension on ItemModel {
  Item? findItemByName(String name) {
    return inventoryItems.firstWhere((item) => item.name == name);
  }
}

