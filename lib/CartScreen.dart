import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ItemModel.dart';

class CartScreen extends StatelessWidget {
  final _cashController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var cartItems = Provider.of<ItemModel>(context).cartItems;
    
    // Calculate total price with explicit type conversion
    var totalPrice = cartItems.fold<double>(0, (sum, item) => 
      sum + (item['price'] * item['quantity'])
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Price')),
                    DataColumn(label: Text('Quantity')),
                    DataColumn(label: Text('Description')),
                  ],
                  rows: cartItems.map((item) {
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
            Text('Total Price: \$${totalPrice.toStringAsFixed(2)}'),
            TextFormField(
              controller: _cashController,
              decoration: InputDecoration(labelText: 'Cash Received'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                var cashReceived = double.parse(_cashController.text);
                var change = cashReceived - totalPrice.toDouble();

                if (change >= 0) {
                  Provider.of<ItemModel>(context, listen: false).finishTransaction();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Transaction complete! Change: \$${change.toStringAsFixed(2)}')),
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Insufficient cash received!')),
                  );
                }
              },
              child: Text('Finish Transaction'),
            ),
          ],
        ),
      ),
    );
  }
}
