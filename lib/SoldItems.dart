import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'item_model.dart';

class SoldItemsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ItemModel>(
      builder: (context, itemModel, child) {
        // Calculate total sales amount
        double totalSales = 0;
        for (var item in itemModel.soldItems) {
          totalSales += item.quantity * item.price;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                _showTotalSalesDialog(context, totalSales);
              },
              child: Text('Tally Sales'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: itemModel.soldItems.length,
                itemBuilder: (context, index) {
                  final item = itemModel.soldItems[index];
                  final totalPrice = item.quantity * item.price;

                  return ListTile(
                    title: Text(item.name),
                    subtitle: Text(
                      'Total Price: $totalPrice\nQuantity: ${item.quantity}\nDescription: ${item.description}\nSold On: ${item.month}/${item.day}/${item.year}',
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showTotalSalesDialog(BuildContext context, double totalSales) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Total Sales'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Total Sales Amount: $totalSales'),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: Text('Delete All'),
                  onPressed: () {
                    _showDeleteConfirmationDialog(context);
                  },
                ),
                ElevatedButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

void _showDeleteConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Do you really want to delete all Sold Items?'),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: Text('Delete All'),
            onPressed: () {
              // Perform delete all action here
              Provider.of<ItemModel>(context, listen: false).deleteAllSoldItems();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      );
    },
  );
}
}