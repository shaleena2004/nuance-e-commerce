import 'package:flutter/material.dart';

class Product {
  final String id;
  final String name;
  final String brand;
  final String category;
  final String department;
  final String description;
  final double price;
  final double? originalPrice;
  final List<String> images;
  final List<String> sizes;
  final List<ProductColor> colors;
  final double rating;
  final int reviewsCount;
  final bool isFeatured;
  final bool isNew;
  final bool inStock;
  final String sku;
  final int stockCount;
  final Map<String, int> variantStock;

  const Product({
    required this.id,
    required this.name,
    this.brand = 'NUANCE',
    required this.category,
    this.department = 'Women',
    required this.description,
    required this.price,
    this.originalPrice,
    required this.images,
    required this.sizes,
    required this.colors,
    this.rating = 4.8,
    this.reviewsCount = 42,
    this.isFeatured = false,
    this.isNew = false,
    this.inStock = true,
    this.sku = '',
    this.stockCount = 15,
    this.variantStock = const {},
  });

  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  int get discountPercentage {
    if (!hasDiscount) return 0;
    return (((originalPrice! - price) / originalPrice!) * 100).round();
  }

  String get mainImage => images.isNotEmpty ? images.first : '';

  int getStockFor(String colorName, String size) {
    final key = '${colorName.trim()}_${size.trim()}';
    if (variantStock.containsKey(key)) {
      return variantStock[key]!;
    }
    if (variantStock.isEmpty) return stockCount;
    return 0;
  }

  int get totalStock {
    if (variantStock.isNotEmpty) {
      return variantStock.values.fold(0, (sum, val) => sum + val);
    }
    return stockCount;
  }

  bool get isSoldOut => !inStock || totalStock <= 0;

  bool get isLowStock => !isSoldOut && totalStock <= 5;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'category': category,
      'department': department,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'images': images,
      'sizes': sizes,
      'colors': colors.map((c) => c.toMap()).toList(),
      'rating': rating,
      'reviewsCount': reviewsCount,
      'isFeatured': isFeatured,
      'isNew': isNew,
      'inStock': inStock,
      'sku': sku,
      'stockCount': stockCount,
      'variantStock': variantStock,
    };
  }

  static String inferDepartment(String name, String category) {
    final lowerName = name.toLowerCase();
    final lowerCat = category.toLowerCase();
    if (lowerCat.contains('acc') ||
        lowerCat.contains('bag') ||
        lowerName.contains('tote') ||
        lowerName.contains('bag') ||
        lowerName.contains('cardholder') ||
        lowerName.contains('belt')) {
      return 'Accessories';
    }
    if (lowerName.contains('dress') ||
        lowerName.contains('skirt') ||
        lowerName.contains('slip') ||
        lowerName.contains('bralette') ||
        lowerName.contains('blouse') ||
        lowerName.contains('gown') ||
        lowerName.contains('crop')) {
      return 'Women';
    }
    if (lowerName.contains('suit') && !lowerName.contains('editorial')) {
      return 'Men';
    }
    if (lowerName.contains('overcoat') ||
        lowerName.contains('trench') ||
        lowerName.contains('mockneck') ||
        lowerName.contains('polo') ||
        lowerName.contains('trouser')) {
      return 'Men';
    }
    return 'Women';
  }

  factory Product.fromMap(Map<String, dynamic> map, [String? docId]) {
    final rawColors = map['colors'];
    final List<ProductColor> parsedColors = [];
    if (rawColors is List) {
      for (final c in rawColors) {
        if (c is Map) {
          parsedColors.add(ProductColor.fromMap(Map<String, dynamic>.from(c)));
        }
      }
    }

    final rawVariantStock = map['variantStock'];
    final Map<String, int> parsedVariantStock = {};
    if (rawVariantStock is Map) {
      rawVariantStock.forEach((k, v) {
        parsedVariantStock[k.toString()] = (v as num?)?.toInt() ?? 0;
      });
    }

    final stock = (map['stockCount'] as num?)?.toInt() ?? 15;
    final inStockVal = map['inStock'] != false && stock > 0;

    final nameStr = map['name']?.toString() ?? '';
    final catStr = map['category']?.toString() ?? 'All';
    final deptStr = map['department']?.toString() ?? inferDepartment(nameStr, catStr);

    return Product(
      id: docId ?? map['id']?.toString() ?? '',
      name: nameStr,
      brand: map['brand']?.toString() ?? 'NUANCE',
      category: catStr,
      department: deptStr,
      description: map['description']?.toString() ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (map['originalPrice'] as num?)?.toDouble(),
      images: List<String>.from(map['images'] ?? []),
      sizes: List<String>.from(map['sizes'] ?? ['S', 'M', 'L']),
      colors: parsedColors.isNotEmpty
          ? parsedColors
          : const [ProductColor(name: 'Black', colorValue: 0xFF1C1C1C)],
      rating: (map['rating'] as num?)?.toDouble() ?? 4.8,
      reviewsCount: (map['reviewsCount'] as num?)?.toInt() ?? 0,
      isFeatured: map['isFeatured'] == true,
      isNew: map['isNew'] == true,
      inStock: inStockVal,
      sku: map['sku']?.toString() ?? '',
      stockCount: stock,
      variantStock: parsedVariantStock,
    );
  }

  Product copyWith({
    String? id,
    String? name,
    String? brand,
    String? category,
    String? department,
    String? description,
    double? price,
    double? originalPrice,
    List<String>? images,
    List<String>? sizes,
    List<ProductColor>? colors,
    double? rating,
    int? reviewsCount,
    bool? isFeatured,
    bool? isNew,
    bool? inStock,
    String? sku,
    int? stockCount,
    Map<String, int>? variantStock,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      department: department ?? this.department,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      images: images ?? this.images,
      sizes: sizes ?? this.sizes,
      colors: colors ?? this.colors,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      isFeatured: isFeatured ?? this.isFeatured,
      isNew: isNew ?? this.isNew,
      inStock: inStock ?? this.inStock,
      sku: sku ?? this.sku,
      stockCount: stockCount ?? this.stockCount,
      variantStock: variantStock ?? this.variantStock,
    );
  }
}

class ProductColor {
  final String name;
  final int colorValue;

  const ProductColor({
    required this.name,
    required this.colorValue,
  });

  Color get color => Color(colorValue);

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'colorValue': colorValue,
    };
  }

  factory ProductColor.fromMap(Map<String, dynamic> map) {
    return ProductColor(
      name: map['name'] ?? 'Standard',
      colorValue: map['colorValue'] ?? 0xFF000000,
    );
  }
}
