import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ItemModel.dart';

class Inventory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var inventoryItems = Provider.of<ItemModel>(context).inventoryItems;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Price')),
              DataColumn(label: Text('Quantity')),
              DataColumn(label: Text('Description')),
            ],
            rows: inventoryItems.map((item) {
              return DataRow(cells: [
                DataCell(Text(item['name'])),
                DataCell(Text(item['price'].toString())),
                DataCell(Text(item['quantity'].toString())),
                DataCell(Text(item['description'])),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }
}
