class ProductReview {
  final String id;
  final String orderId;
  final String productId;
  final String productName;
  final String productImage;
  final String userId;
  final String userName;
  final double rating; // 1.0 to 5.0
  final String title;
  final String comment;
  final String fitFeedback; // "True to Size", "Runs Small", "Runs Large", "Relaxed Fit"
  final String qualityTag; // "Exceptional Fabric", "Impeccable Tailoring", etc.
  final DateTime createdAt;
  final bool isVerifiedPurchase;

  const ProductReview({
    required this.id,
    required this.orderId,
    required this.productId,
    this.productName = '',
    this.productImage = '',
    this.userId = '',
    this.userName = 'Atelier Client',
    required this.rating,
    this.title = '',
    required this.comment,
    this.fitFeedback = 'True to Size',
    this.qualityTag = 'Exceptional Craftsmanship',
    required this.createdAt,
    this.isVerifiedPurchase = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'title': title,
      'comment': comment,
      'fitFeedback': fitFeedback,
      'qualityTag': qualityTag,
      'createdAt': createdAt.toIso8601String(),
      'isVerifiedPurchase': isVerifiedPurchase,
    };
  }

  factory ProductReview.fromMap(Map<String, dynamic> map, [String? docId]) {
    return ProductReview(
      id: docId ?? map['id']?.toString() ?? '',
      orderId: map['orderId']?.toString() ?? '',
      productId: map['productId']?.toString() ?? '',
      productName: map['productName']?.toString() ?? '',
      productImage: map['productImage']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      userName: map['userName']?.toString() ?? 'Atelier Client',
      rating: (map['rating'] as num?)?.toDouble() ?? 5.0,
      title: map['title']?.toString() ?? '',
      comment: map['comment']?.toString() ?? '',
      fitFeedback: map['fitFeedback']?.toString() ?? 'True to Size',
      qualityTag: map['qualityTag']?.toString() ?? 'Exceptional Craftsmanship',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isVerifiedPurchase: map['isVerifiedPurchase'] != false,
    );
  }
}
