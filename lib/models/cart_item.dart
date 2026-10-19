import 'product.dart';

class CartItem {
  final String id;
  final Product product;
  final String selectedSize;
  final ProductColor selectedColor;
  int quantity;

  CartItem({
    required this.id,
    required this.product,
    required this.selectedSize,
    required this.selectedColor,
    this.quantity = 1,
  });

  double get totalPrice => product.price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': product.id,
      'product': product.toMap(),
      'selectedSize': selectedSize,
      'selectedColor': selectedColor.toMap(),
      'quantity': quantity,
      'unitPrice': product.price,
      'totalPrice': totalPrice,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic> productMap = {};
    if (map['product'] is Map) {
      productMap = Map<String, dynamic>.from(map['product'] as Map);
    }

    Map<String, dynamic> colorMap = {};
    if (map['selectedColor'] is Map) {
      colorMap = Map<String, dynamic>.from(map['selectedColor'] as Map);
    }

    return CartItem(
      id: map['id']?.toString() ?? '',
      product: Product.fromMap(productMap),
      selectedSize: map['selectedSize']?.toString() ?? 'M',
      selectedColor: ProductColor.fromMap(colorMap),
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
    );
  }
}
