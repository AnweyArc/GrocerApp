import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'item_model.dart';

class InventoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ItemModel>(
      builder: (context, itemModel, child) {
        return ListView.builder(
          itemCount: itemModel.inventoryItems.length,
          itemBuilder: (context, index) {
            final item = itemModel.inventoryItems[index];
            return ListTile(
              title: Text(item.name),
              subtitle: Text(
                'Price: ${item.price}\nQuantity: ${item.quantity}\nDescription: ${item.description}',
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      int quantityToDelete = 1; // Default to deleting 1 item

                      return AlertDialog(
                        title: Text('Delete Item'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Are you sure you want to delete ${item.name}?'),
                            SizedBox(height: 10),
                            TextFormField(
                              initialValue: '1',
                              decoration: InputDecoration(labelText: 'Quantity to Delete'),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                quantityToDelete = int.tryParse(value) ?? 1;
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a valid quantity';
                                }
                                final int quantity = int.tryParse(value) ?? 0;
                                if (quantity <= 0 || quantity > item.quantity) {
                                  return 'Invalid quantity';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: Text('Cancel'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          ElevatedButton(
                            child: Text('Delete'),
                            onPressed: () {
                              itemModel.removeItem(index, quantity: quantityToDelete);
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
