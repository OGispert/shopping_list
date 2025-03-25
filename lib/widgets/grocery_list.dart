import 'package:flutter/material.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  final List<GroceryItem> groceryItems = [];

  void addItem() async {
    final newItem = await Navigator.of(
      context,
    ).push<GroceryItem>(MaterialPageRoute(builder: (context) => NewItem()));

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

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: Text('Your list is empty.', style: TextStyle(fontSize: 18)),
    );

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
