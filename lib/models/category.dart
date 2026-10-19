import 'package:flutter/material.dart';

class CategoryItem {
  final String id;
  final String name;
  final IconData icon;
  final String image;
  final int itemCount;

  const CategoryItem({
    required this.id,
    required this.name,
    required this.icon,
    this.image = '',
    this.itemCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'itemCount': itemCount,
    };
  }

  factory CategoryItem.fromMap(Map<String, dynamic> map, [String? docId]) {
    return CategoryItem(
      id: docId ?? map['id'] ?? '',
      name: map['name'] ?? '',
      icon: Icons.checkroom_rounded,
      image: map['image'] ?? '',
      itemCount: (map['itemCount'] as num?)?.toInt() ?? 0,
    );
  }
}
