import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/category.dart';
import 'package:shopping_list/models/grocery_item.dart';

enum PageMode { newItem, editItem }

class NewItem extends StatefulWidget {
  const NewItem({super.key, required this.mode, this.item});

  final PageMode mode;
  final GroceryItem? item;

  @override
  State<NewItem> createState() {
    return _NewItem();
  }
}

class _NewItem extends State<NewItem> {
  final formKey = GlobalKey<FormState>();

  var enteredName = '';
  var enteredQuantity = 1;
  var selectedCategory = categories[Categories.vegetables]!;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedCategory =
        widget.mode == PageMode.newItem
            ? selectedCategory
            : (widget.item?.category ?? selectedCategory);
  }

  void saveItem() {
    if (formKey.currentState?.validate() == true) {
      formKey.currentState?.save();
      Navigator.of(context).pop(
        GroceryItem(
          id: UniqueKey().toString(),
          name: enteredName,
          quantity: enteredQuantity,
          category: selectedCategory,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isNewMode = widget.mode == PageMode.newItem;

    return Scaffold(
      appBar: AppBar(title: Text(isNewMode ? 'Add a new item' : 'Edit item')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: InputDecoration(label: Text('Name')),
                initialValue: isNewMode ? '' : (widget.item?.name ?? ''),
                onTapOutside: (PointerDownEvent event) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                keyboardType: TextInputType.name,
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return 'Name must be between 1 and 50 characters.';
                  }
                  return null;
                },
                onSaved: (value) {
                  enteredName = value ?? "";
                },
              ),
              SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(label: Text('Quantity')),
                      initialValue:
                          isNewMode
                              ? enteredQuantity.toString()
                              : (widget.item?.quantity.toString() ?? ''),
                      onTapOutside: (PointerDownEvent event) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return 'Must be a positive number.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        enteredQuantity = int.parse(
                          value ?? enteredQuantity.toString(),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField(
                      value:
                          isNewMode ? selectedCategory : widget.item?.category,
                      validator: (value) {
                        if (value == null) {
                          return 'A category must be selected.';
                        }
                        return null;
                      },
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: category.value.color,
                                ),
                                SizedBox(width: 8),
                                Text(category.value.title),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 44),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      formKey.currentState?.reset();
                    },
                    child: Text('Reset'),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: saveItem,
                    child: Text(isNewMode ? 'Add Item' : 'Save Item'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
