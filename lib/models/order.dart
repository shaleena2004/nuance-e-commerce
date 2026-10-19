import 'cart_item.dart';

enum OrderStatus {
  placed,
  processing,
  shipped,
  delivered,
  cancelled;

  String get displayName {
    switch (this) {
      case OrderStatus.placed:
        return 'Order Placed';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class OrderModel {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double subtotal;
  final double shippingFee;
  final double discount;
  final double totalAmount;
  final String shippingAddress;
  final String phoneNumber;
  final String paymentMethod;
  final OrderStatus status;
  final DateTime createdAt;
  final String courierName;
  final String courierPhone;
  final String trackingNumber;
  final String deliveryNotes;
  final String customerName;
  final List<String> reviewedProductIds;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.shippingFee,
    required this.discount,
    required this.totalAmount,
    required this.shippingAddress,
    this.phoneNumber = '',
    required this.paymentMethod,
    this.status = OrderStatus.placed,
    required this.createdAt,
    this.courierName = 'Nuance White Glove Express',
    this.courierPhone = '+1 (800) 555-0199',
    this.trackingNumber = '',
    this.deliveryNotes = '',
    this.customerName = '',
    this.reviewedProductIds = const [],
  });

  bool isProductReviewed(String productId) => reviewedProductIds.contains(productId);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((i) => i.toMap()).toList(),
      'subtotal': subtotal,
      'shippingFee': shippingFee,
      'discount': discount,
      'totalAmount': totalAmount,
      'shippingAddress': shippingAddress,
      'phoneNumber': phoneNumber,
      'paymentMethod': paymentMethod,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'courierName': courierName,
      'courierPhone': courierPhone,
      'trackingNumber': trackingNumber,
      'deliveryNotes': deliveryNotes,
      'customerName': customerName,
      'reviewedProductIds': reviewedProductIds,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    final rawItems = map['items'];
    final List<CartItem> parsedItems = [];
    if (rawItems is List) {
      for (final rawItem in rawItems) {
        if (rawItem is Map) {
          try {
            parsedItems.add(CartItem.fromMap(Map<String, dynamic>.from(rawItem)));
          } catch (e) {
            // Safe fallback if an item failed
          }
        }
      }
    }

    final rawReviewed = map['reviewedProductIds'];
    final List<String> parsedReviewed = [];
    if (rawReviewed is List) {
      for (final r in rawReviewed) {
        if (r != null) parsedReviewed.add(r.toString());
      }
    }

    return OrderModel(
      id: docId ?? map['id']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      items: parsedItems,
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
      shippingFee: (map['shippingFee'] as num?)?.toDouble() ?? 0.0,
      discount: (map['discount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      shippingAddress: map['shippingAddress']?.toString() ?? 'Standard Delivery',
      phoneNumber: map['phoneNumber']?.toString() ?? '',
      paymentMethod: map['paymentMethod']?.toString() ?? 'Credit Card',
      status: OrderStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => OrderStatus.placed,
      ),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      courierName: map['courierName']?.toString() ?? 'Nuance White Glove Express',
      courierPhone: map['courierPhone']?.toString() ?? '+1 (800) 555-0199',
      trackingNumber: map['trackingNumber']?.toString() ?? '',
      deliveryNotes: map['deliveryNotes']?.toString() ?? '',
      customerName: map['customerName']?.toString() ?? '',
      reviewedProductIds: parsedReviewed,
    );
  }

  OrderModel copyWith({
    String? id,
    String? userId,
    List<CartItem>? items,
    double? subtotal,
    double? shippingFee,
    double? discount,
    double? totalAmount,
    String? shippingAddress,
    String? phoneNumber,
    String? paymentMethod,
    OrderStatus? status,
    DateTime? createdAt,
    String? courierName,
    String? courierPhone,
    String? trackingNumber,
    String? deliveryNotes,
    String? customerName,
    List<String>? reviewedProductIds,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      shippingFee: shippingFee ?? this.shippingFee,
      discount: discount ?? this.discount,
      totalAmount: totalAmount ?? this.totalAmount,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      courierName: courierName ?? this.courierName,
      courierPhone: courierPhone ?? this.courierPhone,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      deliveryNotes: deliveryNotes ?? this.deliveryNotes,
      customerName: customerName ?? this.customerName,
      reviewedProductIds: reviewedProductIds ?? this.reviewedProductIds,
    );
  }
}
