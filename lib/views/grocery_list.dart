import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/views/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> groceryItems = [];
  var isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    reloadItems();
  }

  void reloadItems() async {
    final url = Uri.https(
      'flutter-app-15e03-default-rtdb.firebaseio.com',
      'shopping-list.json',
    );

    final response = await http.get(url);

    if (response.statusCode >= 400) {
      setState(() {
        error = 'Error to fetch data. Please try again later.';
        isLoading = false;
      });
    }

    final Map<String, dynamic> jsonItems = json.decode(response.body);
    final List<GroceryItem> tempItems = [];
    for (final item in jsonItems.entries) {
      final category =
          categories.entries
              .firstWhere(
                (catItem) => catItem.value.title == item.value['category'],
              )
              .value;

      tempItems.add(
        GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category,
        ),
      );
    }

    setState(() {
      groceryItems = tempItems;
      isLoading = false;
    });
  }

  void addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(builder: (context) => NewItem(mode: PageMode.newItem)),
    );

    if (newItem == null) {
      return;
    }

    setState(() {
      groceryItems.add(newItem);
    });
  }

  void removeItem(GroceryItem item) {
    setState(() {
      groceryItems.remove(item);
    });
  }

  void editItem(GroceryItem item, int index) async {
    final editedItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (context) => NewItem(mode: PageMode.editItem, item: item),
      ),
    );

    if (editedItem == null) {
      return;
    }

    setState(() {
      groceryItems.remove(item);
      groceryItems.insert(index, editedItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: Text(
        error != null ? error! : 'Your list is empty.',
        style: TextStyle(fontSize: 18),
      ),
    );

    if (isLoading) {
      content = Center(child: CircularProgressIndicator.adaptive());
    }

    if (groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: groceryItems.length,
        itemBuilder:
            (context, index) => Dismissible(
              background: Container(
                color: const Color.fromARGB(255, 238, 40, 60),
              ),
              key: ValueKey(groceryItems[index].id),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) {
                removeItem(groceryItems[index]);
              },
              child: ListTile(
                title: Text(groceryItems[index].name),
                leading: Container(
                  width: 24,
                  height: 24,
                  color: groceryItems[index].category.color,
                ),
                trailing: Text(groceryItems[index].quantity.toString()),
                onTap: () {
                  editItem(groceryItems[index], index);
                },
              ),
            ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping List'),
        actions: [IconButton(onPressed: addItem, icon: Icon(Icons.add))],
      ),
      body: content,
    );
  }
}
