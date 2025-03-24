import 'package:flutter/material.dart';

enum Categories {
  vegetables,
  fruit,
  meat,
  dairy,
  carbs,
  sweets,
  spices,
  convenience,
  hygiene,
  other,
}

class Category {
  const Category(String name, Color color);

  final String name = '';
  final Color color = const Color.fromARGB(255, 255, 255, 255);
}
