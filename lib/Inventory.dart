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
                      return AlertDialog(
                        title: Text('Delete Item'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Are you sure you want to delete ${item.name}?'),
                            SizedBox(height: 10),
                            TextFormField(
                              decoration: InputDecoration(labelText: 'Quantity to Delete'),
                              keyboardType: TextInputType.number,
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
                              onSaved: (value) {
                                final int quantity = int.tryParse(value!) ?? 0;
                                itemModel.removeItem(index, quantity: quantity);
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
                              final form = Form.of(context);
                              if (form?.validate() ?? false) {
                                form?.save();
                                Navigator.of(context).pop();
                              }
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return EditItemDialog(item: item);
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class EditItemDialog extends StatefulWidget {
  final Item item;

  EditItemDialog({required this.item});

  @override
  _EditItemDialogState createState() => _EditItemDialogState();
}

class _EditItemDialogState extends State<EditItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(text: widget.item.price.toString());
    _quantityController = TextEditingController(text: widget.item.quantity.toString());
    _descriptionController = TextEditingController(text: widget.item.description);
  }

  @override
  void dispose() {
    _priceController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showSaveConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Save'),
          content: Text('Do you want to save changes to ${widget.item.name}?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Save'),
              onPressed: () {
                Navigator.of(context).pop();
                _saveChanges();
              },
            ),
          ],
        );
      },
    );
  }

  void _saveChanges() {
    if (_formKey.currentState?.validate() ?? false) {
      final price = double.tryParse(_priceController.text) ?? 0;
      final quantity = int.tryParse(_quantityController.text) ?? 0;
      final description = _descriptionController.text;

      final updatedItem = Item(
        name: widget.item.name,
        price: price,
        quantity: quantity,
        description: description,
      );

      Provider.of<ItemModel>(context, listen: false).updateItem(widget.item, updatedItem);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Item'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
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
          child: Text('Save'),
          onPressed: () {
            _showSaveConfirmationDialog();
          },
        ),
      ],
    );
  }
}
