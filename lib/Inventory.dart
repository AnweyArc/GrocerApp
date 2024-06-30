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
                  itemModel.removeItem(index);
                },
              ),
            );
          },
        );
      },
    );
  }
}
