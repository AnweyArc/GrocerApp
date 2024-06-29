import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ItemModel.dart';

class SoldItems extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var soldItems = Provider.of<ItemModel>(context).soldItems;

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
              DataColumn(label: Text('Date Sold')),
            ],
            rows: soldItems.map((item) {
              return DataRow(cells: [
                DataCell(Text(item['name'])),
                DataCell(Text(item['price'].toString())),
                DataCell(Text(item['quantity'].toString())),
                DataCell(Text(item['description'])),
                DataCell(Text('${item['date'].month}/${item['date'].day}/${item['date'].year}')),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }
}
