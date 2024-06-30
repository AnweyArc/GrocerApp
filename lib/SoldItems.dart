import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'item_model.dart';

class SoldItemsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ItemModel>(
      builder: (context, itemModel, child) {
        return ListView.builder(
          itemCount: itemModel.soldItems.length,
          itemBuilder: (context, index) {
            final item = itemModel.soldItems[index];
            return ListTile(
              title: Text(item.name),
              subtitle: Text(
                'Price: ${item.price}\nQuantity: ${item.quantity}\nDescription: ${item.description}\nSold On: ${item.month}/${item.day}/${item.year}',
              ),
            );
          },
        );
      },
    );
  }
}
