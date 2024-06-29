import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ItemModel.dart';

class SoldItems extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var soldItems = Provider.of<ItemModel>(context).soldItems;

    void deleteSoldItem(int index) {
      Provider.of<ItemModel>(context, listen: false).deleteSoldItem(index);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Sold Items'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            columnSpacing: 16.0,
            columns: [
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Price')),
              DataColumn(label: Text('Quantity')),
              DataColumn(label: Text('Date Sold')),
              DataColumn(label: Text('Actions')), // Added column for actions
            ],
            rows: soldItems.asMap().entries.map((entry) {
              int index = entry.key;
              var item = entry.value;
              return DataRow(cells: [
                DataCell(Text(item['name'])),
                DataCell(Text('\$${item['price'].toStringAsFixed(2)}')), // Format price as currency
                DataCell(Text(item['quantity'].toString())),
                DataCell(Text('${item['date'].month}/${item['date'].day}/${item['date'].year}')),
                DataCell(
                  IconButton(
                    icon: Icon(Icons.delete),
                    color: Colors.red,
                    onPressed: () {
                      deleteSoldItem(index);
                    },
                  ),
                ),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }
}
